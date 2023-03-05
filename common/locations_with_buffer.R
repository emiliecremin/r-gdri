library(dplyr)
library(sf)
library(units)

locations <- st_read("data/ADMIN/admin_with_buffer.shp")
locations <- st_transform(locations, 4326)
saveRDS(locations, "objects/locations")
