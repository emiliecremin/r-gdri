library(cleaner)
library(dplyr)
library(raster)
library(sf)

source("common/helpers.R")

locations <- st_read("data/ADMIN/admin.shp")
locations <- st_transform(locations, 4326)
# data source: UNEP
# https://wesr.unepgrid.ch/static.html?views=MX-JXZXA-MFZNN-LTXZ8&zoomToViews=true
floods <- raster("data/Hazards/Floods/fl_hazard_100_yrp.tif")

floods_extent <- crop(floods, extent(locations)) ### crop to the extent
floods_roi <- mask(x = floods_extent, mask = locations) ### delimitation to the shape geometry
plot(floods_roi)

### zonal statistics using "raster"
locations$cnt <- extract(floods_roi, locations, fun = mean, na.rm = TRUE) %>% na_replace()
locations$freq <- locations$cnt * locations$pop
locations$norm <- normalize_minmax(locations$freq, na.rm = TRUE)
st_write(locations, "output/exposure/S_EXP_FLO_floods.gpkg", append = FALSE)
