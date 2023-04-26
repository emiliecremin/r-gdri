# Soils
### zonal statistics using "exactextractr"

source("common/helpers.R")

aoi <- st_read("data/ADMIN/admin.shp") %>% st_transform(4326)
msa <- rast("data/Soil/GSOCmap1.5.0.tif") # nolint
aoi$cnt <- exact_extract(msa, aoi, "sum")
aoi$val <- aoi$cnt / aoi$area
aoi$norm <- normalize_minmax(aoi$val, na.rm = TRUE)
st_write(aoi, "output/ecosystem_sensitivity/ES_DEG6_Soil_organic_carbone.gpkg", append = FALSE)

# aoi <- st_read("output/ecosystem_sensitivity/ES_DEG6_Soil_organic_carbone.gpkg")
m <- my_map(data = aoi, "ADM2_EN", "norm", "ES_DEG6 Soil organic carbone", "Reds")
saveWidget(m, file = "html/ES_DEG6.html", selfcontained = FALSE)
