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

# Analysis of duplicates in the shapefile
nrow(esri_wb)
no_na <- esri_wb %>% dplyr::filter(!is.na(censusco_1))
duplicate_counts <- no_na |>
  add_count(censusco_1) |>
  filter(n > 1) |>
  distinct()

st_write(
  duplicate_counts,
  "data/admin/INDIA/duplicates.gpkg",
  append = FALSE
)

dup_without_nohh <- duplicate_counts %>%
  dplyr::filter(is.na(no_hh)) %>%
  dplyr::select(censusco_1)
dup_without_nohh$censusco_1

# We found 3 duplicates in the shapefile that have NA in no_hh column.
# We need to merge each duplicate:
# 801760 - Haldia (x2)
# 801634 - Darjiling (x2)
# 801740 - Haora (x2)
to_merge <- dup_without_nohh$censusco_1

unified <- esri_wb %>%
  dplyr::filter(censusco_1 %in% to_merge) %>%
  group_by(censusco_1) %>%
  summarise(geometry = sf::st_union(geometry)) %>%
  ungroup()

merged <- esri_wb %>%
  dplyr::filter(censusco_1 %in% to_merge & !is.na(no_hh)) %>%
  st_drop_geometry() %>%
  dplyr::left_join(
    unified,
    by = "censusco_1"
  ) %>%
  st_as_sf()

# TODO: recalculate area and length of the merged polygons

binding <- rbind(
  merged,
  esri_wb %>% dplyr::filter(!(censusco_1 %in% to_merge))
)
no_binding <- esri_wb %>% dplyr::filter(is.na(censusco_1))

# POPULATION FINDER 2011
# https://censusindia.gov.in/census.website/data/population-finder

# Basic Population Figures of India, States, Districts, Sub-District and Village, 2011.
# https://censusindia.gov.in/nada/index.php/catalog/42554/download/46180/2011-IndiaStateDistSbDistVill-0000.xlsx
pca11_villages <- read_excel(
  "data/ADMIN/INDIA/CENSUS-2011/2011-IndiaStateDistSbDistVill-0000.xlsx"
) %>%
  dplyr::filter(
    State == 19
  ) %>%
  dplyr::filter(Level == "VILLAGE")
# Basic Population Figures of India, States, Districts, Sub-District and Town (Without Ward), 2011.
# https://censusindia.gov.in/nada/index.php/catalog/42559/download/46185/2011-IndiaStateDistSbDistTwn-0000.xlsx
pca11_towns <- read_excel(
  "data/ADMIN/INDIA/CENSUS-2011/2011-IndiaStateDistSbDistTwn-0000.xlsx"
) %>%
  dplyr::filter(
    State == 19
  ) %>%
  dplyr::filter(Level %in% c("TOWN"))

# Duplicates in Towns
towns_duplicates <- pca11_towns |>
  add_count(`Town/Village`) |>
  filter(n > 1) |>
  distinct()

# There are 2 lines for this Town in the Census,
# but only 1 Polygon in the shapefile.
# We need to add the values of these 2 Census villages together
# to match the shapefile
# 318642
sum_kendra <- pca11_towns %>%
  dplyr::filter(`Town/Village` == 318642) %>%
  summarize_if(is.numeric, sum, na.rm = TRUE)
sum_kendra <- data.frame(sum_kendra)
drop_list <- colnames(sum_kendra)

sum_kendra$`Town/Village` <- "318642"

sum_kendra <- pca11_towns %>%
  dplyr::filter(`Town/Village` == 318642) %>%
  filter(row_number() == 1) %>%
  dplyr::select(-one_of(drop_list)) %>%
  left_join(sum_kendra, by = "Town/Village")

pca11_towns <- rbind(pca11_towns %>%
  dplyr::filter(`Town/Village` != 318642), sum_kendra)

keep_cols <- c(
  "censusname",
  "no_hh",
  "censuscode",
  "censusco_1",
  "censusco_2",
  "lgd_villag",
  "lgd_statec",
  "lgd_distri",
  "lgd_subdis",
  "geometry"
)
binding_min <- binding[, keep_cols]

towns_nohh <- binding_min %>%
  inner_join(
    pca11_towns,
    by = c("censusco_1" = "Town/Village", "no_hh" = "No_HH")
  ) %>%
  st_as_sf()

towns_nohh <- towns_nohh %>%
  dplyr::select(-Subdistt) %>%
  st_as_sf()

st_write(
  towns_nohh,
  "data/admin/INDIA/towns_nohh.gpkg",
  append = FALSE
)

# No duplicates in villages using sub-district
villages_duplicates <- pca11_villages |>
  add_count(`Town/Village`, Subdistt) |>
  filter(n > 1) |>
  distinct()

census_2011_villages <- dplyr::inner_join(
  binding_min, pca11_villages,
  by = c(
    "censusco_1" = "Town/Village",
    "lgd_subdis" = "Subdistt"
  )
) %>%
  st_as_sf()

census_2011_villages <- census_2011_villages %>%
  dplyr::select(-No_HH) %>%
  st_as_sf()

# Define empty columns
empty_cols <- colnames(pca11_towns)
no_binding_min <- no_binding[, keep_cols] %>% st_drop_geometry()
# Add multiple empty columns
no_binding_min[, empty_cols] <- NA
no_binding_min$geometry <- no_binding$geometry
no_binding_min$Name <- no_binding$name
no_binding_min$TRU <- no_binding$tru
no_binding_min <- no_binding_min %>%
  dplyr::select(-Subdistt) %>%
  dplyr::select(-No_HH) %>%
  dplyr::select(-`Town/Village`) %>%
  st_as_sf()

setdiff(colnames(census_2011_villages), colnames(towns_nohh))
census_2011 <- rbind(towns_nohh, census_2011_villages, no_binding_min)

st_write(
  census_2011,
  "data/admin/INDIA/full_census_2011.gpkg",
  append = FALSE
)

census_ind_2011$geo_id <- paste(
  census_ind_2011$lgd_statec,
  census_ind_2011$District,
  census_ind_2011$lgd_subdis,
  census_ind_2011$censusco_1,
  sep = ""
)


# census_ind_2011 <- st_read("data/admin/INDIA/census_ind_2011.gpkg")

  dir <- "data/ADMIN/INDIA/CENSUS-2011/PC11_HL14"
  hlpca_files <- list.files(
    normalizePath(dir),
    pattern = "\\.(xls|xlsx)$",
    ignore.case = TRUE,
    full.names = TRUE
  )
  hlpca = data.frame()
  for (f in hlpca_files) {
      tmp <- read_excel(
        f,
        skip = 2
      ) %>%
      dplyr::filter(
        `State Code` == "19",
        `Rural/Urban` != "Total"
      )
      hlpca <- rbind(hlpca,tmp)
  }
  colnames(hlpca)
  cols_hlpca <- read.csv("data/ADMIN/INDIA/CENSUS-2011/PC11_HL14/hlpca-colnames.csv")
  colnames(hlpca) <- cols_hlpca$column_name

  # TMP ##########################
  data <- st_read("data/admin/INDIA/full_census_2011.gpkg")
  ################################
  hlpca_filtered <- hlpca %>% dplyr::filter(
    # `Tehsil Code` != "00000",
    # `Town Code/Village code` != "00000",
    `Ward No` == "0000"
  )
  nrow(hlpca_filtered)
  hlpca_census_villages <- data %>% dplyr::inner_join(
    hlpca,
    by = c(
      "censusco_1" = "Town Code/Village code", 
      "District" = "District Code", 
      "lgd_subdis" = "Tehsil Code",
      "Ward" = "Ward No",
      "TRU" = "Rural/Urban"
    )
  )
  st_write(
    hlpca_census_villages,
    "data/admin/INDIA/hlpca_census_villages.gpkg",
    append = FALSE
  )

  keep_cols <- hlpca %>%
    dplyr::select(`Number of households with condition of Census House as: Total (Total)`:last_col())
  

  hlpca_towns <- hlpca %>% dplyr::filter(
    `Tehsil Code` == "99999",
    `Town Code/Village code` != "000000",
    `Ward No` == "0000"
  )

  hlpca_census_towns <- data %>% dplyr::inner_join(
    hlpca_towns,
    by = c(
      "censusco_1" = "Town Code/Village code", 
      "District" = "District Code", 
      #"lgd_subdis" = "Tehsil Code",
      # "Ward" = "Ward No",
      "TRU" = "Rural/Urban"
    )
  ) %>% dplyr::filter(!censusco_1 %in% hlpca_census_villages$censusco_1)

  st_write(
    hlpca_census_towns,
    "data/admin/INDIA/hlpca_census_towns.gpkg",
    append = FALSE
  )

  hlpca_per_subdistrict <- hlpca %>% dplyr::filter(
    `Town Code/Village code` == "000000",
    `Tehsil Code` != "00000",
    `Tehsil Code` != "99999"
  )

  hlpca_census_subdistrict <- data %>% 
  dplyr::filter(!censusco_1 %in% c(hlpca_census_villages$censusco_1, hlpca_census_towns$censusco_1)) %>%
  dplyr::inner_join(
    hlpca_per_subdistrict,
    by = c(
      # "censusco_1" = "Town Code/Village code", 
      "District" = "District Code", 
      "lgd_subdis" = "Tehsil Code",
      # "Ward" = "Ward No",
      "TRU" = "Rural/Urban"
    )
  )

  st_write(
    hlpca_census_subdistrict,
    "data/admin/INDIA/hlpca_census_subdistrict.gpkg",
    append = FALSE
  )

  no_binding <- data %>% dplyr::filter(is.na(District))
  # Define empty columns
  empty_cols <- colnames(hlpca)
  no_binding_min <- no_binding[, keep_cols] %>% st_drop_geometry()
  # Add multiple empty columns
  no_binding[, empty_cols] <- NA
  no_binding <- no_binding %>% st_as_sf()
  # st_geometry(no_binding) <- "geometry"
  no_binding <- no_binding %>% relocate(geom, .after = last_col())

  drop_cols <- setdiff(colnames(no_binding), colnames(hlpca_census_villages))
  no_binding$`District Code`
  no_binding$`Tehsil Code`
  no_binding$`Town Code/Village code`
  no_binding$`Ward No`
  no_binding$`Rural/Urban`
  no_binding_drop <- no_binding %>% dplyr::select(-one_of(drop_cols))
  setdiff(colnames(no_binding_drop), colnames(hlpca_census_villages))
  rbind(hlpca_census_villages, no_binding_drop)
  
  drop_cols <- setdiff(colnames(hlpca_census_subdistrict), colnames(hlpca_census_villages))
  hlpca_census_subdistrict_drop <- hlpca_census_subdistrict %>% dplyr::select(-one_of(drop_cols))

  drop_cols <- setdiff(colnames(hlpca_census_towns), colnames(hlpca_census_villages))
  hlpca_census_towns_drop <- hlpca_census_towns %>% dplyr::select(-one_of(drop_cols))

  hlpca_full <- rbind(hlpca_census_villages, hlpca_census_towns_drop, hlpca_census_subdistrict_drop, no_binding_drop)
  st_write(
    hlpca_full,
    "data/admin/INDIA/hlpca_census_2011.gpkg",
    append = FALSE
  )

# TODO: add common columns
# CNTRY_NAME
# country_iso3

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
# Data source:
# https://censusindia.gov.in/nada/index.php/catalog/7036
# Download:
# https://censusindia.gov.in/nada/index.php/catalog/7036/download/10149/PCA-0000.xlsx

# Other data sources:
# https://data.gov.in/resource/female-headed-households-type-structure-census-houses-occupied-2011-west-bengal
# https://data.gov.in/resource/female-headed-households-availability-type-latrine-facility-2011-west-bengal

# What about Gender Inequality as weight?
# http://hdr.undp.org/en/content/gender-inequality-index-gii
S_SOC3 <- function(data, ...) {
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
  pca11_districts <- read_excel(
    "data/ADMIN/INDIA/CENSUS-2011/2011-IndiaStateDistSbDistTwn-0000.xlsx"
  ) %>%
    dplyr::filter(
      State == 19
    ) %>%
    dplyr::filter(Level %in% c("DISTRICT"))

  pca11_districts <- dplyr::inner_join(
    female_hh_min, pca11_districts,
    by = c(
      "District" = "District",
      "TRU" = "TRU"
    )
  )
  pca11_districts$S_SOC3 <- pca11_districts$F_HH / pca11_districts$No_HH
  keep_cols <- c(
    "S_SOC3",
    "District",
    "TRU"
  )
  pca11_districts <- pca11_districts[, keep_cols]
  data <- dplyr::inner_join(
    data, pca11_districts,
    by = c(
      "District" = "District",
      "TRU" = "TRU"
    )
  )
  return(clean_column(data, "S_SOC3"))
}

# S_SOC5
# Percentage of population with disabilities (%)
# https://censusindia.gov.in/nada/index.php/catalog/43388
# https://censusindia.gov.in/nada/index.php/catalog/43388/download/47092/DDW-C20-1900.xlsx
S_SOC5 <- function(data, ...) {
   disabilities <- read_excel("data/ADMIN/INDIA/CENSUS-2011/DDW-C20-1900.xlsx", skip = 1) %>% 
    dplyr::filter(
      `State Code` == "19",
      `Distt.Code` != "000",
      `Age-group` == "Total",
      `Total/Rural/Urban` != "Total"
    )
    colnames(disabilities)
    unique(disabilities$`Distt.Code`)
    disabilities$District <- disabilities$`Distt.Code`
    disabilities$TRU <- disabilities$`Total/Rural/Urban`
    disabilities$disabled_persons <- as.integer(disabilities$`Total number of disabled persons`)
    keep_cols <- c(
      "District",
      "TRU",
      "disabled_persons"
    )
    disabilities <- disabilities[, keep_cols]
    pca11_districts <- read_excel(
      "data/ADMIN/INDIA/CENSUS-2011/2011-IndiaStateDistSbDistTwn-0000.xlsx"
    ) %>%
    dplyr::filter(
      State == 19
    ) %>%
    dplyr::filter(Level %in% c("DISTRICT"))
    pca11_districts <- dplyr::inner_join(
      disabilities, pca11_districts,
      by = c(
        "District" = "District",
        "TRU" = "TRU"
      )
    )
    pca11_districts$S_SOC5 <- pca11_districts$disabled_persons / pca11_districts$TOT_P
    keep_cols <- c(
      "S_SOC5",
      "District",
      "TRU"
    )
    pca11_districts <- pca11_districts[, keep_cols]
    data <- dplyr::inner_join(
      data, pca11_districts,
      by = c(
        "District" = "District",
        "TRU" = "TRU"
      )
    )
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
  data$S_INF1 <- data$`Number of households not having latrine facility within the premises`
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
S_INF2 <- function(data, ...) {
  data$S_INF2 <- data$`Main Source of Drinking Water: Tapwater from treated source` + data$`Main Source of Drinking Water: Spring`
  return(clean_column(data, "S_INF2"))
}

# S_INF3
# Percentage of population without access to electricity (%)
S_INF3 <- function(data, ...) {
  data$S_INF3 <- data$`Main Source of lighting: Electricity`
  return(clean_column(data, "S_INF3"))
}

# --------------------------------------------------
# COPING AND ADAPTATION CAPACITY
# --------------------------------------------------

# C_EWS1
# Percentage of households without access to information (%)
# Proxy: Percentage of households without radio or TV (%)
# Availability of assets: None of the assets specified in col. 10 to 19: TV - Computer/Laptop - Telephone/mobile phone - Scooter/Car
C_EWS1 <- function(data, ...) {
  data$C_EWS1 <- data$`Availability of assets: None of the assets specified in col. 10 to 19`
  return(clean_column(data, "C_EWS1"))
}
