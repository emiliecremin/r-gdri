source("common/admin.R")
source("common/helpers.R")

locations <- st_read("data/ADMIN/admin.shp")
gdri <- locations

# --------------------------------------------------
# SOCIAL SUSCEPTIBILITY
# --------------------------------------------------
source("processing/social_susceptibility/social.R")

# S_SOC3 Percentage female-headed households (%)
indicator <- st_read(
    "output/social_susceptibility/S_SOC3_female_head_household.gpkg"
)
gdri <- updateGdriShp(indicator, locations, "S_SOC3")

# S_SOC5 Percentage of population with disabilities (%)
indicator <- st_read("output/social_susceptibility/S_SOC5_disabilities.gpkg")
gdri <- updateGdriShp(indicator, gdri, "S_SOC5")


# TODO: S_SOC4 Travel time to closest city (mins) - to do
# indicator <- st_read("output/social_susceptibility/S_SOC4_     .gpkg")
# gdri <- updateGdriShp(indicator, gdri, "S_SOC4")

# S_SOC8 Percentage of illiterate population (%)
indicator <- st_read("output/social_susceptibility/S_SOC8_illiteracy.gpkg")
gdri <- updateGdriShp(indicator, gdri, "S_SOC8")

# TODO: S_ECO1 Percentage of population below national poverty line (%) - to do
# indicator <- st_read("output/social_susceptibility/S_ECO1_     .gpkg")
# gdri <- updateGdriShp(indicator, gdri, "S_ECO1")

# S_ECO2 Dependency ratio (%)
indicator <- st_read("output/social_susceptibility/S_ECO2_dependency.gpkg")
gdri <- updateGdriShp(indicator, gdri, "S_ECO2")

# TODO: S_ECO4 GINI index
# indicator <- st_read("output/social_susceptibility/S_ECO4_     .gpkg")
# gdri <- updateGdriShp(indicator, gdri, "S_ECO4")

# TODO: S_OCU1 Dependency on agriculture / forestry / fisheries for livelihood (%) - to do
# indicator <- st_read("output/social_susceptibility/S_OCU1_     .gpkg")
# gdri <- updateGdriShp(indicator, gdri, "S_OCU1")

# S_INF1 / S_INF1_631 Percentage of population without access to (improved) sanitation (%)
indicator <- st_read("output/social_susceptibility/S_INF1_no_toilets.gpkg")
gdri <- updateGdriShp(indicator, gdri, "S_INF1")

# S_INF1 / S_INF1_631 Percentage of population without access to (improved) sanitation (%)
indicator <- st_read("output/social_susceptibility/S_INF1_631.gpkg")
gdri <- updateGdriShp(indicator, gdri, "S_INF1_631")

# S_INF2 / S_INF2_611 Percentage of population without access to clean water (%) / 6.1.1 Proportion of population using safely managed drinking water services
indicator <- st_read("output/social_susceptibility/S_INF2_clean_water.gpkg")
gdri <- updateGdriShp(indicator, gdri, "S_INF2")

# S_INF2 / S_INF2_611 Percentage of population without access to clean water (%)
indicator <- st_read("output/social_susceptibility/S_INF2_611.gpkg")
gdri <- updateGdriShp(indicator, gdri, "S_INF2_611")

# S_INF1_621 Percentage of population without access to (improved) sanitation (%)
indicator <- st_read("output/social_susceptibility/S_INF1_621.gpkg")
gdri <- updateGdriShp(indicator, gdri, "S_INF1_621")

# S_INF3 Percentage of population without access to electricity (%)
indicator <- st_read("output/social_susceptibility/S_INF3_electricity.gpkg")
gdri <- updateGdriShp(indicator, gdri, "S_INF3")

# S_STA1 Prevalence of population who experience violence (%) to be completed
indicator <- st_read("output/social_susceptibility/S_STA1.gpkg")
gdri <- updateGdriShp(indicator, gdri, "S_STA1")


# --------------------------------------------------
# COPING AND ADAPTATION CAPACITY
# --------------------------------------------------

# C_EWS1 Percentage of households without access to information (%)
indicator <- st_read("output/adaptation_capacities/C_EWS1_tv_radio.gpkg")
gdri <- updateGdriShp(indicator, gdri, "C_EWS1")

# TODO: C_EWS2 Existence of early warning systems (EWS) to do

# C_SHE1 Shelters - schools
indicator <- st_read("output/adaptation_capacities/C_SHE1_schools.gpkg")
gdri <- updateGdriShp(indicator, gdri, "C_SHE1")

# TODO: C_INF1

# C_TRA1 Access to transportation network
indicator <- st_read("output/adaptation_capacities/C_TRA1_roads_waterways.gpkg")
gdri <- updateGdriShp(indicator, gdri, "C_TRA1")


# TODO: C_TRA2 Percentage of households without individual means of transportation: car or motorcycle

# TODO: C_GOV1 Poor governance (National?) Corruption Perception Index (CPI)

# C_GOV2 Access to emergency services: hospitals, fire brigades, police stations
indicator <- st_read("output/adaptation_capacities/C_GOV2_emergencies.gpkg")
gdri <- updateGdriShp(indicator, gdri, "C_GOV2")

"
C_GOV3 No national food reserves available (binary) (National?)
C_HEA1 Number of hospital beds per 1,000 inhabitants
C_HEA3 Public health expenditure (% of GDP)
C_HEA4 Private health expenditure (% of GDP)
C_SAV1 Percentage of households without gross savings (%)
C_SAV2 Percentage of households without access to bank loans / (micro-) credits (%)
C_SAV3 Lending interest rate (%)
C_INS1 Percentage of households with insurance – excluding health insurance
A_GOV4 Foreign Direct Investment (FDI)
A_GOV6 Donor aid for adaptation (local)
A_IIR1 Percentage of GDP spent on innovation and research (%)
"

# --------------------------------------------------
# ECOSYSTEM SUSCEPTIBILITY
# --------------------------------------------------

# ES_DEG_1411 Eutrophication
source("processing/ecosystem_sensitivity/ES_DEG_1411.R")
ES_DEG_1411 <- st_read(
    "output/ecosystem_sensitivity/ES_DEG_1411_eutrophication_risk.gpkg"
)
gdri <- updateGdriShp(ES_DEG_1411, gdri, "ES_DEG_1411")

# ES_DES_1511 Forest Area
source("processing/ecosystem_sensitivity/ES_DES1511.R")
ES_DES1511 <- st_read(
    "output/ecosystem_sensitivity/ES_DES1511_forest_area.gpkg"
)
gdri <- updateGdriShp(ES_DES1511, gdri, "ES_DES1511")


# ES_DES2 Freshwater scarcity
source("processing/ecosystem_sensitivity/ES_DES1511.R")
ES_DES1511 <- st_read(
    "output/ecosystem_sensitivity/ES_DES1511_forest_area.gpkg"
)
gdri <- updateGdriShp(ES_DES1511, gdri, "ES_DES1511")

"
# ES_DES3 Percentage of deforested area - to be completed
ES_DES3 Percentage of deforested area (%)


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
gdri <- updateGdriShp(ES_DES1511, gdri, "ER_CON_1512")

# ER_RES2 Forest gain
ES_RES2 <- st_read("output/ecosystem_sensitivity/ER_RES2_forestgain.gpkg")
gdri <- updateGdriShp(ES_DES1511, gdri, "ER_RES2")

"
ER_POL2
ER_FUN2
ER_TRE1457
ER_TRE4
ER_TRES
ER_TER7
ER_ECO1
ER_BIO2
"

st_write(gdri, "gdri.gpkg", append = FALSE)
write.csv(gdri %>% st_drop_geometry(), "gdri.csv")
