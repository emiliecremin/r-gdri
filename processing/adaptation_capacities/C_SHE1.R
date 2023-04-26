library(sf)

source("common/helpers.R")
source("common/osm.R")

sf_use_s2(TRUE)
locations <- st_read("data/ADMIN/admin.shp") %>% st_transform(4326)

# C_SHE1
# Access to shelter places
# Density of schools km2 per 1,000 inhabitants
# https://wiki.openstreetmap.org/wiki/Tag:amenity%3Dschool
# density of primary and secondary schools per km2
education_services <- c("school", "college", "university")

tmp <- "objects/C_SHE1"
mkdirs(tmp)
for (i in 1:nrow(locations)) {
    osm_data <- get_osm(
        locations$GEOLEV2[i],
        locations$ADM2_VI[i],
        locations$geometry[i],
        "amenity",
        education_services,
        tmp
    )
    print(osm_data)
    cnt <- 0
    if (!is.null(osm_data$osm_points)) {
        features_points <- st_intersection(locations$geometry[i], st_make_valid(osm_data$osm_points))
        cnt <- cnt + nrow(as.data.frame(features_points))
    }
    if (!is.null(osm_data$osm_polygons)) {
        features_polygons <- st_intersection(locations$geometry[i], st_make_valid(osm_data$osm_polygons))
        cnt <- cnt + nrow(as.data.frame(features_polygons))
    }
    if (!is.null(osm_data$osm_multipolygons)) {
        features_multipolygons <- st_intersection(locations$geometry[i], st_make_valid(osm_data$osm_multipolygons))
        cnt <- cnt + nrow(as.data.frame(features_multipolygons))
    }
    locations$cnt[i] <- cnt
}
locations$val <- locations$cnt / as.numeric(locations$area) / locations$pop * 1000
locations$norm <- normalize_minmax(locations$val, na.rm = TRUE)
st_write(locations, "output/adaptation_capacities/C_SHE1_schools.gpkg", append = FALSE)
