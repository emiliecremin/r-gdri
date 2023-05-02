# ES_DES3

install.packages("terra")
install.packages("maptools")
# Install gfcanalysis package
install.packages("gfcanalysis")

# Load the gfcanalysis package
library(gfcanalysis)

source("common/helpers.R")

### zonal statistics using "exactextractr"
# Calculate annual statistics on forest loss/gain
install.packages("exactextractr")
library(exactextractr)

aoi <- st_read("data/ADMIN/admin_with_buffer.shp") %>% st_transform(4326)
forests <- rast("data/ESA_Landcover/VNM_forests.tif")
aoi$cnt <- exact_extract(forests, aoi, "sum")
aoi$val <- aoi$cnt / aoi$area
aoi$norm <- normalize_minmax(aoi$val, na.rm = TRUE)
st_write(
    aoi,
    "output/ecosystem_sensitivity/ES_DES1511_forest_area.gpkg",
    append = FALSE
)
