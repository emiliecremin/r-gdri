source("common/helpers.R")

# sf::sf_use_s2(FALSE)
ipums_shp <- st_read("data/ADMIN/world_geolev2_2019/world_geolev2_2019.shp")
colnames(ipums_shp)[colnames(ipums_shp) == "GEOLEVEL2"] <- "GEOLEV2"

mkdirs("objects/ADMIN")

# ---------------------------------------------------- Vietnam - VNM
get_vnm_villages <- function() {
  admin_vnm <- ipums_shp %>%
    dplyr::filter(CNTRY_NAME == "Vietnam") %>%
    st_make_valid() %>%
    st_transform(4326)
  admin_vnm$adm2_name <- admin_vnm$ADMIN_NAME
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

  # VNM Admin 3
  # Hijmans, R. and University of California, Berkeley, Museum of Vertebrate Zoology.
  # Third-level Administrative Divisions, Vietnam, 2015.
  #  UC Berkeley, Museum of Vertebrate Zoology.
  # Available at: http://purl.stanford.edu/dk039bc2779
  # https://stacks.stanford.edu/file/druid:dk039bc2779/data.zip?download=true
  vnm_adm3 <- st_read(
    "data/ADMIN/VNM_adm3/VNM_adm3.shp"
  ) %>% st_transform(4326)
  # geo_id must be at ADM4 level / keep GEOLEV2 for IPUMS
  vnm_adm3$geo_id <- glue::glue(
    "{vnm_adm3$ID_1}-{vnm_adm3$ID_2}-{vnm_adm3$ID_3}"
  )

  # 1. Assign each commune to the IPUMS ADM2 with the largest area overlap
  # (centroid-in-polygon misassigns communes on district boundaries because the
  # GADM 2015 and IPUMS 2009 borders differ slightly).
  # S2 is switched off only here: planar intersection is much faster, and the
  # choice depends only on the relative overlap of candidate districts.
  vnm_adm3_2 <- local({
    s2_prev <- sf_use_s2(FALSE)
    on.exit(sf_use_s2(s2_prev))
    st_intersection(
      st_make_valid(vnm_adm3) %>% dplyr::select(geo_id, NAME_2),
      admin_vnm %>% dplyr::select(GEOLEV2)
    ) %>%
      mutate(overlap = as.numeric(st_area(.))) %>%
      st_drop_geometry() %>%
      group_by(geo_id) %>%
      slice_max(overlap, n = 1, with_ties = FALSE) %>%
      ungroup() %>%
      filter(!NAME_2 == "Tuy Phước")
  })
  # Phụng Hiệp commune lies 49.5/50.5% in Phụng Hiệp/Ngã Bảy: keep the district it is named after
  vnm_adm3_2$GEOLEV2[vnm_adm3_2$geo_id == "31-333-4931"] <- "704093001"
  # Tuy Phước special case this is not matched to the right place
  not_contained <- vnm_adm3 %>% filter(!geo_id %in% vnm_adm3_2$geo_id)

  # 2. Matching on the ADM2 Name from both sides
  # Strip accents to ease the matching
  not_contained$NAME_2_i <- stringi::stri_trans_general(
    not_contained$NAME_2,
    id = "Latin-ASCII"
  )
  # Address mismatching names
  admin_vnm$ADMIN_NAME <- str_replace(admin_vnm$ADMIN_NAME, ", Mong Cai", "")
  admin_vnm$ADMIN_NAME <- str_replace(admin_vnm$ADMIN_NAME, "Thanh pho ", "")
  setdiff(not_contained$NAME_2_i, admin_vnm$ADMIN_NAME)
  f_joined <- not_contained %>%
    collapse::join(
      admin_vnm %>% st_drop_geometry(),
      on = c("NAME_2_i" = "ADMIN_NAME")
    ) %>%
    st_as_sf()
  matching <- f_joined %>%
    filter(!is.na(CNTRY_NAME)) %>%
    st_drop_geometry() %>%
    dplyr::select(geo_id, GEOLEV2)
  not_matching <- f_joined %>%
    filter(is.na(CNTRY_NAME)) %>%
    dplyr::select(geo_id, NAME_3)

  # 3. Use the nearest ADM2 for the remaining 2 mismatching villages
  nearest <- st_join(
    not_matching,
    admin_vnm,
    join = st_nearest_feature
  ) %>%
    st_drop_geometry() %>%
    dplyr::select(geo_id, GEOLEV2)

  # Bind the results of 1. spatial join, 2. name matching and 3. nearest feature
  contained <- vnm_adm3_2 %>%
    st_drop_geometry() %>%
    dplyr::select(geo_id, GEOLEV2)
  join_3_2 <- rbind(contained, matching, nearest)

  # Use the joining table to map both sides
  vnm_villages <- vnm_adm3 %>% collapse::join(
    join_3_2,
    on = "geo_id"
  )
  vnm_villages <- vnm_villages %>%
    collapse::join(
      admin_vnm %>% st_drop_geometry(),
      on = "GEOLEV2"
    ) %>%
    st_as_sf()
  vnm_villages$country_iso3 <- "VNM"
  vnm_villages$adm1_name <- vnm_villages$NAME_1
  # GADM 2015 NAME_2 predates district splits: relabel communes whose IPUMS 2009
  # unit is the newer district (accents kept)
  adm2_label <- c(
    "704026008" = "Sông Lô", "704031012" = "Dương Kinh",
    "704093006" = "Ngã Bảy", "704092005" = "Thới Lai"
  )
  vnm_villages$adm2_name <- vnm_villages$NAME_2
  relabel <- as.character(vnm_villages$GEOLEV2) %in% names(adm2_label)
  vnm_villages$adm2_name[relabel] <- adm2_label[as.character(vnm_villages$GEOLEV2[relabel])]
  vnm_villages$adm3_name <- vnm_villages$NAME_3
  vnm_villages$adm4_name <- NA
  vnm_villages$Name <- vnm_villages$NAME_3
  vnm_villages$adm_level <- "ADM3"
  vnm_villages$area <- units::set_units(st_area(vnm_villages), km^2)
  st_write(vnm_villages, "objects/ADMIN/villages_vnm.gpkg", append = FALSE)
  return(vnm_villages)
}
vnm_villages <- get_vnm_villages()
# -----------------------------------------------------------------------------

# Bangladesh - BGD ------------------------------------------------------------
get_bgd_villages <- function() {
  ipums_bgd <- ipums_shp %>%
    dplyr::filter(CNTRY_NAME == "Bangladesh") %>%
    st_make_valid() %>%
    st_transform(4326)
  ipums_bgd$GEOLEV2 <- str_remove(ipums_bgd$GEOLEV2, "^0+")
  ipums_bgd$CNTRY_CODE <- str_remove(ipums_bgd$CNTRY_CODE, "^0+")

  # TODO: use a more precise population count at village level
  # https://international.ipums.org/international/gis_harmonized_2nd.shtml
  pop_bgd <- read.csv(
    "data/Population/terra_pop/data_14582_IPUMS_BD_HSLAD_1991_2011.csv"
  )
  pop_bgd$GEOLEV2 <- as.character(pop_bgd$GEO2_BD)
  pop_bgd$pop <- pop_bgd$TOTPOP_GEO2_BD_BD2011A
  pop_bgd <- pop_bgd[, c("GEOLEV2", "pop")]
  ipums_bgd <- dplyr::left_join(x = ipums_bgd, y = pop_bgd, by = "GEOLEV2")
  st_write(ipums_bgd, "data/ADMIN/admin_bgd.gpkg", append = FALSE)

  # BGD Admin 4
  # https://www.geoboundaries.org/
  # Runfola D, Anderson A, Baier H, Crittenden M, Dowker E, Fuhrig S, et al. (2020)
  # geoBoundaries: A global database of political administrative boundaries.
  # PLoS ONE 15(4): e0231866. https://doi.org/10.1371/journal.pone.0231866.
  # https://media.githubusercontent.com/media/wmgeolab/geoBoundaries/9469f09592ced973a3448cf66b6100b741b64c0d/releaseData/gbOpen/BGD/ADM4/geoBoundaries-BGD-ADM4-all.zip
  bgd_adm2 <- st_read(
    "data/ADMIN/geoBoundaries-BGD-ADM2-all/geoBoundaries-BGD-ADM2.shp"
  ) %>% st_transform(4326)
  bgd_adm2$adm1_name <- NA
  bgd_adm2$adm2_name <- bgd_adm2$shapeName
  bgd_adm2$adm2_area <- units::set_units(st_area(bgd_adm2), km^2)
  bgd_adm4 <- st_read(
    "data/ADMIN/geoBoundaries-BGD-ADM4-all/geoBoundaries-BGD-ADM4.shp"
  ) %>% st_transform(4326)
  # geo_id must be at ADM4 level / keep GEOLEV2 for IPUMS
  bgd_adm4$geo_id <- bgd_adm4$shapeID
  bgd_adm4$adm3_name <- NA
  bgd_adm4$adm4_name <- bgd_adm4$shapeName
  bgd_adm4$Name <- bgd_adm4$shapeName
  bgd_adm4$adm_level <- "ADM4"
  bgd_adm4$country_iso3 <- "BGD"
  bgd_adm4$area <- units::set_units(st_area(bgd_adm4), km^2)

  # 1. Spatial join to find villages within the IPUMS ADM2 boundaries
  bgd_adm_2_4 <- st_join(
    bgd_adm2 %>% dplyr::select(!starts_with("shape")),
    bgd_adm4,
    join = st_contains
  ) %>%
    st_drop_geometry() %>%
    dplyr::select(shapeID, adm2_name)
  not_contained <- bgd_adm4 %>% filter(!shapeID %in% bgd_adm_2_4$shapeID)

  # 2. Spatial join using the centroid of the villages
  contain <- st_join(
    bgd_adm2 %>% dplyr::select(!starts_with("shape")),
    st_centroid(not_contained),
    join = st_contains
  ) %>%
    filter(!is.na(shapeID)) %>%
    dplyr::select(shapeID, adm2_name) %>%
    st_drop_geometry()

  # 3. Bind the matching results
  setdiff(colnames(bgd_adm_2_4), colnames(contain))
  setdiff(colnames(contain), colnames(bgd_adm_2_4))
  join_adm_2_4 <- rbind(bgd_adm_2_4, contain)
  nrow(join_adm_2_4)
  bgd_2_4 <- bgd_adm4 %>%
    collapse::join(join_adm_2_4, on = "shapeID") %>%
    st_as_sf()

  # 4. Matching on the ADM2 Name from both sides
  # Address mismatching names
  ipums_bgd[ipums_bgd$ADMIN_NAME == "Chapai Nababganj", "ADMIN_NAME"] <- "Nawabganj"
  ipums_bgd[ipums_bgd$ADMIN_NAME == "Jhenaidaha", "ADMIN_NAME"] <- "Jhenaidah"
  ipums_bgd[ipums_bgd$ADMIN_NAME == "Maulvi Bazar", "ADMIN_NAME"] <- "Maulvibazar"
  ipums_bgd[ipums_bgd$ADMIN_NAME == "Netrokona", "ADMIN_NAME"] <- "Netrakona"
  ipums_bgd[ipums_bgd$ADMIN_NAME == "Brahmanbaria", "ADMIN_NAME"] <- "Brahamanbaria"
  bgd_2_4 <- bgd_2_4 %>%
    collapse::join(
      ipums_bgd %>% st_drop_geometry(),
      on = c("adm2_name" = "ADMIN_NAME")
    ) %>%
    st_as_sf()

  # 5. Fill missing adm1_name and adm3_name from full admin list (complete.csv)
  complete <- read_excel("objects/ADMIN/bgd_adminboundaries_tabulardata.xlsx")
  complete_one <- complete %>%
    dplyr::distinct(ADM2_EN, ADM4_EN, .keep_all = TRUE) %>%
    dplyr::select(ADM2_EN, ADM4_EN, ADM1_EN, ADM3_EN)
  bgd_villages <- bgd_2_4 %>%
    dplyr::left_join(complete_one, by = c("adm2_name" = "ADM2_EN", "adm4_name" = "ADM4_EN")) %>%
    dplyr::mutate(
      adm1_name = dplyr::coalesce(adm1_name, ADM1_EN),
      adm3_name = dplyr::coalesce(adm3_name, ADM3_EN)
    ) %>%
    dplyr::select(-ADM1_EN, -ADM3_EN)

  bgd_villages$country_iso3 <- "BGD"
  st_write(bgd_villages, "objects/ADMIN/villages_bgd.gpkg", append = FALSE)
  write.csv(bgd_villages %>% st_drop_geometry(), "objects/ADMIN/bgd_villages.csv", row.names = FALSE)
  return(bgd_villages)
}
bgd_villages <- get_bgd_villages()
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
ind_villages <- get_ind_villages()
# mapPlot(admin_ind, "pop", "persons", "Total Population")

rm(ipums_shp)
