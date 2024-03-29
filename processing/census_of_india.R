source("common/helpers.R")

clean_column <- function(locations, col) {
  data <- locations %>% st_drop_geometry()
  if (!is.numeric(data[[col]])) {
    data[[col]] <- as.numeric(
      sub(",", ".", data[[col]], fixed = TRUE)
    )
  }
  data$val <- data[[col]]
  col_names <- c("geo_id", "val")
  return(data %>% dplyr::select(any_of(col_names)))
}

# Some data sources only have a district level resolution
# so we need the corresponding district level census
pca11_districts <- read_excel(
  "data/ADMIN/INDIA/CENSUS-2011/2011-IndiaStateDistSbDistTwn-0000.xlsx"
) %>%
  dplyr::filter(
    State == 19
  ) %>%
  dplyr::filter(Level %in% c("DISTRICT"))

# --------------------------------------------------
# SOCIAL SUSCEPTIBILITY
# --------------------------------------------------
# S_SOC3
# Percentage female-headed households (%)
# Data source: PC11_PCA-FH at District level
# https://censusindia.gov.in/nada/index.php/catalog/7036
# Download:
# https://censusindia.gov.in/nada/index.php/catalog/7036/download/10149/PCA-0000.xlsx

# Other data sources:
# https://data.gov.in/resource/female-headed-households-type-structure-census-houses-occupied-2011-west-bengal
# https://data.gov.in/resource/female-headed-households-availability-type-latrine-facility-2011-west-bengal

# What about Gender Inequality as weight?
# http://hdr.undp.org/en/content/gender-inequality-index-gii
S_SOC3 <- function(locations, ...) {
  data <- locations %>% st_drop_geometry()
  # PC11_PCA-FH at District level
  female_hh <- read_excel(
    "data/ADMIN/INDIA/CENSUS-2011/PC11_PCA-FH/PCA-0000.xlsx"
  ) %>%
    dplyr::filter(
      `State Code` == "19",
      `Dist.Code` != "000"
    )
  female_hh$District <- female_hh$`Dist.Code`
  female_hh$F_HH <- female_hh$No_HH
  keep_cols <- c(
    "F_HH",
    "District",
    "TRU"
  )
  female_hh_min <- female_hh[, keep_cols]
  pca11_dist <- dplyr::inner_join(
    female_hh_min, pca11_districts,
    by = c(
      "District" = "District",
      "TRU" = "TRU"
    )
  )
  pca11_dist$S_SOC3 <- pca11_dist$F_HH / pca11_dist$No_HH * 100
  keep_cols <- c(
    "S_SOC3",
    "District",
    "TRU"
  )
  pca11_dist <- pca11_dist[, keep_cols]
  data <- dplyr::inner_join(
    data, pca11_dist,
    by = c(
      "District" = "District",
      "TRU" = "TRU"
    )
  )
  return(clean_column(data, "S_SOC3"))
}

# S_SOC5
# Percentage of population with disabilities (%)
# Data at District level
# https://censusindia.gov.in/nada/index.php/catalog/43388
# https://censusindia.gov.in/nada/index.php/catalog/43388/download/47092/DDW-C20-1900.xlsx
S_SOC5 <- function(locations, ...) {
  data <- locations %>% st_drop_geometry()
  disabilities <- read_excel("data/ADMIN/INDIA/CENSUS-2011/DDW-C20-1900.xlsx", skip = 1) %>%
    dplyr::filter(
      `State Code` == "19",
      `Distt.Code` != "000",
      `Age-group` == "Total",
      `Total/Rural/Urban` != "Total"
    )
  disabilities$District <- disabilities$`Distt.Code`
  disabilities$TRU <- disabilities$`Total/Rural/Urban`
  disabilities$disabled_persons <- as.integer(disabilities$`Total number of disabled persons`)
  keep_cols <- c(
    "District",
    "TRU",
    "disabled_persons"
  )
  disabilities <- disabilities[, keep_cols]
  pca11_dist <- dplyr::inner_join(
    disabilities, pca11_districts,
    by = c(
      "District" = "District",
      "TRU" = "TRU"
    )
  )
  pca11_dist$S_SOC5 <- pca11_dist$disabled_persons / pca11_dist$TOT_P * 100
  keep_cols <- c(
    "S_SOC5",
    "District",
    "TRU"
  )
  pca11_dist <- pca11_dist[, keep_cols]
  data <- dplyr::inner_join(
    data, pca11_dist,
    by = c(
      "District" = "District",
      "TRU" = "TRU"
    )
  )
  return(clean_column(data, "S_SOC5"))
}

# S_SOC8
# Percentage of illiterate population (%)
S_SOC8 <- function(locations, ...) {
  data <- locations %>% st_drop_geometry()
  data$S_SOC8 <- data$P_ILL / (data$TOT_P - data$P_06) * 100
  return(clean_column(data, "S_SOC8"))
}

# S_ECO2
# Dependency ratio (%)
"
Main worker:
Person who had ‘worked’ for 6 months or more
during the reference period (code 1).

Marginal worker:
Person who had ‘worked’ for 3 months or more but less than 6 months (code 2).
Person who had ‘worked’ for less than 3 months (code 3).

Non-worker:
Person who did not ‘work’ at all during the reference period (code 4).
They will include students, persons engaged in household duties,
dependents, pensioners, beggars, etc.
"
S_ECO2 <- function(locations, ...) {
  data <- locations %>% st_drop_geometry()
  data$S_ECO2 <- data$NON_WORK_P / data$TOT_P * 100
  return(clean_column(data, "S_ECO2"))
}

# S_INF1
# Percentage of population without access to (improved) sanitation (%)
# PC11_HL14-19
# Number of households not having latrine facility within the premises (col 100)
S_INF1 <- function(locations, ...) {
  data <- locations %>% st_drop_geometry()
  data$S_INF1 <-
    data$`Number.of.households.not.having.latrine.facility.within.the.premises`
  return(clean_column(data, "S_INF1"))
}

# S_INF2
# Percentage of population without access to clean water (%)
# count(filter(vnm, WATSUP != 99 & WATSUP != 00))
# ----------
# TODO: Verify data and check if we need to reverse the normalisation
# ----------
# Main Source of Drinking Water
# 72 Tap water from treated source
# 73 Tapwater from un-treated source
# 74 Covered well
# 75 Un-covered well
# 76 Handpump
# 77 Tubewell/Borehole
# 78 Spring
# 79 River/Canal
# 80 Tank/Pond/Lake
# 81 Other sources
# --------------------
# We consider 72 (Tap water from treated source) and 78 (Spring) as clean water
S_INF2 <- function(locations, ...) {
  data <- locations %>% st_drop_geometry()
  data$S_INF2 <- 100 - as.numeric(
    data$`Main.Source.of.Drinking.Water..Tapwater.from.treated.source`
  ) - as.numeric(data$`Main.Source.of.Drinking.Water..Spring`)
  return(clean_column(data, "S_INF2"))
}

# S_INF3
# Percentage of population without access to electricity (%)
S_INF3 <- function(locations, ...) {
  data <- locations %>% st_drop_geometry()
  data$S_INF3 <- 100 - data$`Main.Source.of.lighting..Electricity`
  return(clean_column(data, "S_INF3"))
}

# --------------------------------------------------
# COPING AND ADAPTATION CAPACITY
# --------------------------------------------------

# C_EWS1
# Percentage of households without access to information (%)
# Proxy: Percentage of households without radio or TV (%)
# Availability of assets: None of the assets specified in col. 10 to 19: TV - Computer/Laptop - Telephone/mobile phone - Scooter/Car
C_EWS1 <- function(locations, ...) {
  data <- locations %>% st_drop_geometry()
  data$C_EWS1 <- data$`Availability.of.assets..None.of.the.assets.specified.in.col..10.to.19`
  return(clean_column(data, "C_EWS1"))
}
