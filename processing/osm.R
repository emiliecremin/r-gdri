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

osm_extract <- function(location, shape, key, values) {
    cat("osm_extract for", location$geo_id, "in", location$CNTRY_NAME, "\n")
    q <- osm_query(shape, key, values)
    osm_data <- oe_get(
        place = location$CNTRY_NAME,
        layer = shape,
        query = q,
        extra_tags = values,
        quiet = TRUE
    )
    if (nrow(osm_data) > 0) {
        osm_data <- terra::crop(vect(osm_data), vect(location))
    }
    return(osm_data)
}

# C_SHE1
# Access to shelter places
# Density of schools km2 per 1,000 inhabitants
# https://wiki.openstreetmap.org/wiki/Tag:amenity%3Dschool
# density of primary and secondary schools per km2
C_SHE1 <- function(locations, ...) {
    education_services <- c("school", "college", "university")
    for (i in 1:nrow(locations)) {
        location <- locations[i, ]
        cnt <- 0
        osm_points <- osm_extract(
            location, "points", "amenity", education_services
        )
        if (nrow(osm_points) > 0) {
            cnt <- cnt + nrow(as.data.frame(osm_points))
        }
        osm_multipolygons <- osm_extract(
            location, "multipolygons", "amenity", education_services
        )
        if (nrow(osm_multipolygons) > 0) {
            cnt <- cnt + nrow(as.data.frame(osm_multipolygons))
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
    for (i in 1:nrow(locations)) {
        location <- locations[i, ]
        cnt <- 0
        osm_points <- osm_extract(
            location, "points", "amenity", emergency_services
        )
        if (nrow(osm_points) > 0) {
            cnt <- cnt + nrow(as.data.frame(osm_points))
        }
        osm_multipolygons <- osm_extract(
            location, "multipolygons", "amenity", emergency_services
        )
        if (nrow(osm_multipolygons) > 0) {
            cnt <- cnt + nrow(as.data.frame(osm_multipolygons))
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
    # highway=trunk, highway=primary, highway=secondary, highway=tertiary, highway=unclassified
    all_road_types <- c(
        "motorway", "trunk", "primary", "secondary", "tertiary", "unclassified"
    )

    for (i in 1:nrow(locations)) {
        location <- locations[i, ]
        cnt <- 0
        osm_lines <- osm_extract(
            location, "lines", "highway", all_road_types
        )
        if (nrow(osm_lines) > 0) {
            cnt <- cnt + as.numeric(sum(st_length(osm_lines)))
        }
        osm_multilines <- osm_extract(
            location, "multilinestrings", "highway", all_road_types
        )
        if (nrow(osm_multilines) > 0) {
            cnt <- cnt + as.numeric(sum(st_length(osm_multilines)))
        }
        locations$cnt[i] <- cnt
    }

    # https://wiki.openstreetmap.org/wiki/Map_features#Waterway
    # waterway=stream for a naturally-forming waterway that is too narrow to be classed as waterway=river
    # (the commonly accepted rule for OpenStreetMap is that a stream can be jumped across by an active, able-bodied person).
    # A stream need not be permanently filled with water. In case of varying size or intermittent waterways
    # the distinction from larger rivers based on the above criterion should be made with respect to the high water level.

    # Use waterway=fairway for a linear way representation of a navigable route in a body of water such as a lake or sea,
    # in cases where other values such as waterway=river or waterway=canal are not appropriate.
    # Do not use instead of waterway=river or waterway=canal.
    waterways_types <- c("river", "canal", "fairway")

    for (i in 1:nrow(locations)) {
        location <- locations[i, ]
        cnt <- 0
        osm_lines <- osm_extract(
            location, "lines", "waterway", waterways_types
        )
        if (nrow(osm_lines) > 0) {
            cnt <- cnt + as.numeric(sum(st_length(osm_lines)))
        }
        osm_multilines <- osm_extract(
            location, "multilinestrings", "waterway", waterways_types
        )
        if (nrow(osm_multilines) > 0) {
            cnt <- cnt + as.numeric(sum(st_length(osm_multilines)))
        }
        locations$cnt[i] <- locations$cnt[i] + cnt
    }

    locations$val <- locations$cnt / locations$pop * 1000
    return(locations)
}
