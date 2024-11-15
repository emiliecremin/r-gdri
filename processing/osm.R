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

calculate_nearest <- function(locations, osm_points) {
    # Find the index of the nearest OSM point for each location
    nearest_indices <- st_nearest_feature(locations, osm_points)

    # Extract the nearest OSM points
    nearest_points <- osm_points[nearest_indices, ]

    # Calculate the distances between each location and its nearest OSM point
    distances <- st_distance(
        locations,
        nearest_points,
        by_element = TRUE # Ensures that distances are calculated between corresponding pairs
    )

    # Add the distances to the locations data (convert to numeric and units to kilometers if needed)
    locations$distance_to_nearest_point <- as.numeric(distances) / 1000 # Convert meters to kilometers

    # Identify locations without nearby OSM points
    missing_indices <- which(is.na(nearest_indices))

    # Assign a default value or handle accordingly
    if (length(missing_indices) > 0) {
        locations$distance_to_nearest_point[missing_indices] <- NA
    }
    # plot(locations['distance_to_nearest_point'])
    return(locations)
}


# C_SHE1
# Access to shelter places
# Density of schools km2 per 1,000 inhabitants
# https://wiki.openstreetmap.org/wiki/Tag:amenity%3Dschool
# unit: distance to school in km
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
    osm_points <- st_transform(osm_points, crs(locations))
    # plot(osm_points["osm_id"])
    result <- calculate_nearest(locations, osm_points) %>%
        dplyr::mutate(val = distance_to_nearest_point) %>%
        dplyr::select(-distance_to_nearest_point)
    return(result)
}

# C_GOV2
# Access to emergency services: hospitals, fire brigades, police stations
# Proxy: Density of  emergency services
# unit: distance to emergency services in km
C_GOV2 <- function(locations, ...) {
    locations <- st_read("objects/ADMIN/villages_bgd.gpkg")
    emergency_services <- c("hospital", "clinic", "police", "fire_station")
    q <- osm_query("points", "amenity", emergency_services)
    osm_points <- oe_get(
        place = locations[1, ]$CNTRY_NAME,
        quiet = FALSE,
        layer = "points",
        query = q,
        extra_tags = emergency_services
    )
    osm_points <- st_transform(osm_points, crs(locations))
    # plot(osm_points["osm_id"])
    result <- calculate_nearest(locations, osm_points) %>%
        dplyr::mutate(val = distance_to_nearest_point) %>%
        dplyr::select(-distance_to_nearest_point)
    return(result)
}

# C_TRA1
# Access to transportation network
# Density of transportation network:
# - roads (highways, trunks, primary / secondary / tertiary),
# - waterways (rivers / canals / streams),
# - ferry stations
# unit: road length in km
C_TRA1 <- function(locations, ...) {
    locations <- st_read("objects/ADMIN/villages_bgd.gpkg")
    all_road_types <- c(
        "motorway", "trunk", "primary", "secondary" # , "tertiary" #, "unclassified"
    )
    road_types <- paste(shQuote(all_road_types), collapse = ", ")
    osm_lines <- oe_get(
        place = locations[1, ]$CNTRY_NAME,
        quiet = FALSE,
        layer = "lines",
        query = glue::glue("
            SELECT osm_id, name as osm_name, highway, waterway, geometry
            FROM 'lines'
            WHERE highway IN ({road_types})
        ")
    )
    osm_points <- st_transform(osm_points, crs(locations))
    # locations <- st_simplify(locations)
    locations_intersect <- terra::intersect(vect(locations), vect(osm_lines)) %>%
        st_as_sf() %>%
        st_cast("MULTILINESTRING")
    locations_intersect$road_length <- as.numeric(st_length(locations_intersect)) / 1000
    # plot(locations_intersect["road_length"])

    # Aggregate the road lengths by location
    road_length_per_location <- locations_intersect %>%
        st_drop_geometry() %>%
        group_by(.data$geo_id) %>%
        summarize(total_road_length = sum(road_length)) %>%
        ungroup()

    locations_with_road_length <- collapse::join(
        result <- calculate_nearest(locations, osm_points) %>%
        dplyr::mutate(val = total_road_length) %>%
        dplyr::select(-total_road_length)
        locations,
        road_length_per_location,
        how = "left",
        on = "geo_id",
        verbose = 2
    ) %>% st_as_sf()
    # Replace NA values with zero for locations without roads
    locations_with_road_length$total_road_length[is.na(locations_with_road_length$total_road_length)] <- 0
    # plot(locations_with_road_length["total_road_length"])
    result <- locations_with_road_length %>%
        dplyr::mutate(val = total_road_length) %>%
        dplyr::select(-total_road_length)
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
