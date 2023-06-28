library(dplyr)
library(glue)
library(sf)
library(terra)

source("common/helpers.R")

# cite: UNEP-WCMC and IUCN (2023), Protected Planet: The World Database on Protected Areas (WDPA) and World Database on Other Effective Area-based Conservation Measures (WD-OECM) [Online], June 2023, Cambridge, UK: UNEP-WCMC and IUCN. Available at: www.protectedplanet.net.
# https://www.protectedplanet.net/country/VNM
locations <- st_read("data/ADMIN/admin.shp") %>% st_make_valid()
# https://github.com/rspatial/terra/issues/38
adm <- terra::vect(locations)
country_iso3 <- "VNM"
dir <- "data/Conservation/WDPA_WDOECM"
vector_files <- list.files(
    normalizePath(dir),
    pattern = glue::glue("_{country_iso3}_.*polygons\\.shp$"),
    ignore.case = TRUE,
    full.names = TRUE,
    recursive = TRUE
)
l <- lapply(vector_files, terra::vect)
v <- do.call(rbind, l)
# plot(v)
# https://gis.stackexchange.com/questions/445620/how-to-efficiently-get-the-intersection-between-vector-and-raster-in-r
conservation <- terra::crop(adm, v)
# XXX Bug in Terra -> terra::area(conservation)
#  unable to find an inherited method for function ‘area’ for signature ‘"SpatVector"’ # nolint
# using sf instead -> sf::st_as_sf(conservation)
sf_use_s2(FALSE)
conservation$conservation_area <-
    units::set_units(st_area(sf::st_as_sf(conservation)), km^2)
# st_write(sf::st_as_sf(conservation),
#     "output/ecosystem_robustness/conservation.gpkg",
#     append = FALSE
# )
# plot(conservation)
df <- sf::st_as_sf(conservation) %>% st_drop_geometry()
locations <-
    right_join(df[c("geo_id", "conservation_area")], locations) %>%
    st_as_sf()
locations$conservation_area[is.na(locations$conservation_area)] <- 0
locations$cnt <- locations$conservation_area
locations$val <-
    as.numeric(locations$conservation_area) / as.numeric(locations$area)

plot(locations$norm)
st_write(locations,
    "output/ecosystem_robustness/ER_CON_1512_conservation_areas.gpkg",
    append = FALSE
)
