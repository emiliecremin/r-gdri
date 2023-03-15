library(cleaner)
library(dplyr)
library(raster)
library(sf)
library(terra)

source("common/helpers.R")

locations <- st_read("data/ADMIN/admin_with_buffer.shp")
locations <- st_transform(locations, 4326)
landcover_roi <- rast("data/ESA_Landcover/VNM_roi.tif")
plot(landcover_roi)
# data source: UNEP GRID
# https://datacore.unepgrid.ch/geoserver/wesr_risk/wcs?service=WCS&Version=2.0.1&request=GetCoverage&coverageId=cy_frequency&outputCRS=EPSG:4326&format=GEOTIFF&compression=DEFLATE
cyclones <- raster("data/Hazards/Cyclones/cy_frequency.tif")
cyclones_roi <- mask(x = cyclones, mask = locations)
cyclones_roi <- project(cyclones_roi, landcover_roi)
plot(cyclones_roi)

ecosystems <- rast("data/ESA_Landcover/VNM_ecosystems.tif")
plot(ecosystems)
cyclones_ecosystems <- mask(cyclones_roi, ecosystems)
plot(cyclones_ecosystems)

### zonal statistics using "raster"
sum_cyclones <- extract(cyclones_ecosystems, locations, fun = sum, na.rm = TRUE) %>% na_replace()
locations$cnt <- sum_cyclones[, 2]
locations$freq <- locations$cnt / as.numeric(locations$area)
locations$norm <- normalize_minmax(locations$freq, na.rm = TRUE)
st_write(locations, "output/exposure/E_EXP_CYC_cyclones.gpkg", append = FALSE)
