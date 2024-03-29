source("common/helpers.R")

# Data sources: ipums, aqueduct and national indicators
soc_susceptibility_indicators <- c(
    "S_SOC3",
    "S_SOC4", # travel time to cities
    "S_SOC5",
    "S_SOC8",
    "S_ECO2",
    "S_INF1",
    "S_INF2",
    "S_INF3",
    "S_ECO4",
    "S_INF1_621",
    "S_INF2_611",
    "S_SDG111_WPC", # National
    "S_SDG111_POV", # National
    "S_SDG211_HUN", # National
    "S_SDG211_STUN", # National
    "S_SDG231_Yield", # National
    "S_SDG3_MRTM", # National
    "S_SDG3_MRT5", # National
    "S_SDG5_EDAT", # National
    "S_SDG5_IFPR_", # National
    "S_SDG8_RIG_", # National
    "S_SDG9_TCOM_", # National
    "S_SDG1111_SLUM", # National
    "S_OCU1", # National
    "S_STA1", # National
)


# install.packages("usethis")
# library(usethis)
# usethis::edit_r_environ()
# R_MAX_VSIZE=100Gb
# Error: vector memory exhausted (limit reached?)
# https://stackoverflow.com/questions/51295402/r-on-macos-error-vector-memory-exhausted-limit-reached


social_susceptibility <- function(locations) {
    return(
        process_indicators(
            locations,
            indicators=soc_susceptibility_indicators,
            output="output/social_susceptibility"
        )
    )
}
