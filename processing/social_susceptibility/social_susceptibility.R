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
    result <- locations
    country_iso3 <- unique(locations$country_iso3)[1]
    output <- str_glue("output/social_susceptibility/{country_iso3}")
    mkdirs(output)
    social <- load_social_data(country_iso3)

    i <- 1
    for (indicator_code in soc_susceptibility_indicators) {
        cat(
            "Processing indicator:", indicator_code,
            "(", i, "/", length(soc_susceptibility_indicators), ")\n"
        )
        indicator <- do.call(
            get(indicator_code),
            list(locations = locations, data = social)
        )
        process_indicator(
            indicator_code, indicator, locations,
            append = FALSE, normalize = FALSE,
            plot = FALSE,
            output = output
        )
        result <- update_gdri(indicator, result, indicator_code)
        i <- i + 1
    }
    return(result)
}
