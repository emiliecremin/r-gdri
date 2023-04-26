create_buffer <- function(admin_shp, geo_id) {
  geom_type <- as.character(st_geometry_type(admin_shp, by_geometry = FALSE))
  st_geometry(admin_shp) <- "geometry"

  if (isTRUE(st_is_longlat(admin_shp))) {
    admin_shp <- st_transform(admin_shp, 3857)
  }

  # https://statnmap.com/2020-07-31-buffer-area-for-nearest-neighbour/
  # https://github.com/statnmap/cartomisc
  admin_buffer <- regional_seas(
    admin_shp,
    geo_id,
    dist = units::set_units(5, km),
    density = units::set_units(0.1, 1 / km)
  ) %>%
    st_cast(geom_type)
  st_geometry(admin_buffer) <- "geometry"

  admin_with_buffer <- rbind(admin_shp[c(geo_id, "geometry")], admin_buffer) %>%
    group_by(geo_id) %>%
    summarise()

  admin_with_buffer <- st_drop_geometry(admin_shp) %>%
    left_join(admin_with_buffer, by = geo_id) %>%
    st_as_sf() %>%
    st_cast(geom_type)

  return(admin_with_buffer)
}
