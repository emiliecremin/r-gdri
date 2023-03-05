install.packages("lwgeom")
library(sf)
library(dplyr)

sf::sf_use_s2(FALSE)
ipums_shp <- st_read("data/ADMIN/world_geolev2_2019/world_geolev2_2019.shp")
ipums_shp <- ipums_shp %>% dplyr::filter(CNTRY_NAME == "Vietnam")
un_shp <- read_sf("data/ADMIN/vnm_adm_gov_20201027_shp/vnm_admbnda_adm2_gov_20201027.shp")

join_shp <- st_centroid(ipums_shp) %>% st_join(un_shp)
join_df <- st_drop_geometry(join_shp[,c("GEOLEVEL2","ADM2_PCODE", "ADM2_EN")])
admin_shp <- joinOnColumn(join_df, ipums_shp, "GEOLEVEL2")
admin_shp$GEOLEV2 <- admin_shp$GEOLEVEL2
admin_shp$area <- units::set_units(st_area(admin_shp), km^2)

# https://international.ipums.org/international/gis_harmonized_2nd.shtml
population <- read.csv(file="data/Population/terra_pop/data_14582_IPUMS_VN_HSLAD_2009.csv")
population$GEOLEV2 <- as.character(population$GEO2_VN)
population$pop <- population$TOTPOP_GEO2_VN_VN2009A
population <- population[,c("GEOLEV2","pop")]
admin_shp <- admin_shp %>% 
  dplyr::inner_join(y = population, by = "GEOLEV2")

# other_shp <- st_centroid(un_shp) %>% st_join(ipums_shp)
# mismatch <- other_shp %>% filter(is.na(GEOLEVEL2))
# st_write(mismatch, str_glue("{output_dir}/mismatch.shp"))
count(admin_shp)

