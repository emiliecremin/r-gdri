library(dplyr)
library(sf)
# https://edo.jrc.ec.europa.eu/gdo/php/index.php?id=2112
# SPI: https://edo.jrc.ec.europa.eu/documents/factsheets/factsheet_spi.pdf
# https://edo.jrc.ec.europa.eu/gdo/php/index.php?id=2001

# https://energydata.info/dataset/global-drought-hazard-0

# https://resourcewatch.org/data/explore/cli023-Standard-Precipitation-Index
# https://resourcewatch.org/data/explore/wat057-Aqueduct-Drought-Risk
# https://resourcewatch.org/data/explore/foo_058_SMAP_soil_moisture

# https://www.sciencedirect.com/science/article/pii/S0959378016300565#bib0420

# https://www.wri.org/research/aqueduct-30-updated-decision-relevant-global-water-risk-indicators
# https://github.com/wri/aqueduct30_data_download/blob/master/metadata.md
locations <- st_read("data/ADMIN/admin.shp")
locations <- st_transform(locations, 4326)
drought <- st_read("data/Water/Y2019M07D12_Aqueduct30_V01/baseline/annual/y2019m07d11_aqueduct30_annual_v01.gpkg")
drought <- dplyr::filter(drought, name_0 == "Vietnam")  %>% st_make_valid()
drought_points <- st_centroid(locations) %>% st_join(drought)
join_df <- st_drop_geometry(drought_points[,c("GEOLEVEL2","drr_score", "drr_cat", "drr_label")])
drought_shp <- joinOnColumn(join_df, locations, "GEOLEVEL2")
drought_shp$freq <- drought_shp$drr_score * drought_shp$pop
drought_shp$norm <- normalize_minmax(drought_shp$freq, na.rm = TRUE)
st_write(drought_shp, "output/S_EXP_DRO_drought_risk.gpkg", append = FALSE)
