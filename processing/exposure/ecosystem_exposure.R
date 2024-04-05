E_EXP_COF <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    # data source: World Bank
    # https://energydata.info/dataset/global-coastal-flood-hazard/resource/46904e08-7daa-4c58-8c62-f0c27407ba5c
    storm_surge <- rast("data/Hazards/StormSurge/ss_muis_rp0100m.tif")
    ecosystems <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_ecosystems.tif"))
    storm_surge_cropped <- crop(storm_surge, ecosystems)
    ### zonal statistics using "exactextractr"
    locations$cnt <- exact_extract(storm_surge_cropped, locations, "sum", progress = TRUE)
    locations$val <- locations$cnt / as.numeric(locations$area)
    return(locations)
}

E_EXP_CYC <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    # data source: UNEP GRID
    # https://datacore.unepgrid.ch/geoserver/wesr_risk/wcs?service=WCS&Version=2.0.1&request=GetCoverage&coverageId=cy_valuency&outputCRS=EPSG:4326&format=GEOTIFF&compression=DEFLATE
    cyclones <- rast("data/Hazards/Cyclones/cy_frequency.tif")
    ecosystems <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_ecosystems.tif"))
    cyclones_cropped <- crop(cyclones, ecosystems)
    ### zonal statistics using "exactextractr"
    locations$cnt <- exact_extract(cyclones_cropped, locations, "sum", progress = TRUE)
    locations$val <- locations$cnt / as.numeric(locations$area)
    return(locations)
}

# Drought data source Aqueduct
# Note: Calculated on the whole administrative area
# will be the exact same for ecosystems, agriculture and waterscape for now
# TODO: take into account the relevant area of the raster
E_EXP_DRO <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    # drr: Drought risk
    drought <- map_aqueduct(locations, "drr")
    locations$val <- drought$val / as.numeric(locations$area)
    return(locations)
}


E_EXP_FLO <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    # data source: UNEP
    # https://wesr.unepgrid.ch/static.html?views=MX-JXZXA-MFZNN-LTXZ8&zoomToViews=true
    floods <- rast("data/Hazards/Floods/fl_hazard_100_yrp.tif")
    ecosystems <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_ecosystems.tif"))
    floods_cropped <- crop(floods, ecosystems)
    ### zonal statistics using "exactextractr"
    locations$cnt <- exact_extract(floods_cropped, locations, "sum", progress = TRUE)
    locations$val <- locations$cnt / as.numeric(locations$area)
    return(locations)
}


ecosystem_exposure_indicators <- c(
    "E_EXP_COF", # Costal Floods, storm surges
    "E_EXP_CYC", # Cyclones
    "E_EXP_DRO", # Droughts
    "E_EXP_FLO" # Floods
)

ecosystem_exposure <- function(locations) {
    return(
        process_indicators(
            locations,
            indicators = ecosystem_exposure_indicators,
            # output = "output/exposure"
        )
    )
}
