locations <- st_as_sf(bgd_villages)
# FLOOD AFFECTED POPULATION
# https://hub.worldpop.org/geodata/summary?id=49935
country_iso3 <- tolower(unique(locations$country_iso3)[1])
world_pop <- rast(glue::glue("data/Population/WorldPop/{country_iso3}_ppp_2020_UNadj_constrained.tif"))
plot(world_pop)
locations$world_pop <- exact_extract(world_pop, locations, "sum", progress = TRUE)
plot(locations["world_pop"])
floods <- rast("data/Hazards/Floods/fl_hazard_100_yrp.tif")
plot(floods)
floods_masked <- mask_rasters(world_pop, floods)
plot(floods_masked)
locations$floods_pop <- exact_extract(floods_masked, locations, "sum", progress = TRUE)
plot(locations["floods_pop"])
locations$val <- locations$floods_pop / locations$world_pop
plot(locations["val"])

# FLOOD AFFECTED AREA
floods_cropped <- crop(floods, locations)
locations <- raster_area_within_polygons(floods_cropped, locations)
locations$cnt <- locations$area_raster_km2
locations$val <- locations$area_raster_km2 / locations$area
plot(locations["val"])

# https://hub.worldpop.org/geodata/summary?id=49992
world_pop <- rast("data/Population/WorldPop/ind_ppp_2020_UNadj_constrained.tif")
plot(world_pop)

# https://hub.worldpop.org/geodata/summary?id=50068
world_pop <- rast("data/Population/WorldPop/vnm_ppp_2020_UNadj_constrained.tif")
plot(world_pop)
