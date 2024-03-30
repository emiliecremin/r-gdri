source("common/helpers.R")

# Data sources: ipums, open street map, world bank, and national indicators
ecosystem_sensitivity_indicators <- c(
    "ES_DEG_1411", # Eutrophication - aqueduct
    "ES_DEG5_642", # Baseline water stress - aqueduct
    "ES_DEG2", # Groundwater quality = gtd: Groundwater table decline - aqueduct
    "ES_BIO1a", # Biodiversity Intactness Index - nhm.ac.uk
    "ES_DEG6", # Soil organic matter
    "ES_DEG7", # Soil workability (FAO HWSD 1.2 SQ7)
    "ES_DEG8", # Soil salinity (Global Soil Salinity Map)
    "ES_DEG9", # Soil Cation exchange capacity
    "ES_DEG10", # Baseline water depletion - aqueduct
    "ES_FRA2", # Connectivity Status Index - Free FLowing Rivers
    "ES_DES3", # Percentage of deforested area - GFC
    "ES_SDG11_Pm25", # National
    "ES_SDG12_nprod", # National
    "ES_SDG1551_RLI" # National
)

ecosystem_sensitivity <- function(locations) {
    return(
        process_indicators(
            locations,
            indicators = ecosystem_sensitivity_indicators,
            # output="output/ecosystem_sensitivity"
        )
    )
}
