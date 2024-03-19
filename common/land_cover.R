source("common/helpers.R")

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

create_landcover <- function(landcover, roi, region_name) {
    # roi <- terra::vect("data/ADMIN/admin_ind.gpkg")
    # region_name <- "IND"
    # landcover_roi <- terra::rast(str_glue("data/ESA_Landcover/{region_name}_roi.tif"))

    roi <- roi %>%
        terra::aggregate()
    pv <- terra::project(roi, landcover)
    landcover_roi <- terra::crop(landcover, pv, mask = TRUE)
    # plot(landcover_roi)
    terra::writeRaster(
        landcover_roi,
        filename = str_glue("data/ESA_Landcover/{region_name}_roi.tif"),
        overwrite = TRUE
    )

    # Ecosystem = Shrubland 20 + Grassland 30 + Herbaceous wetland 90 + Mangroves 95
    ecosystems <- extract_classes(landcover_roi, c(19, 31, 1, 89, 96, 1))
    # plot(ecosystems)
    terra::writeRaster(
        ecosystems,
        filename = str_glue("data/ESA_Landcover/{region_name}_ecosystems.tif"),
        overwrite = TRUE
    )

    # TODO: + protected areas (vect polygons)
    # xv <- rasterize(pv, r, fun=sum)
    # https://rdrr.io/github/rspatial/terra/man/rasterize.html
    # cover= FALSE

    # TODO: rbind(c(10, 1), c(95, 1))
    forests <- extract_classes(landcover_roi, c(9, 11, 1, 94, 96, 1))
    # plot(forests)
    terra::writeRaster(
        forests,
        filename = str_glue("data/ESA_Landcover/{region_name}_forests.tif"),
        overwrite = TRUE
    )

    # TODO: rbind(c(40, 1), c(80, 1))
    # Agriculture = cropland + agro-forestery = forest 10 (-protected area) + Cropland 40
    agriculture <- extract_classes(landcover_roi, c(9, 11, 1, 39, 41, 1))
    # plot(agriculture)
    terra::writeRaster(
        agriculture,
        filename = str_glue("data/ESA_Landcover/{region_name}_agriculture.tif"),
        overwrite = TRUE
    )

    # Waterscape = Water bodies 80 + bare /sparse vegetation 60
    # Can be associated to aquaculture in coastal areas
    waterscape <- extract_classes(landcover_roi, c(79, 81, 1, 59, 61, 1))
    # plot(waterscape)
    terra::writeRaster(
        waterscape,
        filename = str_glue("data/ESA_Landcover/{region_name}_waterscape.tif"),
        overwrite = TRUE
    )
}


roi <- terra::vect("data/ADMIN/villages_vnm.gpkg")
create_landcover(landcover, roi, "VNM")

roi <- terra::vect("data/ADMIN/villages_bgd.gpkg")
create_landcover(landcover, roi, "IND")

roi <- terra::vect("data/ADMIN/villages_ind.gpkg")
create_landcover(landcover, roi, "BGD")
