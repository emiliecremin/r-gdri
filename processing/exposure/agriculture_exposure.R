# data source: World Bank
# doi:10.1038/ncomms11969
# https://www.nature.com/articles/ncomms11969
# https://energydata.info/dataset/global-coastal-flood-hazard/resource/46904e08-7daa-4c58-8c62-f0c27407ba5c
# unit: extreme sea levels in meters caused by storm surges and high tides
# m by % of agriculture in the area
A_EXP_COF <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    storm_surge <- rast("data/Hazards/StormSurge/ss_muis_rp0100m.tif")
    agriculture <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_agriculture.tif"))
    storm_surge_cropped <- crop(storm_surge, agriculture)
    ### zonal statistics using "exactextractr"
    locations$cnt <- exact_extract(storm_surge_cropped, locations, "mean", progress = TRUE)
    locations$val <- locations$cnt * as.numeric(locations$agri_pct)
    return(locations)
}

# Coalition for Disaster Resilient Infrastructure (CDRI)
# https://doi.org/10.59375/biennialreport.ed1
# https://giri.unepgrid.ch/map?list=explore&view=MX-UG0KA-OIQSJ-FIMNA
# unit: cyclone wind km/h by % of ecosystems in the area (for a return period of 100 years)
A_EXP_CYC <- function(locations, ...) {
    locations <- st_read("data/ADMIN/villages_bgd.gpkg")
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    cyclones <- rast("data/Hazards/Cyclones/Wind_T100.tif")
    agriculture <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_agriculture.tif"))
    cyclones_cropped <- crop(cyclones, agriculture)
    ### zonal statistics using "exactextractr"
    locations$cnt <- exact_extract(cyclones_cropped, locations, "mean", progress = TRUE)
    locations$val <- locations$cnt * as.numeric(locations$agri_pct)
    return(locations)
}

# Drought data source Aqueduct
# Note: Calculated on the whole administrative area
# unit: score classification [Low (0.0-0.2), Low-medium (0.2-0.4), Medium (0.4-0.6), Medium-high (0.6-0.8), High (0.8-1.0)]
# drr score by % of agriculture in the area
A_EXP_DRO <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    # drr: Drought risk
    drought <- map_aqueduct(locations, "drr")
    locations$val <- drought$val * as.numeric(locations$agri_pct)
    return(locations)
}

# data source: UNEP
# https://wesr.unepgrid.ch/static.html?views=MX-JXZXA-MFZNN-LTXZ8&zoomToViews=true
# unit: cm of flood on a 100 year return period
# cm by % of agriculture in the area
A_EXP_FLO <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    floods <- rast("data/Hazards/Floods/fl_hazard_100_yrp.tif")
    agriculture <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_agriculture.tif"))
    floods_cropped <- crop(floods, agriculture)
    ### zonal statistics using "exactextractr"
    locations$cnt <- exact_extract(floods_cropped, locations, "mean", progress = TRUE)
    locations$val <- locations$cnt * as.numeric(locations$agri_pct)
    return(locations)
}

# Global Soil Salinity Map
#  https://doi.org/10.1016/j.rse.2019.111260
#  https://data.isric.org/geonetwork/srv/eng/catalog.search#/metadata/c59d0162-a258-4210-af80-777d7929c512
#  https://code.earthengine.google.com/d43e5a92ae1deed32a0929f57b572756
# unit: soil salinity classification 0 to 4 [0: non-saline, 1: slightly, 2: moderately, 3: highly, 4: extremely]
# score by % of agriculture in the area
A_EXP_SAL <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    salinity <- terra::rast("data/Soil/Salinity/salmap2016.vrt")
    ecosystems <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_agriculture.tif"))
    salinity_cropped <- crop(salinity, ecosystems)
    ### zonal statistics using "exactextractr"
    locations$cnt <- exact_extract(salinity_cropped, locations, "mean", progress = TRUE)
    locations$val <- locations$cnt * as.numeric(locations$agri_pct)
    return(locations)
}

agriculture_exposure_indicators <- c(
    "A_EXP_COF", # Costal Floods, storm surges
    "A_EXP_CYC", # Cyclones
    "A_EXP_DRO", # Droughts
    "A_EXP_FLO", # Floods
    "A_EXP_SAL" # Salinity
)

agriculture_exposure <- function(locations) {
    return(
        process_indicators(
            locations,
            indicators = agriculture_exposure_indicators,
            # output="output/exposure"
        )
    )
}
