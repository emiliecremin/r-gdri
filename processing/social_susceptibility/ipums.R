# https://datacornering.com/calculate-the-percentage-by-a-group-in-r-dplyr/

# S_SOC3
# Percentage female-headed households (%)
# What about Gender Inequality as weight?
# http://hdr.undp.org/en/content/gender-inequality-index-gii
S_SOC3 <- function(data) {
  female_head_household <- filter(data, RELATE == 1) %>%
    group_by(GEOLEV2, SEX) %>%
    summarise(cnt = n()) %>%
    mutate(val = (cnt / sum(cnt) * 100)) %>%
    filter(SEX == 2)
  return(female_head_household)
}

# S_SOC5
# Percentage of population with disabilities (%)
S_SOC5 <- function(data) {
  disabled <- filter(data, DISABLED == 1 | DISABLED == 2) %>%
    group_by(GEOLEV2, DISABLED) %>%
    summarise(cnt = n()) %>%
    mutate(val = (cnt / sum(cnt) * 100)) %>%
    filter(DISABLED == 1)
  return(disabled)
}

# S_SOC8
# Percentage of illiterate population (%)
S_SOC8 <- function(data) {
  illiterate <- filter(data, LIT == 1 | LIT == 2) %>%
    group_by(GEOLEV2, LIT) %>%
    summarise(cnt = n()) %>%
    mutate(val = (cnt / sum(cnt) * 100)) %>%
    filter(LIT == 1)
  return(illiterate)
}

# S_ECO2
# Dependency ratio (%)
# count(filter(vnm, (AGE < 15 | AGE > 64)))
S_ECO2 <- function(data) {
  dependency_rate <- data %>%
    mutate(DEP = (AGE < 15 | AGE > 64)) %>%
    group_by(GEOLEV2, DEP) %>%
    summarise(cnt = n()) %>%
    mutate(val = (cnt / sum(cnt) * 100)) %>%
    filter(DEP == TRUE)
  return(dependency_rate)
}

# S_INF1
# Percentage of population without access to (improved) sanitation (%)
S_INF1 <- function(data) {
  no_toilets <- filter(data, TOILET != 99 & TOILET != 00) %>%
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
S_INF2 <- function(data) {
  water_not_piped <- filter(data, WATSUP != 99 & WATSUP != 00) %>%
    mutate(WATSUP = replace(WATSUP, WATSUP == 18, 10)) %>%
    group_by(GEOLEV2, WATSUP) %>%
    summarise(cnt = n()) %>%
    mutate(val = (cnt / sum(cnt) * 100)) %>%
    filter(WATSUP == 20)
  return(water_not_piped)
}

# S_INF3
# Percentage of population without access to electricity (%)
S_INF3 <- function(data) {
  no_electricity <- filter(data, ELECTRIC != 9 & ELECTRIC != 0) %>%
    group_by(GEOLEV2, ELECTRIC) %>%
    summarise(cnt = n()) %>%
    mutate(val = (cnt / sum(cnt) * 100)) %>%
    filter(ELECTRIC == 2)
  return(no_electricity)
}
