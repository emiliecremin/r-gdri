# -------------------------------------------
# Social Susceptibility
# -------------------------------------------

# gini_index
S_ECO4 <- function(locations, ...) {
    locations$val <- 35.7
    return(locations)
}

# agriculture_to_GDP
S_OCU1 <- function(locations, ...) {
    locations$val <- 17.7
    return(locations)
}

# Homicides
S_STA1 <- function(locations, ...) {
    locations$val <- 3.3
    return(locations)
}

# -------------------------------------------
# Adaptation Capacities
# -------------------------------------------

# Corruption
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


# early_warning_systems
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

# A_GOV6 Donor aid for adaptation (local)
A_GOV6 <- function(locations, ...) {
    locations$val <- 0
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

# River connectivity (River basin scale)
ES_FRA2 <- function(locations, ...) {
    locations$val <- 0.5
    return(locations)
}

# -------------------------------------------
# Ecosystem Robustness
# -------------------------------------------

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
