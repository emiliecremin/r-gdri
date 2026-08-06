source("common/install.R")
source("common/libraries.R")
source("common/helpers.R")

# If you have a slow internet connection increase the timeout
options(timeout = 1800) # set the timeout to 30 minutes

# ---------------------------------------------------------------
# DATA PREPARATION: run once to generate admin layers
# ---------------------------------------------------------------
source("common/admin.R")
source("common/land_cover.R")
source("common/aquaculture.R")
source("common/GFC.R")
# ---------------------------------------------------------------

vnm_villages <- st_read("objects/ADMIN/villages_vnm.gpkg")
bgd_villages <- st_read("objects/ADMIN/villages_bgd.gpkg")
ind_villages <- st_read("objects/ADMIN/villages_ind.gpkg")

# ---------------------------------------------------------------
# INDICATORS PER DATA SOURCE
# ---------------------------------------------------------------
source("processing/AidData.R")
source("processing/aqueduct.R")
source("processing/biodiversity.R")
source("processing/conservation.R")
source("processing/exposure/coastal_DEM.R")
source("processing/forest.R")
source("processing/free_flowing_rivers.R")
source("processing/osm.R")
source("processing/poverty.R")
source("processing/soil.R")
source("processing/SDG.R")
source("processing/travel_time.R")
source("processing/world_bank.R")

# CONSTANTS
cyclone_wind_speed <- 118 # km/h

# ---------------------------------------------------------------
# SOCIAL SUSCEPTIBILITY
# ---------------------------------------------------------------

source("processing/social_susceptibility/social_susceptibility.R")
mkdirs("output/social_susceptibility")

source("processing/vietnam_national.R")
soc_sus_vnm <- social_susceptibility(vnm_villages)
saveRDS(soc_sus_vnm, "output/social_susceptibility/social_susceptibility_VNM.rds")

source("processing/bangladesh_national.R")
soc_sus_bgd <- social_susceptibility(bgd_villages)
saveRDS(soc_sus_bgd, "output/social_susceptibility/social_susceptibility_BGD.rds")

source("processing/india_national.R")
soc_sus_ind <- social_susceptibility(ind_villages)
saveRDS(soc_sus_ind, "output/social_susceptibility/social_susceptibility_IND.rds")
soc_sus <- rbind(soc_sus_vnm, soc_sus_bgd, soc_sus_ind)

soc_sus_norm <- normalize(soc_sus)
n <- dplyr::select(st_drop_geometry(soc_sus_norm), ends_with("_norm"))
soc_sus_norm$SOC_MH <- rowMeans(n, na.rm = TRUE)
saveRDS(soc_sus_norm, "output/social_susceptibility/social_susceptibility.rds")
st_write(soc_sus_norm, "output/social_susceptibility/social_susceptibility.gpkg", append = FALSE)

# ---------------------------------------------------------------
# COPING AND ADAPTATION CAPACITY
# ---------------------------------------------------------------

source("processing/adaptation_capacities/adaptation_capacities.R")
mkdirs("output/adaptation_capacities")

source("processing/vietnam_national.R")
cop_adapt_vnm <- adaptation_capacities(vnm_villages)
# saveRDS(cop_adapt_vnm, "output/adaptation_capacities/adaptation_capacities_VNM.rds")

source("processing/bangladesh_national.R")
cop_adapt_bgd <- adaptation_capacities(bgd_villages)
# saveRDS(cop_adapt_bgd, "output/adaptation_capacities/adaptation_capacities_BGD.rds")

source("processing/india_national.R")
cop_adapt_ind <- adaptation_capacities(ind_villages)
# saveRDS(cop_adapt_ind, "output/adaptation_capacities/adaptation_capacities_IND.rds")

cop_adapt <- rbind(cop_adapt_vnm, cop_adapt_bgd, cop_adapt_ind)
cop_adapt_norm <- normalize(cop_adapt)
n <- dplyr::select(st_drop_geometry(cop_adapt_norm), ends_with("_norm"))
cop_adapt_norm$CA_MH <- rowMeans(n, na.rm = TRUE)
saveRDS(cop_adapt_norm, "output/adaptation_capacities/adaptation_capacities.rds")
st_write(cop_adapt_norm, "output/adaptation_capacities/adaptation_capacities.gpkg", append = FALSE)

"
# TODO: C_TRA2 Percentage of households without individual means of transportation: car or motorcycle
"

# ---------------------------------------------------------------
# ECOSYSTEM SENSITIVITY
# ---------------------------------------------------------------
source("processing/ecosystem_sensitivity/ecosystem_sensitivity.R")
mkdirs("output/ecosystem_sensitivity")

source("processing/vietnam_national.R")
eco_sensitivity_vnm <- ecosystem_sensitivity(vnm_villages)
# saveRDS(eco_sensitivity_vnm, "output/ecosystem_sensitivity/ecosystem_sensitivity_VNM.rds")
source("processing/bangladesh_national.R")
eco_sensitivity_bgd <- ecosystem_sensitivity(bgd_villages)
# saveRDS(eco_sensitivity_bgd, "output/ecosystem_sensitivity/ecosystem_sensitivity_BGD.rds")
source("processing/india_national.R")
eco_sensitivity_ind <- ecosystem_sensitivity(ind_villages)
# saveRDS(eco_sensitivity_ind, "output/ecosystem_sensitivity/ecosystem_sensitivity_IND.rds")
eco_sensitivity <- rbind(eco_sensitivity_vnm, eco_sensitivity_bgd, eco_sensitivity_ind)

eco_sensitivity_norm <- normalize(eco_sensitivity)
n <- dplyr::select(st_drop_geometry(eco_sensitivity_norm), ends_with("_norm"))
eco_sensitivity_norm$ES_MH <- rowMeans(n, na.rm = TRUE)
saveRDS(eco_sensitivity_norm, "output/ecosystem_sensitivity/ecosystem_sensitivity.rds")
st_write(eco_sensitivity_norm, "output/ecosystem_sensitivity/ecosystem_sensitivity.gpkg", append = FALSE)

# ---------------------------------------------------------------
# ECOSYSTEM ROBUSTNESS
# ---------------------------------------------------------------

source("processing/ecosystem_robustness/ecosystem_robustness.R")
mkdirs("output/ecosystem_robustness")

source("processing/vietnam_national.R")
eco_robustness_vnm <- ecosystem_robustness(vnm_villages)
# saveRDS(eco_robustness_vnm, "output/ecosystem_robustness/ecosystem_robustness_VNM.rds")
source("processing/bangladesh_national.R")
eco_robustness_bgd <- ecosystem_robustness(bgd_villages)
# saveRDS(eco_robustness_bgd, "output/ecosystem_robustness/ecosystem_robustness_BGD.rds")
source("processing/india_national.R")
eco_robustness_ind <- ecosystem_robustness(ind_villages)
# saveRDS(eco_robustness_ind, "output/ecosystem_robustness/ecosystem_robustness_IND.rds")
eco_robustness <- rbind(eco_robustness_vnm, eco_robustness_bgd, eco_robustness_ind)

eco_robustness_norm <- normalize(eco_robustness)
n <- dplyr::select(st_drop_geometry(eco_robustness_norm), ends_with("_norm"))
eco_robustness_norm$ER_MH <- rowMeans(n, na.rm = TRUE)
saveRDS(eco_robustness_norm, "output/ecosystem_robustness/ecosystem_robustness.rds")
st_write(eco_robustness_norm, "output/ecosystem_robustness/ecosystem_robustness.gpkg", append = FALSE)


# ---------------------------------------------------------------
# AGRICULTURE EXPOSURE
# ---------------------------------------------------------------

source("processing/exposure/agriculture_exposure.R")

agri_exposure_vnm <- agriculture_exposure(vnm_villages)
agri_exposure_bgd <- agriculture_exposure(bgd_villages)
agri_exposure_ind <- agriculture_exposure(ind_villages)
agri_exposure <- rbind(agri_exposure_vnm, agri_exposure_bgd, agri_exposure_ind)

agri_exposure_norm <- normalize(agri_exposure)

n <- dplyr::select(st_drop_geometry(agri_exposure_norm), ends_with("_norm"))
agri_exposure_norm$A_EXP_MH <- rowSums(n, na.rm = TRUE)
saveRDS(agri_exposure_norm, "output/exposure/agriculture_exposure.rds")
st_write(agri_exposure_norm, "output/exposure/agriculture_exposure.gpkg", append = FALSE)
write_xlsx(agri_exposure_norm %>% st_drop_geometry(), path = "output/exposure/agri_exposure.xlsx")

# ---------------------------------------------------------------
# AQUACULTURE EXPOSURE
# ---------------------------------------------------------------

source("processing/exposure/aquaculture_exposure.R")

aquaculture_exposure_vnm <- aquaculture_exposure(vnm_villages)
aquaculture_exposure_bgd <- aquaculture_exposure(bgd_villages)
aquaculture_exposure_ind <- aquaculture_exposure(ind_villages)
aquaculture_exposure <- rbind(aquaculture_exposure_vnm, aquaculture_exposure_bgd, aquaculture_exposure_ind)

aquaculture_exposure_norm <- normalize(aquaculture_exposure)

n <- dplyr::select(st_drop_geometry(aquaculture_exposure_norm), ends_with("_norm"))
aquaculture_exposure_norm$AQ_EXP_MH <- rowSums(n, na.rm = TRUE)
saveRDS(aquaculture_exposure_norm, "output/exposure/aquaculture_exposure.rds")
st_write(aquaculture_exposure_norm, "output/exposure/aquaculture_exposure.gpkg", append = FALSE)
write_xlsx(aquaculture_exposure_norm %>% st_drop_geometry(), path = "output/exposure/aquaculture_exposure.xlsx")

# ---------------------------------------------------------------
# AREA EXPOSURE
# ---------------------------------------------------------------

source("processing/exposure/area_exposure.R")

area_exposure_vnm <- area_exposure(vnm_villages)
area_exposure_bgd <- area_exposure(bgd_villages)
area_exposure_ind <- area_exposure(ind_villages)
area_exposure <- rbind(area_exposure_vnm, area_exposure_bgd, area_exposure_ind)

area_exposure_norm <- normalize(area_exposure)

n <- dplyr::select(st_drop_geometry(area_exposure_norm), ends_with("_norm"))
area_exposure_norm$AREA_EXP_MH <- rowSums(n, na.rm = TRUE)
saveRDS(area_exposure_norm, "output/exposure/area_exposure.rds")
st_write(area_exposure_norm, "output/exposure/area_exposure.gpkg", append = FALSE)
write_xlsx(area_exposure_norm %>% st_drop_geometry(), path = "output/exposure/area_exposure.xlsx")

# ---------------------------------------------------------------
# BUILT UP EXPOSURE
# ---------------------------------------------------------------

source("processing/exposure/built_exposure.R")

built_exposure_vnm <- built_exposure(vnm_villages)
built_exposure_bgd <- built_exposure(bgd_villages)
built_exposure_ind <- built_exposure(ind_villages)
built_exposure <- rbind(built_exposure_vnm, built_exposure_bgd, built_exposure_ind)

built_exposure_norm <- normalize(built_exposure)

n <- dplyr::select(st_drop_geometry(built_exposure_norm), ends_with("_norm"))
built_exposure_norm$B_EXP_MH <- rowSums(n, na.rm = TRUE)
saveRDS(built_exposure_norm, "output/exposure/built_exposure.rds")
st_write(built_exposure_norm, "output/exposure/built_exposure.gpkg", append = FALSE)
write_xlsx(built_exposure_norm %>% st_drop_geometry(), path = "output/exposure/built_exposure.xlsx")

# ---------------------------------------------------------------
# ECOSYSTEM EXPOSURE
# ---------------------------------------------------------------

source("processing/exposure/ecosystem_exposure.R")
mkdirs("output/exposure")

eco_exposure_vnm <- ecosystems_exposure(vnm_villages)
eco_exposure_bgd <- ecosystems_exposure(bgd_villages)
eco_exposure_ind <- ecosystems_exposure(ind_villages)
eco_exposure <- rbind(eco_exposure_vnm, eco_exposure_bgd, eco_exposure_ind)

eco_exposure_norm <- normalize(eco_exposure)

n <- dplyr::select(st_drop_geometry(eco_exposure_norm), ends_with("_norm"))
eco_exposure_norm$E_EXP_MH <- rowSums(n, na.rm = TRUE)
saveRDS(eco_exposure_norm, "output/exposure/ecosystem_exposure.rds")
st_write(eco_exposure_norm, "output/exposure/ecosystem_exposure.gpkg", append = FALSE)
write_xlsx(eco_exposure_norm %>% st_drop_geometry(), path = "output/exposure/eco_exposure.xlsx")

# ---------------------------------------------------------------
# POPULATION EXPOSURE
# ---------------------------------------------------------------

source("processing/exposure/pop_exposure.R")
mkdirs("output/exposure")

pop_exposure_vnm <- population_exposure(vnm_villages)
pop_exposure_bgd <- population_exposure(bgd_villages)
pop_exposure_ind <- population_exposure(ind_villages)
pop_exposure <- rbind(pop_exposure_vnm, pop_exposure_bgd, pop_exposure_ind)

pop_exposure_norm <- normalize(pop_exposure)

n <- dplyr::select(st_drop_geometry(pop_exposure_norm), ends_with("_norm"))
pop_exposure_norm$POP_EXP_MH <- rowSums(n, na.rm = TRUE)
saveRDS(pop_exposure_norm, "output/exposure/pop_exposure.rds")
st_write(pop_exposure_norm, "output/exposure/pop_exposure.gpkg", append = FALSE)
write_xlsx(pop_exposure_norm %>% st_drop_geometry(), path = "output/exposure/pop_exposure.xlsx")

# # ---------------------------------------------------------------
# # SOCIAL EXPOSURE
# # ---------------------------------------------------------------

# source("processing/exposure/social_exposure.R")

# soc_exposure_vnm <- social_exposure(vnm_villages)
# soc_exposure_bgd <- social_exposure(bgd_villages)
# soc_exposure_ind <- social_exposure(ind_villages)
# soc_exposure <- rbind(soc_exposure_vnm, soc_exposure_bgd, soc_exposure_ind)

# soc_exposure_norm <- normalize(soc_exposure)

# n <- dplyr::select(st_drop_geometry(soc_exposure_norm), ends_with("_norm"))
# soc_exposure_norm$S_EXP_MH <- rowMeans(n, na.rm = TRUE)
# saveRDS(soc_exposure_norm, "output/exposure/social_exposure.rds")
# st_write(soc_exposure_norm, "output/exposure/social_exposure.gpkg", append = FALSE)

soc_sus_norm <- readRDS("output/social_susceptibility/social_susceptibility.rds")
cop_adapt_norm <- readRDS("output/adaptation_capacities/adaptation_capacities.rds")
eco_sensitivity_norm <- readRDS("output/ecosystem_sensitivity/ecosystem_sensitivity.rds")
eco_robustness_norm <- readRDS("output/ecosystem_robustness/ecosystem_robustness.rds")
agri_exposure_norm <- readRDS("output/exposure/agriculture_exposure.rds")
aquaculture_exposure_norm <- readRDS("output/exposure/aquaculture_exposure.rds")
area_exposure_norm <- readRDS("output/exposure/area_exposure.rds")
built_exposure_norm <- readRDS("output/exposure/built_exposure.rds")
eco_exposure_norm <- readRDS("output/exposure/ecosystem_exposure.rds")
pop_exposure_norm <- readRDS("output/exposure/pop_exposure.rds")
# soc_exposure_norm <- readRDS("output/exposure/social_exposure.rds")

gdri <- cbind(
    soc_sus_norm,
    cop_adapt_norm,
    eco_sensitivity_norm,
    eco_robustness_norm,
    agri_exposure_norm,
    aquaculture_exposure_norm,
    area_exposure_norm,
    built_exposure_norm,
    eco_exposure_norm,
    pop_exposure_norm
    # soc_exposure_norm
)

gdri$SES_SUS_MH <- (gdri$SOC_MH + gdri$ES_MH) / 2
gdri$SES_CA_MH <- (gdri$CA_MH + gdri$ER_MH) / 2
gdri$SES_VU_MH <- (gdri$SES_SUS_MH + gdri$SES_CA_MH) / 2
# gdri$SES_VU_MH <- rowMeans(subset(gdri, select = c(SES_SUS_MH, SES_CA_MH)), na.rm = TRUE)

# gdri$SES_EXP_MH <- (gdri$S_EXP_MH + gdri$E_EXP_MH + gdri$A_EXP_MH + gdri$AQ_EXP_MH) / 4

# gdri$RISK_MH <- gdri$SES_VU_MH * gdri$SES_EXP_MH

target_col_names <- c(
    "geo_id",
    "CNTRY_NAME",
    "country_iso3",
    "adm1_name",
    "adm2_name",
    "adm3_name",
    "adm4_name",
    "Name",
    "adm_level",
    "pop",
    "area"
)
# Step 1: Get all column names
all_cols <- names(gdri)
# Step 2: Identify columns with '.' in their names
cols_with_dot <- all_cols[grepl("\\.", all_cols)]
# Step 3: Get the geometry column name
geom_col <- attr(gdri, "sf_column")
# Step 4: Exclude geometry column from removal
cols_to_remove <- setdiff(cols_with_dot, geom_col)
# Step 5: Remove columns with '.' in their names
sf_object_clean <- gdri[, !(names(gdri) %in% cols_to_remove)]
# Exclude geometry column from the reordering process
non_geom_cols <- setdiff(names(sf_object_clean), geom_col)
# Columns not in the desired list
other_cols <- setdiff(non_geom_cols, target_col_names)
# Combine columns: desired columns first, then other columns, then geometry column
new_col_order <- c(target_col_names, other_cols, geom_col)
# Reorder the sf_object using the new column order
sf_object_reordered <- sf_object_clean[, new_col_order]

st_write(sf_object_reordered, "output/gdri.gpkg", append = FALSE)
write_xlsx(sf_object_reordered %>% st_drop_geometry(), path = "output/gdri.xlsx")
