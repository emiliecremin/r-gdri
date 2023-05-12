# https://www.wri.org/research/aqueduct-30-updated-decision-relevant-global-water-risk-indicators
# https://github.com/wri/aqueduct30_data_download/blob/master/metadata.md
S_INF1_631 <- function(data, country_name = "") {
    aqueduct <- st_read("data/Water/Y2019M07D12_Aqueduct30_V01/baseline/annual/y2019m07d11_aqueduct30_annual_v01.gpkg")
    if (country_name != "") {
        aqueduct <- dplyr::filter(aqueduct, name_0 == country_name) %>% st_make_valid()
    }
    aqueduct_points <- st_centroid(data) %>% st_join(aqueduct)

    # All values are the same for all locations: Bangladesh, India, Vietnam = Extremely High (100%)
    untreated_wastewater <- st_drop_geometry(aqueduct_points[, c("geo_id", "ucw_score", "ucw_cat", "ucw_label")])
    untreated_wastewater$val <- untreated_wastewater$ucw_score
    return (untreated_wastewater)
}
