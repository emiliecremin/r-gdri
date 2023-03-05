# Used for debug quick preview
install.packages("ggmap")
library(ggmap)
draw_map <- function(location, features) {
  m <- get_map(getbb(location), maptype = "roadmap")
  ggmap(m) +
    geom_sf(
      data = features,
      inherit.aes = FALSE,
      colour = "#08519c",
      fill = "#08306b",
      alpha = .5,
      size = 1
    ) +
    labs(x = "", y = "")
}