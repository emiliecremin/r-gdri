library(cleaner)
library(dplyr)
library(exactextractr)
library(raster)
library(sf)

source("common/helpers.R")

locations <- st_read("data/ADMIN/admin_with_buffer.shp") %>% st_transform(4326)
# https://datacore.unepgrid.ch/geoserver/wesr_risk/wcs?service=WCS&Version=2.0.1&request=GetCoverage&coverageId=cy_physexp&outputCRS=EPSG:4326&format=GEOTIFF&compression=DEFLATE
# population affected
# my_raster <- rast("data/Hazards/Cyclones/cy_physexp.tif")

# https://datacore.unepgrid.ch/geoserver/wesr_risk/wcs?service=WCS&Version=2.0.1&request=GetCoverage&coverageId=cy_valuency&outputCRS=EPSG:4326&format=GEOTIFF&compression=DEFLATE
cyclones <- rast("data/Hazards/Cyclones/cy_frequency.tif")


### zonal statistics using "exactextractr"
locations$cnt <- exact_extract(cyclones, locations, "mean")
locations$val <- locations$cnt * locations$pop
locations$norm <- normalize_minmax(locations$val, na.rm = TRUE)
st_write(locations, "output/exposure/S_EXP_CYC_cyclones.gpkg", append = FALSE)

# Other dataset
# https://risk.preventionweb.net/download/Cyclonic%20wind_RT100years_g152.zip
