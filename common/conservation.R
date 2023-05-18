# https://www.protectedplanet.net/
library(wdpar)
library(dplyr)
library(ggmap)

# Note: as of May 2023 - IND shapefile is broken on the protectedplanet server
# used Google Earth Engine (GEE) to export it with the following code
# https://code.earthengine.google.com/d481fffa83c655ed0f1de7722ad4a923
# var dataset = ee.FeatureCollection('WCMC/WDPA/current/polygons').filter("ISO3 == 'IND'")
# var studyArea = ee.FeatureCollection(dataset)
# Export.table.toDrive({collection: studyArea, fileFormat: 'SHP', description: "WCMC_WPDA_IND"});

create_conservation_areas <- function(iso3) {
  # iso3 <- "BGD"
  data <- "data/Conservation"
  mkdirs(data)
  objects <- "objects/conservation"
  mkdirs(objects)
  raw_pa_data <- wdpa_fetch(
    iso3, wait = TRUE, download_dir = (data)
  )
  pa_data <- wdpa_clean(raw_pa_data)
  plot(pa_data)
  writeVector(
    conservation,
    glue::glue("{objects}/protectedplanet_{iso3}.gpkg"),
    overwrite = TRUE
  )
}