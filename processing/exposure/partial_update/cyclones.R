
source("common/libraries.R")
source("common/helpers.R")

cyclone_wind_speed <- 118 # km/h

exposure_files <- setdiff(
    list.files("processing/exposure", pattern = "\\.R$", full.names = TRUE),
    c("processing/exposure/cyclones.R",
    "processing/exposure/salinity.R")
)
invisible(lapply(exposure_files, source))

keep_cols <- c(
    "geo_id",
    "country_iso3",
    "CNTRY_NAME",
    "adm1_name",
    "adm2_name",
    "adm3_name",
    "adm4_name",
    "adm_level",
    "Name",
    "pop",
    "world_pop",
    "area",
    "agri_km2",
    "aqua_km2",
    "ecosys_km2",
    "built_km2"
)

get_exposure <- function(locations) {
    locations <- locations[, (names(locations) %in% keep_cols)]
    cat("POP_EXP_CYC \n")
    pop_exp_cyc <- POP_EXP_CYC(locations)
    locations$POP_EXP_CYC_cnt <- pop_exp_cyc$cnt
    locations$POP_EXP_CYC_val <- pop_exp_cyc$val

    cat("A_INT_CYC \n")
    locations$A_INT_CYC_val <- A_INT_CYC(locations)$val
    cat("A_AFF_CYC \n")
    a_exp_cyc <- A_AFF_CYC(locations)
    locations$A_AFF_CYC_cnt <- a_exp_cyc$cnt
    locations$A_AFF_CYC_val <- a_exp_cyc$val

    cat("AQ_INT_CYC \n")
    locations$AQ_INT_CYC_val <- AQ_INT_CYC(locations)$val
    cat("AQ_AFF_CYC \n")
    a_exp_cyc <- AQ_AFF_CYC(locations)
    locations$AQ_AFF_CYC_cnt <- a_exp_cyc$cnt
    locations$AQ_AFF_CYC_val <- a_exp_cyc$val

    cat("E_INT_CYC \n")
    locations$E_INT_CYC_val <- E_INT_CYC(locations)$val
    cat("E_AFF_CYC \n")
    e_exp_cyc <- E_AFF_CYC(locations)
    locations$E_AFF_CYC_cnt <- e_exp_cyc$cnt
    locations$E_AFF_CYC_val <- e_exp_cyc$val
    return(locations)
}

cyc_dir <- glue::glue("output/CYC_{cyclone_wind_speed}km")
mkdirs(cyc_dir)

locations <- st_read("objects/ADMIN/villages_bgd.gpkg")
locations$country_iso3 <- "BGD"
locations$CNTRY_NAME <- "Bangladesh"
locations <- get_exposure(locations)
write.csv(
    locations %>% st_drop_geometry(),
    glue::glue("{cyc_dir}/bgd_cyc_locations.csv")
)

locations <- st_read("objects/ADMIN/villages_vnm.gpkg")
locations <- get_exposure(locations)
write.csv(
    locations %>% st_drop_geometry(),
    glue::glue("{cyc_dir}/vnm_cyc_locations.csv")
)

locations <- st_read("objects/ADMIN/villages_ind.gpkg")
locations <- get_exposure(locations)
write.csv(
    locations %>% st_drop_geometry(),
    glue::glue("{cyc_dir}/ind_cyc_locations.csv")
)


# vnm <- st_read("objects/ADMIN/villages_vnm.gpkg")
# vnm_cyc_150 <- read.csv("output/CYC_150km/vnm_cyc_locations.csv")
# vnm_cyc_150 <- vnm %>% joinOnColumn(vnm_cyc_150, "geo_id")
# vnm_cyc_118 <- read.csv("output/CYC_118km/vnm_cyc_locations.csv")
# vnm_cyc_118 <- vnm %>% joinOnColumn(vnm_cyc_118, "geo_id")

quick_map(locations, "POP_EXP_CYC_val")
quick_map(locations, "POP_EXP_CYC_val")
quick_map(locations, "POP_EXP_CYC_cnt")

quick_map(locations, "A_INT_CYC_val")
quick_map(locations, "A_AFF_CYC_val")
quick_map(locations, "A_AFF_CYC_cnt")

quick_map(locations, "E_INT_CYC_val")
quick_map(locations, "E_AFF_CYC_val")
quick_map(locations, "E_AFF_CYC_cnt")
