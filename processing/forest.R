# Source: ESA Landcover
ER_FOR_1511 <- function(locations, ...) {
    country_iso3 <- unique(locations$country_iso3)[1]
    forests <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_forests.tif"))
    locations$cnt <- exact_extract(
        forests, st_as_sf(locations),
        "sum",
        default_value = 0,
        progress = TRUE
    )
    locations$val <- locations$cnt / locations$area
    return(locations)
}

# Source: Global Forest Cover - GFC
ES_DES3 <- function(locations, ...) {
    country_iso3 <- unique(locations$country_iso3)[1]
    gfc_thresholded <- readRDS(glue::glue("objects/Forests/gfc_extract_thresholded_{country_iso3}.rds"))
    lossyear <- gfc_thresholded[["lossyear"]]
    # https://rdrr.io/cran/gfcanalysis/man/threshold_gfc.html
    # all years from year 2000 values > 0 and < 99 become 1
    loss <- extract_classes(lossyear, c(-1, 1, 0, 0, 100, 1))
    locations$cnt <- exact_extract(loss, locations, "sum", progress = TRUE)
    locations$val <- locations$cnt / locations$area
    return(locations)
}

# Source: Global Forest Cover - GFC
ER_RES2 <- function(locations, ...) {
    country_iso3 <- unique(locations$country_iso3)[1]
    gfc_thresholded <- readRDS(glue::glue("objects/Forests/gfc_extract_thresholded_{country_iso3}.rds"))
    # https://rdrr.io/cran/gfcanalysis/man/threshold_gfc.html
    gain <- gfc_thresholded[["gain"]]
    locations$cnt <- exact_extract(gain, locations, "sum", progress = TRUE)
    locations$val <- locations$cnt / locations$area
    return(locations)
}

# Forest landscape Integrity Index
# Data: https://www.forestintegrity.com/download-data
# Paper: https://www.nature.com/articles/s41467-020-19493-3
# TODO: limited to Asia given the raster used, could be improved
ER_ECO2_FLII <- function(locations, ...) {
    flii <- rast("data/Forests/Forest_Landscape_Integrity_Index/FLII_Asia.tif") # nolint
    locations$cnt <- exact_extract(flii, locations, "mean", progress = TRUE)
    locations$val <- locations$cnt
    return(locations)
}
