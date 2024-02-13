# Soils
### zonal statistics using "exactextractr"

# ES_DEG6 Soil_organic_carbone
# https://data.apps.fao.org/catalog/dataset/7730e747-eb73-49c9-bfe6-84ebae718743
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

# ES_DEGx Soil salinity
# Global Soil Salinity Map
# https://doi.org/10.1016/j.rse.2019.111260
# https://data.isric.org/geonetwork/srv/eng/catalog.search#/metadata/c59d0162-a258-4210-af80-777d7929c512
ES_DEGx <- function(locations, ...) {
    locations <- bgd
    sal <- terra::rast("data/Soil/Salinity/salmap2016.vrt")
    locations$cnt <- exact_extract(sal, locations, "sum", progress = TRUE)
    locations$val <- locations$cnt / locations$area
    # ggplot() +
    # geom_sf(
    #     data = locations,
    #     aes(fill = val)
    # ) +
    # scale_fill_viridis_c(option = "C")
    return(locations)
}

