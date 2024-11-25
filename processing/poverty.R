# Global Subnational Atlas of Poverty (version June 2023) [Data set]. World Bank Group
# data source: https://datacatalog.worldbank.org/search/dataset/0064796/Subnational-Poverty-and-Inequality-Database--SPID-
# shapefile: https://datacatalogfiles.worldbank.org/ddh-published/0042041/DR0052554/gsap-maps.zip
# data: https://datacatalogfiles.worldbank.org/ddh-published/0042041/DR0052554/gsap-maps.zip
get_gsap <- function(locations) {
    gsap <- st_read("data/Poverty/GSAP2/gsap-maps/GSAP2.shp",) %>%
        dplyr::filter(code %in% unique(locations$country_iso3)) %>%
        dplyr::select("geo_code2","GSAP2_samp","geometry")
    contained <- st_join(gsap, st_centroid(locations)) %>%
        st_drop_geometry() %>%
        dplyr::select(geo_id, geo_code2) %>%
        filter(!is.na(geo_id))
    not_contained <- locations %>% filter(!geo_id %in% contained$geo_id)
    nearest <- st_join(st_centroid(not_contained), gsap, join = st_nearest_feature, left = TRUE) %>%
        st_drop_geometry() %>% dplyr::select(geo_id, geo_code2)
    joint_codes <- rbind(contained, nearest)
    full_join <- read_excel(
        "data/Poverty/GSAP2/subnational-poverty-inequality-spid-poverty.xlsx",
        sheet = "Data"
    ) %>%
        dplyr::filter(code %in% unique(locations$country_iso3)) %>%
        dplyr::filter(year == max(year)) %>%
        dplyr::right_join(
            y = joint_codes,
            by = "geo_code2"
        ) %>%
        dplyr::left_join(y = locations, by = "geo_id") %>%
        st_as_sf()
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
    return(locations)
}

# S_ECO4 GINI Index
# Global Subnational Atlas of Poverty (version June 2023) [Data set]. World Bank Group
#
# data source: https://datacatalog.worldbank.org/search/dataset/0064796/Subnational-Poverty-and-Inequality-Database--SPID-
S_ECO4 <- function(locations, ...) {
    gsap <- get_gsap(locations)
    locations$val <- gsap$gini
    return(locations)
}
