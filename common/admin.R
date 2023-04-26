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
population <- read.csv(
  "data/Population/terra_pop/data_14582_IPUMS_VN_HSLAD_2009.csv"
)
population$GEOLEV2 <- as.character(population$GEO2_VN)
population$pop <- population$TOTPOP_GEO2_VN_VN2009A
population <- population[, c("GEOLEV2", "pop")]
admin_vnm <- dplyr::left_join(x = admin_vnm, y = population, by = "GEOLEV2")
st_write(admin_vnm, "data/ADMIN/admin_vnm.gpkg", append = FALSE)

admin_vnm_with_buffer <- create_buffer(admin_vnm, "geo_id")
st_write(
  admin_vnm_with_buffer,
  "data/ADMIN/admin_vnm_with_buffer.gpkg",
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
  "data/ADMIN/India-village-boundaries/India-village-boundaries-Dselect.shp"
) %>% st_make_valid()
admin_ind$geo_id <- admin_ind$C_CODE01
# admin_ind$area <- units::set_units(st_area(admin_ind), km^2)
admin_ind$pop <- admin_ind$TOT_P
st_write(admin_ind, "data/ADMIN/admin_ind.gpkg", append = FALSE)

admin_ind_with_buffer <- create_buffer(admin_ind, "geo_id")
st_write(
  admin_ind_with_buffer,
  "data/ADMIN/admin_ind_with_buffer.gpkg",
  append = FALSE
)
admin_ind$TOT_P <- as.numeric(admin_ind$TOT_P)
admin_ind$area <- units::set_units(st_area(admin_ind), km^2)
admin_ind$density <- admin_ind$TOT_P / as.numeric(admin_ind$area)
mapPlot(admin_ind, "TOT_P", "persons", "Total Population")
