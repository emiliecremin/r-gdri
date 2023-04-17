library(cleaner)
library(dplyr)
library(exactextractr)
library(raster)
library(sf)

source("common/helpers.R")

locations <- st_read("data/ADMIN/admin.shp") %>% st_transform(4326)
# data source: UNEP
# https://wesr.unepgrid.ch/static.html?views=MX-JXZXA-MFZNN-LTXZ8&zoomToViews=true
floods <- rast("data/Hazards/Floods/fl_hazard_100_yrp.tif")

### zonal statistics using "exactextractr"
locations$cnt <- exact_extract(floods, locations, "mean")
locations$val <- locations$cnt * locations$pop
locations$norm <- normalize_minmax(locations$val, na.rm = TRUE)
st_write(locations, "output/exposure/S_EXP_FLO_floods.gpkg", append = FALSE)

my_map(data = locations, "ADM2_EN", "norm", "Social Exposure to floods: S_EXP_FLO", "Reds")
