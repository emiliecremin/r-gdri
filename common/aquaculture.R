# Supervised classification based on Sentinel2 images
# Using Google Earth Engine
# https://code.earthengine.google.com/ce85927e0b105d255fab386ae2dc9737?noload=true

# The aquaculture class is detected based on the reflectance of the image
# Areas classified as such have a probability to be used for aquaculture

create_aquaculture <- function(country_iso3) {
    dir <- "data/Landcover/aquaculture_sentinel2"
    src_dir <- glue::glue("{dir}/{country_iso3}")
    raster_files <- list.files(
        normalizePath(src_dir),
        pattern = "\\.(tif|tiff)$",
        ignore.case = TRUE,
        full.names = TRUE
    )

    aquaculture <- terra::vrt(raster_files,
        filename = glue::glue("{src_dir}/{country_iso3}_aquaculture.vrt"),
        overwrite = TRUE
    )

    aquaculture_single <- extract_classes(aquaculture, c(0, 2, 1))
    # plot(aquaculture_single)
    terra::writeRaster(
        aquaculture_single,
        filename = glue::glue("{dir}/{country_iso3}_aquaculture.tif"),
        overwrite = TRUE
    )
}

create_aquaculture("BGD")
create_aquaculture("VNM")
create_aquaculture("IND")
