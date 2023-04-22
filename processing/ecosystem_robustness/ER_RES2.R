### zonal statistics using "exactextractr"
# Calculate annual statistics on forest loss/gain
install.packages("exactextractr")
library(exactextractr)

source("common/helpers.R")
source("common/admin.R")
source("common/GFC.R")

aoi <- st_read("data/ADMIN/admin_with_buffer.shp") %>% st_transform(4326)
aoi$cnt <- exact_extract(gfc_thresholded[["gain"]], aoi, "sum")
aoi$val <- aoi$cnt / aoi$area
aoi$norm <- normalize_minmax(aoi$val, na.rm = TRUE)
st_write(
  aoi,
  "output/ecosystem_robustness/ER_RES2_forest_gain.gpkg",
  append = FALSE
)
