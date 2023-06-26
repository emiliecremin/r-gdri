source("common/helpers.R")

# Data sources: ipums, aqueduct and national indicators
soc_susceptibility_indicators <- c(
    "S_SOC3",
    "S_SOC5",
    "S_SOC8",
    "S_ECO2",
    "S_INF1",
    "S_INF2",
    "S_INF3",
    "S_ECO4",
    "S_OCU1",
    "S_STA1",
    "S_GOV1",
    "S_INF1_621",
    "S_INF2_611"
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
