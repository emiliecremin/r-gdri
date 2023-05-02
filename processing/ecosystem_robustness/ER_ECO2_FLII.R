install.packages("exactextractr")
library(exactextractr)
library(raster)
library(sf)

source("common/helpers.R")

# ER_ECO2_FLII | Forest landscape Integrity Index

aoi <- st_read("data/ADMIN/admin_with_buffer.shp") %>% st_transform(4326)
flii <- rast("data/Forests/Forest_Landscape_Integrity_Index/FLII_Asia.tif") # nolint
aoi$cnt <- exact_extract(flii, aoi, "sum")
aoi$val <- aoi$cnt / aoi$area
aoi$norm <- normalize_minmax(aoi$val, na.rm = TRUE)
st_write(aoi, "output/ecosystem_robustness/ER_ECO2_FLII.gpkg", append = FALSE)
my_map(data = aoi, "ADM2_EN", "norm", "Forest landscape Integrity Index", "Greens")
