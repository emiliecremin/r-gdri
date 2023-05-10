source("common/helpers.R")

# install.packages("usethis")
# library(usethis)
# usethis::edit_r_environ()
# R_MAX_VSIZE=100Gb
# Error: vector memory exhausted (limit reached?)
# https://stackoverflow.com/questions/51295402/r-on-macos-error-vector-memory-exhausted-limit-reached

# https://datacornering.com/calculate-the-percentage-by-a-group-in-r-dplyr/

# S_SOC3
# Percentage female-headed households (%)
# What about Gender Inequality as weight?
# http://hdr.undp.org/en/content/gender-inequality-index-gii
S_SOC3 <- function(social, append = FALSE, normalize = FALSE, plot = FALSE, output = "") { # nolint
  head_household <- filter(social, RELATE == 1) %>%
    group_by(GEOLEV2, RELATE, SEX) %>%
    summarise(cnt = n()) %>%
    mutate(val = (cnt / sum(cnt) * 100))
  female_head_household <- head_household %>% filter(SEX == 2)
  return(
    process_indicator(
      "S_SOC3", female_head_household,
      append, normalize, plot, "output/social_susceptibility"
    )
  )
}

# S_SOC5
# Percentage of population with disabilities (%)
S_SOC5 <- function(social, append = FALSE, normalize = FALSE, plot = FALSE, output = "") { # nolint
  disabilities <- filter(social, DISABLED == 1 | DISABLED == 2) %>%
    group_by(GEOLEV2, DISABLED) %>%
    summarise(cnt = n()) %>%
    mutate(val = (cnt / sum(cnt) * 100))
  disabled <- filter(disabilities, DISABLED == 1)
  return(
    process_indicator(
      "S_SOC5", disabled,
      append, normalize, plot, "output/social_susceptibility"
    )
  )
}

# S_SOC8
# Percentage of illiterate population (%)
S_SOC8 <- function(social, append = FALSE, normalize = FALSE, plot = FALSE, output = "") { # nolint
  literacy <- filter(social, LIT == 1 | LIT == 2) %>%
    group_by(GEOLEV2, LIT) %>%
    summarise(cnt = n()) %>%
    mutate(val = (cnt / sum(cnt) * 100))
  illiterate <- literacy %>% filter(LIT == 1)
  return(
    process_indicator(
      "S_SOC8", illiterate,
      append, normalize, plot, "output/social_susceptibility"
    )
  )
}

# S_ECO2
# Dependency ratio (%)
# count(filter(vnm, (AGE < 15 | AGE > 64)))
S_ECO2 <- function(social, append = FALSE, normalize = FALSE, plot = FALSE, output = "") { # nolint
  dependancy <- social %>%
    mutate(DEP = (AGE < 15 | AGE > 64)) %>%
    group_by(GEOLEV2, DEP) %>%
    summarise(cnt = n()) %>%
    mutate(val = (cnt / sum(cnt) * 100))
  dependency_rate <- filter(dependancy, DEP == TRUE)
  return(
    process_indicator(
      "S_ECO2", dependency_rate,
      append, normalize, plot, "output/social_susceptibility"
    )
  )
}

# S_INF1
# Percentage of population without access to (improved) sanitation (%)
S_INF1 <- function(social, append = FALSE, normalize = FALSE, plot = FALSE, output = "") { # nolint
  toilets <- filter(social, TOILET != 99 & TOILET != 00) %>%
    group_by(GEOLEV2, TOILET) %>%
    summarise(cnt = n()) %>%
    mutate(val = (cnt / sum(cnt) * 100))
  no_toilets <- filter(toilets, TOILET == 10)
  return(
    process_indicator(
      "S_INF1", no_toilets,
      append, normalize, plot, "output/social_susceptibility"
    )
  )
}

# S_INF2
# Percentage of population without access to clean water (%)
# count(filter(vnm, WATSUP != 99 & WATSUP != 00))
# ----------
# TODO: Verify data and check if we need to reverse the normalisation
# ----------
S_INF2 <- function(social, append = FALSE, normalize = FALSE, plot = FALSE, output = "") { # nolint
  watsup <- filter(social, WATSUP != 99 & WATSUP != 00) %>%
    mutate(WATSUP = replace(WATSUP, WATSUP == 18, 10)) %>%
    group_by(GEOLEV2, WATSUP) %>%
    summarise(cnt = n()) %>%
    mutate(val = (cnt / sum(cnt) * 100))
  water_not_piped <- filter(watsup, WATSUP == 20)
  return(
    process_indicator(
      "S_INF2", water_not_piped,
      append, normalize, plot, "output/social_susceptibility"
    )
  )
}

# S_INF3
# Percentage of population without access to electricity (%)
S_INF3 <- function(social, append = FALSE, normalize = FALSE, plot = FALSE, output = "") { # nolint
  electricity <- filter(social, ELECTRIC != 9 & ELECTRIC != 0) %>%
    group_by(GEOLEV2, ELECTRIC) %>%
    summarise(cnt = n()) %>%
    mutate(val = (cnt / sum(cnt) * 100))
  no_electricity <- electricity %>%
    filter(ELECTRIC == 2)
  return(
    process_indicator(
      "S_INF3", no_electricity,
      append, normalize, plot, "output/social_susceptibility"
    )
  )

# C_EWS1
# Percentage of households without access to information (%)
# Proxy: Percentage of households without radio or TV (%)
tv_radio <- filter(vnm, RADIO != 9 & RADIO != 0 & TV != 00 & TV != 99) %>%
  group_by(GEOLEV2, RADIO, TV) %>%
  summarise(cnt = n()) %>%
  mutate(val = (cnt / sum(cnt) * 100))
no_tv_radio <- tv_radio %>%
  filter(RADIO == 1 & TV == 10) %>%
  arrange(val)
no_tv_radio$norm <- normalize_minmax(no_tv_radio$val, na.rm = TRUE)
no_tv_radio <- joinOnColumn(no_tv_radio, locations, "GEOLEV2")
mapPlot(no_tv_radio, "norm", "norm min-max", "C_EWS1_tv_radio")
st_write(no_tv_radio, "output/adaptation_capacities/C_EWS1_tv_radio.gpkg", append = FALSE)

early_warning_system <- locations
early_warning_system$val <- 4
early_warning_system$norm <- 0 # XXX normalize globally?
st_write(Early warning system, "output/adaptation_capacities/C_EWS2_Early_Warning.gpkg", append = FALSE)

health_coverage <- locations
health_coverage$val <- 3.5
health_coverage$norm <- 0.236 # XXX normalize globally?
st_write(Health_coverage, "output/adaptation_capacities/C_HEA34_health_coverage.gpkg", append = FALSE)

lending_interest <- locations
lending_interest$val <- 7.10
lending_interest$norm <- 0 # XXX normalize globally?
st_write(lending_interest, "output/adaptation_capacities/C_SAV3_lending_interest.gpkg", append = FALSE)

Insurance <- locations
Insurance$val <- 7.10
Insurance$norm <- 0 # XXX normalize globally?
st_write(Insurance, "output/adaptation_capacities/C_INS1_Insurance.gpkg", append = FALSE)

Foreign_Direct_Investment <- locations
Foreign_Direct_Investment$val <- 6.4
Foreign_Direct_Investment$norm <- 0 # XXX normalize globally?
st_write(Insurance, "output/adaptation_capacities/A_GOV4_Foreign_Direct_Investment.gpkg", append = FALSE)

Research_and_development <- locations
Research_and_development$val <- 0.6
Research_and_development$norm <- 0.6 # XXX normalize globally?
st_write(Insurance, "output/adaptation_capacities/CA_IIR1_Research_and_development.gpkg", append = FALSE)

Participation_in_treaties <- locations
Participation_in_treaties$val <- 0.6
Participation_in_treaties$norm <- 0.6 # XXX normalize globally?
st_write(Insurance, "output/ecosystem_robustness/ER_TRE1_Participation_in_treaties.gpkg", append = FALSE)


# Mobile
# https://www.gsma.com/mobileeconomy/wp-content/uploads/2021/08/GSMA_ME_APAC_2021_Web_Singles.pdf
# https://www.gsma.com/mobilefordevelopment/wp-content/uploads/2021/03/Achieving-mobile-enabled-digital-inclusion-in-Bangladesh.pdf
# https://www.gsma.com/mobilefordevelopment/
# https://www.gsma.com/betterfuture/wp-content/uploads/2019/08/Mobile-Economic-Impact-2019-Vietnam.pdf
# https://www.nperf.com/fr/about-us/
# https://www.gsmaintelligence.com/data/
# https://www.itu.int/en/ITU-D/Statistics/Pages/stat/default.aspx
# https://www.itu.int/itu-d/sites/statistics/

# Data sources
# http://hdr.undp.org/en/content/human-development-report-office-statistical-data-api
# http://hdr.undp.org/en/statistics/understanding/sources
