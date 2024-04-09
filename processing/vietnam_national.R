# -------------------------------------------
# Social Susceptibility
# -------------------------------------------

# SDG1 WPC Poverty headcount ratio at $2.15/day (2019 PPP, %)
# http://worldpoverty.io/
S_SDG111_WPC <- function(locations, ...) {
    locations$val <- 1
    return(locations)
}

# SDG1 sdg1_lmicpov 2019 Poverty headcount ratio at $3.65/day (2017 PPP, %)
# http://worldpoverty.io/
S_SDG111_POV <- function(locations, ...) {
    locations$val <- 4
    return(locations)
}

# SDG2 Prevalence of undernourishment (%) 2019
# https://www.fao.org/faostat/en/#data/SDGB
S_SDG211_HUN <- function(locations, ...) {
    locations$val <- 6
    return(locations)
}

# SDG2 Stunting 2019 - Prevalence of stunting in children under 5 years of age (%)
# http://data.worldbank.org/indicator/SH.STA.STNT.ZS
S_SDG211_STUN <- function(locations, ...) {
    locations$val <- 21
    return(locations)
}

# SDG2 Cereal yield 2019 Cereal yield (tonnes per hectare of harvested land)
# http://data.worldbank.org/indicator/AG.YLD.CREL.KG
S_SDG231_Yield <- function(locations, ...) {
    locations$val <- 6
    return(locations)
}

# SDG3  Maternal mortality rate (per 100,000 live births) 2019
# https://www.who.int/data/gho/data/indicators/indicator-details/GHO/maternal-mortality-ratio-(per-100-000-live-births)
S_SDG3_MRTM <- function(locations, ...) {
    locations$val <- 134
    return(locations)
}

# SDG3  Mortality rate, under-5 (per 1,000 live births) 2019
# https://childmortality.org/
S_SDG3_MRT5 <- function(locations, ...) {
    locations$val <- 21
    return(locations)
}

# SDG5 Ratio of female-to-male mean years of education received (%) 2019
# http://hdr.undp.org/en/data (education > mean years of schooling)
S_SDG5_EDAT <- function(locations, ...) {
    locations$val <- 92
    return(locations)
}

# SDG5 Ratio of female-to-male labor force participation rate (%) 2019
# https://databank.worldbank.org/source/gender-statistics/Series/SL.TLF.CACT.FM.ZS
S_SDG5_IFPR <- function(locations, ...) {
    locations$val <- 87
    return(locations)
}

# SDG8 Rights Fundamental labor rights are effectively guaranteed (worst 0–1 best) 2019
# https://worldjusticeproject.org/our-work/wjp-rule-law-index
S_SDG8_RIG <- function(locations, ...) {
    locations$val <- 0.62
    return(locations)
}

# SDG9 Population using the internet (%) 2019
# https://www.itu.int/en/ITU-D/Statistics/Pages/stat/default.aspx
S_SDG9_TCOM <- function(locations, ...) {
    locations$val <- 69
    return(locations)
}

# SDG11 - 11.1 Proportion of urban population living in slums, informal settlements or inadequate housing
# https://landportal.org/fr/book/sdgs/1111/sdgs-indicator-1111
# https://data.unhabitat.org/pages/housing-slums-and-informal-settlements
# % of urban population in 2020
S_SDG1111_SLUM <- function(locations, ...) {
    locations$val <- 5.76
    return(locations)
}

# agriculture_to_GDP
S_OCU1 <- function(locations, ...) {
    locations$val <- 17.7
    return(locations)
}

# Homicides
# Homicide rate per 100,000 inhabitants in 2019
# https://www.who.int/data/gho/data/indicators/indicator-details/GHO/estimates-of-rates-of-homicides-per-100-000-population
S_STA1 <- function(locations, ...) {
    locations$val <- 1.9
    return(locations)
}

# -------------------------------------------
# Adaptation Capacities
# -------------------------------------------

# SDG 5.a.2 2019 “Proportion of countries where the legal framework (including customary law) guarantees women’s equal rights to land ownership and/or control”.
# Restricted Resources and Entitlements - Woman Access to Land -> https://landportal.org/book/indicators/indoecd11-0
# https://landportal.org/book/indicators/indoecd11-0
A_SDG5a2_OWN <- function(locations, ...) {
    locations$val <- 0.5
    return(locations)
}

# Corruption
# CPI 100 is very clean and 0 is highly corrupt
# https://www.transparency.org/en/cpi/2022/index/vnm
C_GOV1 <- function(locations, ...) {
    locations$val <- 31
    return(locations)
}

# No national food reserves available (binary) (National?)
# Measuring unit (or proxy): No national food reserves available (YES)
# http://projects.worldbank.org/
# http://www.foodgrainsbank.ca
C_GOV3 <- function(locations, ...) {
    locations$val <- 0
    return(locations)
}

# Hospital beds (per 1,000 people)
# https://data.worldbank.org/indicator/SH.MED.BEDS.ZS
C_HEA1 <- function(locations, ...) {
    locations$val <- 2.6 # year 2014
    return(locations)
}

# Early_warning_systems
C_EWS2 <- function(locations, ...) {
    locations$val <- 4
    return(locations)
}

# C_SAV1
# Indicator: Percentage of households without gross savings (%)
# Measuring unit (or proxy): Population (age 15+) who has not saved any money in the last year (%)
C_SAV1 <- function(locations, ...) {
    locations$val <- 36.7
    return(locations)
}

# C_SAV2
# Indicator: Percentage of households without access to bank loans / (micro-) credits (%)
# Measuring unit (or proxy): Population (age 15+) who has not borrowed any money in the last year (%)
C_SAV2 <- function(locations, ...) {
    locations$val <- 53.2
    return(locations)
}

# C_SAV3
# Indicator: Lending interest rate (%)
# Measuring unit (or proxy): Lending interest rate (%)
C_SAV3 <- function(locations, ...) {
    locations$val <- 7.1
    return(locations)
}

# Insurance
C_INS1 <- function(locations, ...) {
    locations$val <- 0.18
    return(locations)
}

# Research_and_development
A_IIR1 <- function(locations, ...) {
    locations$val <- 0.6
    return(locations)
}

# -------------------------------------------
# Ecosystem Sensitivity
# -------------------------------------------

# SDG12 nprod 2015 Production-based nitrogen emissions (kg/capita)
# http://scp-hat.lifecycleinitiative.org/module-2-scp-hotspots/
ES_SDG12_nprod <- function(locations, ...) {
    locations$val <- 28.84
    return(locations)
}

# SDG11 pm25 Annual mean concentration of particulate matter of less than 2.5 microns in diameter (PM2.5) (μg/m³)
# http://www.healthdata.org/gbd/2019
ES_SDG11_Pm25 <- function(locations, ...) {
    locations$val <- 28
    return(locations)
}

# SDG Red List Index - UNDESA database.2021 OECD STAT
ES_SDG1551_RLI <- function(locations, ...) {
    locations$val <- 0.716
    return(locations)
}

# -------------------------------------------
# Ecosystem Robustness
# -------------------------------------------

# SDG14 cpma 2019 Mean area that is protected in marine sites important to biodiversity (%)
# https://unstats.un.org/sdgs/indicators/database/?indicator=14.5.1
ER_SDG14_cpma <- function(locations, ...) {
    locations$val <- 25
    return(locations)
}

# SDG 15.2.1 Progress towards sustainable forest management
# Proportion of forest area located within legally established protected area https://landportal.org/book/dataset/un-sdg1521
ER_SDG1521_FO <- function(locations, ...) {
    locations$val <- 15.49
    return(locations)
}

# Participation_in_treaties - Convention on Biodiversity (CBD)
ER_TRE1 <- function(locations, ...) {
    locations$val <- 1
    return(locations)
}

# Participation in Treaties - Convention on International Trade in Endangered Species of Wild Fauna and Flora (CITES) (yes/no)
ER_TRE4 <- function(locations, ...) {
    locations$val <- 1
    return(locations)
}

# Participation in Treaties - Convention on the Conservation of Migratory Species of Wild Animals (CMS)  (yes/no)
ER_TRE5 <- function(locations, ...) {
    locations$val <- 0
    return(locations)
}

# Participation in Treaties - Ramsar Convention on Wetlands  (yes/no)
ER_TRE7 <- function(locations, ...) {
    locations$val <- 1
    return(locations)
}

# Policies supporting biodiversity conservation
ER_POL2 <- function(locations, ...) {
    locations$val <- 0.746
    return(locations)
}
