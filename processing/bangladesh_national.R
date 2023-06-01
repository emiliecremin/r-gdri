# -------------------------------------------
# Social Susceptibility
# -------------------------------------------

# gini_index
S_ECO4 <- function(locations, ...) {
    locations$val <- 32.10
    return(locations)
}

# agriculture_to_GDP
S_OCU1 <- function(locations, ...) {
    locations$val <- 8.055
    return(locations)
}

# Homicides 2018 Rate/100.000- data requested on https://homicide.igarape.org.br/ = available at the state level
S_STA1 <- function(locations, ...) {
    locations$val <- 2.4
    return(locations)
}

# Corruption
C_GOV1 <- function(locations, ...) {
    locations$val <- 25
    return(locations)
}

# -------------------------------------------
# Adaptation Capacities
# -------------------------------------------

# Corruption
C_GOV1 <- function(locations, ...) {
    locations$val <- 25
    return(locations)
}

# No national food reserves available (binary) (National?)
C_GOV3 <- function(locations, ...) {
    locations$val <- 1
    return(locations)
}

# early_warning_systems
C_EWS2 <- function(locations, ...) {
    locations$val <- 4
    return(locations)
}

# C_SAV1
# Indicator: Percentage of households without gross savings (%)
# Measuring unit (or proxy): Population (age 15+) who has not saved any money in the last year (%)
C_SAV1 <- function(locations, ...) {
    locations$val <- 76.1
    return(locations)
}

# C_SAV2
# Indicator: Percentage of households without access to bank loans / (micro-) credits (%)
# Measuring unit (or proxy): Population (age 15+) who has not borrowed any money in the last year (%)
C_SAV2 <- function(locations, ...) {
    locations$val <- 53.2
    return(locations)
}

# health_coverage 2014 - Public health expenditure (% of GDP) - http://data.worldbank.org/ 
C_HEA3 <- function(locations, ...) {
    locations$val <- 0.8
    return(locations)
}

# health_coverage 2014 - Private health expenditure (% of GDP) - http://www.data.worldbank.org
C_HEA4 <- function(locations, ...) {
    locations$val <- 2
    return(locations)

# C_SAV3
# Indicator: Lending interest rate (%)
# Measuring unit (or proxy): Lending interest rate (%)
# lending_interest 2015 - http://data.worldbank.org 
C_SAV3 <- function(locations, ...) {
    locations$val <- 11.7
    return(locations)
}

# Insurance 2022 - Percentage of households with insurance – excluding health insurance or Microinsurance penetration (%)
# https://www.munichre-foundation.org/en/Inclusive_insurance/The_World_Map_of_Microinsurance.html#
C_INS1 <- function(locations, ...) {
    locations$val <- 6.2
    return(locations)
}

# Foreign_Direct_Investment - Net inflow in US$ (% of GDP) 2015
A_GOV4 <- function(locations, ...) {
    locations$val <- 1.7
    return(locations)
}

# Research_and_development 2011 - Percentage of GDP spent on innovation and research (%) http://data.uis.unesco.org
A_IIR1 <- function(locations, ...) {
    locations$val <- 0.08
    return(locations)
}

# -------------------------------------------
# Ecosystem Sensitivity
# -------------------------------------------

# River connectivity (River basin scale)
ES_FRA2 <- function(locations, ...) {
    locations$val <- 0.5
    return(locations)
}


# -------------------------------------------
# Ecosystem Robustness
# -------------------------------------------

# Participation_in_treaties
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
    locations$val <- 1
    return(locations)
}

# Participation in Treaties - Ramsar Convention on Wetlands  (yes/no)
ER_TRE7 <- function(locations, ...) {
    locations$val <- 1
    return(locations)
}

# Policies supporting biodiversity conservation
ER_POL2 <- function(locations, ...) {
    locations$val <- 0.58
    return(locations)
}

