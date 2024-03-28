source("common/helpers.R")

osm_query <- function(shape, key, values) {
    cond <- values %>%
        purrr::map_chr(~ paste0(
            glue::glue("other_tags LIKE '%\"{key}\"=>\""), .
        )) %>%
        purrr::map_chr(paste0, "\"%'") %>%
        paste(collapse = " OR ")
    q <- glue::glue("SELECT osm_id, name, other_tags, geometry
    FROM {shape}
    WHERE {cond}")
    return(q)
}

count_osm_features <- function(location, osm_data, counting = "numbers") {
    cnt <- 0
    geom_type <- unique(st_geometry_type(osm_data))
    cat(
        "crop osm data", location$geo_id,
        "in", location$CNTRY_NAME, "\n"
    )
    location_osm <- terra::crop(
        vect(osm_data), vect(location)
    )
    # saveRDS(location_osm, filename)
    # }
    if (nrow(location_osm) > 0) {
        if (counting == "length") {
            cnt <- as.numeric(
                sum(st_length(st_as_sf(location_osm)))
            )
        } else {
            cnt <- nrow(as.data.frame(location_osm))
        }
    }
    return(cnt)
}

osm_analysis <- function(locations,
                         osm_points = data.frame(),
                         osm_multipolygons = data.frame(),
                         osm_lines = data.frame()) {
    for (i in 1:nrow(locations)) {
        cat(i, "/", nrow(locations), " ")
        location <- locations[i, ]
        cnt <- 0
        if (nrow(osm_points) > 0) {
            cnt <- cnt + count_osm_features(location, osm_points)
        }
        if (nrow(osm_multipolygons) > 0) {
            cnt <- cnt + count_osm_features(location, osm_multipolygons)
        }
        if (nrow(osm_lines) > 0) {
            cnt <- cnt + count_osm_features(location, osm_lines, counting = "length")
        }
        locations$cnt[i] <- cnt
    }
    return(locations)
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
    original_loc <- locations
    area <- "area"
    if (exists("GEOLEV2", where = locations)) {
        country_iso3 <- unique(locations$country_iso3)[1]
        locations <- st_read(glue::glue("data/ADMIN/admin_{country_iso3}.gpkg"))
        area <- "adm2_area"
    }
    locations <- osm_analysis(locations, osm_points, osm_multipolygons)
    locations$val <- locations$cnt / as.numeric(locations[[area]]) / locations$pop * 1000
    if (exists("GEOLEV2", where = locations)) {
        locations <- collapse::join(
            original_loc,
            locations,
            how = "full",
            on = "GEOLEV2",
            verbose = 2
        )
    }
    return(locations)
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
    original_loc <- locations
    if (exists("GEOLEV2", where = locations)) {
        country_iso3 <- unique(locations$country_iso3)[1]
        locations <- st_read(glue::glue("data/ADMIN/admin_{country_iso3}.gpkg"))
    }
    locations <- osm_analysis(locations, osm_points, osm_multipolygons)
    locations$val <- locations$cnt / locations$pop * 1000
    if (exists("GEOLEV2", where = locations)) {
        locations <- collapse::join(
            original_loc,
            locations,
            how = "full",
            on = "GEOLEV2",
            verbose = 2
        )
    }
    return(locations)
}

# C_TRA1
# Access to transportation network
# Density of transportation network:
# - roads (highways, trunks, primary / secondary / tertiary),
# - waterways (rivers / canals / streams),
# - ferry stations
# per 1,000 inhabitants
C_TRA1 <- function(locations, ...) {
    locations <- bgd_villages %>% filter(GEOLEV2 %in% c(50040004, 50030009))
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
            SELECT osm_id, name, highway, waterway, geometry
            FROM 'lines'
            WHERE highway IN ({road_types})
            OR waterway IN ({waterways_types})
        ")
    )
    original_loc <- locations
    if (exists("GEOLEV2", where = locations)) {
        country_iso3 <- unique(locations$country_iso3)[1]
        locations <- st_read(glue::glue("data/ADMIN/admin_{country_iso3}.gpkg")) %>% filter(GEOLEV2 %in% c(50040004, 50030009))
    }
    locations <- osm_analysis(locations, osm_lines = osm_lines)
    locations$val <- locations$cnt / locations$pop * 1000
    if (exists("GEOLEV2", where = locations)) {
        keep_cols <- c(
            "cnt",
            "val",
            "GEOLEV2"
        )
        data <- locations[, (names(locations) %in% keep_cols)] %>%
            st_drop_geometry()
        locations <- collapse::join(
            original_loc,
            data,
            how = "left",
            on = "GEOLEV2",
            verbose = 2
        ) %>% st_as_sf()
    }
    return(locations)
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
