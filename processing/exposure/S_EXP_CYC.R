library(cleaner)
library(dplyr)
library(raster)
library(sf)

source("common/helpers.R")

locations <- st_read("data/ADMIN/admin.shp")
locations <- st_transform(locations, 4326)
# https://datacore.unepgrid.ch/geoserver/wesr_risk/wcs?service=WCS&Version=2.0.1&request=GetCoverage&coverageId=cy_physexp&outputCRS=EPSG:4326&format=GEOTIFF&compression=DEFLATE
# population affected
# my_raster <- raster("data/Hazards/Cyclones/cy_physexp.tif")

# https://datacore.unepgrid.ch/geoserver/wesr_risk/wcs?service=WCS&Version=2.0.1&request=GetCoverage&coverageId=cy_frequency&outputCRS=EPSG:4326&format=GEOTIFF&compression=DEFLATE
cyclones <- raster("data/Hazards/Cyclones/cy_frequency.tif")

cyclones_extent <- crop(cyclones, extent(locations)) ### crop to the extent
cyclones_roi <- mask(x = cyclones_extent, mask = locations) ### delimitation to the shape geometry
plot(cyclones_roi)

### zonal statistics using "raster"
locations$cnt <- extract(cyclones_roi, locations, fun = sum, na.rm=TRUE) %>% na_replace()
locations$freq <- locations$cnt * locations$pop
locations$norm <- normalize_minmax(locations$freq, na.rm = TRUE)
st_write(locations, "output/S_EXP_CYC_cyclones.gpkg", append = FALSE)

# Other dataset
# https://risk.preventionweb.net/download/Cyclonic%20wind_RT100years_g152.zip
