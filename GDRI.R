source("common/libraries.R")
source("common/helpers.R")
source("common/admin.R")

# TODO: keep only useful columns in admin.R
vnm <- st_read("data/ADMIN/admin_vnm.gpkg")
bgd <- st_read("data/ADMIN/admin_bgd.gpkg")
# ind <- st_read("data/ADMIN/admin_ind.gpkg")

gdri <- bind_rows(vnm, bgd) # ,ind)

# --------------------------------------------------
# DATA SOURCES
# --------------------------------------------------
source("processing/aqueduct.R")
source("processing/social.R")
source("processing/osm.R")
source("processing/world_bank.R")

# --------------------------------------------------
# SOCIAL SUSCEPTIBILITY
# --------------------------------------------------

source("processing/social_susceptibility/social_susceptibility.R")

soc_sus_vnm <- social_susceptibility(vnm)
soc_sus_bgd <- social_susceptibility(bgd)
# soc_sus_ind <- social_susceptibility(gdri, ind, "India")
soc_sus <- rbind(soc_sus_vnm, soc_sus_bgd) # , soc_sus_ind)

soc_sus_norm <- normalize(soc_sus)

n <- dplyr::select(st_drop_geometry(soc_sus_norm), ends_with("_norm"))
soc_sus_norm$SOC <- rowMeans(n, na.rm = TRUE)
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
cop_adapt_bgd <- adaptation_capacities(bgd)
# cop_adapt_ind <- social_susceptibility(gdri, ind, "India")
cop_adapt <- rbind(cop_adapt_vnm, cop_adapt_bgd) # , cop_adapt_ind)

cop_adapt_norm <- normalize(cop_adapt)

n <- dplyr::select(st_drop_geometry(cop_adapt_norm), ends_with("_norm"))
cop_adapt_norm$CA <- rowMeans(n, na.rm = TRUE)
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
# ECOSYSTEM SUSCEPTIBILITY
# --------------------------------------------------

# ES_DEG_1411 Eutrophication
source("processing/ecosystem_sensitivity/ES_DEG_1411.R")
ES_DEG_1411 <- st_read(
    "output/ecosystem_sensitivity/ES_DEG_1411_eutrophication_risk.gpkg"
)
gdri <- update_gdri(ES_DEG_1411, gdri, "ES_DEG_1411")

# ES_DES_1511 Forest Area
source("processing/ecosystem_sensitivity/ES_DES1511.R")
ES_DES1511 <- st_read(
    "output/ecosystem_sensitivity/ES_DES1511_forest_area.gpkg"
)
gdri <- update_gdri(ES_DES1511, gdri, "ES_DES1511")


# ES_DES2 Freshwater scarcity
source("processing/ecosystem_sensitivity/ES_DES1511.R")
ES_DES1511 <- st_read(
    "output/ecosystem_sensitivity/ES_DES1511_forest_area.gpkg"
)
gdri <- update_gdri(ES_DES1511, gdri, "ES_DES1511")

# TODO: ES_DES3 Percentage of deforested area
# "output/ecosystem_sensitivity/ES_DES3_forest_loss.gpkg"
"
ES_FRA2 River connectivity (River basin scale)

ES_FRA3 Forest connectivity

ES_DEG1 Water quality of freshwater bodies


ES_DEG2 Groundwater quality

ES_DEG4 Return Flow Ratio

ES_DEG6 Soil organic matter

ES_DEG9 Cation exchange capacity

ES_FRG1 Percentage of area covered by “problem soils” (%)

ES_BIO1 Species richness adjusted by intactness
"

# --------------------------------------------------
# ECOSYSTEM ROBUSTNESS
# --------------------------------------------------
# ER_CON_1512_conservation_areas
ES_CON1512 <- st_read(
    "output/ecosystem_sensitivity/ER_CON_1512_conservation_areas.gpkg"
)
gdri <- update_gdri(ES_CON1512, gdri, "ER_CON_1512")

# ER_RES2 Forest gain
ES_RES2 <- st_read("output/ecosystem_sensitivity/ER_RES2_forestgain.gpkg")
gdri <- update_gdri(ES_RES2, gdri, "ER_RES2")

# ER_TRE1457 Participation in Treaties
ER_TRE1457 <- st_read("output/ecosystem_sensitivity/ER_TRE1_Participation_in_treaties.gpkg")
gdri <- update_gdri(ER_TRE1457, gdri, "ER_TRE1457")

"
ER_POL2 Policies supporting biodiversity conservation
ER_FUN2 Donor aid for adaptation
ER_TRE4  Participation in Treaties - Convention on International Trade in Endangered Species of Wild Fauna and Flora (CITES) (yes/no)
ER_TRE5 Participation in Treaties - Convention on the Conservation of Migratory Species of Wild Animals (CMS)  (yes/no)
ER_TRE7 Participation in Treaties - Ramsar Convention on Wetlands  (yes/no)
ER_ECO1 Functionality Index
ER_BIO2 Mean Species Abundance (MSA)
"

st_write(gdri, "gdri.gpkg", append = FALSE)
write.csv(gdri %>% st_drop_geometry(), "gdri.csv")
