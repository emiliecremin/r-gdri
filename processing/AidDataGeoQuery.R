library(dplyr)
library(leaflet)
library(terra)
# Travel time to major cities
# http://geo.aiddata.org/query/#!/status/619eac2a2df858233d1962b2
travel_time_2015 <- read.csv(file = "data/TravelTime/VN ADM_3 GADM2.8 AccessCities2015/61a00be494ed730c9925bd38_results.csv")

gadm_file <- "data/ADMIN/gadm28.shp/gadm28.shp"
gadm_v <- terra::vect(gadm_file)
gadm_d <- as.data.frame(gadm_v)
gadm_vnm <- dplyr::filter(gadm_d, ISO == "VNM")
gadm_vnm_v <- subset(gadm_v, gadm_v$ISO == "VNM")

geolev2_file <- "data/shapefiles/world_geolev2_2019/world_geolev2_2019.shp"
geolev2_p <- vect(geolev2_file)
geolev2_d <- as.data.frame(geolev2_p)
geo_vnm <- dplyr::filter(geolev2_d, CNTRY_CODE == 704)

# Join IPUMS GEOLEV2 shp with GADM
geo_gadm_vnm <- merge(geo_vnm, gadm_vnm, by.x = "ADMIN_NAME", by.y = "VARNAME_2")

# ES_DES3
# Percentage of deforested area (%)
# Hansen et al. (2013) High-Resolution Global Maps of 21st-Century Forest Cover Change
# year_loss * 100 / count

# rename columns?
forest_cover_loss_2000_2020 <- read.csv(file = "data/Forests/VN ADM_3 GADM2.8 GlobalForestCoverLoss 2020/61a00f7b658cb64312252562_results.csv")
forest_cover_loss_2000_2020_geo_v <- merge(gadm_vnm_v, forest_cover_loss_2000_2020, by = "ID_3")
# filter for a year
# normalize
outfile <- "data/Forests/VN ADM_3 GADM2.8 GlobalForestCoverLoss 2020/forest_cover_loss_2000_2020_geo_vn.shp"
writeVector(forest_cover_loss_2000_2020_geo_v, outfile, overwrite = TRUE)
