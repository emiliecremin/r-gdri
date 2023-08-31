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

# Corruption
S_GOV1 <- function(locations, ...) {
    locations$val <- 31
    return(locations)
}

# -------------------------------------------
# Adaptation Capacities
# -------------------------------------------

# early_warning_systems
C_EWS2 <- function(locations, ...) {
    locations$val <- 4
    return(locations)
}

# health_coverage
C_HEA34 <- function(locations, ...) {
    locations$val <- 3.5
    return(locations)
}

# lending_interest
C_SAV3 <- function(locations, ...) {
    locations$val <- 7.1
    return(locations)
}

# Insurance
C_INS1 <- function(locations, ...) {
    locations$val <- 0.18
    return(locations)
}

# Foreign_Direct_Investment
A_GOV4 <- function(locations, ...) {
    locations$val <- 6.1
    return(locations)
}

# Research_and_development
A_IIR1 <- function(locations, ...) {
    locations$val <- 0.6
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
