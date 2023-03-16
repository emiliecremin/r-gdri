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
# data source: World Bank
# https://energydata.info/dataset/global-coastal-flood-hazard/resource/46904e08-7daa-4c58-8c62-f0c27407ba5c
storm_surge <- rast("data/Hazards/StormSurge/ss_muis_rp0100m.tif")
storm_surge_roi <- mask(x = storm_surge, mask = locations)
storm_surge_roi <- project(storm_surge_roi, landcover_roi)
plot(storm_surge_roi)

ecosystems <- rast("data/ESA_Landcover/VNM_ecosystems.tif")
storm_surge_ecosystems <- mask(storm_surge_roi, ecosystems)
plot(storm_surge_ecosystems)

### zonal statistics using "raster"
sum_storm_surge <- extract(storm_surge_ecosystems, locations, fun = sum, na.rm = TRUE) %>% na_replace()
locations$cnt <- sum_storm_surge[, 2]
locations$val <- locations$cnt / as.numeric(locations$area)
locations$norm <- normalize_minmax(locations$val, na.rm = TRUE)
st_write(locations, "output/exposure/E_EXP_COF_storm_surge.gpkg", append = FALSE)
