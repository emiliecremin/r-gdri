# Compare population-weighted Relative Wealth Index (RWI) against GSAP2
# S_ECO1 (poverty headcount) and S_ECO4 (GINI), per study unit.
# Run from the r-gdri project root:
#   Rscript processing/partial_update/rwi_comparison.R
# Output: output/partial_update/rwi_comparison.csv (one row per unit)
#         output/partial_update/rwi_comparison_summary.csv

source("common/libraries.R")
source("common/helpers.R")

mkdirs("output/partial_update")

source("processing/rwi.R")

rwi_for_units <- function(path, iso3) {
    units <- st_read(path, quiet = TRUE)
    units$geo_id <- as.character(units$geo_id)
    units$country_iso3 <- iso3
    stats <- rwi_unit_stats(units)
    cbind(
        st_drop_geometry(units[, c("geo_id", "country_iso3", "adm1_name", "adm2_name")]),
        stats[, c("rwi_mean", "rwi_sd", "pop_worldpop", "rwi_fallback")]
    )
}

rwi <- rbind(
    rwi_for_units("objects/ADMIN/villages_vnm.gpkg", "VNM"),
    rwi_for_units("objects/ADMIN/villages_bgd.gpkg", "BGD"),
    rwi_for_units("objects/ADMIN/villages_ind.gpkg", "IND")
)

# within adm2 dispersion (units of adm2 are the finest level at which RWI
# varies for most units, since tiles are ~2.4 km)
rwi <- rwi %>%
    group_by(country_iso3, adm2_name) %>%
    mutate(
        rwi_mean_adm2 = weighted.mean(rwi_mean, pop_worldpop, na.rm = TRUE),
        rwi_sd_between_units_adm2 = sqrt(weighted.mean(
            (rwi_mean - rwi_mean_adm2)^2, pop_worldpop, na.rm = TRUE
        ))
    ) %>%
    ungroup()

# GSAP2 values computed by the original (pre-RWI) processing/partial_update/poverty.R
gsap <- read.csv("output/partial_update/S_ECO1_S_ECO4.csv") %>%
    dplyr::select(geo_id, S_ECO1_val, S_ECO4_val)
rwi <- dplyr::left_join(rwi, gsap, by = "geo_id")
stopifnot(!anyDuplicated(rwi$geo_id))
write.csv(rwi, "output/partial_update/rwi_comparison.csv", row.names = FALSE)

spearman <- function(a, b) suppressWarnings(cor(a, b, method = "spearman", use = "complete.obs"))
summary_tbl <- rwi %>%
    group_by(country_iso3) %>%
    summarise(
        units = n(),
        na_rwi = sum(is.na(rwi_mean)),
        distinct_gsap_poverty = n_distinct(S_ECO1_val),
        distinct_rwi_mean = n_distinct(round(rwi_mean, 6), na.rm = TRUE),
        distinct_gsap_gini = n_distinct(S_ECO4_val),
        distinct_rwi_sd = n_distinct(round(rwi_sd, 6), na.rm = TRUE),
        share_sd_zero = mean(rwi_sd == 0, na.rm = TRUE),
        # RWI is high = rich, so a negative correlation with poverty is expected
        rho_mean_vs_poverty = spearman(rwi_mean, S_ECO1_val),
        rho_mean_adm2_vs_poverty = spearman(rwi_mean_adm2, S_ECO1_val),
        rho_sd_vs_gini = spearman(rwi_sd, S_ECO4_val),
        rho_sd_adm2_vs_gini = spearman(rwi_sd_between_units_adm2, S_ECO4_val),
        rho_sd_vs_mean = spearman(rwi_sd, rwi_mean)
    )
all_rows <- rwi %>% summarise(
    country_iso3 = "ALL", units = n(), na_rwi = sum(is.na(rwi_mean)),
    distinct_gsap_poverty = n_distinct(S_ECO1_val),
    distinct_rwi_mean = n_distinct(round(rwi_mean, 6), na.rm = TRUE),
    distinct_gsap_gini = n_distinct(S_ECO4_val),
    distinct_rwi_sd = n_distinct(round(rwi_sd, 6), na.rm = TRUE),
    share_sd_zero = mean(rwi_sd == 0, na.rm = TRUE),
    rho_mean_vs_poverty = spearman(rwi_mean, S_ECO1_val),
    rho_mean_adm2_vs_poverty = spearman(rwi_mean_adm2, S_ECO1_val),
    rho_sd_vs_gini = spearman(rwi_sd, S_ECO4_val),
    rho_sd_adm2_vs_gini = spearman(rwi_sd_between_units_adm2, S_ECO4_val),
    rho_sd_vs_mean = spearman(rwi_sd, rwi_mean)
)
summary_tbl <- rbind(summary_tbl, all_rows)
write.csv(summary_tbl, "output/partial_update/rwi_comparison_summary.csv", row.names = FALSE)
print(as.data.frame(t(summary_tbl)))
