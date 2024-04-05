source("common/helpers.R")
source("common/social.R")

# Data sources: ipums, open street map, world bank, and national indicators
adaptation_capacities_indicators <- c(
    "C_EWS1", # IPUMS
    "C_SHE1", # OSM
    "C_TRA1", # OSM
    "C_GOV2", # OSM
    "C_INF1_631", # Aqueduct
    "A_GOV4", #  World Bank
    "C_HEA3", #  World Bank
    "C_HEA4", #  World Bank
    "A_SDG5a2_OWN", # National
    "C_GOV1", # National
    "C_GOV3", # National
    "C_HEA1", # National
    "C_EWS2", # National
    "C_SAV1", # National
    "C_SAV2", # National
    "C_SAV3", # National
    "C_INS1", # National
    "A_IIR1" # National
)

adaptation_capacities <- function(locations) {
    social_data <- get_social_data(locations)
    load_social_indicators(locations)
    return(
        process_indicators(
            locations,
            social_data,
            indicators = adaptation_capacities_indicators,
            # output = "output/adaptation_capacities"
        )
    )
}
