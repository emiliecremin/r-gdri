library(dplyr)
library(ggplot2)
library(sf)
library(terra)

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

# Get the Macro tile from ESA worldcover 2020
# https://worldcover2020.esa.int/downloader
# direct link for Asia:
# https://worldcover2020.esa.int/data/archive/ESA_WorldCover_10m_2020_v100_60deg_macrotile_S30E060.zip
dir <- "data/ESA_Landcover/ESA_WorldCover_10m_2020_v100_60deg_macrotile_S30E060"
raster_files <- list.files(
    normalizePath(dir),
    pattern = "\\.(tif|tiff)$",
    ignore.case = TRUE,
    full.names = TRUE
)

landcover <- terra::vrt(raster_files,
    filename = "data/ESA_Landcover/VNM.vrt"
)
roi <- st_read("data/ADMIN/admin.shp") %>%
    st_make_valid() %>%
    summarise()

buffer <- st_buffer(
    roi,
    dist = units::set_units(5, km)
) %>% st_cast()

roi_with_buffer <- st_union(roi, buffer)

r <- terra::crop(landcover, roi_with_buffer)
terra::writeRaster(r, filename = "data/ESA_Landcover/VNM.tif")
landcover_roi <- mask(x = landcover, mask = roi_with_buffer)
plot(landcover_roi)
terra::writeRaster(landcover_roi, filename = "data/ESA_Landcover/VNM_roi.tif")

# 10 = Tree cover / 20 = Shrubland / 30 = Grassland
# 80 = Permanent water bodies / 90 = Herbaceous wetland / 95 = Mangroves / 100 = Moss and lichen
rclmat <- matrix(c(9, 31, 1, 79, 101, 1), ncol = 3, byrow = TRUE)
ecosystems <- classify(landcover_roi, rclmat, others = NA)
plot(ecosystems)
terra::writeRaster(ecosystems, filename = "data/ESA_Landcover/VNM_ecosystems.tif")

rclmat <- matrix(c(9, 11, 1, 94, 96, 1), ncol = 3, byrow = TRUE)
forests <- classify(landcover_roi, rclmat, others = NA)
plot(forests)
terra::writeRaster(forests, filename = "data/ESA_Landcover/VNM_forests.tif")
