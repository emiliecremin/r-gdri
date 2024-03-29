get_social_data <- function(locations) {
    country_iso3 <- unique(locations$country_iso3)[1]
    if (country_iso3 == "IND") {
        # Census of India is in the shapefile
        social <- locations
    } else {
        cat("This can take some time, depending on the size of the dataset.\n")
        cat(
            "---------------------------------------------------------------\n",
            "If you get 'Error: vector memory exhausted (limit reached?)'\n",
            "Please increase R_MAX_VSIZE more info https://stackoverflow.com/a/52612921 \n", # nolint
            "---------------------------------------------------------------\n"
        )
        mkdirs("objects/IPUMS")
        cat("Social census microdata for", country_iso3, "loading...\n")
        if (country_iso3 == "VNM") {
            f <- "objects/IPUMS/vnm_ipums.rds"
            if (file.exists(f) == TRUE) {
                social <- readRDS(f)
            } else {
                social <- read.csv(file = "data/IPUMS/vietnam_2009.csv")
                saveRDS(social, f)
            }
        }

        if (country_iso3 == "BGD") {
            f <- "objects/IPUMS/bgd_ipums.rds"
            if (file.exists(f) == TRUE) {
                social <- readRDS(f)
            } else {
                social <- read.csv(file = "data/IPUMS/bangladesh_2011.csv")
                saveRDS(social, f)
            }
        }
    }
    return(social)
}

load_social_indicators <- function(locations) {
    country_iso3 <- unique(locations$country_iso3)[1]
    if (country_iso3 == "VNM") {
        source("processing/ipums.R")
    }
    if (country_iso3 == "BGD") {
        source("processing/ipums.R")
    }
    if (country_iso3 == "IND") {
        source("processing/census_of_india.R")
    }
}
