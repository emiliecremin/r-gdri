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

# ES_DEG8 Soil salinity
# Global Soil Salinity Map
# https://doi.org/10.1016/j.rse.2019.111260
# https://data.isric.org/geonetwork/srv/eng/catalog.search#/metadata/c59d0162-a258-4210-af80-777d7929c512
ES_DEG8 <- function(locations, ...) {
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

# ES_DEG7 Soil Workability (HWSD 1.2)
# Harmonized World Soil Database Version 1.2 February 2012
# Workability soil quality SQ7
# Only classes 1 to 4 are corresponding to an assessment of soil limitations for plant growth
"
Note that the classes used in the Soil Quality evaluation are:
1: No or slight limitations
2: Moderate limitations
3: Sever limitations
4: Very severe limitations
5: Mainly non-soil
6: Permafrost area
7: Water bodies
"
# https://data.apps.fao.org/map/catalog/srv/eng/catalog.search?id=12691#/metadata/f1d5ecdd-c078-475e-9ced-0451892381aee
# https://storage.googleapis.com/fao-maps-catalog-data/geonetwork/gsoc/SQ/sq7.tif
ES_DEG7 <- function(locations, ...) {
    soil_quality <- terra::rast("data/Soil/Quality/sq7.tif")
    soil_workability <- extract_classes(
        soil_quality,
        c(0.9, 1.1, 1,
        1.1, 2.1, 2,
        2.1, 3.1, 3,
        3.1, 4.1, 4)
    )
    # terra::writeRaster(
    #     soil_workability,
    #     "data/Soil/Quality/q.tif",
    #     overwrite = TRUE
    # )
    locations$cnt <- exact_extract(
        soil_workability, locations, "sum", progress = TRUE
    )
    locations$val <- locations$cnt / locations$area
}
