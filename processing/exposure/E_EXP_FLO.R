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
# data source: UNEP
# # https://wesr.unepgrid.ch/?project=MX-XVK-HPH-OGN-HVE-GGN&language=en
# https://wesr.unepgrid.ch/static.html?views=MX-JXZXA-MFZNN-LTXZ8&zoomToViews=true
floods <- rast("data/Hazards/Floods/fl_hazard_100_yrp.tif")
floods_roi <- mask(x = floods, mask = locations)
floods_roi <- project(floods_roi, landcover_roi)
plot(floods_roi)

ecosystems <- rast("data/ESA_Landcover/VNM_ecosystems.tif")
plot(ecosystems)
floods_ecosystems <- mask(floods_roi, ecosystems)
plot(floods_ecosystems)

### zonal statistics using "raster"
sum_floods <- extract(floods_ecosystems, locations, fun = sum, na.rm=TRUE) %>% na_replace()
locations$cnt <- sum_floods[,2]
locations$freq <- locations$cnt / as.numeric(locations$area)
locations$norm <- normalize_minmax(locations$freq, na.rm = TRUE)
st_write(locations, "output/E_EXP_FLO_floods.gpkg", append = FALSE)
