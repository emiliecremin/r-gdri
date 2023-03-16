library(dplyr)
library(formattable)
library(magrittr)
library(sf)
library(stringr)

source("common/admin.R")
source("common/helpers.R")

# install.packages("usethis")
# library(usethis)
# usethis::edit_r_environ()
# R_MAX_VSIZE=100Gb 
# Error: vector memory exhausted (limit reached?)
# https://stackoverflow.com/questions/51295402/r-on-macos-error-vector-memory-exhausted-limit-reached

locations <- st_read("data/ADMIN/admin.shp")
# ipums_data <- read.csv(file = "data/IPUMS/ipumsi_00005.csv")
# vnm <- ipums_data %>% dplyr::filter(COUNTRY == 704)
vnm <- read.csv(file = "data/Vietnam/vietnam_2009.csv")

output_dir = "output/social_susceptibility"
mkdirs(output_dir)

# https://datacornering.com/calculate-the-percentage-by-a-group-in-r-dplyr/

# S_SOC3
# Percentage female-headed households (%)
# What about Gender Inequality as weight?
# http://hdr.undp.org/en/content/gender-inequality-index-gii
head_household <- filter(vnm, RELATE == 1) %>%
  group_by(GEOLEV2, RELATE, SEX) %>%
  summarise(cnt = n()) %>%
  mutate(val = (cnt / sum(cnt) * 100))
female_head_household <- head_household %>%
  filter(SEX == 2) %>%
  arrange(desc(val))
female_head_household$norm <- normalize_minmax(female_head_household$val, na.rm = TRUE)
female_head_household <- joinOnColumn(female_head_household, locations, "GEOLEV2")
# mapPlot(female_head_household, "norm", "norm min-max", "S_SOC3_female_head_household")
st_write(female_head_household, "output/social_susceptibility/S_SOC3_female_head_household.gpkg", append = FALSE)


# S_SOC5
# Percentage of population with disabilities (%)
disabilities <- filter(vnm, DISABLED == 1 | DISABLED == 2) %>%
  group_by(GEOLEV2, DISABLED) %>%
  summarise(cnt = n()) %>%
  mutate(val = (cnt / sum(cnt) * 100))
disabled <- filter(disabilities, DISABLED == 1) %>%
  arrange(desc(val))
disabled$norm <- normalize_minmax(disabled$val, na.rm = TRUE)
disabled <- joinOnColumn(disabled, locations, "GEOLEV2")
# mapPlot(disabled, "norm", "norm min-max", "S_SOC5_disabilities")
st_write(disabled, "output/social_susceptibility/S_SOC5_disabilities.gpkg", append = FALSE)

# S_SOC8
# Percentage of illiterate population (%)
literacy <- filter(vnm, LIT == 1 | LIT == 2) %>%
  group_by(GEOLEV2, LIT) %>%
  summarise(cnt = n()) %>%
  mutate(val = (cnt / sum(cnt) * 100))
illiterate <- literacy %>%
  filter(LIT == 1) %>%
  arrange(desc(val))
illiterate$norm <- normalize_minmax(illiterate$val, na.rm = TRUE)
illiterate <- joinOnColumn(illiterate, locations, "GEOLEV2")
# mapPlot(illiterate, "norm", "norm min-max", "S_SOC8_illiteracy")
st_write(illiterate, "output/social_susceptibility/S_SOC8_illiteracy.gpkg", append = FALSE)

# S_ECO2
# Dependency ratio (%)
# count(filter(vnm, (AGE < 15 | AGE > 64)))
dependancy <- vnm %>%
  mutate(DEP=(AGE < 15 | AGE > 64)) %>%
  group_by(GEOLEV2, DEP) %>%
  summarise(cnt = n()) %>%
  mutate(val = (cnt / sum(cnt) * 100)) %>%
  arrange(desc(val))
dependency_rate <- filter(dependancy, DEP == TRUE)
dependency_rate$norm <- normalize_minmax(dependency_rate$val, na.rm = TRUE)
dependency_rate <- joinOnColumn(dependency_rate, locations, "GEOLEV2")
mapPlot(dependency_rate, "norm", "norm min-max", "S_ECO2_dependency")
st_write(dependency_rate, "output/social_susceptibility/S_ECO2_dependency.gpkg", append = FALSE)


# S_INF1
# Percentage of population without access to (improved) sanitation (%)
unique(vnm$TOILET)
toilets <- filter(vnm, TOILET != 99 & TOILET != 00) %>%
  group_by(GEOLEV2, TOILET) %>%
  summarise(cnt = n()) %>%
  mutate(val = (cnt / sum(cnt) * 100))
no_toilets <- filter(toilets, TOILET == 10) %>%
  arrange(desc(val))
no_toilets$norm <- normalize_minmax(no_toilets$val, na.rm = TRUE)
no_toilets <- joinOnColumn(no_toilets, locations, "GEOLEV2")
mapPlot(no_toilets, "norm", "norm min-max", "S_INF1_no_toilets")
st_write(no_toilets, "output/social_susceptibility/S_INF1_no_toilets.gpkg", append = FALSE)

# S_INF2
# Percentage of population without access to clean water (%)
# count(filter(vnm, WATSUP != 99 & WATSUP != 00))
# ----------
# TODO: Verify data and check if we need to reverse the normalisation
# ----------
watsup <- filter(vnm, WATSUP != 99 & WATSUP != 00) %>%
  mutate(WATSUP = replace(WATSUP, WATSUP == 18, 10)) %>%
  group_by(GEOLEV2, WATSUP) %>%
  summarise(cnt = n()) %>%
  mutate(val = (cnt / sum(cnt) * 100))
water_not_piped <- filter(watsup, WATSUP == 20) %>%
  arrange(desc(val))
water_not_piped$norm <- normalize_minmax(water_not_piped$val, na.rm = TRUE)
water_not_piped <- joinOnColumn(water_not_piped, locations, "GEOLEV2")
mapPlot(water_not_piped, "norm", "norm min-max", "S_INF2_clean_water")
st_write(water_not_piped, "output/social_susceptibility/S_INF2_clean_water.gpkg", append = FALSE)

# S_INF3
# Percentage of population without access to electricity (%)
electricity <- filter(vnm, ELECTRIC != 9 & ELECTRIC != 0) %>%
  group_by(GEOLEV2, ELECTRIC) %>%
  summarise(cnt = n()) %>%
  mutate(val = (cnt / sum(cnt) * 100))
no_electricity <- electricity %>%
  filter(ELECTRIC == 2) %>%
  arrange(desc(val))
no_electricity$norm <- normalize_minmax(no_electricity$val, na.rm = TRUE)
no_electricity <- joinOnColumn(no_electricity, locations, "GEOLEV2")
mapPlot(no_electricity, "norm", "norm min-max", "S_INF3_electricity")
st_write(no_electricity, "output/social_susceptibility/S_INF3_electricity.gpkg", append = FALSE)

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
st_write(no_tv_radio, "output/social_susceptibility/C_EWS1_tv_radio.gpkg", append = FALSE)

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
