install.packages(c("raster", "Rcpp", "terra"))
library(terra)
library(dplyr)
library(ggplot2)
library(leaflet)
library(sf)

# https://international.ipums.org/international/gis_harmonized_2nd.shtml
data.file <- "data/shapefiles/world_geolev2_2019/world_geolev2_2019.shp"
p <- vect(data.file)
d_geolev2 <- as.data.frame(p)
filter(d_geolev2, GEOLEVEL2 == 704048006)

population <- read.csv(file="data/Population/terra_pop/data_14582_IPUMS_VN_HSLAD_2009.csv")
geo_vn <- dplyr::filter(d_geolev2, CNTRY_CODE == 704)

# Red river
geo_red_river <- dplyr::filter(geo_vn, GEOLEVEL2 > 704001000 & GEOLEVEL2 < 704039000)
count(geo_red_river)
# Mekong
geo_mekong <- dplyr::filter(geo_vn, GEOLEVEL2 > 704082000 & GEOLEVEL2 < 704096000)
count(geo_mekong)
geo_vn_deltas <- rbind(geo_red_river, geo_mekong)

geolev2 <- st_read(data.file)
get_geolevel2 <- function(code) {
  location <- geolev2 %>% filter(GEOLEVEL2==code)
  location$area <- units::set_units(st_area(location), km^2) # https://r-spatial.github.io/sf/articles/sf1.html#units
  location$pop <- filter(population, GEO2_VN == code)$TOTPOP_GEO2_VN_VN2009A
  return(location)
}

# Example
# giao_thuy <- geolev2 %>% filter(GEOLEVEL2==704036005)
# leaflet()  %>% addTiles() %>%
#   addPolygons(data=giao_thuy, weight=5, col = 'red')
