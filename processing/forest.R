# Source: ESA Landcover
ER_FOR_1511 <- function(locations, ...) {
    country_iso3 <- unique(locations$country_iso3)[1]
    forests <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_forests.tif"))
    locations <- raster_area_within_polygons(forests, locations)
    return(locations)
}

# Source: Global Forest Cover - GFC
ES_DES3 <- function(locations, ...) {
    country_iso3 <- unique(locations$country_iso3)[1]
    gfc_thresholded <- rast(glue::glue("objects/Forests/gfc_extract_thresholded_{country_iso3}.tif"))
    lossyear <- gfc_thresholded[["gfc_extract_thresholded_BGD_2"]]
    # https://rdrr.io/cran/gfcanalysis/man/threshold_gfc.html
    # all years from year 2000 to 2019 values > 0 and < 20 become 1
    loss <- extract_classes(lossyear, c(0, 20, 1))
    locations <- raster_area_within_polygons(loss, locations)
    return(locations)
}

# Source: Global Forest Cover - GFC
ER_RES2 <- function(locations, ...) {
    country_iso3 <- unique(locations$country_iso3)[1]
    gfc_thresholded <- rast(glue::glue("objects/Forests/gfc_extract_thresholded_{country_iso3}.tif"))
    # https://rdrr.io/cran/gfcanalysis/man/threshold_gfc.html
    gain <- gfc_thresholded[["gfc_extract_thresholded_BGD_3"]]
    gain[gain == 0] <- NA
    locations <- raster_area_within_polygons(gain, locations)
    return(locations)
}

# Forest landscape Integrity Index
# Data: https://www.forestintegrity.com/download-data
# Paper: https://www.nature.com/articles/s41467-020-19493-3
# TODO: limited to Asia given the raster used, could be improved
ER_ECO2_FLII <- function(locations, ...) {
    flii <- rast("data/Forests/Forest_Landscape_Integrity_Index/FLII_Asia.tif") # nolint
    locations$val <- exact_extract(flii, locations, "mean", progress = TRUE)
    return(locations)
}
