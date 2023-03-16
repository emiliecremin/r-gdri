source("common/admin.R")
source("common/helpers.R")

locations <- st_read("data/ADMIN/admin.shp")
gdri <- locations

# --------------------------------------------------
# SOCIAL SUSCEPTIBILITY
# --------------------------------------------------
source("processing/social_susceptibility/social.R")

# S_SOC3 Percentage female-headed households (%)
female_head_household <- st_read("output/social_susceptibility/S_SOC3_female_head_household.gpkg")
gdri <- updateGdriShp(female_head_household, locations, "S_SOC3")

# S_SOC5 Percentage of population with disabilities (%)
disabled <- st_read("output/social_susceptibility/S_SOC5_disabilities.gpkg")
gdri <- updateGdriShp(disabled, gdri, "S_SOC5")

"
S_SOC4 Travel time to closest city (mins)

S_SOC8 Percentage of illiterate population (%)

S_ECO1 Percentage of population below national poverty line (%)

S_ECO2 Dependency ratio (%)

S_ECO4 GINI index

S_OCU1 Dependency on agriculture / forestry / fisheries for livelihood (%)

S_INF1 / S_INF1_621 Percentage of population without access to (improved) sanitation (%) 
C_INF 1 Percentage of households without access to waste/water treatment (%)

S_INF2 / S_INF2_611 Percentage of population without access to clean water (%)

S_INF3 Percentage of population without access to electricity (%)

S_STA1 Prevalence of population who experience violence (%)

S_STA3
"

# --------------------------------------------------
# COPING AND ADAPTATION CAPACITY
# --------------------------------------------------
"
C_EWS1 Percentage of households without access to information (%) 
C_EWS2 Existence of early warning systems (EWS)

C_SHE1
C_INF1
C_TRA1 Access to transportation network
C_TRA2 Percentage of households without individual means of transportation: car or motorcycle
C_GOV1 Poor governance (National?) Corruption Perception Index (CPI)

C_GOV2 Access to emergency services: hospitals, fire brigades, police stations

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
source("processing/ecosystem_sensitivity/ES_DEG_1411.R")
ES_DEG_1411 <- st_read('output/ecosystem_sensitivity/ES_DEG_1411_eutrophication_risk.gpkg')
gdri <- updateGdriShp(ES_DEG_1411, gdri, 'ES_DEG_1411')

source("processing/ecosystem_sensitivity/ES_DES1511.R")
ES_DES1511 <- st_read('output/ecosystem_sensitivity/ES_DES1511_forest_area.gpkg')
gdri <- updateGdriShp(ES_DES1511, gdri, 'ES_DES1511')

st_write(gdri, "gdri.gpkg", append = FALSE)

"
ES_DES2 Freshwater scarcity

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
"
ECO_ROB
ER_CON1
ER_RES2
ER_POL2
ER_FUN2
ER_TRE1457
ER_TRE4
ER_TRES
ER_TER7
ER_ECO1
ER_BIO2
"

