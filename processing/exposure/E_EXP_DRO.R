library(cleaner)
library(dplyr)
library(exactextractr)
library(raster)
library(sf)
library(terra)

source("common/helpers.R")

locations <- st_read("data/ADMIN/admin.shp") %>% st_transform(4326)
drought <- st_read("data/Water/Y2019M07D12_Aqueduct30_V01/baseline/annual/y2019m07d11_aqueduct30_annual_v01.gpkg")
ecosystems <- rast("data/ESA_Landcover/VNM_ecosystems.tif")

drought_cropped <- crop(drought, ecosystems)
plot(drought_cropped)
### zonal statistics using "exactextractr"
locations$cnt <- exact_extract(drought_cropped, locations, "sum")
locations$val <- locations$cnt / as.numeric(locations$area)
locations$norm <- normalize_minmax(locations$val, na.rm = TRUE)
st_write(locations, "output/exposure/E_EXP_DRO_drought.gpkg", append = FALSE)
