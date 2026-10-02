#!/usr/bin/env Rscript
#
# One-off analysis (paper section C5): tests whether the "positive
# ES_MH-risk correlation in GBM-I is plausibly explained by intact
# mangrove forest and highest hazard exposure sharing the same coastal
# fringe" explanation (Discussion, para 719) is empirically supported.
# Computes WorldCover mangrove (class 95) area share per village for all
# deltas: IND (GBM-I, villages restricted to its five districts), BGD
# (GBM-B) and VNM (MRD + RRD). Same extract_classes(cropped, c(94,96,1)) +
# raster_area_within_polygons() pattern, against the already-cropped,
# unclassified objects/ESA_Landcover/{IND,BGD,VNM}_roi.tif -- no new raster
# download. Read-only against source rasters (cropped only in memory);
# writes one new CSV per country.
#
# Run from the r-gdri repo root.

source("common/libraries.R")
source("common/helpers.R")

out_dir <- "output/ECOSYSTEM_AREA_FIX"
mkdirs(out_dir)

gbmi_districts <- c(
    "24 Paraganas South", "24 Paraganas North", "Medinipur East",
    "Howrah", "Kolkata"
)

extract_mangrove_share <- function(country_iso3, gpkg_path, out_csv,
                                   districts = NULL) {
    cat("\n\n##", country_iso3, "##\n")
    villages <- st_read(gpkg_path, quiet = TRUE)
    if (!is.null(districts)) {
        villages <- villages[villages$adm2_name %in% districts, ]
    }
    cat("n villages:", nrow(villages), "\n")

    landcover <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_roi.tif"))

    villages_ll <- st_transform(villages, 4326)
    ext <- terra::ext(st_bbox(villages_ll))
    landcover_cropped <- terra::crop(landcover, ext)
    cat("cropped cells:", terra::ncell(landcover_cropped),
        " (was", terra::ncell(landcover), "for the whole", country_iso3, "ROI)\n")

    mangrove <- extract_classes(landcover_cropped, c(94, 96, 1))
    mangrove_result <- raster_area_within_polygons(mangrove, villages)

    out <- mangrove_result %>%
        st_drop_geometry() %>%
        dplyr::mutate(
            mangrove_km2 = area_raster_km2,
            mangrove_pct = val
        ) %>%
        dplyr::select(geo_id, dplyr::any_of("Name"), mangrove_km2, mangrove_pct)

    cat("mangrove_pct summary:\n")
    print(summary(out$mangrove_pct))
    cat("n villages with >0 mangrove:", sum(out$mangrove_pct > 0, na.rm = TRUE),
        "/", nrow(out), "\n")
    cat("n NA mangrove_pct:", sum(is.na(out$mangrove_pct)), "\n")

    write.csv(out, out_csv, row.names = FALSE)
    cat("Written to", out_csv, "\n")
    out
}

ind_out <- extract_mangrove_share("IND", "objects/ADMIN/villages_ind.gpkg",
                                   glue::glue("{out_dir}/gbmi_mangrove_share.csv"),
                                   districts = gbmi_districts)
bgd_out <- extract_mangrove_share("BGD", "objects/ADMIN/villages_bgd.gpkg",
                                   glue::glue("{out_dir}/gbmb_mangrove_share.csv"))
vnm_out <- extract_mangrove_share("VNM", "objects/ADMIN/villages_vnm.gpkg",
                                   glue::glue("{out_dir}/vnm_mangrove_share.csv"))

cat("\n\nDONE.\n")
