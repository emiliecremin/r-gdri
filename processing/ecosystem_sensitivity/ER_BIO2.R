# Biodiversity

# Endangered species
# https://www.iucnredlist.org/search/map?permalink=db4ccf05-aea7-4657-8e08-23a4f6c565b9

# Protected Areas
# https://api.protectedplanet.net/documentation

# Key Biodiversity Areas
# https://www.keybiodiversityareas.org/kba-data/request



### zonal statistics using "exactextractr"
# Calculate annual statistics on forest loss/gain
install.packages("exactextractr")
library(exactextractr)
library(raster)
library(sf)

source("common/helpers.R")

aoi <- st_read("data/ADMIN/admin_with_buffer.shp") %>% st_transform(4326)
msa <- raster("data/Biodiversity/Globio4_TerrestrialMSA_10sec_2015/TerrestrialMSA_2015_World.tif") # nolint
aoi$cnt <- exact_extract(msa, aoi, "sum")
aoi$val <- aoi$cnt / aoi$area
aoi$norm <- normalize_minmax(aoi$val, na.rm = TRUE)
st_write(
    aoi,
    "output/ecosystem_sensitivity/ES_BIO2_mean_species_abundance.gpkg",
    append = FALSE
)
