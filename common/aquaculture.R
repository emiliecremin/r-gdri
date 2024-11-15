# Supervised classification based on Sentinel2 images
# Using Google Earth Engine
# https://code.earthengine.google.com/ce85927e0b105d255fab386ae2dc9737?noload=true

# The aquaculture class is detected based on the reflectance of the image
# Areas classified as such have a probability to be used for aquaculture

create_aquaculture <- function(country_iso3) {
    dir <- "data/Landcover/sentinel2"
    src_dir <- glue::glue("{dir}/{country_iso3}")
    output <- "objects/aquaculture_sentinel2"
    mkdirs(output)
    raster_files <- list.files(
        normalizePath(src_dir),
        pattern = "\\.(tif|tiff)$",
        ignore.case = TRUE,
        full.names = TRUE
    )

    aquaculture_vrt <- terra::vrt(raster_files,
        filename = glue::glue("{src_dir}/{country_iso3}_aquaculture.vrt"),
        overwrite = TRUE
    )

    aquaculture_single <- extract_classes(aquaculture_vrt, c(0.9, 1.1, 1))

    terra::writeRaster(
        aquaculture_single,
        filename = glue::glue("{output}/{country_iso3}_aquaculture.tif"),
        overwrite = TRUE
    )
    return(aquaculture_single)
}

bgd_villages <- st_read("objects/ADMIN/villages_bgd.gpkg")
aquaculture <- create_aquaculture("BGD")
locations <- raster_area_within_polygons(aquaculture, bgd_villages)
locations <- locations %>%
    dplyr::mutate(aqua_km2 = area_raster_km2) %>%
    dplyr::select(-area_raster_km2) %>%
    dplyr::mutate(aqua_pct = val) %>%
    dplyr::select(-val)
# plot(locations["aqua_km2"])
# plot(locations["aqua_pct"])
st_write(locations, "objects/ADMIN/villages_bgd.gpkg", append = FALSE)

vnm_villages <- st_read("objects/ADMIN/villages_vnm.gpkg")
aquaculture <- create_aquaculture("VNM")
locations <- raster_area_within_polygons(aquaculture, vnm_villages)
locations <- locations %>%
    dplyr::mutate(aqua_km2 = area_raster_km2) %>%
    dplyr::select(-area_raster_km2) %>%
    dplyr::mutate(aqua_pct = val) %>%
    dplyr::select(-val)
# plot(locations["aqua_km2"])
# plot(locations["aqua_pct"])
st_write(locations, "objects/ADMIN/villages_vnm.gpkg", append = FALSE)

ind_villages <- st_read("objects/ADMIN/villages_ind.gpkg")
aquaculture <- create_aquaculture("IND")
locations <- raster_area_within_polygons(aquaculture, ind_villages)
locations <- locations %>%
    dplyr::mutate(aqua_km2 = area_raster_km2) %>%
    dplyr::select(-area_raster_km2) %>%
    dplyr::mutate(aqua_pct = val) %>%
    dplyr::select(-val)
# plot(locations["aqua_km2"])
# plot(locations["aqua_pct"])
st_write(locations, "objects/ADMIN/villages_ind.gpkg", append = FALSE)
