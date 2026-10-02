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
    # GSAP regions are coarser than (and nest the first-level admin units of)
    # the study units, so units near a region boundary can land in a
    # neighbouring polygon through the centroid join. Assign every adm1 unit
    # the region that holds most of its units instead.
    joint_codes <- joint_codes %>%
        dplyr::left_join(
            locations %>% st_drop_geometry() %>% dplyr::select(geo_id, adm1_name),
            by = "geo_id"
        ) %>%
        dplyr::group_by(adm1_name) %>%
        dplyr::mutate(
            spatial_code = geo_code2,
            geo_code2 = names(which.max(table(geo_code2)))
        ) %>%
        dplyr::ungroup()
    reassigned <- joint_codes %>% dplyr::filter(spatial_code != geo_code2)
    if (nrow(reassigned) > 0) {
        message(
            nrow(reassigned), " of ", nrow(joint_codes),
            " units moved to their adm1 unit's majority GSAP region: ",
            paste(names(table(reassigned$adm1_name)), table(reassigned$adm1_name),
                  sep = "=", collapse = ", ")
        )
    }
    joint_codes <- joint_codes %>% dplyr::select(geo_id, geo_code2)
    spid <- read_excel(
        "data/Poverty/GSAP2/subnational-poverty-inequality-spid-poverty.xlsx",
        sheet = "Data"
    ) %>%
        dplyr::filter(code %in% unique(locations$country_iso3)) %>%
        dplyr::filter(year == max(year))
    stopifnot(!anyDuplicated(spid$geo_code2))
    # Keyed on geo_id: callers must look values up by geo_id, never by row position
    joint_codes %>%
        dplyr::left_join(spid, by = "geo_code2") %>%
        dplyr::select(-geo_code2)
}

# Look up one GSAP column for every location, aligned on geo_id
gsap_value <- function(locations, column) {
    gsap <- get_gsap(locations)
    stopifnot(!anyDuplicated(gsap$geo_id))
    val <- gsap[[column]][match(locations$geo_id, gsap$geo_id)]
    if (anyNA(val)) {
        warning(sum(is.na(val)), " locations have no GSAP value for ", column)
    }
    val
}

source("processing/rwi.R")

# S_ECO1 Relative Wealth Index (replaces the GSAP2 poverty headcount, which is
# kept below as S_ECO1_gsap). Higher = poorer. See processing/rwi.R
S_ECO1 <- function(locations, ...) {
    S_ECO1_rwi(locations)
}

# S_ECO1_gsap Population below national poverty line (%)
# Global Subnational Atlas of Poverty (version June 2023) [Data set]. World Bank Group
#
# Using 2.15$ per day as global poverty line
# https://www.worldbank.org/en/news/factsheet/2022/05/02/fact-sheet-an-adjustment-to-global-poverty-lines#1
#
# data source: https://datacatalog.worldbank.org/search/dataset/0064796/Subnational-Poverty-and-Inequality-Database--SPID-
S_ECO1_gsap <- function(locations, ...) {
    locations$val <- gsap_value(locations, "poor215")
    return(locations)
}

# S_ECO4 Spatial wealth inequality (replaces the GSAP2 Gini index, which is kept
# below as S_ECO4_gsap). Higher = more unequal. See processing/rwi.R
S_ECO4 <- function(locations, ...) {
    S_ECO4_rwi(locations)
}

# S_ECO4_gsap GINI Index
# Global Subnational Atlas of Poverty (version June 2023) [Data set]. World Bank Group
#
# data source: https://datacatalog.worldbank.org/search/dataset/0064796/Subnational-Poverty-and-Inequality-Database--SPID-
S_ECO4_gsap <- function(locations, ...) {
    locations$val <- gsap_value(locations, "gini")
    return(locations)
}
