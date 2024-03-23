#------------------------------------------------------------------------------
# Source: ESRI 2021
# https://livingatlas-dcdev.opendata.arcgis.com/datasets/esriindia1::india-village-boundary-2021/about
# https://opendata.arcgis.com/api/v3/datasets/6e48332636074603acbc55e116ab264e_0/downloads/data?format=shp&spatialRefId=4326&where=1%3D1
#------------------------------------------------------------------------------
get_ind_villages <- function() {
  print("India_Village_Boundary_2021 is a large data source, loading...")
  esri_wb <- st_read(
    "data/ADMIN/INDIA/ESRI - 2021/India_Village_Boundary_2021/India_Village_Boundary_2021.shp" # nolint
  ) %>%
    dplyr::filter(lgd_statec == 19) %>%
    st_make_valid()
  # Format subdistrict to compare with the census of india
  max(nchar(as.character(esri_wb$lgd_subdis)), na.rm = TRUE)
  esri_wb$lgd_subdis[is.na(esri_wb$lgd_subdis)] <- 99999
  esri_wb$lgd_subdis <- sprintf("%05s", as.character(esri_wb$lgd_subdis))

  # Analysis of duplicates in the shapefile
  nrow(esri_wb)
  no_na <- esri_wb %>% dplyr::filter(!is.na(censusco_1))
  duplicate_counts <- no_na |>
    add_count(censusco_1) |>
    filter(n > 1) |>
    distinct()

  # st_write(
  #   duplicate_counts,
  #   "data/admin/INDIA/duplicates.gpkg",
  #   append = FALSE
  # )

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

  binding <- rbind(
    merged,
    esri_wb %>% dplyr::filter(!(censusco_1 %in% to_merge))
  )
  no_binding <- esri_wb %>% dplyr::filter(is.na(censusco_1))
  #------------------------------------------------------------------------------
  # POPULATION FINDER 2011
  # https://censusindia.gov.in/census.website/data/population-finder
  #------------------------------------------------------------------------------
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

  # st_write(
  #   towns_nohh,
  #   "data/admin/INDIA/towns_nohh.gpkg",
  #   append = FALSE
  # )

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

  # st_write(
  #   census_2011,
  #   "data/admin/INDIA/full_census_2011.gpkg",
  #   append = FALSE
  # )

  #------------------------------------------------------------------------------
  # PC11_HL14-19
  # HL-14: Percentage of households to total households by amenities and assets
  # To get the data at the villages level
  # Download data for each district within the Region of Interest
  # i.e. West Bengal - district of Darjiling
  # https://censusindia.gov.in/nada/index.php/catalog/9625
  #------------------------------------------------------------------------------
  dir <- "data/ADMIN/INDIA/CENSUS-2011/PC11_HL14"
  hlpca_files <- list.files(
    normalizePath(dir),
    pattern = "\\.(xls|xlsx)$",
    ignore.case = TRUE,
    full.names = TRUE
  )
  hlpca <- data.frame()
  for (f in hlpca_files) {
    tmp <- read_excel(
      f,
      skip = 2
    ) %>%
      dplyr::filter(
        `State Code` == "19",
        `Rural/\r\nUrban` != "Total"
      )
    hlpca <- rbind(hlpca, tmp)
  }
  colnames(hlpca)
  cols_hlpca <- read.csv(
    "data/ADMIN/INDIA/CENSUS-2011/PC11_HL14/hlpca-colnames.csv"
  )
  colnames(hlpca) <- cols_hlpca$column_name
  hlpca_filtered <- hlpca %>% dplyr::filter(
    # `Tehsil Code` != "00000",
    # `Town Code/Village code` != "00000",
    `Ward No` == "0000"
  )
  nrow(hlpca_filtered)
  hlpca_census_villages <- census_2011 %>% dplyr::inner_join(
    hlpca,
    by = c(
      "censusco_1" = "Town Code/Village code",
      "District" = "District Code",
      "lgd_subdis" = "Tehsil Code",
      "Ward" = "Ward No",
      "TRU" = "Rural/Urban"
    )
  )
  # st_write(
  #   hlpca_census_villages,
  #   "data/admin/INDIA/hlpca_census_villages.gpkg",
  #   append = FALSE
  # )

  #   keep_cols <- hlpca %>%
  #     dplyr::select(
  #       `Number of households with condition of Census House as: Total (Total)`:last_col() # nolint
  #     )

  hlpca_towns <- hlpca %>% dplyr::filter(
    `Tehsil Code` == "99999",
    `Town Code/Village code` != "000000",
    `Ward No` == "0000"
  )

  hlpca_census_towns <- census_2011 %>%
    dplyr::inner_join(
      hlpca_towns,
      by = c(
        "censusco_1" = "Town Code/Village code",
        "District" = "District Code",
        # "lgd_subdis" = "Tehsil Code",
        # "Ward" = "Ward No",
        "TRU" = "Rural/Urban"
      )
    ) %>%
    dplyr::filter(!censusco_1 %in% hlpca_census_villages$censusco_1)

  # st_write(
  #   hlpca_census_towns,
  #   "data/admin/INDIA/hlpca_census_towns.gpkg",
  #   append = FALSE
  # )

  hlpca_per_subdistrict <- hlpca %>% dplyr::filter(
    `Town Code/Village code` == "000000",
    `Tehsil Code` != "00000",
    `Tehsil Code` != "99999"
  )

  hlpca_census_subdistrict <- census_2011 %>%
    dplyr::filter(
      !censusco_1 %in% c(
        hlpca_census_villages$censusco_1, hlpca_census_towns$censusco_1
      )
    ) %>%
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

  # st_write(
  #   hlpca_census_subdistrict,
  #   "data/admin/INDIA/hlpca_census_subdistrict.gpkg",
  #   append = FALSE
  # )

  no_binding <- census_2011 %>% dplyr::filter(is.na(District))
  # Define empty columns
  empty_cols <- colnames(hlpca)
  #   no_binding_min <- no_binding[, keep_cols] %>% st_drop_geometry()
  # Add multiple empty columns
  no_binding[, empty_cols] <- NA
  no_binding <- no_binding %>% st_as_sf()
  st_geometry(no_binding) <- "geometry"
  no_binding <- no_binding %>% relocate(geometry, .after = last_col())

  drop_cols <- setdiff(colnames(no_binding), colnames(hlpca_census_villages))
  no_binding$`District Code`
  no_binding$`Tehsil Code`
  no_binding$`Town Code/Village code`
  no_binding$`Ward No`
  no_binding$`Rural/Urban`
  no_binding_drop <- no_binding %>% dplyr::select(-one_of(drop_cols))
  setdiff(colnames(no_binding_drop), colnames(hlpca_census_villages))
  rbind(hlpca_census_villages, no_binding_drop)
  drop_cols <- setdiff(
    colnames(hlpca_census_subdistrict), colnames(hlpca_census_villages)
  )
  hlpca_census_subdistrict_drop <- hlpca_census_subdistrict %>%
    dplyr::select(-one_of(drop_cols))
  drop_cols <- setdiff(
    colnames(hlpca_census_towns), colnames(hlpca_census_villages)
  )
  hlpca_census_towns_drop <- hlpca_census_towns %>%
    dplyr::select(-one_of(drop_cols))
  ind_villages <- rbind(
    hlpca_census_villages,
    hlpca_census_towns_drop,
    hlpca_census_subdistrict_drop,
    no_binding_drop
  )
  ind_villages$CNTRY_NAME <- "India"
  ind_villages$country_iso3 <- "IND"
  ind_villages$geo_id <- paste(
    ind_villages$lgd_statec,
    ind_villages$District,
    ind_villages$lgd_subdis,
    ind_villages$censusco_1,
    sep = ""
  )
  ind_villages$pop <- as.numeric(ind_villages$TOT_P)
  ind_villages$area <- units::set_units(st_area(ind_villages), km^2)
  st_write(
    ind_villages,
    "data/ADMIN/villages_ind.gpkg",
    append = FALSE
  )
  return(ind_villages)
}
#------------------------------------------------------------------------------
