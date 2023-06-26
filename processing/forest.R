ES_DES3 <- function(locations, ...) {
    country_iso3 <- unique(locations$country_iso3)[1]
    gfc_thresholded <- rast("data/Forests/GFC/gfc_extract_thresholded_{country_iso3}.tif")
    locations$cnt <- exact_extract(gfc_thresholded[["lossyear"]], locations, "sum", progress = TRUE)
    locations$val <- locations$cnt / locations$area
    return(locations)
}

ES_DES_1511 <- function(locations, ...) {
    country_iso3 <- unique(locations$country_iso3)[1]
    forests <- rast(glue::glue("data/ESA_Landcover/{country_iso3}_forests.tif"))
    locations$cnt <- exact_extract(
        forests, st_as_sf(locations),
        "sum",
        default_value=0,
        progress = TRUE
        )
    locations$val <- locations$cnt / locations$area
    return(locations)
}
