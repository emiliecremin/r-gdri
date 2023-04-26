library(dplyr)
library(sf)

source("common/helpers.R")

# https://www.wri.org/research/aqueduct-30-updated-decision-relevant-global-water-risk-indicators
# https://github.com/wri/aqueduct30_data_download/blob/master/metadata.md
locations <- st_read("data/ADMIN/admin.shp") %>% st_transform(4326)
aqueduct <- st_read("data/Water/Y2019M07D12_Aqueduct30_V01/baseline/annual/y2019m07d11_aqueduct30_annual_v01.gpkg")
aqueduct <- dplyr::filter(aqueduct, name_0 == "Vietnam") %>% st_make_valid()
aqueduct_points <- st_centroid(locations) %>% st_join(aqueduct)

# All values are the same for all locations: Bangladesh, India, Vietnam = Extremely High (100%)

join_df <- st_drop_geometry(aqueduct_points[, c("GEOLEV2", "ucw_score", "ucw_cat", "ucw_label")])
untreated_wastewater <- joinOnColumn(join_df, locations, "GEOLEV2")
untreated_wastewater$val <- untreated_wastewater$ucw_score
untreated_wastewater$norm <- normalize_minmax(untreated_wastewater$ucw_score, na.rm = TRUE)
st_write(untreated_wastewater, "output/social_susceptibility/S_INF1_631.gpkg", append = FALSE)
