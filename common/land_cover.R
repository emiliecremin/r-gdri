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
dir <- "data/Landcover/ESA_Landcover/ESA_WorldCover_10m_2020_v100_60deg_macrotile_S30E060"
raster_files <- list.files(
    normalizePath(dir),
    pattern = "\\.(tif|tiff)$",
    ignore.case = TRUE,
    full.names = TRUE
)

output <- "objects/ESA_Landcover"
mkdirs(output)

landcover <- terra::vrt(raster_files,
    filename = "data/Landcover/ESA_Landcover/Asia.vrt",
    overwrite = TRUE
)

create_landcover <- function(landcover, roi, region_name) {
    roi <- roi %>%
        terra::aggregate()
    pv <- terra::project(roi, landcover)
    landcover_roi <- terra::crop(landcover, pv, mask = TRUE)
    # plot(landcover_roi)
    terra::writeRaster(
        landcover_roi,
        filename = str_glue("{output}/{region_name}_roi.tif"),
        overwrite = TRUE
    )

    # Ecosystems = Forest 10, Shrubland 20 + Grassland 30 + Open Water 80 + Herbaceous wetland 90 + Mangroves 95
    ecosystems <- extract_classes(landcover_roi, c(9, 31, 1, 79, 96, 1))
    # plot(ecosystems)
    terra::writeRaster(
        ecosystems,
        filename = str_glue("{output}/{region_name}_ecosystems.tif"),
        overwrite = TRUE
    )

    # TODO: + protected areas (vect polygons)
    # xv <- rasterize(pv, r, fun=sum)
    # https://rdrr.io/github/rspatial/terra/man/rasterize.html
    # cover= FALSE
    forests <- extract_classes(landcover_roi, c(9, 11, 1, 94, 96, 1))
    #  plot(forests)
    terra::writeRaster(
        forests,
        filename = str_glue("{output}/{region_name}_forests.tif"),
        overwrite = TRUE
    )

    # Agriculture = Cropland 40 + bare /sparse vegetation 60
    agriculture <- extract_classes(landcover_roi, c(39, 41, 1, 59, 61, 1))
    # plot(agriculture)
    terra::writeRaster(
        agriculture,
        filename = str_glue("{output}/{region_name}_agriculture.tif"),
        overwrite = TRUE
    )
}

calculate_percentages <- function(locations, region_name) {
    agriculture <- terra::rast(str_glue("{output}/{region_name}_agriculture.tif"))
    locations <- raster_area_within_polygons(agriculture, locations)
    locations <- locations %>%
        dplyr::mutate(agri_km2 = area_raster_km2) %>%
        dplyr::select(-area_raster_km2) %>%
        dplyr::mutate(agri_pct = val) %>%
        dplyr::select(-val)
    ecosystems <- terra::rast(str_glue("{output}/{region_name}_ecosystems.tif"))
    locations <- raster_area_within_polygons(ecosystems, locations)
    locations <- locations %>%
        dplyr::mutate(ecosys_km2 = area_raster_km2) %>%
        dplyr::select(-area_raster_km2) %>%
        dplyr::mutate(ecosys_pct = val) %>%
        dplyr::select(-val)
    return(locations)
}

if (!exists("vnm_villages")) {
    vnm_villages <- terra::vect("objects/ADMIN/villages_vnm.gpkg")
} else {
    vnm_villages <- terra::vect(vnm_villages)
}
region_name <- "VNM"
create_landcover(landcover, vnm_villages, region_name)
locations <- calculate_percentages(vnm_villages, region_name)
locations <- st_read("objects/ADMIN/villages_vnm.gpkg")
# plot(locations["agri_km2"])
# plot(locations["agri_pct"])
# plot(locations["ecosys_km2"])
# plot(locations["ecosys_pct"])
st_write(locations, "objects/ADMIN/villages_vnm.gpkg", append = FALSE)

if (!exists("bgd_villages")) {
    bgd_villages <- terra::vect("objects/ADMIN/villages_bgd.gpkg")
} else {
    bgd_villages <- terra::vect(bgd_villages)
}
region_name <- "BGD"
create_landcover(landcover, bgd_villages, region_name)
locations <- calculate_percentages(bgd_villages, region_name)
# plot(locations["agri_km2"])
# plot(locations["agri_pct"])
# plot(locations["ecosys_km2"])
# plot(locations["ecosys_pct"])
st_write(locations, "objects/ADMIN/villages_bgd.gpkg", append = FALSE)

if (!exists("ind_villages")) {
    ind_villages <- terra::vect("objects/ADMIN/villages_ind.gpkg")
} else {
    ind_villages <- terra::vect(ind_villages)
}
region_name <- "IND"
create_landcover(landcover, ind_villages, region_name)
locations <- calculate_percentages(ind_villages, region_name)
# plot(locations["agri_km2"])
# plot(locations["agri_pct"])
# plot(locations["ecosys_km2"])
# plot(locations["ecosys_pct"])
st_write(locations, "objects/ADMIN/villages_ind.gpkg", append = FALSE)

rm(landcover)
