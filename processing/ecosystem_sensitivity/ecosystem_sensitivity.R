source("common/helpers.R")

# Data sources: ipums, open street map, world bank, and national indicators
ecosystem_sensitivity_indicators <- c(
    "ES_DES_1511", # Forest Area - ESA Landuse
    "ES_DEG_1411", # Eutrophication - aqueduct
    "ES_DES2", # Freshwater scarcity = Baseline water depletion - aqueduct
    "ES_WS_642", # Baseline water stress - aqueduct
    "ES_DEG2", # Groundwater quality = gtd: Groundwater table decline - aqueduct
    "ES_BIO1a", # Biodiversity Intactness Index - nhm.ac.uk
    "ES_DEG6", # Soil organic matter
    #"ES_DEG9", # Cation exchange capacity
    "ES_FRA2", # National - River connectivity (River basin scale)
    "ES_DES3" # Percentage of deforested area - GFC

    # TODO: ES_FRA3 Forest connectivity
    # TODO: ES_FRG1 Percentage of area covered by “problem soils” (%)
    # TODO: ES_DEG4 Return Flow Ratio
)

ecosystem_sensitivity <- function(locations) {
    return(
        process_indicators(
            locations, 
            indicators=ecosystem_sensitivity_indicators, 
            output="output/ecosystem_sensitivity"
        )
    )
}
