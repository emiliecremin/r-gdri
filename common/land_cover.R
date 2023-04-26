source("common/libraries.R")

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
    filename = "data/ESA_Landcover/Asia.vrt",
    overwrite = TRUE
)

extract_classes <- function(landcover, classes) {
    rclmat <- matrix(classes, ncol = 3, byrow = TRUE)
    extracted_classes <- terra::classify(landcover, rclmat, others = NA)
    return(extracted_classes)
}

create_landcover <- function(landcover, roi, region_name) {
    roi <- roi %>%
        terra::aggregate()
    pv <- terra::project(roi, landcover)
    landcover_roi <- terra::crop(landcover, pv, mask = TRUE)
    plot(landcover_roi)
    terra::writeRaster(
        landcover_roi,
        filename = str_glue("data/ESA_Landcover/{region_name}_roi.tif")
    )
    # 10 = Tree cover / 20 = Shrubland / 30 = Grassland
    # 80 = Permanent water bodies / 90 = Herbaceous wetland / 95 = Mangroves / 100 = Moss and lichen
    ecosystems <- extract_classes(landcover_roi, c(9, 31, 1, 79, 101, 1))
    plot(ecosystems)
    terra::writeRaster(ecosystems, filename = str_glue("data/ESA_Landcover/{region_name}_ecosystems.tif"))

    # TODO: rbind(c(10, 1), c(95, 1))
    forests <- extract_classes(landcover_roi, c(9, 11, 1, 94, 96, 1))
    plot(forests)
    terra::writeRaster(forests, filename = str_glue("data/ESA_Landcover/{region_name}_forests.tif"))

    # TODO: rbind(c(40, 1), c(80, 1))
    agriculture <- extract_classes(landcover_roi, c(39, 41, 1, 79, 81, 1))
    plot(agriculture)
    terra::writeRaster(agriculture, filename = str_glue("data/ESA_Landcover/{region_name}_agriculture.tif"))
}

roi <- terra::vect("data/ADMIN/admin_vnm_with_buffer.gpkg")
create_landcover(landcover, roi, "VNM")

roi <- terra::vect("data/ADMIN/admin_ind_with_buffer.gpkg")
create_landcover(landcover, roi, "IND")
