# data source: World Bank
# doi:10.1038/ncomms11969
# https://www.nature.com/articles/ncomms11969
# https://energydata.info/dataset/global-coastal-flood-hazard/resource/46904e08-7daa-4c58-8c62-f0c27407ba5c
# unit: extreme sea levels in meters caused by storm surges and high tides
# m by % of ecosystems in the area
E_EXP_COF <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    storm_surge <- rast("data/Hazards/StormSurge/ss_muis_rp0100m.tif")
    ecosystems <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_ecosystems.tif"))
    storm_surge_cropped <- crop(storm_surge, ecosystems)
    ### zonal statistics using "exactextractr"
    locations$cnt <- exact_extract(storm_surge_cropped, locations, "mean", progress = TRUE)
    locations$val <- locations$cnt * as.numeric(locations$ecosys_pct)
    return(locations)
}

# Coalition for Disaster Resilient Infrastructure (CDRI)
# https://doi.org/10.59375/biennialreport.ed1
# https://giri.unepgrid.ch/map?list=explore&view=MX-UG0KA-OIQSJ-FIMNA
# unit: cyclone wind km/h by % of ecosystems in the area (for a return period of 100 years)
E_EXP_CYC <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    cyclones <- rast("data/Hazards/Cyclones/Wind_T100.tif")
    ecosystems <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_ecosystems.tif"))
    cyclones_cropped <- crop(cyclones, ecosystems)
    ### zonal statistics using "exactextractr"
    locations$cnt <- exact_extract(cyclones_cropped, locations, "mean", progress = TRUE)
    locations$val <- locations$cnt * as.numeric(locations$ecosys_pct)
    return(locations)
}

# Drought data source Aqueduct
# Note: Calculated on the whole administrative area
# unit: score classification [Low (0.0-0.2), Low-medium (0.2-0.4), Medium (0.4-0.6), Medium-high (0.6-0.8), High (0.8-1.0)]
# drr score by % of ecosystems in the area
E_EXP_DRO <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    # drr: Drought risk
    drought <- map_aqueduct(locations, "drr")
    locations$val <- drought$val * as.numeric(locations$ecosys_pct)
    return(locations)
}

# data source: UNEP
# https://wesr.unepgrid.ch/static.html?views=MX-JXZXA-MFZNN-LTXZ8&zoomToViews=true
# unit: cm of flood on a 100 year return period
# cm by % of ecosystems in the area
E_EXP_FLO <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    floods <- rast("data/Hazards/Floods/fl_hazard_100_yrp.tif")
    ecosystems <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_ecosystems.tif"))
    floods_cropped <- crop(floods, ecosystems)
    ### zonal statistics using "exactextractr"
    locations$cnt <- exact_extract(floods_cropped, locations, "mean", progress = TRUE)
    locations$val <- locations$cnt * as.numeric(locations$ecosys_pct)
    return(locations)
}

# Global Soil Salinity Map
#  https://doi.org/10.1016/j.rse.2019.111260
#  https://data.isric.org/geonetwork/srv/eng/catalog.search#/metadata/c59d0162-a258-4210-af80-777d7929c512
#  https://code.earthengine.google.com/d43e5a92ae1deed32a0929f57b572756
# unit: soil salinity classification 0 to 4 [0: non-saline, 1: slightly, 2: moderately, 3: highly, 4: extremely]
# score by % of ecosystems in the area
E_EXP_SAL <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    salinity <- terra::rast("data/Soil/Salinity/salmap2016.vrt")
    ecosystems <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_ecosystems.tif"))
    salinity_cropped <- crop(salinity, ecosystems)
    ### zonal statistics using "exactextractr"
    locations$val <- exact_extract(salinity_cropped, locations, "mean", progress = TRUE)
    return(locations)
}

ecosystem_exposure_indicators <- c(
    "E_EXP_COF", # Costal Floods, storm surges
    "E_EXP_CYC", # Cyclones
    "E_EXP_DRO", # Droughts
    "E_EXP_FLO", # Floods
    "E_EXP_SAL" # Salinity
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
