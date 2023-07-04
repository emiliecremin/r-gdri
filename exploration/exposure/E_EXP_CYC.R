library(cleaner)
library(dplyr)
library(exactextractr)
library(raster)
library(sf)
library(terra)

source("common/helpers.R")

locations <- st_read("data/ADMIN/admin_with_buffer.shp") %>% st_transform(4326)
# data source: UNEP GRID
# https://datacore.unepgrid.ch/geoserver/wesr_risk/wcs?service=WCS&Version=2.0.1&request=GetCoverage&coverageId=cy_valuency&outputCRS=EPSG:4326&format=GEOTIFF&compression=DEFLATE
cyclones <- rast("data/Hazards/Cyclones/cy_frequency.tif")
ecosystems <- rast("data/ESA_Landcover/VNM_ecosystems.tif")

cyclones_cropped <- crop(cyclones, ecosystems)
plot(cyclones_cropped)
### zonal statistics using "exactextractr"
locations$cnt <- exact_extract(cyclones_cropped, locations, "sum")
locations$val <- locations$cnt / as.numeric(locations$area)
locations$norm <- normalize_minmax(locations$val, na.rm = TRUE)
st_write(locations, "output/exposure/E_EXP_CYC_cyclones.gpkg", append = FALSE)
