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
# Units with fewer WorldPop inhabitants than this get no value of their own
# (S_ECO1_rwi / S_ECO4_rwi then fill them with the country median)
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
# RWI_MIN_POP inhabitants stay NA.
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

    missing <- which(is.na(out$rwi_mean) & out$pop_worldpop >= RWI_MIN_POP)
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

# Gaps left after the fallbacks (unpopulated units, and populated units with no
# RWI data within the fallback distance) take the median of the valid values.
# One country per call, so this is the country median of the locations passed in.
# The paper workbooks use the paper-list units: identical for VNM and BGD, but for
# IND only 7,648 of the 21,867 units in villages_ind.gpkg, so run it on those
# units to reproduce the workbook values (IND medians differ otherwise).
impute_country_median <- function(val, label) {
    missing <- is.na(val)
    if (any(missing) && !all(missing)) {
        val[missing] <- median(val[!missing])
        message(sum(missing), " units without a ", label, " value filled with the country median")
    }
    if (anyNA(val)) {
        warning(sum(is.na(val)), " locations have no ", label, " value")
    }
    val
}

# S_ECO1 Poverty / wealth, replaces the GSAP2 poverty headcount.
# val = - population-weighted mean RWI, so higher = poorer = more susceptible,
# the same direction as the headcount it replaces. Normalised downstream.
# Remaining gaps take the country median.
S_ECO1_rwi <- function(locations, ...) {
    stats <- rwi_unit_stats(locations)
    locations$val <- -stats$rwi_mean[match(as.character(locations$geo_id), stats$geo_id)]
    locations$val <- impute_country_median(locations$val, "RWI")
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
# rest (including unpopulated units) take the country median.
RWI_WINDOW_KM <- 10
RWI_WINDOW_KM_FALLBACK <- 20

S_ECO4_rwi <- function(locations, ...) {
    stats <- rwi_window_stats(locations, RWI_WINDOW_KM)
    locations$val <- stats$rwi_sd_window
    unpopulated <- unit_population(locations) < RWI_MIN_POP
    locations$val[unpopulated] <- NA_real_
    missing <- which(is.na(locations$val) & !unpopulated)
    if (length(missing) > 0) {
        wide <- rwi_window_stats(locations[missing, ], RWI_WINDOW_KM_FALLBACK)
        locations$val[missing] <- wide$rwi_sd_window
        message(
            length(missing), " units without enough tiles within ", RWI_WINDOW_KM, " km, ",
            sum(!is.na(wide$rwi_sd_window)), " filled with a ", RWI_WINDOW_KM_FALLBACK,
            " km window, ", sum(is.na(wide$rwi_sd_window)), " left NA"
        )
    }
    still_missing <- which(is.na(locations$val) & !unpopulated)
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
    locations$val[unpopulated] <- NA_real_
    locations$val <- impute_country_median(locations$val, "RWI dispersion")
    return(locations)
}
