# Partial update: recompute S_ECO1 (population-weighted RWI) and S_ECO4 (RWI dispersion) only.
# Fixes the positional-assignment bug in processing/poverty.R (values are now
# looked up by geo_id). Run from the r-gdri project root:
#   Rscript processing/partial_update/poverty.R
# Output: output/partial_update/S_ECO1_rwi_S_ECO4.csv

source("common/libraries.R")
source("common/helpers.R")
source("processing/poverty.R")

mkdirs("output/partial_update")

update_poverty <- function(path, iso3) {
    locations <- st_read(path, quiet = TRUE)
    locations$geo_id <- as.character(locations$geo_id)
    # villages_bgd.gpkg has no country_iso3 column
    locations$country_iso3 <- iso3
    # get_gsap() is called per country: the latest survey year is per country
    year <- read_excel(
        "data/Poverty/GSAP2/subnational-poverty-inequality-spid-poverty.xlsx",
        sheet = "Data"
    ) %>%
        dplyr::filter(code %in% unique(locations$country_iso3)) %>%
        dplyr::pull(year) %>%
        max()
    data.frame(
        geo_id = locations$geo_id,
        country_iso3 = locations$country_iso3,
        adm1_name = locations$adm1_name,
        adm2_name = locations$adm2_name,
        S_ECO1_val = S_ECO1(locations)$val,
        S_ECO1_gsap_val = S_ECO1_gsap(locations)$val,
        S_ECO4_val = S_ECO4(locations)$val,
        S_ECO4_gsap_val = S_ECO4_gsap(locations)$val,
        gsap_survey_year = year
    )
}

result <- rbind(
    update_poverty("objects/ADMIN/villages_vnm.gpkg", "VNM"),
    update_poverty("objects/ADMIN/villages_bgd.gpkg", "BGD"),
    update_poverty("objects/ADMIN/villages_ind.gpkg", "IND")
)
stopifnot(!anyDuplicated(result$geo_id))
write.csv(result, "output/partial_update/S_ECO1_rwi_S_ECO4.csv", row.names = FALSE)

# Sanity check: distinct values per country and per adm1 unit
print(result %>% group_by(country_iso3) %>% summarise(
    units = n(),
    distinct_poverty = n_distinct(S_ECO1_val),
    distinct_gini = n_distinct(S_ECO4_val),
    na_poverty = sum(is.na(S_ECO1_val)),
    na_gini = sum(is.na(S_ECO4_val)),
    survey_year = first(gsap_survey_year)
))
