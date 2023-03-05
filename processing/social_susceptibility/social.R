library(dplyr)
library(formattable)
library(magrittr)
library(sf)
library(stringr)

source("helpers.R")
source("admin.R")

gdri_shp <- admin_shp
vn_deltas <- read.csv(file = "data/Vietnam/vn_deltas.csv")
head(vn_deltas)
# 704 082 005
# VN   82 005
output_dir = "output/Vietnam"
mkdirs(str_glue("{output_dir}/gdri"))

updateGdriShp <- function(df, shp, indicator_code) {
  indicator <- subset(df, select = c (GEOLEV2, cnt, freq, norm))
  indicator <- indicator %>% rename_with( ~ paste0(str_glue("{indicator_code}_"), .x), !matches("GEOLEV2"))
  return(joinOnColumn(indicator, shp, "GEOLEV2"))
}

# https://datacornering.com/calculate-the-percentage-by-a-group-in-r-dplyr/

# S_SOC3
# Percentage female-headed households (%)
# What about Gender Inequality as weight?
# http://hdr.undp.org/en/content/gender-inequality-index-gii
head_household <- filter(vn_deltas, RELATE == 1) %>%
  group_by(GEOLEV2, RELATE, SEX) %>%
  summarise(cnt = n()) %>%
  mutate(freq = (cnt / sum(cnt) * 100))
female_head_household <- head_household %>%
  filter(SEX == 2) %>%
  arrange(desc(freq))
female_head_household$norm <- normalize_minmax(female_head_household$freq, na.rm = TRUE)
write.csv(female_head_household, file = str_glue("{output_dir}/female_head_household.csv"))
gdri_shp <- updateGdriShp(female_head_household, gdri_shp, "S_SOC3")

# S_SOC5
# Percentage of population with disabilities (%)
disabilities <- filter(vn_deltas, DISABLED == 1 | DISABLED == 2) %>%
  group_by(GEOLEV2, DISABLED) %>%
  summarise(cnt = n()) %>%
  mutate(freq = (cnt / sum(cnt) * 100))
disabled <- filter(disabilities, DISABLED == 1) %>%
  arrange(desc(freq))
disabled$norm <- normalize_minmax(disabled$freq, na.rm = TRUE)
write.csv(disabled, file = str_glue("{output_dir}/disabled.csv"))
gdri_shp <- updateGdriShp(disabled, gdri_shp, "S_SOC5")

# S_SOC8
# Percentage of illiterate population (%)
literacy <- filter(vn_deltas, LIT == 1 | LIT == 2) %>%
  group_by(GEOLEV2, LIT) %>%
  summarise(cnt = n()) %>%
  mutate(freq = (cnt / sum(cnt) * 100))
illiterate <- literacy %>%
  filter(LIT == 1) %>%
  arrange(desc(freq))
illiterate$norm <- normalize_minmax(illiterate$freq, na.rm = TRUE)
write.csv(illiterate, file = str_glue("{output_dir}/illiterate.csv"))
gdri_shp <- updateGdriShp(illiterate, gdri_shp, "S_SOC8")

# S_ECO2
# Dependency ratio (%)
# count(filter(vn_deltas, (AGE < 15 | AGE > 64)))
dependancy <- vn_deltas %>%
  mutate(DEP=(AGE < 15 | AGE > 64)) %>%
  group_by(GEOLEV2, DEP) %>%
  summarise(cnt = n()) %>%
  mutate(freq = (cnt / sum(cnt) * 100)) %>%
  arrange(desc(freq))
dependancy_rate <- filter(dependancy, DEP == TRUE)
dependancy_rate$norm <- normalize_minmax(dependancy_rate$freq, na.rm = TRUE)
write.csv(dependancy_rate, file = str_glue("{output_dir}/dependancy_rate.csv"))
gdri_shp <- updateGdriShp(dependancy_rate, gdri_shp, "S_ECO2")

# S_INF1
# Percentage of population without access to (improved) sanitation (%)
toilets <- filter(vn_deltas, TOILET != 99 & TOILET != 00) %>%
  group_by(GEOLEV2, TOILET) %>%
  summarise(cnt = n()) %>%
  mutate(freq = (cnt / sum(cnt) * 100))
no_toilets <- filter(toilets, TOILET == 10) %>%
  arrange(desc(freq))
no_toilets$norm <- normalize_minmax(no_toilets$freq, na.rm = TRUE)
write.csv(no_toilets, file = str_glue("{output_dir}/no_toilets.csv"))
gdri_shp <- updateGdriShp(no_toilets, gdri_shp, "S_INF1")

# S_INF2
# Percentage of population without access to clean water (%)
# count(filter(vn_deltas, WATSUP != 99 & WATSUP != 00))
watsup <- filter(vn_deltas, WATSUP != 99 & WATSUP != 00) %>%
  mutate(WATSUP = replace(WATSUP, WATSUP == 18, 10)) %>%
  group_by(GEOLEV2, WATSUP) %>%
  summarise(cnt = n()) %>%
  mutate(freq = (cnt / sum(cnt) * 100))

water_not_piped <- filter(watsup, WATSUP == 20) %>%
  arrange(desc(freq))
water_not_piped$norm <- normalize_minmax(water_not_piped$freq, na.rm = TRUE)
write.csv(water_not_piped, file = str_glue("{output_dir}/water_not_piped.csv"))
gdri_shp <- updateGdriShp(water_not_piped, gdri_shp, "S_INF2")

# S_INF3
# Percentage of population without access to electricity (%)
electricity <- filter(vn_deltas, ELECTRIC != 9 & ELECTRIC != 0) %>%
  group_by(GEOLEV2, ELECTRIC) %>%
  summarise(cnt = n()) %>%
  mutate(freq = (cnt / sum(cnt) * 100))
no_electricity <- electricity %>%
  filter(ELECTRIC == 2) %>%
  arrange(desc(freq))
no_electricity$norm <- normalize_minmax(no_electricity$freq, na.rm = TRUE)
write.csv(no_electricity, file = str_glue("{output_dir}/no_electricity.csv"))
gdri_shp <- updateGdriShp(no_electricity, gdri_shp, "S_INF3")

# C_EWS1
# Percentage of households without access to information (%)
# Proxy: Percentage of households without radio or TV (%)
tv_radio <- filter(vn_deltas, RADIO != 9 & RADIO != 0 & TV != 00 & TV != 99) %>%
  group_by(GEOLEV2, RADIO, TV) %>%
  summarise(cnt = n()) %>%
  mutate(freq = (cnt / sum(cnt) * 100))
no_tv_radio <- tv_radio %>%
  filter(RADIO == 1 & TV == 10) %>%
  arrange(freq)
no_tv_radio$norm <- normalize_minmax(no_tv_radio$freq, na.rm = TRUE)
write.csv(no_tv_radio, file = str_glue("{output_dir}/no_tv_radio.csv"))
gdri_shp <- updateGdriShp(no_tv_radio, gdri_shp, "C_EWS1")

mapPlot(gdri_shp, "S_SOC3_norm", "Normalized 0 to 1", "S_SOC3 female headed households")

st_write(gdri_shp, str_glue("{output_dir}/gdri/gdri.shp"), append=FALSE)

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
