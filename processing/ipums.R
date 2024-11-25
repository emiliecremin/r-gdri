# https://datacornering.com/calculate-the-percentage-by-a-group-in-r-dplyr/


# --------------------------------------------------
# SOCIAL SUSCEPTIBILITY
# --------------------------------------------------

# S_SOC3
# Percentage female-headed households (%)
# What about Gender Inequality as weight?
# http://hdr.undp.org/en/content/gender-inequality-index-gii
S_SOC3 <- function(locations, social_data, ...) {
  female_head_household <- social_data %>%
    st_drop_geometry() %>%
    dplyr::select(GEOLEV2, RELATE, SEX) %>%
    filter(RELATE == 1) %>%
    group_by(GEOLEV2, SEX) %>%
    summarise(cnt = n()) %>%
    mutate(val = (cnt / sum(cnt) * 100)) %>%
    filter(SEX == 2)
  result <- collapse::join(
    locations,
    female_head_household,
    how = "full",
    on = "GEOLEV2",
    verbose = 2
  )
  return(result)
}

# S_SOC5
# Percentage of population with disabilities (%)
S_SOC5 <- function(locations, social_data, ...) {
  disabled <- social_data %>%
    st_drop_geometry() %>%
    dplyr::select(GEOLEV2, DISABLED) %>%
    filter(DISABLED == 1 | DISABLED == 2) %>%
    group_by(GEOLEV2, DISABLED) %>%
    summarise(cnt = n()) %>%
    mutate(val = (cnt / sum(cnt) * 100)) %>%
    filter(DISABLED == 1)
  result <- collapse::join(
    locations,
    disabled,
    how = "full",
    on = "GEOLEV2",
    verbose = 2
  )
  return(result)
}

# S_SOC8
# Percentage of illiterate population (%)
S_SOC8 <- function(locations, social_data, ...) {
  illiterate <- social_data %>%
    st_drop_geometry() %>%
    dplyr::select(GEOLEV2, LIT) %>%
    filter(LIT == 1 | LIT == 2) %>%
    group_by(GEOLEV2, LIT) %>%
    summarise(cnt = n()) %>%
    mutate(val = (cnt / sum(cnt) * 100)) %>%
    filter(LIT == 1)
  result <- collapse::join(
    locations,
    illiterate,
    how = "full",
    on = "GEOLEV2",
    verbose = 2
  )
  return(result)
}

# S_ECO2
# Dependency ratio (%)
# count(filter(vnm, (AGE < 15 | AGE > 64)))
S_ECO2 <- function(locations, social_data, ...) {
  dependency_rate <- social_data %>%
    st_drop_geometry() %>%
    dplyr::select(GEOLEV2, AGE) %>%
    mutate(DEP = (AGE < 15 | AGE > 64)) %>%
    group_by(GEOLEV2, DEP) %>%
    summarise(cnt = n()) %>%
    mutate(val = (cnt / sum(cnt) * 100)) %>%
    filter(DEP == TRUE)
  result <- collapse::join(
    locations,
    dependency_rate,
    how = "full",
    on = "GEOLEV2",
    verbose = 2
  )
  return(result)
}

# S_INF1
# Percentage of population without access to (improved) sanitation (%)
S_INF1 <- function(locations, social_data, ...) {
  no_toilets <- social_data %>%
    st_drop_geometry() %>%
    dplyr::select(GEOLEV2, TOILET) %>%
    filter(TOILET != 99 & TOILET != 00) %>%
    group_by(GEOLEV2, TOILET) %>%
    summarise(cnt = n()) %>%
    mutate(val = (cnt / sum(cnt) * 100)) %>%
    filter(TOILET == 10)
  result <- collapse::join(
    locations,
    no_toilets,
    how = "full",
    on = "GEOLEV2",
    verbose = 2
  )
  return(result)
}

# S_INF2
# Percentage of population without access to clean water (%)
# count(filter(vnm, WATSUP != 99 & WATSUP != 00))
# BGD data from SDG
source("processing/SDG.R")
S_INF2 <- function(locations, social_data, ...) {
  if (unique(locations$country_iso3)[1] == "BGD") {
    result <- bgd_water_supply(locations)
  } else {
    water_not_piped <- social_data %>%
      st_drop_geometry() %>%
      dplyr::select(GEOLEV2, WATSUP) %>%
      filter(WATSUP != 99 & WATSUP != 00) %>%
      mutate(WATSUP = replace(WATSUP, WATSUP == 18, 10)) %>%
      group_by(GEOLEV2, WATSUP) %>%
      summarise(cnt = n()) %>%
      mutate(val = (cnt / sum(cnt) * 100)) %>%
      filter(WATSUP == 20)
    result <- collapse::join(
      locations,
      water_not_piped,
      how = "full",
      on = "GEOLEV2",
      verbose = 2
    )
  }
  return(result)
}

# S_INF3
# Percentage of population without access to electricity (%)
S_INF3 <- function(locations, social_data, ...) {
  no_electricity <- social_data %>%
    st_drop_geometry() %>%
    dplyr::select(GEOLEV2, ELECTRIC) %>%
    filter(ELECTRIC != 9 & ELECTRIC != 0) %>%
    group_by(GEOLEV2, ELECTRIC) %>%
    summarise(cnt = n()) %>%
    mutate(val = (cnt / sum(cnt) * 100)) %>%
    filter(ELECTRIC == 2)
  result <- collapse::join(
    locations,
    no_electricity,
    how = "full",
    on = "GEOLEV2",
    verbose = 2
  )
  return(result)
}

# --------------------------------------------------
# COPING AND ADAPTATION CAPACITY
# --------------------------------------------------

# Bangladesh Bureau of Statistics (BBS)
# Census 2011
# http://redatam.bbs.gov.bd/redbin/RpWebEngine.exe/Portal?BASE=HPC2011_long&lang=ENG
bgd_tv_radio <- function(locations) {
  bgd_tv_radio <- read_excel("data/ADMIN/BGD/TV-Radio.xlsx", sheet="tv-radio")
  locations <- locations %>% collapse::join(bgd_tv_radio, on = c("adm2_name" = "Zila"))
  locations$val <- locations$No * 100 / locations$Household
  return(locations)
}


# C_EWS1
# Percentage of households without access to information (%)
# Proxy: Percentage of households without radio or TV (%)
C_EWS1 <- function(locations, social_data, ...) {
  if (unique(locations$country_iso3)[1] == "BGD") {
    result <- bgd_tv_radio(locations)
  } else {
    no_tv_radio <- social_data %>%
      st_drop_geometry() %>%
      dplyr::select(GEOLEV2, RADIO, TV) %>%
      filter(RADIO != 9 & RADIO != 0 & TV != 00 & TV != 99) %>%
      group_by(GEOLEV2, RADIO, TV) %>%
      summarise(cnt = n()) %>%
      mutate(val = (cnt / sum(cnt) * 100)) %>%
      filter(RADIO == 1 & TV == 10)
    result <- collapse::join(
      locations,
      no_tv_radio,
      how = "full",
      on = "GEOLEV2",
      verbose = 2
    )
  }
  return(result)
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
