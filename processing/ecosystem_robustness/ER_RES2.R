
### zonal statistics using "exactextractr"
# Calculate annual statistics on forest loss/gain
install.packages("exactextractr")
library(exactextractr)

source("common/admin.R")
source("common/helpers.R")
source("common/GFC.R")

aoi$cnt <- exact_extract(gfc_thresholded[["gain"]], admin_shp, "sum")
aoi$freq <- aoi$cnt / aoi$area
aoi$norm <- normalize_minmax(aoi$freq, na.rm = TRUE)
st_write(
  aoi,
  "output/ecosystem_robustness/ER_RES2_forest_gain.gpkg",
  append = FALSE
)

