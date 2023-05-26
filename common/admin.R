source("common/helpers.R")
source("common/coastal_buffer.R")

# sf::sf_use_s2(FALSE)
ipums_shp <- st_read("data/ADMIN/world_geolev2_2019/world_geolev2_2019.shp")
colnames(ipums_shp)[colnames(ipums_shp) == "GEOLEVEL2"] <- "GEOLEV2"

admin_vnm <- ipums_shp %>%
  dplyr::filter(CNTRY_NAME == "Vietnam") %>%
  st_make_valid()
admin_vnm$geo_id <- admin_vnm$GEOLEV2
admin_vnm$area <- units::set_units(st_area(admin_vnm), km^2)

# https://international.ipums.org/international/gis_harmonized_2nd.shtml
pop_vnm <- read.csv(
  "data/Population/terra_pop/data_14582_IPUMS_VN_HSLAD_2009.csv"
)
pop_vnm$GEOLEV2 <- as.character(pop_vnm$GEO2_VN)
pop_vnm$pop <- pop_vnm$TOTPOP_GEO2_VN_VN2009A
pop_vnm <- pop_vnm[, c("GEOLEV2", "pop")]
admin_vnm <- dplyr::left_join(x = admin_vnm, y = pop_vnm, by = "GEOLEV2")
# TODO: keep only useful columns
st_write(admin_vnm, "data/ADMIN/admin_vnm.gpkg", append = FALSE)

admin_vnm_with_buffer <- create_buffer(admin_vnm, "geo_id")
st_write(
  admin_vnm_with_buffer,
  "data/ADMIN/admin_vnm_with_buffer.gpkg",
  append = FALSE
)

admin_bgd <- ipums_shp %>%
  dplyr::filter(CNTRY_NAME == "Bangladesh") %>%
  st_make_valid()
admin_bgd$GEOLEV2 <- str_remove(admin_bgd$GEOLEV2, "^0+")
admin_bgd$CNTRY_CODE <- str_remove(admin_bgd$CNTRY_CODE, "^0+")
admin_bgd$geo_id <- admin_bgd$GEOLEV2
admin_bgd$area <- units::set_units(st_area(admin_bgd), km^2)

# https://international.ipums.org/international/gis_harmonized_2nd.shtml
pop_bgd <- read.csv(
  "data/Population/terra_pop/data_14582_IPUMS_BD_HSLAD_1991_2011.csv"
)
pop_bgd$GEOLEV2 <- as.character(pop_bgd$GEO2_BD)
pop_bgd$pop <- pop_bgd$TOTPOP_GEO2_BD_BD2011A
pop_bgd <- pop_bgd[, c("GEOLEV2", "pop")]
admin_bgd <- dplyr::left_join(x = admin_bgd, y = pop_bgd, by = "GEOLEV2")
# TODO: keep only useful columns
st_write(admin_bgd, "data/ADMIN/admin_bgd.gpkg", append = FALSE)

admin_bgd_with_buffer <- create_buffer(admin_bgd, "geo_id")
st_write(
  admin_bgd_with_buffer,
  "data/ADMIN/admin_bgd_with_buffer.gpkg",
  append = FALSE
)

# un_shp <- read_sf("data/ADMIN/vnm_adm_gov_20201027_shp/vnm_admbnda_adm2_gov_20201027.shp")
# join_shp <- st_centroid(ipums_shp) %>% st_join(un_shp)
# join_df <- st_drop_geometry(join_shp[, c("GEOLEV2", "ADM2_PCODE", "ADM2_EN")])
# admin_vnm <- joinOnColumn(join_df, ipums_shp, "GEOLEV2")
# other_shp <- st_centroid(un_shp) %>% st_join(ipums_shp)
# mismatch <- other_shp %>% filter(is.na(GEOLEV2))
# st_write(mismatch, str_glue("{output_dir}/mismatch.shp"))
# other source: https://data.apps.fao.org/catalog/organization/fao-region-mapping

admin_ind <- st_read(
  "data/ADMIN/India-village-boundaries/India-village-boundaries-AOI.shp"
) %>% st_make_valid()
admin_ind$geo_id <- admin_ind$C_CODE01
admin_ind$pop <- as.numeric(admin_ind$TOT_P)
admin_ind$area <- units::set_units(st_area(admin_ind), km^2)
admin_ind$density <- admin_ind$pop / as.numeric(admin_ind$area)

# TODO: keep only useful columns
st_write(admin_ind, "data/ADMIN/admin_ind.gpkg", append = FALSE)

# Buffer is missing some features, not very accurate for this roi
admin_ind_with_buffer <- create_buffer(admin_ind, "UID")
st_write(
  admin_ind_with_buffer,
  "data/ADMIN/admin_ind_with_buffer.gpkg",
  append = FALSE
)
# mapPlot(admin_ind, "pop", "persons", "Total Population")
