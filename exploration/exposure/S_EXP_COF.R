library(cleaner)
library(dplyr)
library(exactextractr)
library(raster)
library(sf)

source("common/helpers.R")

locations <- st_read("data/ADMIN/admin_with_buffer.shp") %>% st_transform(4326)
# data source: World Bank
# https://energydata.info/dataset/global-coastal-flood-hazard/resource/46904e08-7daa-4c58-8c62-f0c27407ba5c
storm_surge <- rast("data/Hazards/StormSurge/ss_muis_rp0100m.tif")

# Other dataset to consider
# https://www.frontiersin.org/articles/10.3389/fmars.2020.00263/full
# data: https://zenodo.org/record/3660927#.Y1JwOuzMKDU
# Mesh Layer QGIS: https://gis.stackexchange.com/questions/357159/cannot-open-netcdf-file-in-qgis

### zonal statistics using "exactextractr"
locations$cnt <- exact_extract(storm_surge, locations, "mean")
locations$val <- locations$cnt * locations$pop
locations$norm <- normalize_minmax(locations$val, na.rm = TRUE)
st_write(locations, "output/exposure/S_EXP_COF_storm_surge.gpkg", append = FALSE)
