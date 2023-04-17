library(cleaner)
library(dplyr)
library(raster)
library(sf)
library(terra)

source("common/helpers.R")

locations <- st_read("data/ADMIN/admin_with_buffer.shp") %>% st_transform(4326)
# data source: UNEP
# # https://wesr.unepgrid.ch/?project=MX-XVK-HPH-OGN-HVE-GGN&language=en
# https://wesr.unepgrid.ch/static.html?views=MX-JXZXA-MFZNN-LTXZ8&zoomToViews=true
floods <- rast("data/Hazards/Floods/fl_hazard_100_yrp.tif")
ecosystems <- rast("data/ESA_Landcover/VNM_ecosystems.tif")

floods_cropped <- crop(floods, ecosystems)
plot(floods_cropped)
### zonal statistics using "exactextractr"
locations$cnt <- exact_extract(floods_cropped, locations, "sum")
locations$val <- locations$cnt / as.numeric(locations$area)
locations$norm <- normalize_minmax(locations$val, na.rm = TRUE)
st_write(locations, "output/exposure/E_EXP_FLO_floods.gpkg", append = FALSE)
