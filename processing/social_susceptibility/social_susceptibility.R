source("common/helpers.R")

soc_susceptibility_indicators <- c(
    # ipums
    "S_SOC3",
    "S_SOC5",
    "S_SOC8",
    "S_ECO2",
    "S_INF1",
    "S_INF2",
    "S_INF3",
    # National indicators
    "S_ECO4",
    "S_OCU1",
    "S_STA1",
    "S_GOV1"
)

social_susceptibility <- function(gdri, locations, country_name) {
    if (country_name == "Vietnam") {
        source("processing/social_susceptibility/ipums.R")
        source("processing/vietnam_national.R")
        # social <- ipums_data %>% dplyr::filter(COUNTRY == 704)
        social <- read.csv(file = "data/Vietnam/vietnam_2009.csv")
        social$geo_id <- social$GEOLEV2
        social <- joinOnColumn(social, locations, "geo_id")
    }

    if (country_name == "Bangladesh") {
        source("processing/social_susceptibility/ipums.R")
        source("processing/bangladesh_national.R")
        social <- read.csv(file = "data/Bangladesh/bangladesh_2011.csv")
        social$geo_id <- social$GEOLEV2
        social <- joinOnColumn(social, locations, "geo_id")
    }

    if (country_name == "India") {
        source("processing/social_susceptibility/census_of_india.R")
        source("processing/india_national.R")
        social <- st_read(
            "data/ADMIN/India-village-boundaries/India-village-boundaries-Dselect.shp" # nolint
        )
        social$geo_id <- social$C_CODE01
    }

    for (indicator_code in soc_susceptibility_indicators) {
        indicator <- do.call(
            indicator_code,
            c(social, locations, append = TRUE)
        )
        gdri <- updateGdriShp(indicator, gdri, indicator_code)
    }
}
