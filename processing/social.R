load_social_data <- function(country_iso3) {
    cat("This can take some time, depending on the size of the dataset.\n")
    cat(
        " ------------------------------------------------------------------\n",
        "If it fails with 'Error: vector memory exhausted (limit reached?)'\n",
        "Please increase R_MAX_VSIZE more info https://stackoverflow.com/a/52612921 \n", # nolint
        "-------------------------------------------------------------------\n"
    )
    cat("Social data for", country_iso3, "loading...\n")
    if (country_iso3 == "VNM") {
        source("processing/ipums.R")
        # social <- ipums_data %>% dplyr::filter(COUNTRY == 704)
        f <- "objects/vnm_ipums.rds"
        if (file.exists(f) == TRUE) {
            social <- readRDS(f)
        } else {
            social <- read.csv(file = "data/Vietnam/vietnam_2009.csv")
            saveRDS(social, f)
        }
        geo_id <- "GEOLEV2"
        social$geo_id <- social$GEOLEV2
    }

    if (country_iso3 == "BGD") {
        source("processing/ipums.R")
        f <- "objects/bgd_ipums.rds"
        if (file.exists(f) == TRUE) {
            social <- readRDS(f)
        } else {
            social <- read.csv(file = "data/Bangladesh/bangladesh_2011.csv")
            saveRDS(social, f)
        }
        geo_id <- "GEOLEV2"
        social$geo_id <- social$GEOLEV2
    }

    if (country_iso3 == "IND") {
        # TODO: this is not ready yet
        colnames(social)
        source("processing/census_of_india.R")
    }

    return(social)
}
