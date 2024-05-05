source("common/helpers.R")

# Data sources: ipums, open street map, world bank, and national indicators
ecosystem_robustness_indicators <- c(
    "ER_FOR_1511", # Percentage of Forest Area - ESA Landuse
    "ER_CON_1512", # Conservation areas - conservation.R - protectedplanet.net
    "ER_CON_1521", # Forest in Conservation areas - ESA Landuse and protectedplanet.net
    "ER_RES2", # Forest gain - forest.R - GFC
    "ER_ECO2_FLII", # Forest Landscape Integrity Index - forest.R - forestintegrity.com
    "ER_ECO1", # Ecosystem Functionality Index - biodiversity.R -
    "ER_BIO2", # Mean Species Abundance (MSA) - biodiversity.R - Globio
    "ER_SDG14_cpma", # National
    "ER_SDG1521_FO", # National
    "ER_TRE1", # National
    "ER_TRE4", # National
    "ER_TRE5", # National
    "ER_TRE7", # National
    "ER_POL2" # National
)

ecosystem_robustness <- function(locations) {
    locations <- st_as_sf(locations) %>% st_simplify()
    return(
        process_indicators(
            locations,
            indicators = ecosystem_robustness_indicators,
            # output="output/ecosystem_robustness"
        )
    )
}
