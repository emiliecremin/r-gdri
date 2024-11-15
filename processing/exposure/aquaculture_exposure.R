# data source: World Bank
# doi:10.1038/ncomms11969
# https://www.nature.com/articles/ncomms11969
# https://energydata.info/dataset/global-coastal-flood-hazard/resource/46904e08-7daa-4c58-8c62-f0c27407ba5c
# unit: extreme sea levels in meters caused by storm surges and high tides
# m by % of aquaculture in the area
AQ_EXP_COF <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    storm_surge <- rast("data/Hazards/StormSurge/ss_muis_rp0100m.tif")
    aquaculture <- rast(glue::glue("objects/aquaculture_sentinel2/{country_iso3}_aquaculture.tif"))
    storm_surge_cropped <- crop(storm_surge, aquaculture)
    ### zonal statistics using "exactextractr"
    locations$cnt <- exact_extract(storm_surge_cropped, locations, "mean", progress = TRUE)
    locations$val <- locations$cnt * as.numeric(locations$aqua_pct)
    return(locations)
}

AQ_EXP_CYC <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    # data source: UNEP GRID
    # https://datacore.unepgrid.ch/geoserver/wesr_risk/wcs?service=WCS&Version=2.0.1&request=GetCoverage&coverageId=cy_valuency&outputCRS=EPSG:4326&format=GEOTIFF&compression=DEFLATE
    cyclones <- rast("data/Hazards/Cyclones/cy_frequency.tif")
    aquaculture <- rast(glue::glue("objects/aquaculture_sentinel2/{country_iso3}_aquaculture.tif"))
    cyclones_cropped <- crop(cyclones, aquaculture)
    ### zonal statistics using "exactextractr"
    locations$cnt <- exact_extract(cyclones_cropped, locations, "sum", progress = TRUE)
    locations$val <- locations$cnt / as.numeric(locations$area)
    return(locations)
}

# Drought data source Aqueduct
# Note: Calculated on the whole administrative area
# unit: score classification [Low (0.0-0.2), Low-medium (0.2-0.4), Medium (0.4-0.6), Medium-high (0.6-0.8), High (0.8-1.0)]
# drr score by % of aquaculture in the area
AQ_EXP_DRO <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    # drr: Drought risk
    drought <- map_aqueduct(locations, "drr")
    locations$val <- drought$val * as.numeric(locations$aqua_pct)
    return(locations)
}

# data source: UNEP
# https://wesr.unepgrid.ch/static.html?views=MX-JXZXA-MFZNN-LTXZ8&zoomToViews=true
# unit: cm of flood on a 100 year return period
# cm by % of aquaculture in the area
AQ_EXP_FLO <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    floods <- rast("data/Hazards/Floods/fl_hazard_100_yrp.tif")
    aquaculture <- rast(glue::glue("objects/aquaculture_sentinel2/{country_iso3}_aquaculture.tif"))
    floods_cropped <- crop(floods, aquaculture)
    ### zonal statistics using "exactextractr"
    locations$cnt <- exact_extract(floods_cropped, locations, "sum", progress = TRUE)
    locations$val <- locations$cnt * as.numeric(locations$aqua_pct)
    return(locations)
}

# Global Soil Salinity Map
#  https://doi.org/10.1016/j.rse.2019.111260
#  https://data.isric.org/geonetwork/srv/eng/catalog.search#/metadata/c59d0162-a258-4210-af80-777d7929c512
# unit: soil salinity classification 0 to 4 [0: non-saline, 1: slightly, 2: moderately, 3: highly, 4: extremely]
# score by % of aquaculture in the area
AQ_EXP_SAL <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    salinity <- terra::rast("data/Soil/Salinity/salmap2016.vrt")
    aquaculture <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_aquaculture.tif"))
    salinity_cropped <- crop(salinity, aquaculture)
    ### zonal statistics using "exactextractr"
    locations$cnt <- exact_extract(salinity_cropped, locations, "mean", progress = TRUE)
    locations$val <- locations$cnt * as.numeric(locations$aqua_pct)
    return(locations)
}

aquaculture_exposure_indicators <- c(
    "AQ_EXP_COF", # Costal Floods, storm surges
    "AQ_EXP_CYC", # Cyclones
    "AQ_EXP_DRO", # Droughts
    "AQ_EXP_FLO", # Floods
    "AQ_EXP_SAL" # Salinity
)

aquaculture_exposure <- function(locations) {
    return(
        process_indicators(
            locations,
            indicators = aquaculture_exposure_indicators,
            # output = "output/exposure"
        )
    )
}
