source("common/helpers.R")

# Source: ESRI 2021
# https://livingatlas-dcdev.opendata.arcgis.com/datasets/esriindia1::india-village-boundary-2021/about
# https://opendata.arcgis.com/api/v3/datasets/6e48332636074603acbc55e116ab264e_0/downloads/data?format=shp&spatialRefId=4326&where=1%3D1
print("India_Village_Boundary_2021 is a large data source, loading...")
esri_wb <- st_read(
  "data/ADMIN/INDIA/ESRI - 2021/India_Village_Boundary_2021/India_Village_Boundary_2021.shp"
) %>%
  dplyr::filter(lgd_statec == 19) %>%
  st_make_valid()
# Format subdistrict to compare with the census of india
max(nchar(as.character(esri_wb$lgd_subdis)), na.rm = TRUE)
esri_wb$lgd_subdis[is.na(esri_wb$lgd_subdis)] <- 99999
esri_wb$lgd_subdis <- sprintf("%05s", as.character(esri_wb$lgd_subdis))
esri_wb$C_CODE11 <- esri_wb$censusco_1

# POPULATION FINDER 2011
# https://censusindia.gov.in/census.website/data/population-finder

# Basic Population Figures of India, States, Districts, Sub-District and Village, 2011.
# https://censusindia.gov.in/nada/index.php/catalog/42554/download/46180/2011-IndiaStateDistSbDistVill-0000.xlsx
pca11_villages <- read_excel(
  "data/ADMIN/INDIA/CENSUS-2011/2011-IndiaStateDistSbDistVill-0000.xlsx"
)
# Basic Population Figures of India, States, Districts, Sub-District and Town (Without Ward), 2011.
# https://censusindia.gov.in/nada/index.php/catalog/42559/download/46185/2011-IndiaStateDistSbDistTwn-0000.xlsx
pca11_towns <- read_excel(
  "data/ADMIN/INDIA/CENSUS-2011/2011-IndiaStateDistSbDistTwn-0000.xlsx"
)
pca11 <- rbind(pca11_towns, pca11_villages)

colnames(pca11)
unique(pca11$TRU)
unique(pca11$Level)
pca11_wb <- pca11 %>% dplyr::filter(
  State == 19
)
write.csv(pca11_wb, "data/ADMIN/INDIA/CENSUS-2011/pca11_wb.csv")
pca11_wb$Subdistt <- as.numeric(pca11_wb$Subdistt)

keep_cols <- c(
  "censuscode",
  "censusco_1",
  "censusco_2",
  "lgd_villag",
  "lgd_statec",
  "lgd_distri",
  "lgd_subdis",
  "geometry"
)
esri_wb <- esri_wb[, keep_cols]

census_ind_2011 <- dplyr::left_join(
  esri_wb, pca11_wb,
  by = c("censusco_1" = "Town/Village", "lgd_subdis" = "Subdistt")
) %>% st_as_sf()


census_ind_2011$geo_id <- paste(
  census_ind_2011$lgd_statec,
  census_ind_2011$District,
  census_ind_2011$lgd_subdis,
  census_ind_2011$censusco_1,
  sep = ""
)

st_write(
  census_ind_2011,
  "data/admin/INDIA/census_ind_2011.gpkg",
  append = FALSE
)

# census_ind_2011 <- st_read("data/admin/INDIA/census_ind_2011.gpkg")

# --------------------------------------------------
# SOCIAL SUSCEPTIBILITY
# --------------------------------------------------

clean_column <- function(data, col) {
  if (!is.numeric(data[[col]])) {
    data[[col]] <- as.numeric(
      sub(",", ".", data[[col]], fixed = TRUE)
    )
  }
  col_names <- c("geo_id", col)
  return(data %>% dplyr::select(any_of(col_names)))
}

# S_SOC3
# Percentage female-headed households (%)
# What about Gender Inequality as weight?
# http://hdr.undp.org/en/content/gender-inequality-index-gii
S_SOC3 <- function(data, ...) {
  return(clean_column(data, "S_SOC3"))
}

# S_SOC5
# Percentage of population with disabilities (%)
S_SOC5 <- function(data, ...) {
  return(clean_column(data, "S_SOC5"))
}

# S_SOC8
# Percentage of illiterate population (%)
S_SOC8 <- function(data, ...) {
  data$S_SOC8 <- data$P_ILL / (data$TOT_P - data$P_06)
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
S_ECO2 <- function(data, ...) {
  data$S_ECO2 <- data$NON_WORK_P / data$TOT_P
  return(clean_column(data, "S_ECO2"))
}

# S_INF1
# Percentage of population without access to (improved) sanitation (%)
# PC11_HL14-19
# Number of households not having latrine facility within the premises (col 100)
S_INF1 <- function(data, ...) {
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
S_INF2 <- function(data, ...) {
  return(clean_column(data, "S_INF2"))
}

# S_INF3
# Percentage of population without access to electricity (%)
S_INF3 <- function(data, ...) {
  return(clean_column(data, "S_INF3"))
}

# --------------------------------------------------
# COPING AND ADAPTATION CAPACITY
# --------------------------------------------------

# C_EWS1
# Percentage of households without access to information (%)
# Proxy: Percentage of households without radio or TV (%)
C_EWS1 <- function(data, ...) {
  return(clean_column(data, "C_EWS1"))
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
