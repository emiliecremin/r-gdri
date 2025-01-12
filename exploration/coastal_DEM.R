source("common/libraries.R")
source("common/helpers.R")
library(purrr)
library(sf)
library(terra)

get_coastal_dem <- function(locations) {
    country_iso3 <- unique(locations$country_iso3)[1]

    src_dir <- "data/Landcover/coastaldemv2.1_90m_egm96"

    if(country_iso3 == "VNM") {
        """
        Coordinates for Vietnam
        N08 - N21
        E103 - E109
        """
        raster_files <- list.files(
            normalizePath(src_dir),
            pattern = "N(0[8-9]|1[0-9]|2[0-2])E(10[3-9])\\.tif$",
            ignore.case = TRUE,
            full.names = TRUE
        )
    } else {
        """
        Coordinates for Bangladesh and West Bengal
        N20 - N25
        E085 - E094
        """
        raster_files <- list.files(
            normalizePath(src_dir),
            pattern = "N(20|2[1-5])E(08[5-9]|09[0-4])\\.tif$",
            ignore.case = TRUE,
            full.names = TRUE
        )
    }

    coastal_dem_vrt <- terra::vrt(raster_files)
    # plot(coastal_dem_vrt)
    coastal_dem_cropped <- crop(coastal_dem_vrt, ext(locations))
    # plot(coastal_dem_cropped)
    coastal_dem_filtered <- coastal_dem_cropped
    coastal_dem_filtered[coastal_dem_filtered > 2] <- NA
    # plot(coastal_dem_filtered)
    return(coastal_dem_filtered)
}

coastal_dem_filtered <- get_coastal_dem(locations)
country_iso3 <- unique(locations$country_iso3)[1]
agriculture <- glue::glue("objects/ESA_Landcover/{country_iso3}_agriculture.tif")

coastal_dem_masked <- mask_rasters(agriculture, coastal_dem_filtered)
plot(coastal_dem_masked)
locations <- raster_area_within_polygons(coastal_dem_masked, locations)
locations$cnt <- locations$area_raster_km2
locations$val <- locations$area_raster_km2 / locations$agri_km2
plot(locations["val"])
