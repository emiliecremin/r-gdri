source("common/helpers.R")
source("common/social.R")

# sf::sf_use_s2(FALSE)
ipums_shp <- st_read("data/ADMIN/world_geolev2_2019/world_geolev2_2019.shp")
colnames(ipums_shp)[colnames(ipums_shp) == "GEOLEVEL2"] <- "GEOLEV2"

# ---------------------------------------------------- Vietnam - VNM
admin_vnm <- ipums_shp %>%
  dplyr::filter(CNTRY_NAME == "Vietnam") %>%
  st_make_valid()
admin_vnm$country_iso3 <- "VNM"
admin_vnm$adm2_area <- units::set_units(st_area(admin_vnm), km^2)
# TODO: use a more precise population count at village level
# https://international.ipums.org/international/gis_harmonized_2nd.shtml
pop_vnm <- read.csv(
  "data/Population/terra_pop/data_14582_IPUMS_VN_HSLAD_2009.csv"
)
pop_vnm$GEOLEV2 <- as.character(pop_vnm$GEO2_VN)
pop_vnm$pop <- pop_vnm$TOTPOP_GEO2_VN_VN2009A
pop_vnm <- pop_vnm[, c("GEOLEV2", "pop")]
admin_vnm <- dplyr::left_join(x = admin_vnm, y = pop_vnm, by = "GEOLEV2")
st_write(admin_vnm, "data/ADMIN/admin_vnm.gpkg", append = FALSE)
# Load IPUMS Social Census data
social_vnm <- load_social_data(admin_vnm)
# VNM Admin 3
# Hijmans, R. and University of California, Berkeley, Museum of Vertebrate Zoology.
# Third-level Administrative Divisions, Vietnam, 2015.
# UC Berkeley, Museum of Vertebrate Zoology.
# Available at: http://purl.stanford.edu/dk039bc2779
# https://stacks.stanford.edu/file/druid:dk039bc2779/data.zip?download=true
vnm_adm3 <- st_read(
  "data/ADMIN/VNM_adm3/VNM_adm3.shp"
) %>% st_transform(4326)
# geo_id must be at ADM4 level / keep GEOLEV2 for IPUMS
vnm_adm3$geo_id <- glue::glue(
  "{vnm_adm3$ID_1}-{vnm_adm3$ID_2}-{vnm_adm3$ID_3}"
)
vnm_i <- st_intersection(st_centroid(vnm_adm3), social_vnm)
# st_write(vnm_i, "data/ADMIN/vnm_i.gpkg", append = FALSE)
keep_cols <- c("geo_id", "GEOLEV2")
joint_codes <- vnm_i[, keep_cols] %>% st_drop_geometry()
vnm_villages <- vnm_adm3 %>%
  left_join(joint_codes, by = "geo_id") %>%
  left_join(st_drop_geometry(social_vnm), by = "GEOLEV2")
vnm_villages$area <- units::set_units(st_area(vnm_villages), km^2)
st_write(vnm_villages, "data/ADMIN/villages_vnm.gpkg", append = FALSE)
# -----------------------------------------------------------------------------

# Bangladesh - BGD ------------------------------------------------------------
admin_bgd <- ipums_shp %>%
  dplyr::filter(CNTRY_NAME == "Bangladesh") %>%
  st_make_valid()
admin_bgd$country_iso3 <- "BGD"
admin_bgd$GEOLEV2 <- str_remove(admin_bgd$GEOLEV2, "^0+")
admin_bgd$CNTRY_CODE <- str_remove(admin_bgd$CNTRY_CODE, "^0+")
admin_bgd$adm2_area <- units::set_units(st_area(admin_bgd), km^2)

# TODO: use a more precise population count at village level
# https://international.ipums.org/international/gis_harmonized_2nd.shtml
pop_bgd <- read.csv(
  "data/Population/terra_pop/data_14582_IPUMS_BD_HSLAD_1991_2011.csv"
)
pop_bgd$GEOLEV2 <- as.character(pop_bgd$GEO2_BD)
pop_bgd$pop <- pop_bgd$TOTPOP_GEO2_BD_BD2011A
pop_bgd <- pop_bgd[, c("GEOLEV2", "pop")]
admin_bgd <- dplyr::left_join(x = admin_bgd, y = pop_bgd, by = "GEOLEV2")
st_write(admin_bgd, "data/ADMIN/admin_bgd.gpkg", append = FALSE)
# Load IPUMS Social Census data
social_bgd <- load_social_data(admin_bgd)

# BGD Admin 4
# https://www.geoboundaries.org/
# Runfola D, Anderson A, Baier H, Crittenden M, Dowker E, Fuhrig S, et al. (2020) 
# geoBoundaries: A global database of political administrative boundaries. 
# PLoS ONE 15(4): e0231866. https://doi.org/10.1371/journal.pone.0231866. 
# https://media.githubusercontent.com/media/wmgeolab/geoBoundaries/9469f09592ced973a3448cf66b6100b741b64c0d/releaseData/gbOpen/BGD/ADM4/geoBoundaries-BGD-ADM4-all.zip
bgd_adm4 <- st_read(
  "data/ADMIN/geoBoundaries-BGD-ADM4-all/geoBoundaries-BGD-ADM4.shp"
) %>% st_transform(4326)
# geo_id must be at ADM4 level / keep GEOLEV2 for IPUMS
bgd_adm4$geo_id <- bgd_adm4$shapeID
bgd_i <- st_intersection(st_centroid(bgd_adm4), social_bgd)
keep_cols <- c("geo_id", "GEOLEV2")
joint_codes <- bgd_i[, keep_cols] %>% st_drop_geometry()
bgd_villages <- bgd_adm4 %>%
  left_join(joint_codes, by = "geo_id") %>%
  left_join(st_drop_geometry(social_bgd), by = "GEOLEV2")
bgd_villages$area <- units::set_units(st_area(bgd_villages), km^2)
st_write(bgd_villages, "data/ADMIN/villages_bgd.gpkg", append = FALSE)
# -----------------------------------------------------------------------------

# un_shp <- read_sf("data/ADMIN/vnm_adm_gov_20201027_shp/vnm_admbnda_adm2_gov_20201027.shp")
# join_shp <- st_centroid(ipums_shp) %>% st_join(un_shp)
# join_df <- st_drop_geometry(join_shp[, c("GEOLEV2", "ADM2_PCODE", "ADM2_EN")])
# admin_vnm <- joinOnColumn(join_df, ipums_shp, "GEOLEV2")
# other_shp <- st_centroid(un_shp) %>% st_join(ipums_shp)
# mismatch <- other_shp %>% filter(is.na(GEOLEV2))
# st_write(mismatch, str_glue("{output_dir}/mismatch.shp"))
# other source: https://data.apps.fao.org/catalog/organization/fao-region-mapping

# India - IND -----------------------------------------------------------------
source("common/admin_india.R")
# mapPlot(admin_ind, "pop", "persons", "Total Population")
