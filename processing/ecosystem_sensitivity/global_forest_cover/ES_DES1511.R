# ES_DES3

install.packages("terra")
install.packages("maptools")
# Install gfcanalysis package
install.packages("gfcanalysis")

# Load the gfcanalysis package
library(gfcanalysis)

source("common/admin.R")
source("common/helpers.R")

### zonal statistics using "exactextractr"
# Calculate annual statistics on forest loss/gain
install.packages("exactextractr")
library(exactextractr)

forests <- raster("data/ESA_Landcover/VNM_forests.tif")
aoi$cnt <- exact_extract(forests, admin_shp, "sum")
aoi$freq <- aoi$cnt / aoi$area
aoi$norm <- normalize_minmax(aoi$freq, na.rm = TRUE)
st_write(
    aoi,
    "output/ecosystem_sensitivity/ER_DES1511_forest_area.gpkg",
    append = FALSE
)
