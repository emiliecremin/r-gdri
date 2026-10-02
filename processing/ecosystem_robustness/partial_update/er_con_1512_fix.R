#!/usr/bin/env Rscript
#
# Partial-update / diagnostic script for ER_CON_1512 ("Terrestrial protected
# areas, % of total land area") showing values above the physically-possible
# ceiling of 1.0 in the published data (45/14389 units across_deltas, max
# 1.045).
#
# Root cause (processing/conservation.R:55-74, ER_CON_1512()): the numerator
# (conservation_area, the WDPA-protected share of each admin unit) is
# computed with sf_use_s2(FALSE) -- PLANAR area on raw lon/lat degrees, which
# is not a valid area measure except very close to the equator -- while the
# denominator (locations$area, from common/admin.R) is computed with the
# default sf_use_s2(TRUE) -- proper spherical/geodesic area. Two different,
# incompatible area-measurement systems divided against each other. The
# original file even has a self-documenting TODO on this exact line:
#   "TODO: fix although coordinates are longitude/latitude, st_union assumes
#    that they are planar"
#
# This script does NOT edit processing/conservation.R. It reimplements
# ER_CON_1512 locally with sf_use_s2(TRUE) kept on throughout (no planar
# detour), for comparison against the published values. Nothing is written
# back to processing/conservation.R or to any source data file.
#
# "Old" values are read directly from the already-published per-delta CSV
# (gdri_correlations/data/GDRI_2025_{delta}.csv), not recomputed. "New" is
# computed once per delta, with sf_use_s2(TRUE) held constant.
#
# NOTE before running: this needs objects/conservation/WCMC_WPDA_{iso3}.geojson
# for BGD/IND/VNM. As of writing, objects/conservation/ does not exist locally
# -- get_conservation_areas() (common code, sourced from processing/conservation.R)
# will call wdpa_fetch(), a NETWORK call to protectedplanet.net, the first time
# it runs for each country. That's a real external request, not something to
# trigger silently -- confirm before running.

source("common/libraries.R")
source("common/helpers.R")
source("processing/conservation.R")

gdri_csv_dir <- "/Users/loicbaron/Documents/gdri_correlations/data"
delta_csv_file <- c(
    "GBM-B" = "GDRI_2025_GBM-B.csv",
    "GBM-I" = "GDRI_2025_GBM-I.csv",
    "MRD"   = "GDRI_2025_MRD.csv",
    "RRD"   = "GDRI_2025_RRD.csv"
)

out_dir <- "output/ER_CON_1512_FIX"
mkdirs(out_dir)

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

# Reimplementation of ER_CON_1512() (processing/conservation.R:55-74) with
# sf_use_s2(TRUE) held constant -- no sf_use_s2(FALSE) planar detour. Every
# other step (WDPA source data, st_intersection, st_union, st_area) is
# identical to the original.
ER_CON_1512_fixed <- function(locations, country_iso3) {
    stopifnot(sf::sf_use_s2())  # fail loudly if S2 isn't on -- this fix depends on it
    conservation <- get_conservation_areas(country_iso3)
    conservation <- st_read(glue::glue("objects/conservation/WCMC_WPDA_{country_iso3}.geojson"), quiet = TRUE)
    intersect <- st_intersection(locations, st_union(st_geometry(conservation)))
    intersect$conservation_area <- units::set_units(st_area(intersect), km^2)
    df <- sf::st_as_sf(intersect) %>% st_drop_geometry()
    locations <- right_join(df[c("geo_id", "conservation_area")], locations) %>% st_as_sf()
    locations$conservation_area[is.na(locations$conservation_area)] <- 0
    locations$val_new <- as.numeric(locations$conservation_area) / as.numeric(locations$area)
    locations
}

process_delta <- function(delta_name) {
    spec <- deltas[[delta_name]]
    iso3 <- spec$iso3
    cat("\n\n########## ", delta_name, " (", iso3, ") ##########\n")

    villages <- get_villages(spec$country)
    villages$country_iso3 <- iso3
    if (!("Name" %in% names(villages))) villages$Name <- villages$shapeName
    if (!is.null(spec$filter)) villages <- villages[villages[[spec$filter_col]] %in% spec$filter, ]
    cat("  n villages:", nrow(villages), "\n")

    published <- read.csv(glue::glue("{gdri_csv_dir}/{delta_csv_file[[delta_name]]}"), colClasses = "character")
    published$geo_id <- as.character(published$geo_id)
    published$ER_CON_1512_val <- as.numeric(published$ER_CON_1512_val)

    fixed <- ER_CON_1512_fixed(villages, iso3)

    results <- data.frame(geo_id = as.character(villages$geo_id), Name = villages$Name)
    results <- results %>%
        dplyr::left_join(published %>% dplyr::select(geo_id, ER_CON_1512_val), by = "geo_id") %>%
        dplyr::rename(ER_CON_1512_old = ER_CON_1512_val)
    results$ER_CON_1512_new <- fixed$val_new[match(results$geo_id, as.character(fixed$geo_id))]
    results$Delta <- delta_name

    n_over_old <- sum(results$ER_CON_1512_old > 1.0, na.rm = TRUE)
    n_over_new <- sum(results$ER_CON_1512_new > 1.0, na.rm = TRUE)
    cat(sprintf("  n>1.0: published=%d (max=%.4f)  new(sf_use_s2=TRUE throughout)=%d (max=%.4f)\n",
                n_over_old, suppressWarnings(max(results$ER_CON_1512_old, na.rm = TRUE)),
                n_over_new, suppressWarnings(max(results$ER_CON_1512_new, na.rm = TRUE))))

    write.csv(results, glue::glue("{out_dir}/{delta_name}_er_con_1512_before_after.csv"), row.names = FALSE)
    results
}

delta_order <- c("RRD", "GBM-I", "MRD", "GBM-B")
all_results <- list()
for (d in delta_order) all_results[[d]] <- process_delta(d)

all_results_df <- do.call(rbind, all_results)
write.csv(all_results_df, glue::glue("{out_dir}/all_deltas_er_con_1512_before_after.csv"), row.names = FALSE)

cat("\n\n=========== DONE. Outputs written to", out_dir, "===========\n")
