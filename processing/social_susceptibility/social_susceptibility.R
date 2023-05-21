source("common/helpers.R")

# Census and ipums
soc_susceptibility_indicators <- c(
    "S_SOC3",
    "S_SOC5",
    "S_SOC8",
    "S_ECO2",
    "S_INF1",
    "S_INF2",
    "S_INF3"
)

# National indicators
soc_susceptibility_nat_indicators <- c(
    "S_ECO4",
    "S_OCU1",
    "S_STA1",
    "S_GOV1",
    "S_INF1_621",
    "S_INF1_631",
    "S_INF2_611"
)


# install.packages("usethis")
# library(usethis)
# usethis::edit_r_environ()
# R_MAX_VSIZE=100Gb
# Error: vector memory exhausted (limit reached?)
# https://stackoverflow.com/questions/51295402/r-on-macos-error-vector-memory-exhausted-limit-reached

social_susceptibility <- function(locations, country_name) {
    result <- locations
    mkdirs(str_glue("output/social_susceptibility/{country_name}"))
    cat("This can take some time, depending on the size of the dataset.\n")
    source("processing/social_susceptibility/aqueduct.R")
    cat(
        " ------------------------------------------------------------------\n",
        "If it fails with 'Error: vector memory exhausted (limit reached?)'\n",
        "Please increase R_MAX_VSIZE more info https://stackoverflow.com/a/52612921 \n", # nolint
        "-------------------------------------------------------------------\n"
    )
    cat("Social data for", country_name, "loading...\n")
    if (country_name == "Vietnam") {
        source("processing/social_susceptibility/ipums.R")
        source("processing/vietnam_national.R")
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

    if (country_name == "Bangladesh") {
        source("processing/social_susceptibility/ipums.R")
        source("processing/bangladesh_national.R")
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

    if (country_name == "India") {
        source("processing/social_susceptibility/census_of_india.R")
        source("processing/india_national.R")
        social <- st_read(
            "data/ADMIN/India-village-boundaries/India-village-boundaries-Dselect.shp" # nolint
        ) %>% st_drop_geometry
        geo_id <- "C_CODE01"
        social$geo_id <- social$C_CODE01
    }
    cat("Census indicators:\n")
    i <- 1
    for (indicator_code in soc_susceptibility_indicators) {
        cat(
            "Processing indicator:", indicator_code,
            "(", i, "/", length(soc_susceptibility_indicators), ")\n"
        )
        indicator <- do.call(
            get(indicator_code),
            list(data = social)
        )
        cat("Join social data with geometries...\n")
        cat(colnames(indicator), "\n")
        print(head(indicator, 2))
        indicator <- joinOnColumn(indicator, locations, geo_id)
        indicator$geo_id <- indicator[[geo_id]]
        process_indicator(
            indicator_code, indicator,
            append=FALSE, normalize=FALSE,
            plot=FALSE, output=str_glue("output/social_susceptibility/{country_name}")
        )
        result <- update_gdri(indicator, result, indicator_code)
        i <- i + 1
    }
    cat("National indicators:\n")
    i <- 1
    for (indicator_code in soc_susceptibility_nat_indicators) {
        cat(
            "Processing indicator:", indicator_code,
            "(", i, "/", length(soc_susceptibility_nat_indicators), ")\n"
        )
        indicator <- do.call(
            get(indicator_code),
            list(data = locations)
        )
        process_indicator(
            indicator_code, indicator,
            append=FALSE, normalize=FALSE,
            plot=FALSE, output=str_glue("output/social_susceptibility/{country_name}")
        )
        result <- update_gdri(indicator, result, indicator_code)
        i <- i + 1
    }
    return(result)
}
