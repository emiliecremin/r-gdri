source("common/libraries.R")

mkdirs <- function(fp) {
  if (!file.exists(fp)) {
    mkdirs(dirname(fp))
    dir.create(fp)
  }
}

# https://stackoverflow.com/a/47051133/6081943
# https://medium.com/swlh/data-normalisation-with-r-6ef1d1947970#:~:text=Min%2DMax%20Normalization%20transforms%20x,been%20between%20%2D1%20and%201.
normalize_minmax <- function(x, ...) {
  return((x - min(x, ...)) / (max(x, ...) - min(x, ...)))
}

updateGdriShp <- function(df, shp, indicator_code) {
  df <- df %>% st_drop_geometry()
  indicator <- subset(df, select = c("geo_id", "val", "norm"))
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

addIpums <- function(df) {
  # PCODE:  VN  82 005
  # IPUMS: 704 082 005
  cntry <- substr(df$ADM2_PCODE, 1, 2)
  adm1 <- substr(df$ADM2_PCODE, 3, 4)
  adm2 <- substr(df$ADM2_PCODE, 5, 7)
  df$GEOLEV2 <- str_replace_all(df$ADM2_PCODE, cntry, sapply(cntry, ipums))
  df$GEOLEV2 <- str_replace_all(df$GEOLEV2, adm1, str_pad(adm1, 3, pad = "0"))
  df$GEOLEV2 <- str_replace_all(df$GEOLEV2, adm2, str_pad(adm2, 3, pad = "0"))
  return(df)
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

  data$label <- paste0(data[[col_label]], ": ", round(data[[col_value]], digits = 2))

  # TODO: replace NA in char columns with empty string
  data[is.na(data)] <- 0

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
