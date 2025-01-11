# https://www.nature.com/articles/s41597-021-00846-6
# https://sedac.ciesin.columbia.edu/data/set/pend-gdis-1960-2018/data-download
# https://public.emdat.be/data

# Data filtered since year 2000
# source("processing/GDIS.R")

S_EXP_COF_151_A <- function(locations, ...) {
    locations <- get_emdat_indicator_per_hazards(locations, "Total.Deaths", c("Coastal flood"))
    locations$val <- locations$idx / locations$pop
    return(locations)
}

S_EXP_CYC_151_A <- function(locations, ...) {
    locations <- get_emdat_indicator_per_hazards(locations, "Total.Deaths", c("Tropical cyclone", "Convective storm"))
    locations$val <- locations$idx / locations$pop
    return(locations)
}

S_EXP_FLO_151_A <- function(locations, ...) {
    locations <- get_emdat_indicator_per_hazards(locations, "Total.Deaths", c("Flash flood", "Riverine flood"))
    locations$val <- locations$idx / locations$pop
    return(locations)
}

S_EXP_COF_151_B <- function(locations, ...) {
    locations <- get_emdat_indicator_per_hazards(locations, "Total.Affected", c("Coastal flood"))
    locations$val <- locations$idx / locations$pop
    return(locations)
}

S_EXP_CYC_151_B <- function(locations, ...) {
    locations <- get_emdat_indicator_per_hazards(locations, "Total.Affected", c("Tropical cyclone", "Convective storm"))
    locations$val <- locations$idx / locations$pop
    return(locations)
}

S_EXP_FLO_151_B <- function(locations, ...) {
    locations <- get_emdat_indicator_per_hazards(locations, "Total.Affected", c("Flash flood", "Riverine flood"))
    locations$val <- locations$idx / locations$pop
    return(locations)
}

S_EXP_COF_152 <- function(locations, ...) {
    locations <- get_emdat_indicator_per_hazards(locations, "Total.Damages..Adjusted...000.US..", c("Coastal flood"))
    locations$val <- locations$idx
    return(locations)
}

S_EXP_CYC_152 <- function(locations, ...) {
    locations <- get_emdat_indicator_per_hazards(locations, "Total.Damages..Adjusted...000.US..", c("Tropical cyclone", "Convective storm"))
    locations$val <- locations$idx
    return(locations)
}

S_EXP_FLO_152 <- function(locations, ...) {
    locations <- get_emdat_indicator_per_hazards(locations, "Total.Damages..Adjusted...000.US..", c("Flash flood", "Riverine flood"))
    locations$val <- locations$idx
    return(locations)
}

social_exposure_indicators <- c(
    "S_EXP_COF_151_A", # EM-DAT: Deaths due to Costal Floods
    "S_EXP_CYC_151_A", # EM-DAT: Deaths due to Cyclones
    "S_EXP_FLO_151_A", # EM-DAT: Deaths due to Floods
    "S_EXP_COF_151_B", # EM-DAT: People affected by Costal Floods
    "S_EXP_CYC_151_B", # EM-DAT: People affected by Cyclones
    "S_EXP_FLO_151_B", # EM-DAT: People affected by Floods
    "S_EXP_COF_152", # EM-DAT: Cost of damages in adjusted USD due to Costal Floods
    "S_EXP_CYC_152", # EM-DAT: Cost of damages in adjusted USD due to Cyclones
    "S_EXP_FLO_152" # EM-DAT: Cost of damages in adjusted USD due to Floods
)

social_exposure <- function(locations) {
    return(
        process_indicators(
            locations,
            indicators = social_exposure_indicators,
            # output="output/exposure"
        )
    )
}
