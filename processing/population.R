# bgd_villages <- st_read("objects/ADMIN/villages_bgd.gpkg")
# pop <- terra::rast("data/Population/BGD_GPW_v411_Population_Count.tif")
# bgd_villages$gridded_pop <- exact_extract(
#     pop, bgd_villages, "sum",
#     progress = TRUE
# )
# bgd_villages$gridded_pop_density <- bgd_villages$gridded_pop / bgd_villages$area
# st_write(bgd_villages, "objects/ADMIN/villages_bgd_wp.gpkg", append = FALSE)
# plot(bgd_villages["gridded_pop_density"])

# NASA SEDAC at the Center for International Earth Science Information Network (CIESIN)
# https://developers.google.com/earth-engine/datasets/catalog/CIESIN_GPWv411_GPW_Population_Count
# https://code.earthengine.google.com/f75e5f01cec3de8d368d1a3ae4f38e26?noload=true
pop_density <- function(locations) {
    country_iso3 <- unique(locations$country_iso3)[1]
    world_pop <- terra::rast(
        glue::glue("data/Population/{country_iso3}_GPW_v411_Population_Count.tif")
    )
    locations$gridded_pop <- exact_extract(
        world_pop, locations, "sum",
        progress = TRUE
    )
    locations$gridded_pop_density <- locations$gridded_pop / locations$area
    return(locations)
}

target_col_names <- c(
    "geo_id",
    "CNTRY_NAME",
    "country_iso3",
    "adm1_name",
    "adm2_name",
    "adm3_name",
    "adm4_name",
    "Name",
    "adm_level",
    "pop",
    "area",
    "gridded_pop",
    "gridded_pop_density"
)
vnm_villages <- pop_density(vnm_villages) %>%
    dplyr::select(all_of(target_col_names))
bgd_villages <- pop_density(bgd_villages) %>%
    dplyr::select(all_of(target_col_names))
ind_villages <- pop_density(ind_villages) %>%
    dplyr::select(all_of(target_col_names))

pop <- rbind(vnm_villages, bgd_villages, ind_villages)
write_xlsx(pop %>% st_drop_geometry(), path = "output/pop.xlsx")
