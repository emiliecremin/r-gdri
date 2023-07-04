# Soils
### zonal statistics using "exactextractr"

# ES_DEG6 Soil_organic_carbone
ES_DEG6 <- function(locations, ...) {
    soc <- rast("data/Soil/GSOCmap1.5.0.tif") # nolint
    locations$cnt <- exact_extract(soc, locations, "sum", progress = TRUE)
    locations$val <- locations$cnt / locations$area
    return(locations)
}

# ES_DEG9 Cation_exchange_capacity
ES_DEG9 <- function(locations, ...) {
    cec <- rast("data/Soil/Cation_exchange_capacity.tif") # nolint
    locations$cnt <- exact_extract(cec, locations, "sum", progress = TRUE)
    locations$val <- locations$cnt / locations$area
    return(locations)
}
