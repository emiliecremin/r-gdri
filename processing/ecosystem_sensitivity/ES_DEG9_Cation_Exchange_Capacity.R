# Soils
### zonal statistics using "exactextractr"


install.packages("exactextractr")
library(exactextractr)
library(raster)
library(sf)

source("common/helpers.R")

aoi <- st_read("data/ADMIN/admin_with_buffer.shp") %>% st_transform(4326)
msa <- rast("data/ES_Soils/Cation_exchange_capacity.tif") # nolint
aoi$cnt <- exact_extract(msa, aoi, "sum")
aoi$val <- aoi$cnt / aoi$area
aoi$norm <- normalize_minmax(aoi$val, na.rm = TRUE)
st_write(aoi,"output/ecosystem_sensitivity/ES_DEG9_Cation_exchange_capacity.gpkg",append = FALSE)
my_map(data = locations, "ADM2_EN", "norm", "Ecosystem Sensitivity: ES_DEG9_Cation_exchange_capacity", "Reds")
