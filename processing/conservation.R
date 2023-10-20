# cite: UNEP-WCMC and IUCN (2023), Protected Planet: The World Database on Protected Areas (WDPA) and World Database on Other Effective Area-based Conservation Measures (WD-OECM) [Online], June 2023, Cambridge, UK: UNEP-WCMC and IUCN. Available at: www.protectedplanet.net.
# data: https://www.protectedplanet.net/country/VNM

# Using package to download data
library(wdpar)

# Note: as of May 2023 - IND shapefile is broken on the protectedplanet server
# used Google Earth Engine (GEE) to export it with the following code
# https://code.earthengine.google.com/d481fffa83c655ed0f1de7722ad4a923
# var dataset = ee.FeatureCollection('WCMC/WDPA/current/polygons').filter("ISO3 == 'IND'")
# var studyArea = ee.FeatureCollection(dataset)
# Export.table.toDrive({collection: studyArea, fileFormat: 'SHP', description: "WCMC_WPDA_IND"});

get_conservation_areas <- function(iso3) {
  objects <- "objects/conservation"
  mkdirs(objects)
  filename <- glue::glue("{objects}/protectedplanet_{iso3}.gpkg")
  if (file.exists(filename) == TRUE) {
    pa_data <- terra::vect(filename)
  } else {
    raw_pa_data <- wdpa_fetch(
      iso3, wait = TRUE, download_dir = (objects)
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
ER_CON_1512 <- function(locations, ...) {
  country_iso3 <- unique(locations$country_iso3)[1]
  conservation <- get_conservation_areas(country_iso3)
  sf_use_s2(FALSE)
  conservation <- st_read(glue::glue("objects/conservation/protectedplanet_{country_iso3}.gpkg"))
  intersect <- st_intersection(locations, st_union(st_geometry(conservation)))
  sf_use_s2(TRUE)
  st_write(intersect, glue::glue("objects/conservation/protectedplanet_intersection_{country_iso3}.gpkg"), append = FALSE)
  intersect$conservation_area <- units::set_units(st_area(i), km^2)
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
