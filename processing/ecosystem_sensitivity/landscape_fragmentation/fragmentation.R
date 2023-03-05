source("install.R")
source("libraries.R")

"
Value	Color	Description
10	006400	Trees
20	ffbb22	Shrubland
30	ffff4c	Grassland
40	f096ff	Cropland
50	fa0000	Built-up
60	b4b4b4	Barren / sparse vegetation
70	f0f0f0	Snow and ice
80	0064c8	Open water
90	0096a0	Herbaceous wetland
95	00cf75	Mangroves
100	fae6a0	Moss and lichen
https://developers.google.com/earth-engine/datasets/catalog/ESA_WorldCover_v100#bands
"

landscape <- terra::rast("ESA_landcover_2020_10m.tif")
adm_shp <- terra::vect("../ER_Coastal_Mun.shp")
landscape <- crop(landscape, ext(adm_shp))
landscape <- mask(landscape, adm_shp)
plot(landscape)
# Re-Classify vegetation / non-vegetation
# class 1 < 40
# class 0 >= 40
vegetation <- landscape < 40
plot(vegetation)
# check_landscape(vegetation)

result <- rep(NA, nrow(adm_shp))

for(i in 1:nrow(adm_shp)) {
  feature <- adm_shp[i,]
  cat(sprintf("%s: (%s/%s)\n", feature$NAME_3, i, nrow(adm_shp)))
  l <- mask(vegetation, feature)
  plot(l)
  feat_agg_index <- lsm_c_ai(l)
  print(feat_agg_index)
  if (nrow(feat_agg_index) > 1) {
    result[i] <- dplyr::filter(feat_agg_index, class == 1)$value
  }
}
adm_shp$agg_index <- result
export <- subset(adm_shp, !is.na(adm_shp$agg_index), select=c("NAME_3", "agg_index"), drop=TRUE)
print(export)
write.csv(export, file="aggregated_index.csv")


# check_landscape(vegetation)
"
  layer        crs   units   class n_classes OK
1     1 geographic degrees integer         2  ✖
Warning message:
Caution: Coordinate reference system not metric - Units of results based on cellsizes and/or distances may be incorrect.
"

# crs(landscape)
# crs(adm_shp)
# check_landscape(landscape)
# lsm_l_ai(landscape)

# cat_raster_wgs84 = terra::project(landscape, "EPSG:4326", method = "near")
# crs(cat_raster_wgs84)
# check_landscape(cat_raster_wgs84)
# crs(landscape) <- CRS('+init=EPSG:4326')
# check_landscape(landscape)
# check_landscape(landscapemetrics::augusta_nlcd)
