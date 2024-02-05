# AidData. 2017.
# WorldBank_GeocodedResearchRelease_Level1_v1.4.2 geocoded dataset.
# Williamsburg, VA and Washington, DC: AidData.
# Accessed on [date]. http://aiddata.org/research-datasets.
# https://www.aiddata.org/data/world-bank-geocoded-research-release-level-1-v1-4-2
# https://raw.githubusercontent.com/AidData-WM/public_datasets/master/geocoded/WorldBank_GeocodedResearchRelease_Level1_v1.4.2.zip
A_GOV6 <- function(locations, ...) {
    # ad_sector_code 151 = Government and civil society, general
    aid_data <- read.csv(
      "data/WorldBank_GeocodedResearchRelease_Level1_v1.4.2/data/level_1a.csv"
    ) %>% dplyr::filter(
        end_actual_isodate > "2014-01-01" &
        recipients_iso3 %in% unique(locations$country_iso3) &
        grepl('151', ad_sector_codes) &
        !is.na(longitude) & !is.na(latitude)
    )
    aid_points <- st_as_sf(
        aid_data,
        coords = c("longitude", "latitude"),
        crs = 4326
    )
    # https://gis.stackexchange.com/a/323706
    locations$aid_points <- lengths(st_intersects(locations, aid_points))
    # ggplot() +
    # geom_sf(
    #     data = locations,
    #     aes(fill = aid_points)
    # ) +
    # scale_fill_viridis_c(option = "C")

    # locations$aid_density <- locations$aid_points / locations$area
    # ggplot() +
    # geom_sf(
    #     data = locations,
    #     aes(fill = aid_density)
    # ) +
    # scale_fill_viridis_c(option = "C")

    locations$val <- locations$aid_points / locations$area
    return(locations)
}

ER_FUN2 <- function(locations, ...) {
    # ad_sector_code
    # 310 = Agriculture, forestry, fishing
    # 311 = Agriculture
    # 312 = Forestry
    # 410 = General environmental protection
    aid_data <- read.csv(
        "data/WorldBank_GeocodedResearchRelease_Level1_v1.4.2/data/level_1a.csv"
    ) %>% dplyr::filter(
        end_actual_isodate > "2014-01-01" &
        recipients_iso3 %in% unique(locations$country_iso3) &
        !is.na(longitude) & !is.na(latitude)
    ) %>% dplyr::filter(
        grepl("310", ad_sector_codes) |
        grepl("311", ad_sector_codes) |
        grepl("312", ad_sector_codes) |
        grepl("410", ad_sector_codes)
    )
    aid_points <- st_as_sf(
        aid_data,
        coords = c("longitude", "latitude"),
        crs = 4326
    )
    # https://gis.stackexchange.com/a/323706
    locations$aid_points <- lengths(st_intersects(locations, aid_points))
    # ggplot() +
    # geom_sf(
    #     data = locations,
    #     aes(fill = aid_points)
    # ) +
    # scale_fill_viridis_c(option = "C")

    # locations$aid_density <- locations$aid_points / locations$area
    # ggplot() +
    # geom_sf(
    #     data = locations,
    #     aes(fill = aid_density)
    # ) +
    # scale_fill_viridis_c(option = "C")
    # ggsave("all_env.png")

    locations$val <- locations$aid_points / locations$area
    return(locations)
}
