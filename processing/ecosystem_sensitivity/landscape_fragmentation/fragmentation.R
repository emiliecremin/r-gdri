source("common/install.R")
source("common/libraries.R")

landscape <- terra::rast("data/ESA_Landcover/VNM_forests.tif")
check_landscape(landscape)
"
  layer        crs   units   class n_classes OK
1     1 geographic degrees integer         2  ✖
Warning message:
Caution: Coordinate reference system not metric - Units of results based on cellsizes and/or distances may be incorrect.
"
admin_shp <- st_read("data/ADMIN/admin_with_buffer.shp") %>%
  st_transform(4326) %>%
  st_make_valid()
plot(landscape)

result <- rep(NA, nrow(admin_shp))

# install.packages("usethis")
# library(usethis)
# usethis::edit_r_environ()
# R_MAX_VSIZE=100Gb
# Error: vector memory exhausted (limit reached?)
# https://stackoverflow.com/questions/51295402/r-on-macos-error-vector-memory-exhausted-limit-reached

for (i in 1:nrow(admin_shp)) {
  feature <- admin_shp[i, ]
  cat(sprintf("%s: (%s/%s)\n", feature$ADM2_EN, i, nrow(admin_shp)))
  c <- terra::crop(landscape, feature)
  m <- mask(c, feature)
  # plot(m)
  feat_agg_index <- lsm_c_ai(m)
  print(feat_agg_index)
  result[i] <- dplyr::filter(feat_agg_index, class == 1)$value
}
admin_shp$agg_index <- result

export <- subset(
  admin_shp,
  !is.na(admin_shp$agg_index),
  select = c("ADM2_EN", "agg_index"),
  drop = TRUE
)
print(export)
write.csv(export, file = "aggregated_index.csv")

library(Makurhini)
library(stars)
i <- 1
feature <- admin_shp[i, ]
cat(sprintf("%s: (%s/%s)\n", feature$ADM2_EN, i, nrow(admin_shp)))
c <- terra::crop(landscape, feature)
m <- mask(c, feature)

MK_ProtConn_raster(landscape, feature)

s <- read_stars(raster(m))
plot(m)
# https://gis.stackexchange.com/a/415680
vegetation <- sf::st_as_sf(as.polygons(m, trunc = TRUE, dissolve = TRUE))
vege <- sf::st_cast(vegetation, "POLYGON")


vege_simple <- st_simplify(vege,
  preserveTopology = TRUE,
  dTolerance = 1000
)
st_write(
  vege,
  "vege.gpkg",
  append = FALSE
)

IIC <- MK_dPCIIC(
  vege,
  attribute = NULL,
  distance = list(type = "centroid"),
  metric = "IIC", distance_thresholds = 1000
) # 1000 m

PC <- MK_dPCIIC(
  nodes = vege, attribute = NULL,
  distance = list(type = "centroid"),
  metric = "PC", probability = 0.05,
  distance_thresholds = 1000
) # 1000 m

data("vegetation_patches", package = "Makurhini")
colnames(vegetation_patches)
st_write(
  vegetation_patches,
  "vegetation_patches.gpkg",
  append = FALSE
)
plot(vegetation_patches)
# crs(landscape)
# crs(admin_shp)
# check_landscape(landscape)
# lsm_l_ai(landscape)

# cat_raster_wgs84 = terra::project(landscape, "EPSG:4326", method = "near")
# crs(cat_raster_wgs84)
# check_landscape(cat_raster_wgs84)
# crs(landscape) <- CRS('+init=EPSG:4326')
# check_landscape(landscape)
# check_landscape(landscapemetrics::augusta_nlcd)
