# tuto: https://inbo.github.io/tutorials/tutorials/spatial_standards_vector/#reading-a-geopackage-file

# datasource ---------------------
# Author: Rutger Hofste
# Date: 2019/07/12
# Version: 01
# S3 Path: s3://wri-projects/Aqueduct30/finalData/Y2019M07D12_Aqueduct30_V01
# Instructions: https://github.com/wri/aqueduct30_data_download/blob/master/metadata.md
# --------------------------------

# https://www.wri.org/research/aqueduct-30-updated-decision-relevant-global-water-risk-indicators
# https://github.com/wri/aqueduct30_data_download/blob/master/metadata.md
cat("Loading Aqueduct dataset...\n")
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
S_INF1_621 <- function(locations, ...) {
    # usa: Unimproved/no sanitation
    return(map_aqueduct(locations, "usa"))
}

# C_INF1_631 Percentage of households without access to wastewater treatment (%)
C_INF1_631 <- function(locations, ...) {
    # ucw: Untreated connected wastewater
    return(map_aqueduct(locations, "ucw"))
}

# S_INF2 / S_INF2_611 Percentage of population without access to clean driking water (%)
S_INF2_611 <- function(locations, ...) {
    # udw: Unimproved/no drinking water
    return(map_aqueduct(locations, "udw"))
}

# ES_DEG_1411 Eutrophication
ES_DEG_1411 <- function(locations, ...) {
    # cep: Coastal eutrophication potential
    return(map_aqueduct(locations, "cep"))
}

# ES_DEG10 Baseline water depletion
ES_DEG10 <- function(locations, ...) {
    # bwd: Baseline water depletion
    return(map_aqueduct(locations, "bwd"))
}

# ES_DEG5_642 Baseline water stress
ES_DEG5_642 <- function(locations, ...) {
    # bws: Baseline water stress
    return(map_aqueduct(locations, "bws"))
}

# ES_DEG2 Groundwater table decline
ES_DEG2 <- function(locations, ...) {
    # gtd: Groundwater table decline
    return(map_aqueduct(locations, "gtd"))
}
