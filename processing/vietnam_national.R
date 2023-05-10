# -------------------------------------------
# Social Susceptibility
# -------------------------------------------

# gini_index
S_ECO4 <- function(locations, append = FALSE, normalize = FALSE, plot = FALSE, output = "") { # nolint
    locations$val <- 35.7
    return(
        process_indicator(
            "S_ECO4", locations,
            append, normalize, plot, "output/social_susceptibility"
        )
    )
}

# agriculture_to_GDP
S_OCU1 <- function(locations, append = FALSE, normalize = FALSE, plot = FALSE, output = "") { # nolint
    locations$val <- 17.7
    return(
        process_indicator(
            "S_OCU1", locations,
            append, normalize, plot, "output/social_susceptibility"
        )
    )
}

# Homicides
S_STA1 <- function(locations, append = FALSE, normalize = FALSE, plot = FALSE, output = "") { # nolint
    locations$val <- 3.3
    return(
        process_indicator(
            "S_STA1", locations,
            append, normalize, plot, "output/social_susceptibility"
        )
    )
}

# Corruption
S_GOV1 <- function(locations, append = FALSE, normalize = FALSE, plot = FALSE, output = "") { # nolint
    locations$val <- 31
    return(
        process_indicator(
            "S_GOV1", locations,
            append, normalize, plot, "output/social_susceptibility"
        )
    )
}

# -------------------------------------------
# Adaptation Capacities
# -------------------------------------------

# early_warning_systems
C_EWS2 <- function(locations, append = FALSE, normalize = FALSE, plot = FALSE, output = "") { # nolint
    locations$val <- 4
    return(
        process_indicator(
            "C_EWS2", locations,
            append, normalize, plot, "output/adaptation_capacities"
        )
    )
}

# health_coverage
C_HEA34 <- function(locations, append = FALSE, normalize = FALSE, plot = FALSE, output = "") { # nolint
    locations$val <- 3.5
    return(
        process_indicator(
            "C_HEA34", locations,
            append, normalize, plot, "output/adaptation_capacities"
        )
    )
}

# lending_interest
C_SAV3 <- function(locations, append = FALSE, normalize = FALSE, plot = FALSE, output = "") { # nolint
    locations$val <- 7.1
    return(
        process_indicator(
            "C_SAV3", locations,
            append, normalize, plot, "output/adaptation_capacities"
        )
    )
}

# Insurance
C_INS1 <- function(locations, append = FALSE, normalize = FALSE, plot = FALSE, output = "") { # nolint
    locations$val <- 0.18
    return(
        process_indicator(
            "C_INS1", locations,
            append, normalize, plot, "output/adaptation_capacities"
        )
    )
}

# Foreign_Direct_Investment
A_GOV4 <- function(locations, append = FALSE, normalize = FALSE, plot = FALSE, output = "") { # nolint
    locations$val <- 6.1
    return(
        process_indicator(
            "A_GOV4", locations,
            append, normalize, plot, "output/adaptation_capacities"
        )
    )
}

# Research_and_development
CA_IIR1 <- function(locations, append = FALSE, normalize = FALSE, plot = FALSE, output = "") { # nolint
    locations$val <- 0.6
    return(
        process_indicator(
            "CA_IIR1", locations,
            append, normalize, plot, "output/adaptation_capacities"
        )
    )
}

# -------------------------------------------
# Ecosystem Robustness
# -------------------------------------------

# Participation_in_treaties
ER_TRE1 <- function(locations, append = FALSE, normalize = FALSE, plot = FALSE, output = "") { # nolint
    locations$val <- 1
    return(
        process_indicator(
            "ER_TRE1", locations,
            append, normalize, plot, "output/ecosystem_robustness"
        )
    )
}
