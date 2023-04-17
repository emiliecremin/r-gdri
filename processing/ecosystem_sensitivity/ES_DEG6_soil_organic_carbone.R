# Soils
### zonal statistics using "exactextractr"


install.packages("exactextractr")
library(exactextractr)
library(raster)
library(sf)

source("common/helpers.R")

aoi <- st_read("data/ADMIN/admin_with_buffer.shp") %>% st_transform(4326)
msa <- raster("data/ES_Soils/Soil_Organic_Carbone.tif") # nolint
aoi$cnt <- exact_extract(msa, aoi, "sum")
aoi$val <- aoi$cnt / aoi$area
aoi$norm <- normalize_minmax(aoi$val, na.rm = TRUE)
st_write(aoi,"output/ecosystem_sensitivity/ES_DEG6_Soil_organic_carbone.gpkg",append = FALSE)
my_map(data = locations, "ADM2_EN", "norm", "Ecosystem Sensitivity: ES_DEG6 Soil organic carbone", "Reds")
  
