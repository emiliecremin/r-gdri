# Source: ESA Landcover
ER_FOR_1511 <- function(locations, ...) {
    country_iso3 <- unique(locations$country_iso3)[1]
    forests <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_forests.tif"))
    locations <- raster_area_within_polygons(forests, locations)
    return(locations)
}

# Source: Global Forest Change - GFC
# https://developers.google.com/earth-engine/datasets/catalog/UMD_hansen_global_forest_change_2023_v1_11
# https://doi.org/10.1126/science.1244693
# Forest loss % from 2000 to 2023Ż
ES_DES3 <- function(locations, ...) {
    country_iso3 <- unique(locations$country_iso3)[1]
    gfc_thresholded <- rast(glue::glue("objects/Forests/gfc_extract_thresholded_{country_iso3}.tif"))
    lossyear <- gfc_thresholded[[glue::glue("gfc_extract_thresholded_{country_iso3}_2")]]
    # https://rdrr.io/cran/gfcanalysis/man/threshold_gfc.html
    # all years from year 2000 to 2019 values > 0 and < 20 become 1
    loss <- extract_classes(lossyear, c(0, 20, 1))
    locations <- raster_area_within_polygons(loss, locations)
    return(locations)
}

# Source: Global Forest Change - GFC
# https://developers.google.com/earth-engine/datasets/catalog/UMD_hansen_global_forest_change_2023_v1_11
# https://doi.org/10.1126/science.1244693
# Forest gain % from 2000 to 2023Ż
ER_RES2 <- function(locations, ...) {
    country_iso3 <- unique(locations$country_iso3)[1]
    gfc_thresholded <- rast(glue::glue("objects/Forests/gfc_extract_thresholded_{country_iso3}.tif"))
    # https://rdrr.io/cran/gfcanalysis/man/threshold_gfc.html
    gain <- gfc_thresholded[[glue::glue("gfc_extract_thresholded_{country_iso3}_3")]]
    gain[gain == 0] <- NA
    locations <- raster_area_within_polygons(gain, locations)
    return(locations)
}

# Forest landscape Integrity Index
# Data: https://www.forestintegrity.com/download-data
# Paper: https://www.nature.com/articles/s41467-020-19493-3
# index from 0 (low integrity) to 10 (high integrity)
ER_ECO2_FLII <- function(locations, ...) {
    flii <- rast("data/Forests/Forest_Landscape_Integrity_Index/FLII_Asia.tif") # nolint
    raster_divided <- flii / 1000
    raster_divided[raster_divided < 0] <- 0
    locations$val <- exact_extract(raster_divided, locations, "mean", progress = TRUE)
    return(locations)
}
