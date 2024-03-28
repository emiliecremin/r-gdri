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
source("processing/aqueduct.R")
source("processing/biodiversity.R")
source("processing/conservation.R")
source("processing/forest.R")
source("processing/free_flowing_rivers.R")
source("processing/osm.R")
source("processing/travel_time.R")
source("processing/world_bank.R")

# ---------------------------------------------------------------
# SOCIAL SUSCEPTIBILITY
# ---------------------------------------------------------------

source("processing/social_susceptibility/social_susceptibility.R")

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

# TODO: S_ECO1 Percentage of population below national poverty line (%) - to do

# ---------------------------------------------------------------
# COPING AND ADAPTATION CAPACITY
# ---------------------------------------------------------------

source("processing/adaptation_capacities/adaptation_capacities.R")

source("processing/vietnam_national.R")
cop_adapt_vnm <- adaptation_capacities(vnm_villages)
saveRDS(cop_adapt_vnm, "output/adaptation_capacities/adaptation_capacities_VNM.rds")
source("processing/bangladesh_national.R")
cop_adapt_bgd <- adaptation_capacities(bgd_villages)
saveRDS(cop_adapt_bgd, "output/adaptation_capacities/adaptation_capacities_BGD.rds")
source("processing/india_national.R")
cop_adapt_ind <- adaptation_capacities(ind_villages)
saveRDS(cop_adapt_ind, "output/adaptation_capacities/adaptation_capacities_IND.rds")
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

source("processing/vietnam_national.R")
eco_sensitivity_vnm <- ecosystem_sensitivity(vnm_villages)
saveRDS(eco_sensitivity_vnm, "output/ecosystem_sensitivity/ecosystem_sensitivity_VNM.rds")
source("processing/bangladesh_national.R")
eco_sensitivity_bgd <- ecosystem_sensitivity(bgd_villages)
saveRDS(eco_sensitivity_bgd, "output/ecosystem_sensitivity/ecosystem_sensitivity_BGD.rds")
source("processing/india_national.R")
eco_sensitivity_ind <- ecosystem_sensitivity(ind_villages)
saveRDS(eco_sensitivity_ind, "output/ecosystem_sensitivity/ecosystem_sensitivity_IND.rds")
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

source("processing/vietnam_national.R")
eco_robustness_vnm <- ecosystem_robustness(vnm_villages)
saveRDS(eco_robustness_vnm, "output/ecosystem_robustness/ecosystem_robustness_VNM.rds")
source("processing/bangladesh_national.R")
eco_robustness_bgd <- ecosystem_robustness(bgd_villages)
saveRDS(eco_robustness_bgd, "output/ecosystem_robustness/ecosystem_robustness_BGD.rds")
source("processing/india_national.R")
eco_robustness_ind <- ecosystem_robustness(ind_villages)
saveRDS(eco_robustness_ind, "output/ecosystem_robustness/ecosystem_robustness_IND.rds")
eco_robustness <- rbind(eco_robustness_vnm, eco_robustness_bgd, eco_robustness_ind)

eco_robustness_norm <- normalize(eco_robustness)

n <- dplyr::select(st_drop_geometry(eco_robustness_norm), ends_with("_norm"))
eco_robustness_norm$ER_MH <- rowMeans(n, na.rm = TRUE)
saveRDS(eco_robustness_norm, "output/ecosystem_robustness/ecosystem_robustness.rds")
st_write(eco_robustness_norm, "output/ecosystem_robustness/ecosystem_robustness.gpkg", append = FALSE)

"
ER_FUN2 Donor aid for adaptation
"

# ---------------------------------------------------------------
# ECOSYSTEM EXPOSURE
# ---------------------------------------------------------------

source("processing/exposure/ecosystem_exposure.R")

eco_exposure_vnm <- ecosystem_exposure(vnm_villages)
o_exposure_bgd <- ecosystem_exposure(bgd_villages)
eco_exposure_ind <- ecosystem_exposure(ind_villages)
o_exposure <- rbind(eco_exposure_vnm, eco_exposure_bgd, eco_exposure_ind)

eco_exposure_norm <- normalize(eco_exposure)

n <- dplyr::select(st_drop_geometry(eco_exposure_norm), ends_with("_norm"))
eco_exposure_norm$E_EXP_MH <- rowMeans(n, na.rm = TRUE)
saveRDS(eco_exposure_norm, "output/exposure/ecosystem_exposure.rds")
st_write(eco_exposure_norm, "output/exposure/ecosystem_exposure.gpkg", append = FALSE)

# ---------------------------------------------------------------
# SOCIAL EXPOSURE
# ---------------------------------------------------------------

source("processing/exposure/social_exposure.R")

soc_exposure_vnm <- social_exposure(vnm_villages)
c_exposure_bgd <- social_exposure(bgd_villages)
soc_exposure_ind <- social_exposure(ind_villages)
c_exposure <- rbind(soc_exposure_vnm, soc_exposure_bgd, soc_exposure_ind)

soc_exposure_norm <- normalize(soc_exposure)

n <- dplyr::select(st_drop_geometry(soc_exposure_norm), ends_with("_norm"))
soc_exposure_norm$S_EXP_MH <- rowMeans(n, na.rm = TRUE)
saveRDS(soc_exposure_norm, "output/exposure/social_exposure.rds")
st_write(soc_exposure_norm, "output/exposure/social_exposure.gpkg", append = FALSE)

# ---------------------------------------------------------------
# AGRICULTURE EXPOSURE
# ---------------------------------------------------------------

source("processing/exposure/agriculture_exposure.R")

agri_exposure_vnm <- agriculture_exposure(vnm_villages)
ri_exposure_bgd <- agriculture_exposure(bgd_villages)
agri_exposure_ind <- agriculture_exposure(ind_villages)
ri_exposure <- rbind(agri_exposure_vnm, agri_exposure_bgd, agri_exposure_ind)

agri_exposure_norm <- normalize(agri_exposure)

n <- dplyr::select(st_drop_geometry(agri_exposure_norm), ends_with("_norm"))
agri_exposure_norm$A_EXP_MH <- rowMeans(n, na.rm = TRUE)
saveRDS(agri_exposure_norm, "output/exposure/agriculture_exposure.rds")
st_write(agri_exposure_norm, "output/exposure/agriculture_exposure.gpkg", append = FALSE)

# ---------------------------------------------------------------
# WATERSCAPE EXPOSURE
# ---------------------------------------------------------------

source("processing/exposure/waterscape_exposure.R")

water_exposure_vnm <- waterscape_exposure(vnm_villages)
ter_exposure_bgd <- waterscape_exposure(bgd_villages)
water_exposure_ind <- waterscape_exposure(ind_villages)
ter_exposure <- rbind(water_exposure_vnm, water_exposure_bgd, water_exposure_ind)

water_exposure_norm <- normalize(water_exposure)

n <- dplyr::select(st_drop_geometry(water_exposure_norm), ends_with("_norm"))
water_exposure_norm$W_EXP_MH <- rowMeans(n, na.rm = TRUE)
saveRDS(water_exposure_norm, "output/exposure/waterscape_exposure.rds")
st_write(water_exposure_norm, "output/exposure/waterscape_exposure.gpkg", append = FALSE)


# ---------------------------------------------------------------
# AQUACULTURE EXPOSURE
# ---------------------------------------------------------------

source("processing/exposure/aquaculture_exposure.R")

aquaculture_exposure_vnm <- aquaculture_exposure(vnm)
aquaculture_exposure_bgd <- aquaculture_exposure(bgd)
# aquaculture_exposure_ind <- aquaculture_exposure(gdri, ind, "India")
aquaculture_exposure <- rbind(aquaculture_exposure_vnm, aquaculture_exposure_bgd) # , aquaculture_exposure_ind)

aquaculture_exposure_norm <- normalize(aquaculture_exposure)

n <- dplyr::select(st_drop_geometry(aquaculture_exposure_norm), ends_with("_norm"))
aquaculture_exposure_norm$W_EXP_MH <- rowMeans(n, na.rm = TRUE)
saveRDS(aquaculture_exposure_norm, "output/exposure/aquaculture_exposure.rds")
st_write(aquaculture_exposure_norm, "output/exposure/aquaculture_exposure.gpkg", append = FALSE)



gdri <- cbind(
    soc_sus_norm,
    cop_adapt_norm,
    eco_sensitivity_norm,
    eco_robustness_norm,
    soc_exposure_norm,
    eco_exposure_norm,
    agri_exposure_norm,
    water_exposure_norm,
    aquaculture_exposure_norm
)
gdri <- gdri[!duplicated(as.list(gdri))]

gdri$SES_SUS_MH <- (gdri$SOC_MH + gdri$ES_MH) / 2
gdri$SES_CA_MH <- (gdri$CA_MH + gdri$ER_MH) / 2
gdri$SES_VU_MH <- (gdri$SES_SUS_MH + gdri$SES_CA_MH) / 2
# gdri$SES_VU_MH <- rowMeans(subset(gdri, select = c(SES_SUS_MH, SES_CA_MH)), na.rm = TRUE)

gdri$SES_EXP_MH <- (gdri$S_EXP_MH + gdri$E_EXP_MH + gdri$A_EXP_MH + gdri$W_EXP_MH) / 4

gdri$RISK_MH <- gdri$SES_VU_MH * gdri$SES_EXP_MH

st_write(gdri, "gdri.gpkg", append = FALSE)
write.csv(gdri %>% st_drop_geometry(), "gdri.csv")
