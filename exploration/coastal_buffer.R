# Check if the system has mapshaper installed
install.packages("rmapshaper")
check_sys_mapshaper()
# if not, then install it using npm
# https://nodejs.org/en/download/
# npm install -g mapshaper

create_buffer <- function(admin_shp, geo_id) {
  admin_shp_simple <- ms_simplify(
    admin_shp,
    keep = 0.001,
    keep_shapes = FALSE,
    sys = TRUE
  )
  geom_type <- as.character(
    st_geometry_type(admin_shp_simple, by_geometry = FALSE)
  )
  st_geometry(admin_shp_simple) <- "geometry"

  if (isTRUE(st_is_longlat(admin_shp_simple))) {
    admin_shp_simple <- st_transform(admin_shp_simple, 3857)
  }
  admin_shp_simple$geo_id
  # https://statnmap.com/2020-07-31-buffer-area-for-nearest-neighbour/
  # https://github.com/statnmap/cartomisc
  admin_buffer <- regional_seas(
    admin_shp_simple,
    "geo_id",
    dist = units::set_units(5, km),
    density = units::set_units(0.1, 1 / km)
  ) %>%
    st_cast(geom_type)
  st_geometry(admin_buffer) <- "geometry"
  plot(admin_buffer)
  admin_with_buffer <- rbind(admin_shp_simple[c("geo_id", "geometry")], admin_buffer) %>%
    group_by(across(all_of("geo_id"))) %>%
    summarise()
  colnames(admin_with_buffer)
  admin_with_buffer <- st_drop_geometry(admin_shp_simple) %>%
    left_join(admin_with_buffer, by = {{"geo_id"}}) %>%
    st_as_sf() %>%
    st_cast(geom_type)

  return(admin_with_buffer)
}
