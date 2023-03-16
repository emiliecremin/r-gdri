library(dplyr)
library(sf)

source("common/helpers.R")

# https://www.wri.org/research/aqueduct-30-updated-decision-relevant-global-water-risk-indicators
# https://github.com/wri/aqueduct30_data_download/blob/master/metadata.md
locations <- st_read("data/ADMIN/admin.shp")
locations <- st_transform(locations, 4326)
aqueduct <- st_read("data/Water/Y2019M07D12_Aqueduct30_V01/baseline/annual/y2019m07d11_aqueduct30_annual_v01.gpkg")
aqueduct <- dplyr::filter(aqueduct, name_0 == "Vietnam")  %>% st_make_valid()
aqueduct_points <- st_centroid(locations) %>% st_join(aqueduct)
join_df <- st_drop_geometry(aqueduct_points[,c("GEOLEVEL2","gtd_score", "gtd_cat", "gtd_label")])
ground_watertable_decline <- joinOnColumn(join_df, locations, "GEOLEVEL2")
names(ground_watertable_decline)[names(ground_watertable_decline) == "gtd_score"] <- "val"
ground_watertable_decline$norm <- normalize_minmax(ground_watertable_decline$gtd_score, na.rm = TRUE)
st_write(ground_watertable_decline, "output/ecosystem_sensitivity/ES_DEG_GTD.gpkg", append = FALSE)