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
        layer = "points",
        query = q,
        extra_tags = education_services
    )
    q <- osm_query("multipolygons", "amenity", education_services)
    osm_multipolygons <- oe_get(
        place = locations[1, ]$CNTRY_NAME,
        layer = "multipolygons",
        query = q,
        extra_tags = education_services
    )
    for (i in 1:nrow(locations)) {
        location <- locations[i, ]
        cnt <- 0
        if (nrow(osm_points) > 0) {
            cat(
                "osm_extract points for", location$geo_id,
                "in", location$CNTRY_NAME, "\n"
            )
            location_points <- terra::crop(
                vect(osm_points), vect(location)
            )
            if (nrow(location_points) > 0) {
                cnt <- cnt + nrow(as.data.frame(location_points))
            }
        }
        if (nrow(osm_multipolygons) > 0) {
            cat(
                "osm_extract multipolygons for", location$geo_id,
                "in", location$CNTRY_NAME, "\n"
            )
            location_multipolygons <- terra::crop(
                vect(osm_multipolygons), vect(location)
            )
            if (nrow(location_multipolygons) > 0) {
                cnt <- cnt + nrow(as.data.frame(location_multipolygons))
            }
        }
        locations$cnt[i] <- cnt
    }
    locations$val <- locations$cnt / as.numeric(locations$area) / locations$pop * 1000
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
        layer = "points",
        query = q,
        extra_tags = emergency_services
    )
    q <- osm_query("multipolygons", "amenity", emergency_services)
    osm_multipolygons <- oe_get(
        place = locations[1, ]$CNTRY_NAME,
        layer = "multipolygons",
        query = q,
        extra_tags = emergency_services
    )
    for (i in 1:nrow(locations)) {
        location <- locations[i, ]
        cnt <- 0
        if (nrow(osm_points) > 0) {
            cat(
                "osm_extract points for", location$geo_id,
                "in", location$CNTRY_NAME, "\n"
            )
            location_points <- terra::crop(
                vect(osm_points), vect(location)
            )
            if (nrow(location_points) > 0) {
                cnt <- cnt + nrow(as.data.frame(location_points))
            }
        }
        if (nrow(osm_multipolygons) > 0) {
            cat(
                "osm_extract multipolygons for", location$geo_id,
                "in", location$CNTRY_NAME, "\n"
            )
            location_multipolygons <- terra::crop(
                vect(osm_multipolygons), vect(location)
            )
            if (nrow(location_multipolygons) > 0) {
                cnt <- cnt + nrow(as.data.frame(location_multipolygons))
            }
        }
        locations$cnt[i] <- cnt
    }
    locations$val <- locations$cnt / locations$pop * 1000
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
    locations <- bgd
    all_road_types <- c(
        "motorway", "trunk", "primary", "secondary", "tertiary", "unclassified"
    )
    road_types <- paste(shQuote(all_road_types), collapse = ", ")
    waterways_types <- c("river", "canal", "fairway")
    waterways_types <- paste(shQuote(waterways_types), collapse = ", ")
    osm_data <- oe_get(
        place = location$CNTRY_NAME,
        layer = "lines",
        query = glue::glue("
            SELECT osm_id, name, highway, waterway, geometry
            FROM 'lines'
            WHERE highway IN ({road_types})
            OR waterway IN ({waterways_types})
        ")
    )
    for (i in 1:nrow(locations)) {
        location <- locations[i, ]
        cnt <- 0
        if (nrow(osm_data) > 0) {
            cat(
                "osm_extract highways and waterways for", location$geo_id,
                "in", location$CNTRY_NAME, "\n"
            )
            location_data <- terra::crop(vect(osm_data), vect(location))
            if (nrow(location_data) > 0) {
                cnt <- as.numeric(
                    sum(st_length(st_as_sf(location_data)))
                )
            }
        }
        locations$cnt[i] <- cnt
    }
    locations$val <- locations$cnt / locations$pop * 1000
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
