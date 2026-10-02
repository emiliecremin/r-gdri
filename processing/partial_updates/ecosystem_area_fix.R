#!/usr/bin/env Rscript
#
# Partial-update / diagnostic script for the E_AFF / A_AFF / AQ_AFF > 1.0
# issue (paper section B9), rebuilt to crop rasters to each DELTA's own
# extent before recomputing, instead of processing whole-country rasters.
#
# v3 changes from the previous version:
#   - The original ecosystem_exposure.R / agriculture_exposure.R /
#     aquaculture_exposure.R AFF_* functions are NOT called anymore: they
#     always re-read the FULL, uncropped country raster internally,
#     ignoring any cropped raster passed in as `locations`. Calling them
#     alongside a separately-cropped denominator therefore mixed a
#     full-country numerator with a delta-cropped denominator -- a new,
#     worse mismatch than the one being diagnosed. This version
#     reimplements the AFF logic directly, generic over sector, so the
#     SAME cropped raster is used for both the denominator and the
#     numerator.
#   - No buffer around the delta's bounding box: st_bbox() already
#     encloses every village polygon exactly, and the resampling used in
#     mask_rasters() is nearest-neighbor (no wide interpolation
#     neighbourhood), so padding isn't needed.
#
# Rasters (objects/ESA_Landcover/*.tif, objects/aquaculture_sentinel2/*.tif,
# data/Hazards/**, data/Soil/**) are only ever READ and cropped IN MEMORY
# (terra::crop() on a SpatRaster object) -- never written back to their
# source path. No original file is modified by this script.
#
# "Old" values are read directly from the already-published per-delta CSV
# (gdri_correlations/data/GDRI_2025_{delta}.csv), not recomputed -- see the
# comment in process_delta() for why recomputing "old" would be redundant.
#
# Delta scoping:
#   GBM-B: all of villages_bgd.gpkg (already scoped to Barisal/Chittagong/
#          Dhaka/Khulna, the four GBM-B divisions -- no filter needed)
#   GBM-I: villages_ind.gpkg filtered to the five coastal districts
#          (24 Paraganas South, 24 Paraganas North, Medinipur East,
#          Howrah, Kolkata) -- excludes the five inland West Bengal
#          districts that are outside the paper's GBM-I study area
#   MRD:   villages_vnm.gpkg filtered to the 13 MRD provinces
#   RRD:   villages_vnm.gpkg filtered to the 12 RRD provinces
#
# Run from the r-gdri repo root.

source("common/libraries.R")
source("common/helpers.R")
source("processing/exposure/coastal_DEM.R") # get_coastal_dem()

cyclone_wind_speed <- 118 # km/h, matches §2.5.4 and partial_update/cyclones.R
SAL_AFF_THRESHOLD <- 2 # matches agriculture_exposure.R / ecosystem_exposure.R / aquaculture_exposure.R

out_dir <- "output/ECOSYSTEM_AREA_FIX"
mkdirs(out_dir)

gdri_csv_dir <- "/Users/loicbaron/Documents/gdri_correlations/data"
delta_csv_file <- c(
    "GBM-B" = "GDRI_2025_GBM-B.csv",
    "GBM-I" = "GDRI_2025_GBM-I.csv",
    "MRD"   = "GDRI_2025_MRD.csv",
    "RRD"   = "GDRI_2025_RRD.csv"
)

mrd_provinces <- c(
    "An Giang", "Bạc Liêu", "Bến Tre", "Cà Mau", "Cần Thơ", "Đồng Tháp",
    "Hậu Giang", "Kiên Giang", "Long An", "Sóc Trăng", "Tiền Giang",
    "Trà Vinh", "Vĩnh Long"
)
rrd_provinces <- c(
    "Bắc Giang", "Bắc Ninh", "Hà Nam", "Hà Nội", "Hải Dương", "Hải Phòng",
    "Hưng Yên", "Nam Định", "Ninh Bình", "Quảng Ninh", "Thái Bình", "Vĩnh Phúc"
)
gbmi_districts <- c(
    "24 Paraganas South", "24 Paraganas North", "Medinipur East",
    "Howrah", "Kolkata"
)

deltas <- list(
    "GBM-B" = list(country = "bgd", iso3 = "BGD", filter = NULL),
    "GBM-I" = list(country = "ind", iso3 = "IND", filter = gbmi_districts, filter_col = "adm2_name"),
    "MRD"   = list(country = "vnm", iso3 = "VNM", filter = mrd_provinces, filter_col = "adm1_name"),
    "RRD"   = list(country = "vnm", iso3 = "VNM", filter = rrd_provinces, filter_col = "adm1_name")
)

villages_cache <- new.env()
get_villages <- function(country) {
    if (!exists(country, envir = villages_cache)) {
        assign(country, st_read(glue::glue("objects/ADMIN/villages_{country}.gpkg"), quiet = TRUE),
               envir = villages_cache)
    }
    get(country, envir = villages_cache)
}

# No buffer: st_bbox() already fully encloses every village polygon, and
# mask_rasters() resamples with nearest-neighbor, so no extra margin is
# needed for interpolation neighbourhoods.
crop_to_delta <- function(rst, delta_villages) {
    delta_villages_ll <- st_transform(delta_villages, 4326)
    ext <- terra::ext(st_bbox(delta_villages_ll))
    terra::crop(rst, ext)
}

# --- Generic AFF computation, sector-agnostic, using an ALREADY-CROPPED
# sector raster for both the hazard mask and the area extraction, so the
# numerator and denominator are always built from the same raster extent.
aff_cyc <- function(sector_delta, iso3) {
    cyclones <- rast("data/Hazards/Cyclones/Wind_T100.tif")
    cyclones_cropped <- crop(cyclones, sector_delta)
    cyclones_filtered <- cyclones_cropped
    cyclones_filtered[cyclones_filtered < cyclone_wind_speed] <- NA
    mask_rasters(sector_delta, cyclones_filtered)
}

aff_flo <- function(sector_delta, iso3) {
    floods <- rast("data/Hazards/Floods/fl_hazard_100_yrp.tif")
    floods_cropped <- crop(floods, sector_delta)
    mask_rasters(sector_delta, floods_cropped)
}

aff_sal <- function(sector_delta, iso3) {
    salinity <- rast("data/Soil/Salinity/HWSD v2.01/DATA_GAEZ-V5_MAPSET_SQX_GAEZ-V5.SQX.SQ5.HIM.tif")
    salinity_cropped <- crop(salinity, sector_delta)
    salinity_filtered <- salinity_cropped
    salinity_filtered[salinity_filtered == 0] <- NA
    salinity_filtered[salinity_filtered > 10] <- NA
    r_rev <- 11 - salinity_filtered
    r_rev[r_rev < SAL_AFF_THRESHOLD] <- NA
    mask_rasters(sector_delta, r_rev)
}

aff_cof <- function(sector_delta, iso3, villages) {
    coastal_dem_filtered <- get_coastal_dem(villages %>% dplyr::mutate(country_iso3 = iso3))
    coastal_dem_cropped <- crop(coastal_dem_filtered, sector_delta)
    mask_rasters(sector_delta, coastal_dem_cropped)
}

process_delta <- function(delta_name) {
    spec <- deltas[[delta_name]]
    iso3 <- spec$iso3
    cat("\n\n########## ", delta_name, " (", iso3, ") ##########\n")

    villages <- get_villages(spec$country)
    villages$country_iso3 <- iso3
    # villages_bgd.gpkg has no "Name" column (uses "shapeName" instead);
    # villages_ind.gpkg / villages_vnm.gpkg both have "Name".
    if (!("Name" %in% names(villages))) villages$Name <- villages$shapeName

    if (!is.null(spec$filter)) {
        villages <- villages[villages[[spec$filter_col]] %in% spec$filter, ]
    }
    cat("  n villages:", nrow(villages), "\n")

    # --- load + crop the three land-cover rasters to this delta's extent
    # (no buffer) ---
    sectors <- list(
        agri   = list(full = rast(glue::glue("objects/ESA_Landcover/{iso3}_agriculture.tif")), denom = "agri_km2", prefix = "A"),
        ecosys = list(full = rast(glue::glue("objects/ESA_Landcover/{iso3}_ecosystems.tif")),  denom = "ecosys_km2", prefix = "E"),
        aqua   = list(full = rast(glue::glue("objects/aquaculture_sentinel2/{iso3}_aquaculture.tif")), denom = "aqua_km2", prefix = "AQ")
    )

    cat("  Cropping rasters to delta extent (in memory only, source .tif files untouched)...\n")
    for (s in names(sectors)) {
        sectors[[s]]$delta <- crop_to_delta(sectors[[s]]$full, villages)
        cat("   ", s, "cells:", terra::ncell(sectors[[s]]$delta),
            " (was", terra::ncell(sectors[[s]]$full), "for the whole country)\n")
    }

    # --- recompute denominators fresh, on the CROPPED rasters ---
    for (s in names(sectors)) {
        tmp <- raster_area_within_polygons(sectors[[s]]$delta, villages)
        villages[[paste0(sectors[[s]]$denom, "_v2")]] <- tmp$area_raster_km2
    }

    comp <- villages %>%
        st_drop_geometry() %>%
        dplyr::select(geo_id, Name, agri_km2, agri_km2_v2, ecosys_km2, ecosys_km2_v2, aqua_km2, aqua_km2_v2) %>%
        dplyr::mutate(
            agri_km2_diff = agri_km2_v2 - agri_km2,
            ecosys_km2_diff = ecosys_km2_v2 - ecosys_km2,
            aqua_km2_diff = aqua_km2_v2 - aqua_km2,
            agri_km2_pct_diff = ifelse(agri_km2 > 0, agri_km2_diff / agri_km2 * 100, NA),
            ecosys_km2_pct_diff = ifelse(ecosys_km2 > 0, ecosys_km2_diff / ecosys_km2 * 100, NA),
            aqua_km2_pct_diff = ifelse(aqua_km2 > 0, aqua_km2_diff / aqua_km2 * 100, NA)
        )
    write.csv(comp, glue::glue("{out_dir}/{delta_name}_denominator_comparison.csv"), row.names = FALSE)

    cat("\n  --- denominator comparison (cached vs fresh, delta-cropped) ---\n")
    for (col in c("agri_km2", "ecosys_km2", "aqua_km2")) {
        d <- comp[[paste0(col, "_diff")]]
        p <- comp[[paste0(col, "_pct_diff")]]
        cat(sprintf(
            "  %-12s max abs diff = %.6f km2 | mean abs %% diff = %.4f%% | n with >1%% diff = %d / %d\n",
            col, max(abs(d), na.rm = TRUE), mean(abs(p), na.rm = TRUE),
            sum(abs(p) > 1, na.rm = TRUE), nrow(comp)
        ))
    }

    # --- read published ("old") AFF values from the CSV ---
    hazards <- list(
        CYC = aff_cyc, FLO = aff_flo, SAL = aff_sal, COF = aff_cof
    )
    # Aquaculture has no salinity-exposure indicator (§2.6.4)
    skip <- list(aqua = c("SAL"))
    # COF is published under "_EXP_" naming, not "_AFF_" (confirmed against
    # the actual CSV header; CYC/FLO/SAL keep "_AFF_").
    pub_col_name <- function(prefix, hz) {
        if (hz == "COF") glue::glue("{prefix}_EXP_COF_val") else glue::glue("{prefix}_AFF_{hz}_val")
    }

    cat("\n  Reading published (\"old\") AFF values from",
        glue::glue("{gdri_csv_dir}/{delta_csv_file[[delta_name]]}"), "\n")
    published <- read.csv(glue::glue("{gdri_csv_dir}/{delta_csv_file[[delta_name]]}"), colClasses = "character")
    published$geo_id <- as.character(published$geo_id)

    results <- data.frame(geo_id = as.character(villages$geo_id), Name = villages$Name)

    cat("\n  --- recomputing AFF indicators (numerator + denominator from the SAME cropped raster) ---\n")
    for (s in names(sectors)) {
        prefix <- sectors[[s]]$prefix
        denom_v2 <- villages[[paste0(sectors[[s]]$denom, "_v2")]]
        for (hz in names(hazards)) {
            if (hz %in% skip[[s]]) next
            ind_name <- glue::glue("{prefix}_AFF_{hz}")
            cat("   ", ind_name, "\n")
            masked <- tryCatch(
                if (hz == "COF") hazards[[hz]](sectors[[s]]$delta, iso3, villages) else hazards[[hz]](sectors[[s]]$delta, iso3),
                error = function(e) { cat("     ERROR (mask):", conditionMessage(e), "\n"); NULL }
            )
            new_val <- if (!is.null(masked)) {
                tryCatch(raster_area_within_polygons(masked, villages)$area_raster_km2 / denom_v2,
                         error = function(e) { cat("     ERROR (extract):", conditionMessage(e), "\n"); NA })
            } else NA

            pub_col <- pub_col_name(prefix, hz)
            old_val <- if (pub_col %in% names(published)) as.numeric(published[[pub_col]][match(results$geo_id, published$geo_id)]) else NA

            results[[paste0(ind_name, "_old")]] <- old_val
            results[[paste0(ind_name, "_new")]] <- new_val
        }
    }
    write.csv(results, glue::glue("{out_dir}/{delta_name}_aff_before_after.csv"), row.names = FALSE)

    cat("\n  --- SUMMARY for", delta_name, ": units exceeding physically possible 1.0 ---\n")
    ind_names <- names(results)[grepl("_old$", names(results))] %>% stringr::str_remove("_old$")
    for (ind_name in ind_names) {
        old_vals <- results[[paste0(ind_name, "_old")]]
        new_vals <- results[[paste0(ind_name, "_new")]]
        n_over_old <- sum(old_vals > 1.0, na.rm = TRUE)
        n_over_new <- sum(new_vals > 1.0, na.rm = TRUE)
        max_old <- suppressWarnings(max(old_vals, na.rm = TRUE))
        max_new <- suppressWarnings(max(new_vals, na.rm = TRUE))
        cat(sprintf(
            "  %-12s n>1.0 published=%4d (max=%.4f)   n>1.0 fresh=%4d (max=%.4f)\n",
            ind_name, n_over_old, max_old, n_over_new, max_new
        ))
    }

    results$Delta <- delta_name
    results
}

# RRD, GBM-I and MRD already succeeded in the previous run (per-delta CSVs
# on disk in out_dir); only GBM-B needs re-running (villages_bgd.gpkg has no
# "Name" column, now aliased above).
delta_order <- c("GBM-B")

all_results <- list()
for (d in delta_order) {
    all_results[[d]] <- process_delta(d)
}

# Rebuild the combined file from every delta's per-delta CSV on disk, not
# just the one(s) re-run this call, so a partial re-run doesn't drop deltas
# that already succeeded.
all_deltas <- c("RRD", "GBM-I", "MRD", "GBM-B")
all_results_df <- do.call(rbind, lapply(all_deltas, function(d) {
    df <- read.csv(glue::glue("{out_dir}/{d}_aff_before_after.csv"), colClasses = c(geo_id = "character"))
    df$Delta <- d
    df
}))
write.csv(all_results_df, glue::glue("{out_dir}/all_deltas_aff_before_after.csv"), row.names = FALSE)

cat("\n\n=========== OVERALL DONE. Outputs written to", out_dir, "===========\n")
