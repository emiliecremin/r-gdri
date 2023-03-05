install.packages("dplyr")
install.packages("leaflet")
install.packages("osmdata")
install.packages("sf")
library(dplyr)
library(ggplot2)
library(leaflet)
library(osmdata)
library(sf)

adm_shp <- read_sf("../ER_Coastal_Mun.shp")
adm_shp$NAME_3
draw_leaflet <- function(features) {
  m <- leaflet() %>%
    addTiles()
  m %>%
    addPolylines(data = features, label = features$name, weight=1, col = 'red')
}

get_municipality <- function(location) {
  return(
    adm_shp %>% dplyr::filter(NAME_3 == location)
  )
}

get_osm_features <- function(location, key, value) {
  result <- opq(bbox = location) %>%
    add_osm_feature(key, value) %>%
    osmdata_sf() %>%
    unname_osmdata_sf()
  return(result)
}

all_road_types <- c("motorway", "trunk", "primary", "secondary", "tertiary", "unclassified")

# returns roads length in meters
get_roads_length <- function(location) {
  cat("get roads from: ", location, "\n")
  roads <- get_osm_features(location, "highway", all_road_types)$osm_lines
  municipality <- get_municipality(location)
  location_roads <- st_intersection(st_geometry(roads), st_geometry(municipality))
  return(sum(st_length(location_roads)))
}

locations <- read.csv("population.csv")

# CA_4
# Access to transportation network (Density of transportation network) (road (km) per 1000 population)
locations$roads_length <- lapply(locations$municipality, get_roads_length)
locations$roads_length <- as.numeric(locations$roads_length)
locations$CA_4 <- locations$roads_length / locations$population
# locations[order(locations$roads_length),]

write.csv(locations, "output.csv")

## Example to visualize on a map 
ex <- "Savignano Sul Rubicone"
roads <- get_osm_features(ex, "highway", all_road_types)$osm_lines
municipality <- get_municipality(ex)
location_roads <- st_intersection(st_geometry(roads), st_geometry(municipality))
draw_leaflet(location_roads)

