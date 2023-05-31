source("common/helpers.R")

# Data sources: ipums, open street map, world bank, and national indicators
adaptation_capacities_indicators <- c(
    "C_EWS1", # IPUMS
    "C_SHE1", # OSM
    "C_TRA1", # OSM
    "C_GOV2", # OSM
    "S_INF1_631", # Aqueduct
    "A_GOV4", #  World Bank
    "C_SAV3", #  World Bank
    "C_HEA3", #  World Bank
    "C_HEA4", #  World Bank
    "C_INS1", # National
    "A_IIR1" # National
)

adaptation_capacities <- function(locations) {
    result <- locations
    country_iso3 <- unique(locations$country_iso3)[1]
    output <- str_glue("output/adaptation_capacities/{country_iso3}")
    mkdirs(output)
    social <- load_social_data(country_iso3)

    i <- 1
    for (indicator_code in adaptation_capacities_indicators) {
        cat(
            "Processing indicator:", indicator_code,
            "(", i, "/", length(adaptation_capacities_indicators), ")\n"
        )
        indicator <- do.call(
            get(indicator_code),
            list(locations = locations, data = social)
        )
        process_indicator(
            indicator_code, indicator, locations,
            append = FALSE, normalize = FALSE, plot = FALSE,
            output = output
        )
        result <- update_gdri(indicator, result, indicator_code)
        i <- i + 1
    }
    return(result)
}
