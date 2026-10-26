#!/usr/bin/env Rscript
#
# Overlap between the Sentinel-2 aquaculture layer and the ESA WorldCover classes (paper review M6).
#
# Ecosystems (WorldCover 10, 20, 30, 80, 90, 95) and agriculture (40, 60) are built from WorldCover
# without removing the separately classified aquaculture pixels (common/land_cover.R,
# common/aquaculture.R), and WorldCover has no pond class. This script crosses the two rasters
# inside each delta to show, in km2:
#   - which WorldCover classes the aquaculture pixels fall in (so which sectors count them twice),
#   - what share of each WorldCover class is flagged as aquaculture.
# The delta domain is the set of units (geo_id) of gdri_correlations/data/GDRI_2025_<delta>.csv.
# Rasters are read in 0.2 degree tiles; the aquaculture layer (0.00009 deg) is resampled to the
# WorldCover grid (0.000083 deg) by nearest neighbour; pixel areas come from terra::cellSize.
#
# Output: output/AQUACULTURE_OVERLAP/overlap_by_class.csv (delta, WorldCover class, aquaculture 0/1, km2)
#         output/AQUACULTURE_OVERLAP/overlap_summary.csv  (per delta, per class shares)
# Run from the r-gdri repo root: Rscript processing/aquaculture/aquaculture_overlap.R [delta ...]

suppressMessages({
    library(terra)
    library(sf)
    library(data.table)
})
terraOptions(progress = 0)

args <- commandArgs(trailingOnly = TRUE)
csv_dir <- if (dir.exists("gdri_correlations/data")) "gdri_correlations/data" else "../gdri_correlations/data"
out_dir <- "output/AQUACULTURE_OVERLAP"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
tile_deg <- 0.2

deltas <- list(
    "GBM-B" = list(country = "bgd", iso3 = "BGD", csv = "GDRI_2025_GBM-B.csv"),
    "GBM-I" = list(country = "ind", iso3 = "IND", csv = "GDRI_2025_GBM-I.csv"),
    "MRD"   = list(country = "vnm", iso3 = "VNM", csv = "GDRI_2025_MRD.csv"),
    "RRD"   = list(country = "vnm", iso3 = "VNM", csv = "GDRI_2025_RRD.csv")
)
if (length(args)) deltas <- deltas[intersect(names(deltas), args)]

class_names <- c(
    "10" = "Trees", "20" = "Shrubland", "30" = "Grassland", "40" = "Cropland", "50" = "Built-up",
    "60" = "Bare / sparse vegetation", "70" = "Snow and ice", "80" = "Open water",
    "90" = "Herbaceous wetland", "95" = "Mangroves", "100" = "Moss and lichen"
)
sector_of <- function(cls) {
    ifelse(cls %in% c(10, 20, 30, 80, 90, 95), "Ecosystems",
        ifelse(cls %in% c(40, 60), "Agriculture", ifelse(cls == 50, "Built-up", "Other")))
}

process_delta <- function(delta_name, cfg) {
    cat("==", delta_name, "\n")
    ids <- read.csv(file.path(csv_dir, cfg$csv), colClasses = c(geo_id = "character"))$geo_id
    vil <- st_read(sprintf("objects/ADMIN/villages_%s.gpkg", cfg$country), quiet = TRUE)
    vil <- st_transform(vil[vil$geo_id %in% ids, "geo_id"], 4326)
    cat("   units:", nrow(vil), "of", length(ids), "in the CSV\n")
    v <- terra::vect(vil)
    esa <- terra::rast(sprintf("objects/ESA_Landcover/%s_roi.tif", cfg$iso3))
    aqua <- terra::rast(sprintf("objects/aquaculture_sentinel2/%s_aquaculture.tif", cfg$iso3))

    e <- as.vector(ext(v))
    xs <- seq(e[["xmin"]], e[["xmax"]], by = tile_deg)
    ys <- seq(e[["ymin"]], e[["ymax"]], by = tile_deg)
    res_list <- list()
    n_tiles <- 0
    for (x0 in xs) for (y0 in ys) {
        te <- ext(x0, min(x0 + tile_deg, e[["xmax"]] + 1e-6), y0, min(y0 + tile_deg, e[["ymax"]] + 1e-6))
        vt <- tryCatch(terra::crop(v, te), error = function(err) NULL)
        if (is.null(vt) || nrow(vt) == 0) next
        et <- tryCatch(terra::crop(esa, te), error = function(err) NULL)
        if (is.null(et)) next
        at <- tryCatch(terra::resample(terra::crop(aqua, ext(et) + 0.001), et, method = "near"), error = function(err) NULL)
        mask_r <- terra::rasterize(vt, et, field = 1, background = NA)
        area_r <- terra::cellSize(et, unit = "km")
        dt <- data.table(
            cls = as.vector(terra::values(et)),
            aq = if (is.null(at)) 0L else as.integer(!is.na(as.vector(terra::values(at))) & as.vector(terra::values(at)) > 0),
            inside = as.vector(terra::values(mask_r)),
            km2 = as.vector(terra::values(area_r))
        )
        dt <- dt[!is.na(inside) & !is.na(cls)]
        if (nrow(dt)) res_list[[length(res_list) + 1]] <- dt[, .(km2 = sum(km2)), by = .(cls, aq)]
        n_tiles <- n_tiles + 1
    }
    cat("   tiles processed:", n_tiles, "\n")
    out <- rbindlist(res_list)[, .(km2 = sum(km2)), by = .(cls, aq)]
    out[, `:=`(delta = delta_name, class_name = class_names[as.character(cls)], sector = sector_of(cls))]
    setcolorder(out, c("delta", "cls", "class_name", "sector", "aq", "km2"))
    out[order(cls, aq)]
}

all_out <- rbindlist(lapply(names(deltas), function(nm) {
    res <- process_delta(nm, deltas[[nm]])
    fwrite(res, file.path(out_dir, sprintf("overlap_by_class_%s.csv", nm)))
    res
}))

summary_tab <- all_out[, {
    tot <- sum(km2)
    aq_tot <- sum(km2[aq == 1])
    .SD[, .(
        class_km2 = sum(km2),
        aquaculture_km2_in_class = sum(km2[aq == 1])
    ), by = .(cls, class_name, sector)][, `:=`(
        share_of_class_flagged_aquaculture = aquaculture_km2_in_class / class_km2,
        share_of_aquaculture_in_class = aquaculture_km2_in_class / aq_tot,
        share_of_delta_area = class_km2 / tot,
        delta_area_km2 = tot, aquaculture_km2 = aq_tot
    )]
}, by = delta]
fwrite(all_out, file.path(out_dir, "overlap_by_class.csv"))
fwrite(summary_tab, file.path(out_dir, "overlap_summary.csv"))
print(as.data.frame(summary_tab[, .(delta, class_name, class_km2 = round(class_km2), aquaculture_km2_in_class = round(aquaculture_km2_in_class),
    pct_class_aq = round(100 * share_of_class_flagged_aquaculture, 1), pct_aq_in_class = round(100 * share_of_aquaculture_in_class, 1))]), row.names = FALSE)
