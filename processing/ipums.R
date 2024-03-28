# https://datacornering.com/calculate-the-percentage-by-a-group-in-r-dplyr/


# --------------------------------------------------
# SOCIAL SUSCEPTIBILITY
# --------------------------------------------------

# S_SOC3
# Percentage female-headed households (%)
# What about Gender Inequality as weight?
# http://hdr.undp.org/en/content/gender-inequality-index-gii
S_SOC3 <- function(locations, ...) {
  female_head_household <- locations %>%
    st_drop_geometry() %>%
    dplyr::select(GEOLEV2, RELATE, SEX) %>%
    filter(RELATE == 1) %>%
    group_by(GEOLEV2, SEX) %>%
    summarise(cnt = n()) %>%
    mutate(val = (cnt / sum(cnt) * 100)) %>%
    filter(SEX == 2)
  return(female_head_household)
}

# S_SOC5
# Percentage of population with disabilities (%)
S_SOC5 <- function(locations, ...) {
  disabled <- locations %>%
    st_drop_geometry() %>%
    dplyr::select(GEOLEV2, DISABLED) %>%
    filter(DISABLED == 1 | DISABLED == 2) %>%
    group_by(GEOLEV2, DISABLED) %>%
    summarise(cnt = n()) %>%
    mutate(val = (cnt / sum(cnt) * 100)) %>%
    filter(DISABLED == 1)
  return(disabled)
}

# S_SOC8
# Percentage of illiterate population (%)
S_SOC8 <- function(locations, ...) {
  illiterate <- locations %>%
    st_drop_geometry() %>%
    dplyr::select(GEOLEV2, LIT) %>%
    filter(LIT == 1 | LIT == 2) %>%
    group_by(GEOLEV2, LIT) %>%
    summarise(cnt = n()) %>%
    mutate(val = (cnt / sum(cnt) * 100)) %>%
    filter(LIT == 1)
  return(illiterate)
}

# S_ECO2
# Dependency ratio (%)
# count(filter(vnm, (AGE < 15 | AGE > 64)))
S_ECO2 <- function(locations, ...) {
  dependency_rate <- locations %>%
    st_drop_geometry() %>%
    dplyr::select(GEOLEV2, AGE) %>%
    mutate(DEP = (AGE < 15 | AGE > 64)) %>%
    group_by(GEOLEV2, DEP) %>%
    summarise(cnt = n()) %>%
    mutate(val = (cnt / sum(cnt) * 100)) %>%
    filter(DEP == TRUE)
  return(dependency_rate)
}

# S_INF1
# Percentage of population without access to (improved) sanitation (%)
S_INF1 <- function(locations, ...) {
  no_toilets <- locations %>%
    st_drop_geometry() %>%
    dplyr::select(GEOLEV2, TOILET) %>%
    filter(TOILET != 99 & TOILET != 00) %>%
    group_by(GEOLEV2, TOILET) %>%
    summarise(cnt = n()) %>%
    mutate(val = (cnt / sum(cnt) * 100)) %>%
    filter(TOILET == 10)
  return(no_toilets)
}

# S_INF2
# Percentage of population without access to clean water (%)
# count(filter(vnm, WATSUP != 99 & WATSUP != 00))
# ----------
# TODO: Verify data and check if we need to reverse the normalisation
# ----------
S_INF2 <- function(locations, ...) {
  water_not_piped <- locations %>%
    st_drop_geometry() %>%
    dplyr::select(GEOLEV2, WATSUP) %>%
    filter(WATSUP != 99 & WATSUP != 00) %>%
    mutate(WATSUP = replace(WATSUP, WATSUP == 18, 10)) %>%
    group_by(GEOLEV2, WATSUP) %>%
    summarise(cnt = n()) %>%
    mutate(val = (cnt / sum(cnt) * 100)) %>%
    filter(WATSUP == 20)
  return(water_not_piped)
}

# S_INF3
# Percentage of population without access to electricity (%)
S_INF3 <- function(locations, ...) {
  no_electricity <- locations %>%
    st_drop_geometry() %>%
    dplyr::select(GEOLEV2, ELECTRIC) %>%
    filter(ELECTRIC != 9 & ELECTRIC != 0) %>%
    group_by(GEOLEV2, ELECTRIC) %>%
    summarise(cnt = n()) %>%
    mutate(val = (cnt / sum(cnt) * 100)) %>%
    filter(ELECTRIC == 2)
  return(no_electricity)
}

# --------------------------------------------------
# COPING AND ADAPTATION CAPACITY
# --------------------------------------------------

# C_EWS1
# Percentage of households without access to information (%)
# Proxy: Percentage of households without radio or TV (%)
C_EWS1 <- function(locations, ...) {
  no_tv_radio <- locations %>%
    st_drop_geometry() %>%
    dplyr::select(GEOLEV2, RADIO, TV) %>%
    filter(RADIO != 9 & RADIO != 0 & TV != 00 & TV != 99) %>%
    group_by(GEOLEV2, RADIO, TV) %>%
    summarise(cnt = n()) %>%
    mutate(val = (cnt / sum(cnt) * 100)) %>%
    filter(RADIO == 1 & TV == 10)
  return(no_tv_radio)
}

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
