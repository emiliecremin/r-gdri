## Open Street Map
# https://wiki.openstreetmap.org/wiki/Map_features
# https://wiki.openstreetmap.org/wiki/Key:amenity
# https://rspatialdata.github.io/osm.html#Retrieving_the_osmdata_object
# http://joshuamccrain.com/tutorials/maps/streets_tutorial.html
# https://towardsdatascience.com/calculating-building-density-in-r-with-osm-data-e9d85c701e19
# https://r-spatial.github.io/sf/reference/geos_measures.html
# https://www.mdpi.com/1660-4601/15/11/2443/htm
# QGIS: https://www.youtube.com/watch?v=BMzJNScR76U


# Scaling issue
# Download OSM data and be able to reproduce
# https://github.com/ropensci/osmextract

install.packages("leaflet")
install.packages("osmdata")
install.packages("sf")
library(leaflet)
library(osmdata)
library(ggplot2)
library(sf)
# "Ha Noi, Hoa Binh, Phu Tho, Vinh Phuc"

get_osm <- function(location, key, value) {
  osm_boundary <- getbb(location)
  result <- osm_boundary %>%
    opq() %>%
    add_osm_feature(key, value) %>%
    osmdata_sf() %>%
    unname_osmdata_sf()
  return(result)
}

get_leaflet <- function(location, admin, roads, waterways, emergencies, schools) {
  m = leaflet() %>%
        addTiles() %>%
        addPolygons(data = admin,
              label = admin$name, weight=1, col = 'green') %>%
        addPolygons(data = location,
                label = location$ADMIN_NAME, weight=1, col = 'red')
  if(length(roads) > 0){
    m = addPolylines(m, data=roads, color='black', weight=3)
  }
  if(length(waterways) > 0){
    m = addPolylines(m, data=waterways, color='blue', weight=3)
  }
  if(length(emergencies) > 0){
    m = m %>% addPolygons(data = emergencies,
                          label = emergencies$name)
  }
  if(length(schools) > 0){
    m = m %>% addPolygons(data = schools,
                          label = schools$name)
  }
  return(m)
}

# VN admin_levels
# 4 = province border
# 6 = district / township border
# 8 = commune / town / ward border

# IN admin_levels
# 3 = Division
# 4 = State
# 5 = District
# 6 = Subdistrict (Tehsil / Mandal / Taluk)
# 7 = Metropolitan Area
# 8 = Municipal Corporation / Municipality / City Council
# 9 = Civic Zone
# 10 = Village/Civic Ward

# BD admin_levels
# 3 = Division
# 5 = District
# 6 = Subdistrict (Upazila / Thana)
# 7 = City Corporation
# 8 = Municipal Corporation / Pourashava
# 9 = Union

location <- get_geolevel2(code=704001001)

# TESTS
# main_road_types <- c("motorway", "trunk", "primary")
# roads <- get_osm(location$ADMIN_NAME, "highway", all_road_types)$osm_lines
# location_roads <- st_intersection(st_geometry(roads), st_geometry(location))
# emergency_services <- c("hospital", "police", "fire_station")
# osm_emergency <- get_osm(location$ADMIN_NAME, "amenity", emergency_services)$osm_polygons
# location_emergencies <- st_intersection(st_geometry(osm_emergency), st_geometry(location))
# waterways_types <- c("river", "canal", "fairway")
# osm_waterways <- get_osm(location$ADMIN_NAME, "waterway", waterways_types)$osm_lines
# location_waterways <- st_intersection(st_geometry(osm_waterways), st_geometry(location))
# osm_schools <- get_osm(location$ADMIN_NAME, "amenity", "school")$osm_polygons
# location_schools <- st_intersection(st_geometry(osm_schools), st_geometry(location))
# osm_admin <- get_osm(location$ADMIN_NAME, "admin_level", 6)$osm_multipolygons
# 
# map <- get_leaflet(location, osm_admin, location_roads, location_waterways, location_emergencies, location_schools)

# C_GOV2
# Access to emergency services: hospitals, fire brigades, police stations
# Proxy: Density of  emergency services: hospitals, fire brigades, police stations per 100,000 inhabitants
# What about these? https://wiki.openstreetmap.org/wiki/Map_features#Emergency
emergency_services <- c("hospital", "police", "fire_station")
osm_emergency <- get_osm(location$ADMIN_NAME, "amenity", emergency_services)$osm_polygons
nrow(osm_emergency)
C_GOV2 <- nrow(osm_emergency) / location$pop * 100000

# C_TRA1
# Access to transportation network
# Density of transportation network: 
# - roads (highways, trunks, primary / secondary / tertiary), 
# - waterways (rivers / canals / streams), 
# - ferry stations 
# per 100,000 inhabitants
main_road_types <- c("motorway", "trunk", "primary")
roads <- get_osm(location$ADMIN_NAME, "highway", all_road_types)$osm_lines
location_roads <- st_intersection(st_geometry(roads), st_geometry(location))
sum(st_length(location_roads))

# highway=trunk, highway=primary, highway=secondary, highway=tertiary, highway=unclassified
all_road_types <- c("motorway", "trunk", "primary", "secondary", "tertiary", "unclassified")
osm_all_roads <- get_osm(location$ADMIN_NAME, "highway", all_road_types)$osm_lines
location_all_roads <- st_intersection(st_geometry(osm_all_roads), st_geometry(location))
sum(st_length(osm_all_roads))

# https://wiki.openstreetmap.org/wiki/Map_features#Waterway
# waterway=stream for a naturally-forming waterway that is too narrow to be classed as waterway=river 
# (the commonly accepted rule for OpenStreetMap is that a stream can be jumped across by an active, able-bodied person). 
# A stream need not be permanently filled with water. In case of varying size or intermittent waterways 
# the distinction from larger rivers based on the above criterion should be made with respect to the high water level.

# Use waterway=fairway for a linear way representation of a navigable route in a body of water such as a lake or sea, 
# in cases where other values such as waterway=river or waterway=canal are not appropriate. 
# Do not use instead of waterway=river or waterway=canal.
waterways_types <- c("river", "canal", "fairway")
osm_waterways <- get_osm(location$ADMIN_NAME, "waterway", waterways_types)$osm_lines
location_waterways <- st_intersection(st_geometry(osm_waterways), st_geometry(location))
sum(st_length(location_waterways))

trans_network <- sum(st_length(location_roads)) + sum(st_length(location_waterways))
C_TRA1 <- trans_network / location$pop * 100000

# C_SHE1
# Access to shelter places
# Density of schools km2 per 100,000 inhabitants
# https://wiki.openstreetmap.org/wiki/Tag:amenity%3Dschool
# density of primary and secondary schools per km2
osm_schools <- get_osm(location$ADMIN_NAME, "amenity", "school")$osm_polygons
location_schools <- st_intersection(st_geometry(osm_schools), st_geometry(location))
C_SHE1 <- length(location_schools) / as.numeric(location$area) / location$pop * 100000
