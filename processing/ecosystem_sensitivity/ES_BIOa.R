install.packages("exactextractr")
library(exactextractr)
library(raster)
library(sf)

source("common/helpers.R")

aoi <- st_read("data/ADMIN/admin_with_buffer.shp") %>% st_transform(4326)
bii <- rast("data/Biodiversity/Biodiversity_Intactness_Index/BII.asc") # nolint
aoi$cnt <- exact_extract(bii, aoi, "sum")
aoi$val <- aoi$cnt / aoi$area
aoi$norm <- normalize_minmax(aoi$val, na.rm = TRUE)
st_write(aoi,"output/ecosystem_sensitivity/ES_BIO1a.gpkg",append = FALSE)
my_map(data = aoi, "ADM2_EN", "norm", "ES_BIO1a Biodiversity Intactness", "Greens")
