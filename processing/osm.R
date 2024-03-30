source("common/helpers.R")

osm_query <- function(shape, key, values) {
    cond <- values %>%
        purrr::map_chr(~ paste0(
            glue::glue("other_tags LIKE '%\"{key}\"=>\""), .
        )) %>%
        purrr::map_chr(paste0, "\"%'") %>%
        paste(collapse = " OR ")
    q <- glue::glue("SELECT osm_id, name as osm_name, other_tags, geometry
    FROM {shape}
    WHERE {cond}")
    return(q)
}

# C_SHE1
# Access to shelter places
# Density of schools km2 per 1,000 inhabitants
# https://wiki.openstreetmap.org/wiki/Tag:amenity%3Dschool
# density of primary and secondary schools per km2
C_SHE1 <- function(locations, ...) {
    education_services <- c("school", "college", "university")
    q <- osm_query("points", "amenity", education_services)
    osm_points <- oe_get(
        place = locations[1, ]$CNTRY_NAME,
        quiet = FALSE,
        layer = "points",
        query = q,
        extra_tags = education_services
    )
    q <- osm_query("multipolygons", "amenity", education_services)
    osm_multipolygons <- oe_get(
        place = locations[1, ]$CNTRY_NAME,
        quiet = FALSE,
        layer = "multipolygons",
        query = q,
        extra_tags = education_services
    )
    if (exists("GEOLEV2", where = locations)) {
        original_loc <- locations
        country_iso3 <- unique(locations$country_iso3)[1]
        locations <- st_read(glue::glue("data/ADMIN/admin_{country_iso3}.gpkg")) %>% st_simplify()
        id_col <- "GEOLEV2"
        area <- "adm2_area"
    } else {
        id_col <- "geo_id"
        area <- "area"
    }
    if (nrow(osm_multipolygons) > 0) {
        osm_multipolygons <- st_centroid(osm_multipolygons)
    }
    bind_data(osm_points, osm_multipolygons)
    locations <- st_simplify(locations)
    locations <- terra::intersect(vect(locations), vect(osm_points)) %>%
        st_as_sf() %>%
        st_cast("MULTIPOINT")
    result <- st_drop_geometry(locations) %>%
        group_by(.data[[id_col]], .data[[area]], pop) %>%
        summarize(cnt = n()) %>%
        summarize(val = cnt / .data[[area]] / pop * 1000)
    if (exists("GEOLEV2", where = locations)) {
        result <- collapse::join(
            original_loc,
            result,
            how = "left",
            on = "GEOLEV2",
            verbose = 2
        ) %>% st_as_sf()
    }
    return(result)
}

# C_GOV2
# Access to emergency services: hospitals, fire brigades, police stations
# Proxy: Density of  emergency services
# hospitals, fire brigades, police stations per 1,000 inhabitants
C_GOV2 <- function(locations, ...) {
    emergency_services <- c("hospital", "clinic", "police", "fire_station")
    q <- osm_query("points", "amenity", emergency_services)
    osm_points <- oe_get(
        place = locations[1, ]$CNTRY_NAME,
        quiet = FALSE,
        layer = "points",
        query = q,
        extra_tags = emergency_services
    )
    q <- osm_query("multipolygons", "amenity", emergency_services)
    osm_multipolygons <- oe_get(
        place = locations[1, ]$CNTRY_NAME,
        quiet = FALSE,
        layer = "multipolygons",
        query = q,
        extra_tags = emergency_services
    )
    if (exists("GEOLEV2", where = locations)) {
        original_loc <- locations
        country_iso3 <- unique(locations$country_iso3)[1]
        locations <- st_read(glue::glue("data/ADMIN/admin_{country_iso3}.gpkg")) %>% st_simplify()
        id_col <- "GEOLEV2"
    } else {
        id_col <- "geo_id"
    }
    if (nrow(osm_multipolygons) > 0) {
        osm_multipolygons <- st_centroid(osm_multipolygons)
    }
    bind_data(osm_points, osm_multipolygons)
    locations <- st_simplify(locations)
    locations <- terra::intersect(vect(locations), vect(osm_points)) %>%
        st_as_sf() %>%
        st_cast("MULTIPOINT")
    result <- st_drop_geometry(locations) %>%
        group_by(.data[[id_col]], pop) %>%
        summarize(cnt = n()) %>%
        summarize(val = cnt / pop * 1000)
    if (exists("GEOLEV2", where = locations)) {
        result <- collapse::join(
            original_loc,
            result,
            how = "left",
            on = "GEOLEV2",
            verbose = 2
        ) %>% st_as_sf()
    }
    return(result)
}

# C_TRA1
# Access to transportation network
# Density of transportation network:
# - roads (highways, trunks, primary / secondary / tertiary),
# - waterways (rivers / canals / streams),
# - ferry stations
# per 1,000 inhabitants
C_TRA1 <- function(locations, ...) {
    all_road_types <- c(
        "motorway", "trunk", "primary", "secondary", "tertiary", "unclassified"
    )
    road_types <- paste(shQuote(all_road_types), collapse = ", ")
    waterways_types <- c("river", "canal", "fairway")
    waterways_types <- paste(shQuote(waterways_types), collapse = ", ")
    osm_lines <- oe_get(
        place = locations[1, ]$CNTRY_NAME,
        quiet = FALSE,
        layer = "lines",
        query = glue::glue("
            SELECT osm_id, name as osm_name, highway, waterway, geometry
            FROM 'lines'
            WHERE highway IN ({road_types})
            OR waterway IN ({waterways_types})
        ")
    )
    if (exists("GEOLEV2", where = locations)) {
        original_loc <- locations
        country_iso3 <- unique(locations$country_iso3)[1]
        locations <- st_read(glue::glue("data/ADMIN/admin_{country_iso3}.gpkg")) %>% st_simplify()
        id_col <- "GEOLEV2"
    } else {
        id_col <- "geo_id"
    }
    locations <- st_simplify(locations)
    locations <- terra::intersect(vect(locations), vect(osm_lines)) %>%
        st_as_sf() %>%
        st_cast("MULTILINESTRING")
    # st_write(locations, "objects/roads_per_location.gpkg", append = FALSE)
    locations$road_length <- st_length(locations)
    result <- st_drop_geometry(locations) %>%
        group_by(.data[[id_col]], pop) %>%
        summarize(cnt = sum(road_length)) %>%
        summarize(val = cnt / pop * 1000)
    if (exists("GEOLEV2", where = locations)) {
        result <- collapse::join(
            original_loc,
            result,
            how = "left",
            on = "GEOLEV2",
            verbose = 2
        ) %>% st_as_sf()
    }
    return(result)
}

# highway=trunk, highway=primary, highway=secondary, highway=tertiary, highway=unclassified

# https://wiki.openstreetmap.org/wiki/Map_features#Waterway
# waterway=stream for a naturally-forming waterway that is too narrow to be classed as waterway=river
# (the commonly accepted rule for OpenStreetMap is that a stream can be jumped across by an active, able-bodied person).
# A stream need not be permanently filled with water. In case of varying size or intermittent waterways
# the distinction from larger rivers based on the above criterion should be made with respect to the high water level.

# Use waterway=fairway for a linear way representation of a navigable route in a body of water such as a lake or sea,
# in cases where other values such as waterway=river or waterway=canal are not appropriate.
# Do not use instead of waterway=river or waterway=canal.
