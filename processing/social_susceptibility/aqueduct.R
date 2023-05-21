# https://www.wri.org/research/aqueduct-30-updated-decision-relevant-global-water-risk-indicators
# https://github.com/wri/aqueduct30_data_download/blob/master/metadata.md
aqueduct <- vect("data/Water/Y2019M07D12_Aqueduct30_V01/baseline/annual/y2019m07d11_aqueduct30_annual_v01.gpkg")

map_aqueduct <- function(data, col_code) {
    aqueduct_roi <- terra::crop(aqueduct, data)
    # mapPlot(
    #     sf::st_as_sf(aqueduct_roi),
    #     glue::glue("{col_code}_score"),
    #     "score", glue::glue("Aqueduct {col_code} score")
    # )
    aqueduct_points <- st_centroid(sf::st_as_sf(aqueduct_roi))
    roi_points <- st_centroid(sf::st_as_sf(data))
    aqueduct_points_no_na <- aqueduct_points %>%
        drop_na(glue::glue("{col_code}_score"))
    nearest_indexes <- st_nearest_feature(roi_points, aqueduct_points_no_na)
    nearest <- aqueduct_points_no_na[nearest_indexes, ]
    nearest_aqueduct <- cbind(sf::st_as_sf(data), nearest)
    # mapPlot(
    #     sf::st_as_sf(nearest_aqueduct),
    #     glue::glue("{col_code}_score"),
    #     "score", glue::glue("Aqueduct {col_code} score")
    # )
    sanitation <- st_drop_geometry(
        nearest_aqueduct[, c(
            "geo_id",
            glue::glue("{col_code}_score"),
            glue::glue("{col_code}_cat"),
            glue::glue("{col_code}_label")
        )]
    )
    sanitation$val <- sanitation[[glue::glue("{col_code}_score")]]
    return(sanitation)
}

# S_INF1_621 Percentage of population without access to (improved) sanitation (%)
S_INF1_621 <- function(data) {
    # usa: Unimproved/no sanitation
    return(map_aqueduct(data, "usa"))
}

# S_INF1 / S_INF1_631 Percentage of houseolds without access to wastewater treatment (%)
S_INF1_631 <- function(data) {
    # ucw: Untreated connected wastewater
    return(map_aqueduct(data, "ucw"))
}

# S_INF2 / S_INF2_611 Percentage of population without access to clean driking water (%)
S_INF2_611 <- function(data) {
    # udw: Unimproved/no drinking water
    return(map_aqueduct(data, "udw"))
}
