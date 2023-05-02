install.packages("exactextractr")
library(exactextractr)
library(raster)
library(sf)

source("common/helpers.R")

aoi <- st_read("data/ADMIN/admin_with_buffer.shp") %>% st_transform(4326)
efi <- rast("data/Biodiversity/Ecosystem_Functionality_Index/EFI.tif") # nolint
aoi$cnt <- exact_extract(efi, aoi, "sum")
aoi$val <- aoi$cnt / aoi$area
aoi$norm <- normalize_minmax(aoi$val, na.rm = TRUE)
st_write(aoi, "output/ecosystem_robustness/ER_ECO1.gpkg", append = FALSE)
my_map(data = locations, "ADM2_EN", "norm", "ER_ECO1_Ecosystem_Functionality_index", "Greens")
