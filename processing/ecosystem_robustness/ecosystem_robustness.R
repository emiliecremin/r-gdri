source("common/helpers.R")

# Data sources: ipums, open street map, world bank, and national indicators
ecosystem_robustness_indicators <- c(
    "ER_CON_1512", # Conservation areas - biodiversity.R - protectedplanet.net
    "ER_RES2", # Forest gain - forest.R - GFC
    "ER_ECO2_FLII", # Forest Landscape Integrity Index - forest.R - forestintegrity.com
    "ER_TRE1457", # Participation in Treaties - National indicator
    "ER_ECO1", # Ecosystem Functionality Index - biodiversity.R - 
    "ER_BIO2", # Mean Species Abundance (MSA) - biodiversity.R - Globio
)

ecosystem_robustness <- function(locations) {
    return(
        process_indicators(
            locations, 
            indicators=ecosystem_robustness_indicators, 
            output="output/ecosystem_robustness"
        )
    )
}
