library(dplyr)
library(glue)
library(sf)
library(terra)

source("common/helpers.R")

locations <- st_read("data/ADMIN/admin.shp") %>% st_make_valid()
# https://github.com/rspatial/terra/issues/38
adm <- terra::vect(locations)
# https://www.protectedplanet.net/en
# https://www.protectedplanet.net/country/VNM
get_vector <- function(i) {
    folder <- glue::glue("data/Conservation/WDPA_WDOECM_Feb2023_Public_VNM_shp/WDPA_WDOECM_Feb2023_Public_VNM_shp_{i}") # nolint
    filename <- glue::glue("{folder}/WDPA_WDOECM_Feb2023_Public_VNM_shp-polygons.shp") # nolint
    return(terra::vect(filename))
}
v <- rbind(get_vector(0), get_vector(1), get_vector(2))
plot(v)
plot(adm)
# https://gis.stackexchange.com/questions/445620/how-to-efficiently-get-the-intersection-between-vector-and-raster-in-r
conservation <- terra::crop(adm, v)
# XXX Bug in Terra -> terra::area(conservation)
#  unable to find an inherited method for function ‘area’ for signature ‘"SpatVector"’ # nolint
# using sf instead -> sf::st_as_sf(conservation)
sf_use_s2(FALSE)
conservation$conservation_area <-
    units::set_units(st_area(sf::st_as_sf(conservation)), km^2)
st_write(sf::st_as_sf(conservation),
    "output/ecosystem_robustness/conservation.gpkg",
    append = FALSE
)
plot(conservation)
df <- sf::st_as_sf(conservation) %>% st_drop_geometry()
locations <-
    right_join(df[c("GEOLEV2", "conservation_area")], locations) %>%
    st_as_sf()
locations$conservation_area[is.na(locations$conservation_area)] <- 0
locations$norm <-
    as.numeric(locations$conservation_area) / as.numeric(locations$area)

plot(locations$norm)
st_write(locations,
    "output/ecosystem_robustness/ER_CON_1512_conservation_areas.gpkg",
    append = FALSE
)
