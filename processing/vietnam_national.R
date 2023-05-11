# -------------------------------------------
# Social Susceptibility
# -------------------------------------------

# gini_index
S_ECO4 <- function(data) {
    data$val <- 35.7
    return(data)
}

# agriculture_to_GDP
S_OCU1 <- function(data) {
    data$val <- 17.7
    return(data)
}

# Homicides
S_STA1 <- function(data) {
    data$val <- 3.3
    return(data)
}

# Corruption
S_GOV1 <- function(data) {
    data$val <- 31
    return(data)
}

# -------------------------------------------
# Adaptation Capacities
# -------------------------------------------

# early_warning_systems
C_EWS2 <- function(data) {
    data$val <- 4
    return(data)
}

# health_coverage
C_HEA34 <- function(data) {
    data$val <- 3.5
    return(data)
}

# lending_interest
C_SAV3 <- function(data) {
    data$val <- 7.1
    return(data)
}

# Insurance
C_INS1 <- function(data) {
    data$val <- 0.18
    return(data)
}

# Foreign_Direct_Investment
A_GOV4 <- function(data) {
    data$val <- 6.1
    return(data)
}

# Research_and_development
CA_IIR1 <- function(data) {
    data$val <- 0.6
    return(data)
}

# -------------------------------------------
# Ecosystem Robustness
# -------------------------------------------

# Participation_in_treaties
ER_TRE1 <- function(data) {
    data$val <- 1
    return(data)
}
