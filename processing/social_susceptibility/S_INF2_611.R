library(dplyr)
library(sf)

source("common/helpers.R")

# https://www.wri.org/research/aqueduct-30-updated-decision-relevant-global-water-risk-indicators
# https://github.com/wri/aqueduct30_data_download/blob/master/metadata.md
locations <- st_read("data/ADMIN/admin.shp") %>% st_transform(4326)
aqueduct <- st_read("data/Water/Y2019M07D12_Aqueduct30_V01/baseline/annual/y2019m07d11_aqueduct30_annual_v01.gpkg")
aqueduct <- dplyr::filter(aqueduct, name_0 == "Vietnam") %>% st_make_valid()
aqueduct_points <- st_centroid(locations) %>% st_join(aqueduct)
join_df <- st_drop_geometry(aqueduct_points[, c("GEOLEV2", "udw_score", "udw_cat", "udw_label")])
unimproved_drinking_water <- joinOnColumn(join_df, locations, "GEOLEV2")
unimproved_drinking_water$val <- unimproved_drinking_water$udw_score
unimproved_drinking_water$norm <- normalize_minmax(unimproved_drinking_water$udw_score, na.rm = TRUE)
st_write(unimproved_drinking_water, "output/social_susceptibility/S_INF2_611.gpkg", append = FALSE)
