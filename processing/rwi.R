# Relative Wealth Index (RWI), Meta / Data for Good
# Dataset (2021-2023 version): https://data.humdata.org/dataset/relative-wealth-index
# Paper: Chi, G., Fang, H., Chatterjee, S., & Blumenstock, J. E. (2022).
#   "Microestimates of wealth for all low- and middle-income countries".
#   PNAS 119(3), e2113658119. https://doi.org/10.1073/pnas.2113658119
# Files: data/Poverty/RWI/{iso3}_relative_wealth_index.csv
# (IND is in the combined ind_pak file).
#
# RWI points are centres of zoom-14 web-mercator tiles (~2.4 km). The tile
# footprints are rebuilt and rasterised on the WorldPop grid so that every
# unit, including units smaller than one tile, gets a population-weighted value.
# RWI is relative within a country: 0 is the country mean.

RWI_ZOOM <- 14
RWI_MAX_FALLBACK_KM <- 20
# Units with fewer WorldPop inhabitants than this have no usable population weights:
# S_ECO1 takes the unweighted mean of the RWI pixels of the unit instead (rwi_unit_stats)
RWI_MIN_POP <- 1

rwi_file <- function(country_iso3) {
    prefix <- if (country_iso3 == "IND") "ind_pak" else tolower(country_iso3)
    glue::glue("data/Poverty/RWI/{prefix}_relative_wealth_index.csv")
}

rwi_tile_polygons <- function(rwi) {
    n <- 2^RWI_ZOOM
    x <- floor((rwi$longitude + 180) / 360 * n)
    y <- floor((1 - asinh(tan(rwi$latitude * pi / 180)) / pi) / 2 * n)
    lon <- function(x) x / n * 360 - 180
    lat <- function(y) atan(sinh(pi * (1 - 2 * y / n))) * 180 / pi
    ext <- cbind(lon(x), lon(x + 1), lat(y + 1), lat(y))
    polys <- lapply(seq_len(nrow(ext)), function(i) {
        e <- ext[i, ]
        st_polygon(list(rbind(
            c(e[1], e[3]), c(e[2], e[3]), c(e[2], e[4]), c(e[1], e[4]), c(e[1], e[3])
        )))
    })
    st_sf(rwi = rwi$rwi, geometry = st_sfc(polys, crs = 4326))
}

# Population-weighted mean and SD of RWI over the pixels of one unit
rwi_weighted_stats <- function(values) {
    w <- values$pop * values$coverage_fraction
    ok <- !is.na(values$rwi) & !is.na(w) & w > 0
    if (!any(ok)) {
        return(data.frame(rwi_mean = NA_real_, rwi_sd = NA_real_))
    }
    v <- values$rwi[ok]
    w <- w[ok]
    m <- sum(w * v) / sum(w)
    data.frame(rwi_mean = m, rwi_sd = sqrt(sum(w * (v - m)^2) / sum(w)))
}

# Mean of RWI over the pixels of one unit weighted by coverage only (no population weight):
# used for inhabited units whose WorldPop count is below RWI_MIN_POP, where the
# population weights are unusable
rwi_unweighted_stats <- function(values) {
    w <- values$coverage_fraction
    ok <- !is.na(values$rwi) & !is.na(w) & w > 0
    if (!any(ok)) {
        return(data.frame(rwi_mean = NA_real_))
    }
    data.frame(rwi_mean = sum(w[ok] * values$rwi[ok]) / sum(w[ok]))
}

# WorldPop and RWI tiles on the same grid, cropped to the locations + pad (degrees)
rwi_rasters <- function(locations, pad = 0.05) {
    country_iso3 <- unique(locations$country_iso3)
    stopifnot(length(country_iso3) == 1)
    pop <- terra::rast(glue::glue(
        "data/Population/WorldPop/{tolower(country_iso3)}_ppp_2020_UNadj_constrained.tif"
    ))
    pop <- terra::crop(pop, terra::ext(terra::vect(locations)) + pad)
    names(pop) <- "pop"

    rwi <- read.csv(rwi_file(country_iso3))
    bb <- st_bbox(locations)
    rwi <- rwi[
        rwi$longitude >= bb["xmin"] - pad & rwi$longitude <= bb["xmax"] + pad &
        rwi$latitude >= bb["ymin"] - pad & rwi$latitude <= bb["ymax"] + pad,
    ]
    message(country_iso3, ": ", nrow(rwi), " RWI tiles around ", nrow(locations), " units")
    rwi_rast <- terra::rasterize(terra::vect(rwi_tile_polygons(rwi)), pop, field = "rwi")
    names(rwi_rast) <- "rwi"
    list(pop = pop, rwi_rast = rwi_rast, tiles = rwi)
}

# One row per location (aligned on geo_id): rwi_mean, rwi_sd, pop_worldpop.
# Populated locations without populated pixels on an RWI tile (outside the RWI
# coverage) take the nearest tile centre within RWI_MAX_FALLBACK_KM, flagged by
# rwi_fallback = TRUE; otherwise they stay NA. Locations with fewer than
# RWI_MIN_POP inhabitants take the plain (unweighted) mean of the RWI pixels inside
# the unit (rwi_unweighted = TRUE), then the nearest tile like the others.
rwi_unit_stats <- function(locations) {
    country_iso3 <- unique(locations$country_iso3)
    locations <- st_transform(locations, 4326)
    r <- rwi_rasters(locations)
    pop <- r$pop
    rwi_rast <- r$rwi_rast
    rwi <- r$tiles

    stats <- exact_extract(
        c(rwi_rast, pop), locations,
        fun = rwi_weighted_stats, summarize_df = TRUE, progress = FALSE
    )
    out <- data.frame(
        geo_id = as.character(locations$geo_id),
        stats,
        pop_worldpop = exact_extract(pop, locations, "sum", progress = FALSE),
        rwi_fallback = FALSE
    )
    out$rwi_mean[out$pop_worldpop < RWI_MIN_POP] <- NA_real_
    out$rwi_sd[out$pop_worldpop < RWI_MIN_POP] <- NA_real_

    # Units below RWI_MIN_POP inhabitants in WorldPop (e.g. char islands, remote villages
    # that WorldPop's settlement mask misses) take the plain mean of the RWI pixels inside the
    # unit; units that are really unpopulated are blanked later, from the census (ecosystem-only units)
    out$rwi_unweighted <- FALSE
    low <- which(out$pop_worldpop < RWI_MIN_POP)
    if (length(low) > 0) {
        uw <- exact_extract(
            c(rwi_rast, pop), locations[low, ],
            fun = rwi_unweighted_stats, summarize_df = TRUE, progress = FALSE
        )
        out$rwi_mean[low] <- uw$rwi_mean
        out$rwi_unweighted[low[!is.na(uw$rwi_mean)]] <- TRUE
    }

    missing <- which(is.na(out$rwi_mean))
    if (length(missing) > 0) {
        tiles <- st_as_sf(rwi, coords = c("longitude", "latitude"), crs = 4326)
        centroids <- suppressWarnings(st_centroid(locations[missing, ]))
        nearest <- st_nearest_feature(centroids, tiles)
        km <- as.numeric(st_distance(centroids, tiles[nearest, ], by_element = TRUE)) / 1000
        use <- km <= RWI_MAX_FALLBACK_KM
        out$rwi_mean[missing[use]] <- tiles$rwi[nearest[use]]
        out$rwi_fallback[missing[use]] <- TRUE
        message(
            country_iso3, ": ", length(missing), " populated units without RWI pixels, ",
            sum(use), " filled from the nearest tile, ", sum(!use), " left NA"
        )
    }
    out
}

# WorldPop inhabitants per location
unit_population <- function(locations) {
    pop <- terra::rast(glue::glue(
        "data/Population/WorldPop/{tolower(unique(locations$country_iso3))}_ppp_2020_UNadj_constrained.tif"
    ))
    exact_extract(pop, st_transform(locations, 4326), "sum", progress = FALSE)
}

# Gaps left after the fallbacks (units with no RWI data within the fallback distance)
# take the mean of the valid values of the units of the same district (adm1_name +
# adm2_name), then of the same province (adm1_name), then the country median of the
# locations passed in. One country per call.
# The paper workbooks use the paper-list units: identical for VNM and BGD, but for
# IND only 7,648 of the 21,867 units in villages_ind.gpkg, so run it on those
# units to reproduce the workbook values.
impute_district_mean <- function(val, adm1, adm2, label) {
    missing <- is.na(val)
    if (any(missing) && !all(missing)) {
        district <- paste(adm1, adm2, sep = "|")
        by_district <- ave(val, district, FUN = function(x) mean(x, na.rm = TRUE))
        by_province <- ave(val, adm1, FUN = function(x) mean(x, na.rm = TRUE))
        fill <- ifelse(!is.nan(by_district), by_district,
                       ifelse(!is.nan(by_province), by_province, median(val[!missing])))
        val[missing] <- fill[missing]
        message(
            sum(missing), " units without a ", label, " value filled with the district mean (",
            sum(missing & !is.nan(by_district)), "), the province mean (",
            sum(missing & is.nan(by_district) & !is.nan(by_province)), ") or the country median (",
            sum(missing & is.nan(by_district) & is.nan(by_province)), ")"
        )
    }
    if (anyNA(val)) {
        warning(sum(is.na(val)), " locations have no ", label, " value")
    }
    val
}

# S_ECO1 Poverty / wealth, replaces the GSAP2 poverty headcount.
# val = - population-weighted mean RWI, so higher = poorer = more susceptible,
# the same direction as the headcount it replaces. Normalised downstream.
# Remaining gaps take the mean of the district (then province, then country median).
S_ECO1_rwi <- function(locations, ...) {
    stats <- rwi_unit_stats(locations)
    locations$val <- -stats$rwi_mean[match(as.character(locations$geo_id), stats$geo_id)]
    locations$val <- impute_district_mean(locations$val, locations$adm1_name, locations$adm2_name, "RWI")
    return(locations)
}

# Population-weighted SD of RWI inside a fixed-radius window around each
# location's centroid. A fixed window removes the dependence of the SD on the
# size of the unit (a unit smaller than one ~2.4 km tile has SD ~ 0).
# n_tiles = distinct populated RWI tiles in the window; the SD is NA below
# min_tiles so that windows on the edge of the coverage do not get a noisy SD.
rwi_window_stats <- function(locations, radius_km = 10, min_tiles = 5) {
    locations <- st_transform(locations, 4326)
    r <- rwi_rasters(locations, pad = radius_km / 111 + 0.05)
    windows <- suppressWarnings(st_buffer(st_centroid(locations), radius_km * 1000, nQuadSegs = 8))
    stats <- exact_extract(
        c(r$rwi_rast, r$pop), windows,
        fun = function(values) {
            w <- values$pop * values$coverage_fraction
            ok <- !is.na(values$rwi) & !is.na(w) & w > 0
            if (!any(ok)) {
                return(data.frame(rwi_sd_window = NA_real_, n_tiles = 0L))
            }
            v <- values$rwi[ok]
            w <- w[ok]
            m <- sum(w * v) / sum(w)
            data.frame(
                rwi_sd_window = sqrt(sum(w * (v - m)^2) / sum(w)),
                n_tiles = length(unique(v))
            )
        },
        summarize_df = TRUE, progress = FALSE
    )
    stats$rwi_sd_window[stats$n_tiles < min_tiles] <- NA_real_
    data.frame(geo_id = as.character(locations$geo_id), stats)
}

# S_ECO4 Spatial wealth inequality, replaces the GSAP2 Gini index.
# Proxy: population-weighted SD of RWI inside a RWI_WINDOW_KM window around the
# unit centroid (higher = more unequal = more susceptible, same direction as the
# Gini). It captures wealth differences between ~2.4 km tiles, not household
# income inequality. Units whose window holds too few populated tiles are
# recomputed with a RWI_WINDOW_KM_FALLBACK window; populated units still without
# a value take that of the nearest valid unit within RWI_MAX_FALLBACK_KM; the
# rest take the mean of the district (then province, then country median). The window
# weights are the WorldPop counts of the window pixels, so units with few inhabitants of
# their own (WorldPop < RWI_MIN_POP) get a value too.
RWI_WINDOW_KM <- 10
RWI_WINDOW_KM_FALLBACK <- 20

S_ECO4_rwi <- function(locations, ...) {
    stats <- rwi_window_stats(locations, RWI_WINDOW_KM)
    locations$val <- stats$rwi_sd_window
    missing <- which(is.na(locations$val))
    if (length(missing) > 0) {
        wide <- rwi_window_stats(locations[missing, ], RWI_WINDOW_KM_FALLBACK)
        locations$val[missing] <- wide$rwi_sd_window
        message(
            length(missing), " units without enough tiles within ", RWI_WINDOW_KM, " km, ",
            sum(!is.na(wide$rwi_sd_window)), " filled with a ", RWI_WINDOW_KM_FALLBACK,
            " km window, ", sum(is.na(wide$rwi_sd_window)), " left NA"
        )
    }
    still_missing <- which(is.na(locations$val))
    valid <- which(!is.na(locations$val))
    if (length(still_missing) > 0 && length(valid) > 0) {
        centroids <- suppressWarnings(st_centroid(st_transform(locations, 4326)))
        nearest <- st_nearest_feature(centroids[still_missing, ], centroids[valid, ])
        km <- as.numeric(st_distance(
            centroids[still_missing, ], centroids[valid[nearest], ], by_element = TRUE
        )) / 1000
        use <- km <= RWI_MAX_FALLBACK_KM
        locations$val[still_missing[use]] <- locations$val[valid[nearest[use]]]
        message(
            length(still_missing), " units still without a value, ", sum(use),
            " filled from the nearest valid unit within ", RWI_MAX_FALLBACK_KM, " km, ",
            sum(!use), " left NA"
        )
    }
    locations$val <- impute_district_mean(locations$val, locations$adm1_name, locations$adm2_name, "RWI dispersion")
    return(locations)
}
