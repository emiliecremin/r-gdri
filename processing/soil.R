# Soils
### zonal statistics using "exactextractr"

# ES_DEG6 Soil_organic_carbone
# Global Soil Organic Carbon Map v1.5 (GSOC), 2019
# https://data.apps.fao.org/catalog/dataset/7730e747-eb73-49c9-bfe6-84ebae718743
# GSOCmap: The GSOCmap is a spatial raster file with soil organic carbon stock values in Mg/ha for a depth of 0-30 cm.
ES_DEG6 <- function(locations, ...) {
    soc <- rast("data/Soil/organic_carbone/GSOCmap1.5.0.tif") # nolint
    locations$cnt <- exact_extract(soc, locations, "mean", progress = TRUE)
    locations$val <- locations$cnt
    return(locations)
}

# ES_DEG9 Cation_exchange_capacity
# datasource: soilgrids-isric
# SoilGrids250m 2.0 - Cation exchange capacity at ph7, 2020
# Data: 2016
# https://data.isric.org/geonetwork/srv/eng/catalog.search#/metadata/713396fc-1687-11ea-a7c0-a0481ca9e724
# Google Earth Engine (GEE) to export it with the following code
# https://code.earthengine.google.com/21df6671fc3d2c2ea7bad15d3b878268?noload=true
# var cec = ee.Image("projects/soilgrids-isric/cec_mean")
#           .select("cec_60-100cm_mean")
#           .clip(roi_boundary.geometry().bounds())
# Export.image.toDrive({
#   image: cec,
#   description: 'cec_60-100cm_mean',
#   folder: 'GEE',
#   region: roi_boundary.geometry().bounds(),
#   scale: 250, // Soilgrids offers 250m resolution
#   fileFormat: 'GeoTIFF',
#   maxPixels: 1e13,
# });
# unit: mmol/kg
ES_DEG9 <- function(locations, ...) {
    country_iso3 <- unique(locations$country_iso3)[1]
    cec <- terra::rast(glue::glue("data/Soil/CationExchangeCapacity/{country_iso3}_cec_60-100cm_mean.tif"))
    cec <- terra::project(cec, crs(locations))
    locations$cnt <- exact_extract(cec, locations, "mean", progress = TRUE)
    locations$val <- locations$cnt
    return(locations)
}

# Other data sources
#  Excess Salts (FAO HWSD v1.2)
# https://data.apps.fao.org/map/catalog/srv/eng/catalog.search?id=12691#/metadata/40db0008-f365-43ca-953d-cabdcadc24a5
# Soil Toxicities (HWSD)
# https://data.apps.fao.org/map/catalog/srv/eng/catalog.search?id=12691#/metadata/ec81aff5-2b00-4534-a780-78178288d21d


# ES_DEG7 Soil Workability (HWSD 1.2)
# Harmonized World Soil Database Version 1.2 February 2012
# Fischer, G., F. Nachtergaele, S. Prieler, H.T. van Velthuizen, L. Verelst, D. Wiberg, 2008. Global Agro-ecological Zones Assessment for Agriculture (GAEZ 2008). IIASA, Laxenburg, Austria and FAO, Rome, Italy.
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
        c(
            0.9, 1.1, 1,
            1.1, 2.1, 2,
            2.1, 3.1, 3,
            3.1, 4.1, 4
        )
    )
    # terra::writeRaster(
    #     soil_workability,
    #     "data/Soil/Quality/q.tif",
    #     overwrite = TRUE
    # )
    locations$cnt <- exact_extract(
        soil_workability, locations, "mean",
        progress = TRUE
    )
    locations$val <- locations$cnt
    return(locations)
}

# FAO - Harmonized World Soil Database v2.0
#  https://www.fao.org/soils-portal/data-hub/soil-maps-and-databases/harmonized-world-soil-database-v20/en/
# doc: https://www.fao.org/3/cc3823en/cc3823en.pdf
# https://data.isric.org/geonetwork/srv/all/catalog.search#/metadata/54aebf11-ec73-4ff8-bf6c-ecff4b0725ea
# GEE: https://gee-community-catalog.org/projects/hwsd/
