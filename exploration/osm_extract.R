# Include the parallel library. If the next line does not work, run install.packages(“parallel”) first
install.packages("osmextract")
install.packages("parallel")
install.packages("tidyverse")
install.packages("rgeos", type = "source")
install.packages("rgdal", type = "source")
library(osmextract)
library(parallel)
library(purrr)
library(sf)

admin_shp <- st_read("data/ADMIN/admin.shp")

# check the default download_directory used by oe_get()
oe_download_directory()

vietnam <- oe_get("Vietnam")

q_roads <- "SELECT osm_id, highway, geometry FROM 'lines' WHERE highway IN ('motorway', 'trunk', 'primary', 'secondary', 'tertiary', 'unclassified')"

roads_vietnam <- oe_get(
  "Vietnam",
  quiet = FALSE,
  query = q_roads
)

locations <- admin_shp

locations$ADM1_EN[10]
roads_geo <- oe_get(
  st_bbox(locations$geometry[10]),
  quiet = FALSE,
  query = q_roads
)
roads_clipped <- oe_get(
  locations$ADM2_VI[10],
  boundary = locations$geometry[10],
  boundary_type = "clipsrc",
  quiet = FALSE
)
st_crs(roads_adm1)
st_crs(locations)
roads_adm2 <- st_intersection(locations$geometry[10], roads_geo)


plot(roads_adm2)
plot(sf::st_geometry(roads_adm2))

for (i in 1:nrow(locations)) {
  print(locations$ADM2_VI[i])
  roads_adm1 <- oe_get(
    locations$ADM1_VI[i],
    quiet = FALSE,
    query = q_roads
  )
  roads_adm2 <- st_intersection(locations$geometry[i], roads_adm1$geometry)
  locations$roads_length[i] <- as.numeric(sum(st_length(locations$roads_adm2)))
}

# Use the detectCores() function to find the number of cores in system
no_cores <- detectCores()
# Setup cluster
clust <- makeCluster(no_cores) # This line will take time
# The parallel version of lapply() is parLapply() and needs an additional cluster argument.

roads <- mcmapply(st_intersection, locations$geometry, roads_vietnam$geometry)
stopCluster(clust)


crop <- function(x) {
  return(st_intersection(x, roads_vietnam$geometry))
}
roads <- locations %>% map(function(x) st_intersection(x["geometry"], roads_vietnam$geometry))
locations$roads <- lapply(locations$geometry, crop)


locations$ADM1_VI[1]
locations$ADM2_VI[1]
locations$geometry[1]
nrow(locations)

# simplify polygons

saveRDS(locations, "./locations")
saveRDS(roads_vietnam, "./roads_vietnam")

f <- st_intersection(locations$geometry[1], roads_vietnam$geometry)
plot(sf::st_geometry(f))

q_roads <- "SELECT osm_id, highway, geometry FROM 'lines' WHERE highway IN ('motorway', 'trunk', 'primary', 'secondary', 'tertiary', 'unclassified')"
first <- oe_get(place = "Bangladesh", query = q_roads)
first <- terra::crop(vect(first), vect(bgd[1, ]))
plot(first)
writeVector(
  first,
  "first.gpkg",
  overwrite = TRUE
)
