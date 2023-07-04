source("common/helpers.R")

# Data sources: ipums, open street map, world bank, and national indicators
adaptation_capacities_indicators <- c(
    "C_EWS1", # IPUMS
    "C_SHE1", # OSM
    "C_TRA1", # OSM
    "C_GOV2", # OSM
    "C_INF1_631", # Aqueduct
    "A_GOV4", #  World Bank
    "C_SAV3", #  World Bank
    "C_HEA3", #  World Bank
    "C_HEA4", #  World Bank
    "C_INS1", # National
    "A_IIR1" # National
)

adaptation_capacities <- function(locations) {
    return(
        process_indicators(
            locations, 
            indicators=adaptation_capacities_indicators, 
            output="output/adaptation_capacities"
        )
    )
}
