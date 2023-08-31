source("common/libraries.R")
source("common/helpers.R")

# If you have a slow internet connection increase the timeout
options(timeout = 1800) # set the timeout to 30 minutes

# --------------------------------------------------
# DATA PREPARATION
# --------------------------------------------------
source("common/admin.R")
source("common/land_cover.R")
source("common/GFC.R")

# TODO: keep only useful columns in admin.R
vnm <- st_read("data/ADMIN/admin_vnm.gpkg")
bgd <- st_read("data/ADMIN/admin_bgd.gpkg")
# ind <- st_read("data/ADMIN/admin_ind.gpkg")

# --------------------------------------------------
# INDICATORS PER DATA SOURCE
# --------------------------------------------------
source("processing/aqueduct.R")
source("processing/social.R")
source("processing/osm.R")
source("processing/world_bank.R")
source("processing/forest.R")
source("processing/biodiversity.R")
source("processing/conservation.R")

# --------------------------------------------------
# SOCIAL SUSCEPTIBILITY
# --------------------------------------------------

source("processing/social_susceptibility/social_susceptibility.R")

soc_sus_vnm <- social_susceptibility(vnm)
saveRDS(soc_sus_vnm, "output/social_susceptibility/social_susceptibility_VNM.rds")
soc_sus_bgd <- social_susceptibility(bgd)
saveRDS(soc_sus_bgd, "output/social_susceptibility/social_susceptibility_BGD.rds")
# soc_sus_ind <- social_susceptibility(gdri, ind, "India")
# saveRDS(soc_sus_ind, "output/social_susceptibility/social_susceptibility_IND.rds")
soc_sus <- rbind(soc_sus_vnm, soc_sus_bgd) # , soc_sus_ind)

soc_sus_norm <- normalize(soc_sus)

n <- dplyr::select(st_drop_geometry(soc_sus_norm), ends_with("_norm"))
soc_sus_norm$SOC_MH <- rowMeans(n, na.rm = TRUE)
saveRDS(soc_sus_norm, "output/social_susceptibility/social_susceptibility.rds")
st_write(soc_sus_norm, "output/social_susceptibility/social_susceptibility.gpkg", append = FALSE)

# TODO: S_SOC4 Travel time to closest city (mins) - to do
# indicator <- st_read("output/social_susceptibility/S_SOC4_     .gpkg")
# gdri <- update_gdri(indicator, gdri, "S_SOC4")

# TODO: S_ECO1 Percentage of population below national poverty line (%) - to do
# indicator <- st_read("output/social_susceptibility/S_ECO1_     .gpkg")
# gdri <- update_gdri(indicator, gdri, "S_ECO1")

# --------------------------------------------------
# COPING AND ADAPTATION CAPACITY
# --------------------------------------------------

source("processing/adaptation_capacities/adaptation_capacities.R")

cop_adapt_vnm <- adaptation_capacities(vnm)
saveRDS(cop_adapt_vnm, "output/adaptation_capacities/adaptation_capacities_VNM.rds")
cop_adapt_bgd <- adaptation_capacities(bgd)
saveRDS(cop_adapt_bgd, "output/adaptation_capacities/adaptation_capacities_BGD.rds")
# cop_adapt_ind <- adaptation_capacities(gdri, ind, "India")
# saveRDS(cop_adapt_ind, "output/adaptation_capacities/adaptation_capacities_IND.rds")
cop_adapt <- rbind(cop_adapt_vnm, cop_adapt_bgd) # , cop_adapt_ind)

cop_adapt_norm <- normalize(cop_adapt)

n <- dplyr::select(st_drop_geometry(cop_adapt_norm), ends_with("_norm"))
cop_adapt_norm$CA_MH <- rowMeans(n, na.rm = TRUE)
saveRDS(cop_adapt_norm, "output/adaptation_capacities/adaptation_capacities.rds")
st_write(cop_adapt_norm, "output/adaptation_capacities/adaptation_capacities.gpkg", append = FALSE)


# TODO: C_EWS2 Existence of early warning systems (EWS) to do

# TODO: C_INF1 Percentage of houseolds without access to wastewater treatment (%)

# TODO: C_TRA2 Percentage of households without individual means of transportation: car or motorcycle

# TODO: C_GOV1 Poor governance (National?) Corruption Perception Index (CPI)

"
C_GOV3 No national food reserves available (binary) (National?)
C_HEA1 Number of hospital beds per 1,000 inhabitants
C_SAV1 Percentage of households without gross savings (%)
C_SAV2 Percentage of households without access to bank loans / (micro-) credits (%)
A_GOV6 Donor aid for adaptation (local)
"

# --------------------------------------------------
# ECOSYSTEM SENSITIVITY
# --------------------------------------------------

source("processing/ecosystem_sensitivity/ecosystem_sensitivity.R")

eco_sensitivity_vnm <- ecosystem_sensitivity(vnm)
saveRDS(eco_sensitivity_vnm, "output/ecosystem_sensitivity/ecosystem_sensitivity_VNM.rds")
eco_sensitivity_bgd <- ecosystem_sensitivity(bgd)
saveRDS(eco_sensitivity_bgd, "output/ecosystem_sensitivity/ecosystem_sensitivity_BGD.rds")
# eco_sensitivity_ind <- ecosystem_sensitivity(gdri, ind, "India")
# saveRDS(eco_sensitivity_ind, "output/ecosystem_sensitivity/ecosystem_sensitivity_IND.rds")
eco_sensitivity <- rbind(eco_sensitivity_vnm, eco_sensitivity_bgd) # , eco_sensitivity_ind)

eco_sensitivity_norm <- normalize(eco_sensitivity)

n <- dplyr::select(st_drop_geometry(eco_sensitivity_norm), ends_with("_norm"))
eco_sensitivity_norm$ES_MH <- rowMeans(n, na.rm = TRUE)
saveRDS(eco_sensitivity_norm, "output/ecosystem_sensitivity/ecosystem_sensitivity.rds")
st_write(eco_sensitivity_norm, "output/ecosystem_sensitivity/ecosystem_sensitivity.gpkg", append = FALSE)

# TODO: ES_FRA2 River connectivity (River basin scale)
# TODO: ES_FRA3 Forest connectivity
# TODO: ES_DEG2 Groundwater quality
# TODO: ES_DEG4 Return Flow Ratio
# TODO: ES_FRG1 Percentage of area covered by “problem soils” (%)

# --------------------------------------------------
# ECOSYSTEM ROBUSTNESS
# --------------------------------------------------

source("processing/ecosystem_robustness/ecosystem_robustness.R")

eco_robustness_vnm <- ecosystem_robustness(vnm)
saveRDS(eco_robustness_vnm, "output/ecosystem_robustness/ecosystem_robustness_VNM.rds")
eco_robustness_bgd <- ecosystem_robustness(bgd)
saveRDS(eco_robustness_bgd, "output/ecosystem_robustness/ecosystem_robustness_BGD.rds")
# eco_robustness_ind <- ecosystem_robustness(gdri, ind, "India")
# saveRDS(eco_robustness_ind, "output/ecosystem_robustness/ecosystem_robustness_IND.rds")
eco_robustness <- rbind(eco_robustness_vnm, eco_robustness_bgd) # , eco_robustness_ind)

eco_robustness_norm <- normalize(eco_robustness)

n <- dplyr::select(st_drop_geometry(eco_robustness_norm), ends_with("_norm"))
eco_robustness_norm$ER_MH <- rowMeans(n, na.rm = TRUE)
saveRDS(eco_robustness_norm, "output/ecosystem_robustness/ecosystem_robustness.rds")
st_write(eco_robustness_norm, "output/ecosystem_robustness/ecosystem_robustness.gpkg", append = FALSE)

"
ER_POL2 Policies supporting biodiversity conservation
ER_FUN2 Donor aid for adaptation
ER_TRE4 Participation in Treaties - Convention on International Trade in Endangered Species of Wild Fauna and Flora (CITES) (yes/no)
ER_TRE5 Participation in Treaties - Convention on the Conservation of Migratory Species of Wild Animals (CMS)  (yes/no)
ER_TRE7 Participation in Treaties - Ramsar Convention on Wetlands  (yes/no)
"

# --------------------------------------------------
# ECOSYSTEM EXPOSURE
# --------------------------------------------------

source("processing/exposure/ecosystem_exposure.R")

eco_exposure_vnm <- ecosystem_exposure(vnm)
eco_exposure_bgd <- ecosystem_exposure(bgd)
# eco_exposure_ind <- ecosystem_exposure(gdri, ind, "India")
eco_exposure <- rbind(eco_exposure_vnm, eco_exposure_bgd) # , eco_exposure_ind)

eco_exposure_norm <- normalize(eco_exposure)

n <- dplyr::select(st_drop_geometry(eco_exposure_norm), ends_with("_norm"))
eco_exposure_norm$E_EXP_MH <- rowMeans(n, na.rm = TRUE)
st_write(eco_exposure_norm, "output/exposure/ecosystem_exposure.gpkg", append = FALSE)

# --------------------------------------------------
# SOCIAL EXPOSURE
# --------------------------------------------------

source("processing/exposure/social_exposure.R")

soc_exposure_vnm <- social_exposure(vnm)
soc_exposure_bgd <- social_exposure(bgd)
# soc_exposure_ind <- social_exposure(gdri, ind, "India")
soc_exposure <- rbind(soc_exposure_vnm, soc_exposure_bgd) # , soc_exposure_ind)

soc_exposure_norm <- normalize(soc_exposure)

n <- dplyr::select(st_drop_geometry(soc_exposure_norm), ends_with("_norm"))
soc_exposure_norm$S_EXP_MH <- rowMeans(n, na.rm = TRUE)
saveRDS(soc_exposure_norm, "output/exposure/social_exposure.rds")
st_write(soc_exposure_norm, "output/exposure/social_exposure.gpkg", append = FALSE)

# --------------------------------------------------
# AGRICULTURE EXPOSURE
# --------------------------------------------------

source("processing/exposure/agriculture_exposure.R")

agri_exposure_vnm <- agriculture_exposure(vnm)
agri_exposure_bgd <- agriculture_exposure(bgd)
# agri_exposure_ind <- agriculture_exposure(gdri, ind, "India")
agri_exposure <- rbind(agri_exposure_vnm, agri_exposure_bgd) # , agri_exposure_ind)

agri_exposure_norm <- normalize(agri_exposure)

n <- dplyr::select(st_drop_geometry(agri_exposure_norm), ends_with("_norm"))
agri_exposure_norm$A_EXP_MH <- rowMeans(n, na.rm = TRUE)
st_write(agri_exposure_norm, "output/exposure/agriculture_exposure.gpkg", append = FALSE)

# --------------------------------------------------
# WATERSCAPE EXPOSURE
# --------------------------------------------------

source("processing/exposure/waterscape_exposure.R")

water_exposure_vnm <- waterscape_exposure(vnm)
water_exposure_bgd <- waterscape_exposure(bgd)
# water_exposure_ind <- waterscape_exposure(gdri, ind, "India")
water_exposure <- rbind(water_exposure_vnm, water_exposure_bgd) # , water_exposure_ind)

water_exposure_norm <- normalize(water_exposure)

n <- dplyr::select(st_drop_geometry(water_exposure_norm), ends_with("_norm"))
water_exposure_norm$W_EXP_MH <- rowMeans(n, na.rm = TRUE)
st_write(water_exposure_norm, "output/exposure/waterscape_exposure.gpkg", append = FALSE)


gdri <- cbind(
    soc_sus_norm, 
    cop_adapt_norm, 
    eco_sensitivity_norm, 
    eco_robustness_norm, 
    soc_exposure_norm,
    eco_exposure_norm,
    agri_exposure_norm,
    water_exposure_norm
    )
gdri <- gdri[!duplicated(as.list(gdri))]

gdri$SES_SUS_MH <- (gdri$SOC_MH + gdri$ES_MH) / 2
gdri$SES_CA_MH <- (gdri$CA_MH + gdri$ER_MH) / 2
gdri$SES_VU_MH <- (gdri$SES_SUS_MH + gdri$SES_CA_MH) / 2
# gdri$SES_VU_MH <- rowMeans(subset(gdri, select = c(SES_SUS_MH, SES_CA_MH)), na.rm = TRUE)

gdri$SES_EXP_MH <- (gdri$S_EXP_MH + gdri$E_EXP_MH + gdri$A_EXP_MH + gdri$W_EXP_MH) / 4

gdri$RISK_MH <- SES_VU_MH * SES_EXP_MH

st_write(gdri, "gdri.gpkg", append = FALSE)
write.csv(gdri %>% st_drop_geometry(), "gdri.csv")
