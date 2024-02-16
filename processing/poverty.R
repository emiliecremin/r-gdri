# Global Subnational Atlas of Poverty (version June 2023) [Data set]. World Bank Group
# data source: https://datacatalog.worldbank.org/search/dataset/0064796/Subnational-Poverty-and-Inequality-Database--SPID-
# shapefile: blob:https://datacatalog.worldbank.org/0292ac56-c01e-4f00-8f57-6be76a844f5b
# data: blob:https://datacatalog.worldbank.org/7d7937a6-8476-4473-8bee-32cf112f82f5
get_gsap <- function(locations) {
    gsap <- st_read(
        "data/Poverty/GSAP2/gsap-maps/GSAP2.shp",
    ) %>% dplyr::filter(code %in% unique(locations$country_iso3))
    keep_cols <- c(
        "geo_code2",
        "GSAP2_samp",
        "geometry"
    )
    gsap_min <- gsap[, keep_cols]
    sp_join <- st_intersection(st_centroid(locations), gsap_min)
    # st_write(sp_join, "data/Poverty/GSAP2/sp_join.gpkg", append = FALSE)
    keep_cols <- c(
        "geo_code2",
        "geo_id"
    )
    joint_codes <- sp_join[, keep_cols]
    full_join <- read_excel(
        "data/Poverty/GSAP2/subnational-poverty-inequality-spid-poverty.xlsx",
        sheet = "Data"
    ) %>%
        dplyr::filter(code %in% unique(locations$country_iso3)) %>%
        dplyr::filter(year == max(year)) %>%
        dplyr::full_join(
            y = st_drop_geometry(joint_codes),
            by = "geo_code2"
        ) %>%
        dplyr::full_join(y = locations, by = "geo_id") %>%
        st_as_sf()
    # st_write(full_join, "data/Poverty/GSAP2/full_join.gpkg", append = FALSE)
    return(full_join)
}

# S_ECO1 Population below national poverty line (%)
# Global Subnational Atlas of Poverty (version June 2023) [Data set]. World Bank Group
#
# Using 2.15$ per day as global poverty line
# https://www.worldbank.org/en/news/factsheet/2022/05/02/fact-sheet-an-adjustment-to-global-poverty-lines#1
#
# data source: https://datacatalog.worldbank.org/search/dataset/0064796/Subnational-Poverty-and-Inequality-Database--SPID-
S_ECO1 <- function(locations, ...) {
    gsap <- get_gsap(locations)
    locations$val <- gsap$poor215
}

# S_ECO4 GINI Index
# Global Subnational Atlas of Poverty (version June 2023) [Data set]. World Bank Group
#
# data source: https://datacatalog.worldbank.org/search/dataset/0064796/Subnational-Poverty-and-Inequality-Database--SPID-
S_ECO4 <- function(locations, ...) {
    gsap <- get_gsap(locations)
    locations$val <- gsap$gini
}
