library(cleaner)
library(dplyr)
library(exactextractr)
library(raster)
library(sf)
library(terra)

source("common/helpers.R")

locations <- st_read("data/ADMIN/admin_with_buffer.shp") %>% st_transform(4326)
# data source: World Bank
# https://energydata.info/dataset/global-coastal-flood-hazard/resource/46904e08-7daa-4c58-8c62-f0c27407ba5c
storm_surge <- rast("data/Hazards/StormSurge/ss_muis_rp0100m.tif")
ecosystems <- rast("data/ESA_Landcover/VNM_ecosystems.tif")

storm_surge_cropped <- crop(storm_surge, ecosystems)
plot(storm_surge_cropped)
### zonal statistics using "exactextractr"
locations$cnt <- exact_extract(storm_surge_cropped, locations, "sum")
locations$val <- locations$cnt / as.numeric(locations$area)
locations$norm <- normalize_minmax(locations$val, na.rm = TRUE)
st_write(locations, "output/exposure/E_EXP_COF_storm_surge.gpkg", append = FALSE)
