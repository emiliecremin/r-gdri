# https://datatopics.worldbank.org/world-development-indicators/
# https://data.worldbank.org/indicator?tab=all
# https://databank.worldbank.org/source/adjusted-net-savings/Type/TABLE/preview/on
# https://datahelpdesk.worldbank.org/knowledgebase/topics/125589-developer-information

# A_GOV4
# Indicator: Foreign Direct Investment (FDI)
# Measuring unit (or proxy): Net inflow (% of GDP)
# http://data.worldbank.org
A_GOV4 <- function(locations, ...) {
    country_iso3 <- unique(locations$country_iso3)[1]
    FDI <- read.csv(file = "data/WorldBank/FDI/API_BX.KLT.DINV.WD.GD.ZS_DS2_en_csv_v2_3159100.csv", skip = 4)
    A_GOV4 <- dplyr::filter(FDI, Country.Code == country_iso3)
    locations$val <- A_GOV4$X2009
    return(locations)
}

# C_GOV3
# Indicator: No national food reserves available (binary)
# Measuring unit (or proxy): No national food reserves available (YES)
# http://projects.worldbank.org/
# http://www.foodgrainsbank.ca

# C_HEA3
# Indicator: Public health expenditure (% of GDP)
C_HEA3 <- function(locations, ...) {
    country_iso3 <- unique(locations$country_iso3)[1]

    # Domestic general government health expenditure (% of GDP)
    # https://data.worldbank.org/indicator/SH.XPD.GHED.GD.ZS
    HEALTH_GOV_EXP <- read.csv(file = "data/WorldBank/HEALTH_GOV_EXP/API_SH.XPD.GHED.GD.ZS_DS2_en_csv_v2_3165532.csv", skip = 4)
    C_HEA3_1 <- dplyr::filter(HEALTH_GOV_EXP, Country.Code == country_iso3)

    # Current health expenditure (% of GDP)
    # https://data.worldbank.org/indicator/SH.XPD.CHEX.GD.ZS
    # Level of current health expenditure expressed as a percentage of GDP.
    # Estimates of current health expenditures include healthcare goods and services consumed during each year.
    # This indicator does not include capital health expenditures such as buildings, machinery, IT and stocks of vaccines for emergency or outbreaks.
    # HEALTH_EXP <- read.csv(file = "data/WorldBank/HEALTH_EXP/API_SH.XPD.CHEX.GD.ZS_DS2_en_csv_v2_3158870.csv", skip = 4)
    # C_HEA3_2 <- dplyr::filter(HEALTH_EXP, Country.Code == country_iso3)

    # locations$val <- C_HEA3_1$X2009 + C_HEA3_2$X2009

    locations$val <- C_HEA3_1$X2009
    return(locations)
}

# C_HEA4
# Indicator: Private health expenditure (% of GDP)
# Domestic private health expenditure (% of current health expenditure)
# https://data.worldbank.org/indicator/SH.XPD.PVTD.CH.ZS
# Share of current health expenditures funded from domestic private sources.
# Domestic private sources include funds from households, corporations and non-profit organizations.
# Such expenditures can be either prepaid to voluntary health insurance or paid directly to healthcare providers.
C_HEA4 <- function(locations, ...) {
    country_iso3 <- unique(locations$country_iso3)[1]
    HEALTH_PRIV_EXP <- read.csv(file = "data/WorldBank/HEALTH_PRIV_EXP/API_SH.XPD.PVTD.CH.ZS_DS2_en_csv_v2_3165539.csv", skip = 4)
    C_HEA4 <- dplyr::filter(HEALTH_PRIV_EXP, Country.Code == country_iso3)
    locations$val <- C_HEA4$X2009
    return(locations)
}

# C_SAV1
# Indicator: Percentage of households without gross savings (%)
# Measuring unit (or proxy): Population (age 15+) who has not saved any money in the last year (%)

# C_SAV2
# Indicator: Percentage of households without access to bank loans / (micro-) credits (%)
# Measuring unit (or proxy): Population (age 15+) who has not borrowed any money in the last year (%)

# C_SAV3
# Indicator: Lending interest rate (%)
# Measuring unit (or proxy): Lending interest rate (%)

# S_ECO4
# Poverty & inequality
# GINI index VS
# By its construction, the Gini coefficient puts equal weights to the entire distribution, while the Atkinson inequality measure puts more weight to the lower end, thus it accounts better for child mortality, illiteracy, and income poverty.
# http://hdr.undp.org/en/content/gini-coefficient-not-sufficient-measure-inequality-what-difference-between-gini-and-atkinson

# https://dhsprogram.com/data/available-datasets.cfm
# http://hdr.undp.org/en/content/mpi-statistical-programmes
