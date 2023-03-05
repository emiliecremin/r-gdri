library(dplyr)
library(sf)
library(leaflet)

source("common/helpers.R")

# https://www.wri.org/research/aqueduct-30-updated-decision-relevant-global-water-risk-indicators
# https://github.com/wri/aqueduct30_data_download/blob/master/metadata.md
locations <- st_read("data/ADMIN/admin.shp")
locations <- st_transform(locations, 4326)
aqueduct <- st_read("data/Water/Y2019M07D12_Aqueduct30_V01/baseline/annual/y2019m07d11_aqueduct30_annual_v01.gpkg")
aqueduct <- dplyr::filter(aqueduct, name_0 == "Vietnam")  %>% st_make_valid()
aqueduct_points <- st_centroid(locations) %>% st_join(aqueduct)
join_df <- st_drop_geometry(aqueduct_points[,c("GEOLEVEL2","usa_score", "usa_cat", "usa_label")])
sanitation <- joinOnColumn(join_df, locations, "GEOLEVEL2")
sanitation$norm <- normalize_minmax(sanitation$usa_score, na.rm = TRUE)
st_write(sanitation, "output/social_susceptibility/S_INF3_621.gpkg", append = FALSE)

my_map(data = sanitation, "ADM2_EN", "norm", "Sanitation: S_INF3_621", "Reds")
