
### zonal statistics using "exactextractr"
# Calculate annual statistics on forest loss/gain
install.packages("exactextractr")
library(exactextractr)

source("common/admin.R")
source("common/helpers.R")
source("common/GFC.R")

aoi$cnt <- exact_extract(gfc_thresholded[["lossyear"]], admin_shp, "sum")
aoi$val <- aoi$cnt / aoi$area
aoi$norm <- normalize_minmax(aoi$val, na.rm = TRUE)
st_write(
    aoi,
    "output/ecosystem_sensitivity/ES_DES3_forest_loss.gpkg",
    append = FALSE
)

