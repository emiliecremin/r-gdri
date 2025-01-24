# cite: UNEP-WCMC and IUCN (2023), Protected Planet: The World Database on Protected Areas (WDPA) and World Database on Other Effective Area-based Conservation Measures (WD-OECM) [Online], June 2023, Cambridge, UK: UNEP-WCMC and IUCN. Available at: www.protectedplanet.net.
# data: https://www.protectedplanet.net/country/VNM

# Using package to download data
library(wdpar)

# Note: as of May 2023 - IND shapefile is broken on the protectedplanet server
# used Google Earth Engine (GEE) to export it with the following code
# https://code.earthengine.google.com/b31f06484c20093b32f911e05137fcdc?noload=true
# var getPolygons = function(features) {
#   return features
#     .map(function (f) {
#       return ee.Feature(f).set('geometry_type', ee.Feature(f).geometry().type()); })
#     .filter(ee.Filter.equals('geometry_type', 'Polygon'));
# }

# var dataset = ee.FeatureCollection('WCMC/WDPA/current/polygons').filter("ISO3 == 'IND'");
# var studyArea = getPolygons(ee.FeatureCollection(dataset));
# Export.table.toDrive({collection: studyArea, fileFormat: 'GEO_JSON', description: "WCMC_WPDA_IND"});

# var dataset = ee.FeatureCollection('WCMC/WDPA/current/polygons').filter("ISO3 == 'VNM'");
# var studyArea = getPolygons(ee.FeatureCollection(dataset));
# Export.table.toDrive({collection: studyArea, fileFormat: 'GEO_JSON', description: "WCMC_WPDA_VNM"});

# var dataset = ee.FeatureCollection('WCMC/WDPA/current/polygons').filter("ISO3 == 'BGD'");
# var studyArea = getPolygons(ee.FeatureCollection(dataset));
# Export.table.toDrive({collection: studyArea, fileFormat: 'GEO_JSON', description: "WCMC_WPDA_BGD"});


get_conservation_areas <- function(iso3) {
  objects <- "objects/conservation"
  mkdirs(objects)
  filename <- glue::glue("{objects}/WCMC_WPDA_{iso3}.geojson")
  if (file.exists(filename) == TRUE) {
    pa_data <- terra::vect(filename)
  } else {
    raw_pa_data <- wdpa_fetch(
      iso3,
      wait = TRUE, download_dir = (objects)
    )
    pa_data <- wdpa_clean(raw_pa_data)
    # plot(pa_data)
    writeVector(
      pa_data,
      filename,
      overwrite = TRUE
    )
  }
  return(pa_data)
}

# cite: UNEP-WCMC and IUCN (2023), Protected Planet: The World Database on Protected Areas (WDPA) and World Database on Other Effective Area-based Conservation Measures (WD-OECM) [Online], June 2023, Cambridge, UK: UNEP-WCMC and IUCN. Available at: www.protectedplanet.net.
# data: https://www.protectedplanet.net/country/VNM
# Terrestrial protected areas (% of total land area)
ER_CON_1512 <- function(locations, ...) {
  country_iso3 <- unique(locations$country_iso3)[1]
  conservation <- get_conservation_areas(country_iso3)
  # TODO: fix although coordinates are longitude/latitude, st_union assumes that they are planar
  sf_use_s2(FALSE)
  conservation <- st_read(glue::glue("objects/conservation/WCMC_WPDA_{country_iso3}.geojson"))
  intersect <- st_intersection(locations, st_union(st_geometry(conservation)))
  sf_use_s2(TRUE)
  # st_write(intersect, glue::glue("objects/conservation/WCMC_WPDA_intersection_{country_iso3}.geojson"), append = FALSE)
  intersect$conservation_area <- units::set_units(st_area(intersect), km^2)
  df <- sf::st_as_sf(intersect) %>% st_drop_geometry()
  locations <-
    right_join(df[c("geo_id", "conservation_area")], locations) %>%
    st_as_sf()
  locations$conservation_area[is.na(locations$conservation_area)] <- 0
  locations$cnt <- locations$conservation_area
  locations$val <-
    as.numeric(locations$conservation_area) / as.numeric(locations$area)
  return(locations)
}

# Forests within conservation area
# Forest: ESA Landcover 2020
# Conservation areas: UNEP-WCMC and IUCN (2023)
# cite: UNEP-WCMC and IUCN (2023), Protected Planet: The World Database on Protected Areas (WDPA) and World Database on Other Effective Area-based Conservation Measures (WD-OECM) [Online], June 2023, Cambridge, UK: UNEP-WCMC and IUCN. Available at: www.protectedplanet.net.
# data: https://www.protectedplanet.net/country/VNM
# % of forest area within protected area
# Proportion of forest area located within legally established protected areas
ER_CON_1521 <- function(locations, ...) {
  country_iso3 <- unique(locations$country_iso3)[1]
  forests <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_forests.tif"))
  conservation <- get_conservation_areas(country_iso3)
  conservation <- vect(glue::glue("objects/conservation/WCMC_WPDA_{country_iso3}.geojson")) %>% terra::aggregate()
  forest_in_conservation <- terra::crop(forests, conservation, mask = TRUE)
  locations <- raster_area_within_polygons(forest_in_conservation, locations)
  return(locations)
}
