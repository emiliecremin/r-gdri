source("common/libraries.R")

# Function to extract the area of a raster within each polygon
raster_area_within_polygons <- function(rst, polygons) {
  # Ensure the raster has the correct CRS
  cat("Setting the CRS of the raster...\n")
  if (is.na(crs(rst)) || crs(rst) == "") {
    crs(rst) <- "EPSG:4326" # Assign CRS if it's missing
  }
  # Ensure the polygons are in sf format
  cat("Converting polygons to sf format...\n")
  if (!inherits(polygons, "sf")) {
    polygons <- sf::st_as_sf(polygons)
  }
  # Check for invalid geometries
  cat("Checking for invalid geometries...\n")
  invalid_geometries <- !st_is_valid(polygons)

  # If any invalid geometries are found, you can attempt to fix them
  cat("Fixing invalid geometries...\n")
  if (any(invalid_geometries)) {
    polygons <- st_make_valid(polygons)
  }
  # cat("Simplifying polygons...\n")
  # polygons <- st_simplify(polygons, dTolerance = 100)
  # Ensure the polygons have an area column
  if (!"area" %in% colnames(polygons)) {
    cat("Calculating area of polygons...\n")
    polygons$area <- units::set_units(st_area(polygons), km^2)
  }

  # Define the global equal-area projection (Mollweide)
  target_crs <- "ESRI:54009" # Mollweide Projection

  # Project the raster
  cat("Projecting the raster...\n")
  r_projected <- project(rst, target_crs)

  # Project the shapefile
  cat("Projecting the shapefile...\n")
  polygons_projected <- st_transform(polygons, crs = target_crs)

  # Compute the area of each raster cell in square kilometers
  cat("Calculating the area of each raster cell in square kilometers...\n")
  cell_areas <- cellSize(r_projected, unit = "km", mask = TRUE)

  # Calculate the area of the raster within each polygon
  areas_within_polygons <- exact_extract(
    cell_areas, polygons_projected, "sum",
    default_value = 0,
    progress = TRUE
  )

  # Add the area results to the polygons data frame
  polygons_projected$area_raster_km2 <- areas_within_polygons

  # Transform back to EPSG:4326
  polygons_final <- st_transform(polygons_projected, crs = 4326)

  # Calculate the area ratio
  polygons_final$val <- polygons_final$area_raster_km2 / polygons_final$area

  return(polygons_final)
}

extract_classes <- function(landcover, classes) {
  if (!inherits(landcover, "SpatRaster")) {
    landcover <- terra::rast(landcover)
  }
  rclmat <- matrix(classes, ncol = 3, byrow = TRUE)
  extracted_classes <- terra::classify(landcover, rclmat, others = NA)
  return(extracted_classes)
}

mkdirs <- function(fp) {
  if (!file.exists(fp)) {
    mkdirs(dirname(fp))
    dir.create(fp)
  }
}

# Function to bind data frames only if there is data
bind_data <- function(df_main, df_to_bind) {
  if (nrow(df_to_bind) > 0) {
    df_main <<- rbind(df_main, df_to_bind)
  }
}


rename_geometry <- function(g, name) {
  current <- attr(g, "sf_column")
  names(g)[names(g) == current] <- name
  st_geometry(g) <- name
  g
}

# https://stackoverflow.com/a/47051133/6081943
# https://medium.com/swlh/data-normalisation-with-r-6ef1d1947970#:~:text=Min%2DMax%20Normalization%20transforms%20x,been%20between%20%2D1%20and%201.
normalize_minmax <- function(x, ...) {
  res <- 1
  if (min(x, na.rm = TRUE) < max(x, na.rm = TRUE)) {
    res <- (x - min(x, ...)) / (max(x, ...) - min(x, ...))
  }
  return(res)
}

normalize <- function(data, ...) {
  tmp <- data[endsWith(colnames(data), "_val")] %>% st_drop_geometry()
  tmp[colnames(tmp)] <- lapply(
    tmp[colnames(tmp)],
    FUN = function(x) normalize_minmax(x, na.rm = TRUE)
  )
  norm <- rename_with(tmp, ~ gsub("_val", "_norm", .x, fixed = TRUE))
  return(cbind(data, norm))
}

update_gdri <- function(df, shp, indicator_code) {
  df <- df %>% st_drop_geometry()
  cols <- c("geo_id", "val")
  if ("morm" %in% colnames(df)) {
    cols <- append(cols, "nrom")
  }
  indicator <- subset(df, select = cols)
  indicator <- indicator %>% rename_with(~ paste0(str_glue("{indicator_code}_"), .x), !matches("geo_id"))
  return(joinOnColumn(indicator, shp, "geo_id"))
}

iso_country <- c("VN", "BD", "IN")
ipums_cntry <- c("704", "50", "356")
iso_ipums <- setNames(as.list(ipums_cntry), iso_country)
ipums_iso <- setNames(as.list(iso_country), ipums_cntry)

ipums <- function(iso_code) {
  return(iso_ipums[[iso_code]])
}
iso <- function(cntry_code) {
  return(ipums_iso[[cntry_code]])
}

joinOnColumn <- function(df, shp, col) {
  df[[col]] <- as.character(df[[col]])
  shp[[col]] <- as.character(shp[[col]])
  return(
    df %>%
      dplyr::full_join(y = shp, by = eval(col)) %>%
      st_as_sf()
  )
}

# leaflet color ramp
# https://rstudio.github.io/leaflet/
my_map <- function(data, col_label, col_value, title, pal_colors) {
  pal <- colorNumeric(
    palette = pal_colors,
    domain = data[[col_value]]
  )

  data[[col_value]][is.na(data[[col_value]])] <- 0
  data$label <- paste0(data[[col_label]], ": ", round(data[[col_value]], digits = 2))

  l <- leaflet() %>%
    addTiles() %>%
    addPolygons(
      data = data, label = data$label,
      stroke = FALSE, smoothFactor = 0.2, fillOpacity = 1,
      color = ~ pal(norm)
    ) %>%
    addLegend("bottomright",
      pal = pal, values = data[[col_value]],
      title = title,
      opacity = 1
    )
  return(l)
}

mapPlot <- function(shp, columnName, unit, title) {
  ggplot() +
    geom_sf(data = shp, aes(fill = eval(as.name(columnName)))) +
    scale_fill_gradient(name = unit, low = "yellow", high = "red", na.value = NA, breaks = scales::breaks_extended(), labels = scales::comma) +
    ggtitle(title) +
    coord_sf()
}

addPostcode <- function(df) {
  df$ADM2_PCODE <- paste("BD", str_pad(df$DivisionCode, 2, pad = "0"), str_pad(df$ZilaCode, 2, pad = "0"), sep = "")
  return(df)
}

joinOnPostcode <- function(df, shp) {
  return(
    df %>%
      dplyr::full_join(y = shp, by = "ADM2_PCODE") %>%
      st_as_sf()
  )
}

process_indicators <- function(locations, social_data = data.frame(), indicators, output = "") {
  result <- keep_common_columns(locations)
  country_iso3 <- unique(locations$country_iso3)[1]
  if (output != "") {
    output <- str_glue("{output}/{country_iso3}")
    mkdirs(output)
  }
  i <- 1
  for (indicator_code in indicators) {
    cat(
      "Processing indicator:", indicator_code,
      "(", i, "/", length(indicators), ")\n"
    )
    indicator <- do.call(
      get(indicator_code),
      list(locations = locations, social_data = social_data)
    )
    format_indicator(
      indicator_code, indicator, locations,
      append = FALSE, normalize = FALSE, plot = FALSE,
      output = output
    )
    result <- update_gdri(indicator, result, indicator_code)
    i <- i + 1
  }
  return(result)
}

keep_common_columns <- function(data) {
  keep_cols <- c(
    "geo_id",
    "val",
    "country_iso3",
    "CNTRY_NAME",
    "adm1_name",
    "adm2_name",
    "adm3_name",
    "adm4_name",
    "adm_level",
    "Name",
    "pop",
    "area"
  )
  data <- data[, (names(data) %in% keep_cols)]
  return(data)
}

format_indicator <- function(indicator_name, data, locations, append = FALSE, normalize = FALSE, plot = FALSE, output = "") { # nolint
  cat("format_indicator for", indicator_name, "\n")
  cat("class", class(data), "\n")
  if (!(is(data, "sf") || is(data, "SpatVector"))) {
    cat("Join data with geometries...\n")
    data <- joinOnColumn(data, locations, "geo_id")
  }
  data <- keep_common_columns(data)
  if (normalize) {
    cat("normalize", indicator_name, "\n")
    data$norm <- normalize_minmax(data$val, na.rm = TRUE)
  }
  if (plot) {
    cat("plot", indicator_name, "\n")
    mapPlot(data, "norm", "norm min-max", indicator_name)
  }
  if (output != "") {
    cat("write", indicator_name, "\n")
    st_write(data, str_glue("{output}/{indicator_name}.gpkg"), append = append)
  }
  return(data)
}


# This can ERROR with HTTP 504
# Saving each location as an object
# we can re-run the code and skip if we already have it stored
get_osm <- function(location, key, value, folder) {
  g <- attr(location, "sf_column")
  loc_code <- location$geo_id
  loc_geo <- location[[g]]
  f <- str_glue("{folder}/{loc_code}.rds")
  if (file.exists(f) == TRUE) {
    cat("already have features for: ", loc_code, "\n")
    osm_features <- readRDS(f)
  } else {
    cat("get osm features for: ", loc_code, "\n")
    osm_features <- opq(bbox = st_bbox(loc_geo), timeout = 1000) %>%
      add_osm_feature(key, value) %>%
      osmdata_sf() %>%
      unique_osmdata()
    saveRDS(osm_features, f)
  }
  return(osm_features)
}
