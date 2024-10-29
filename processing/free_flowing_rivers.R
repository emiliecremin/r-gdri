
# Connectivity Status Index from 0 to 100%;
#  100% = full connectivity; 0% = no connectivity.
# FFR assessment (Grill et al., 2019)
# Grill, G., Lehner, B., Thieme, M. et al. Mapping the world’s free-flowing rivers. Nature 569, 215–221 (2019). https://doi.org/10.1038/s41586-019-1111-9
# https://www.nature.com/articles/s41586-019-1111-9#data-availability
# https://figshare.com/articles/dataset/Mapping_the_world_s_free-flowing_rivers_data_set_and_technical_documentation/7688801?file=15090536
free_flowing_rivers <- sf::st_read(
    "data/Mapping the worlds free-flowing rivers_Data_Geodatabase/FFR_river_network.gdb" # nolint
)
keep_cols <- c(
    "GOID",
    "NOID",
    "CON_ID",
    "COUNTRY",
    "BAS_ID",
    "BAS_NAME",
    "LENGTH_KM",
    "BB_ID",
    "BB_NAME",
    "DOF",
    "DOR",
    "RDD",
    "URB",
    "CSI"
)
free_flowing_rivers <- free_flowing_rivers[, keep_cols]

ES_FRA2 <- function(locations, ...) {
    rivers <- free_flowing_rivers %>% dplyr::filter(
        COUNTRY %in% unique(locations$CNTRY_NAME)
    )
    rivers_per_location <- terra::intersect(vect(locations), vect(rivers))
    result <- st_as_sf(rivers_per_location) %>%
        st_drop_geometry() %>%
        group_by(geo_id) %>%
        summarize(val = mean(CSI))
    return(result)
}
