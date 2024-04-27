# https://www.nature.com/articles/s41597-021-00846-6
# https://sedac.ciesin.columbia.edu/data/set/pend-gdis-1960-2018/data-download
# https://public.emdat.be/data

# Data filtered since year 2000
source("processing/GDIS.R")

S_EXP_COF_151_A <- function(locations, ...) {
    locations <- get_emdat_indicator_per_hazards(locations, "Total.Deaths", c("Coastal flood"))
    locations$val <- locations$idx / locations$pop
    return(locations)
}

S_EXP_CYC_151_A <- function(locations, ...) {
    locations <- get_emdat_indicator_per_hazards(locations, "Total.Deaths", c("Tropical cyclone", "Convective storm"))
    locations$val <- locations$idx / locations$pop
    return(locations)
}

S_EXP_FLO_151_A <- function(locations, ...) {
    locations <- get_emdat_indicator_per_hazards(locations, "Total.Deaths", c("Flash flood", "Riverine flood"))
    locations$val <- locations$idx / locations$pop
    return(locations)
}

S_EXP_COF_151_B <- function(locations, ...) {
    locations <- get_emdat_indicator_per_hazards(locations, "Total.Affected", c("Coastal flood"))
    locations$val <- locations$idx / locations$pop
    return(locations)
}

S_EXP_CYC_151_B <- function(locations, ...) {
    locations <- get_emdat_indicator_per_hazards(locations, "Total.Affected", c("Tropical cyclone", "Convective storm"))
    locations$val <- locations$idx / locations$pop
    return(locations)
}

S_EXP_FLO_151_B <- function(locations, ...) {
    locations <- get_emdat_indicator_per_hazards(locations, "Total.Affected", c("Flash flood", "Riverine flood"))
    locations$val <- locations$idx / locations$pop
    return(locations)
}

S_EXP_COF_152 <- function(locations, ...) {
    locations <- get_emdat_indicator_per_hazards(locations, "Total.Damages..Adjusted...000.US..", c("Coastal flood"))
    locations$val <- locations$idx
    return(locations)
}

S_EXP_CYC_152 <- function(locations, ...) {
    locations <- get_emdat_indicator_per_hazards(locations, "Total.Damages..Adjusted...000.US..", c("Tropical cyclone", "Convective storm"))
    locations$val <- locations$idx
    return(locations)
}

S_EXP_FLO_152 <- function(locations, ...) {
    locations <- get_emdat_indicator_per_hazards(locations, "Total.Damages..Adjusted...000.US..", c("Flash flood", "Riverine flood"))
    locations$val <- locations$idx
    return(locations)
}

S_EXP_COF <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    # data source: World Bank
    # https://energydata.info/dataset/global-coastal-flood-hazard/resource/46904e08-7daa-4c58-8c62-f0c27407ba5c
    storm_surge <- rast("data/Hazards/StormSurge/ss_muis_rp0100m.tif")

    # Other dataset to consider
    # https://www.frontiersin.org/articles/10.3389/fmars.2020.00263/full
    # data: https://zenodo.org/record/3660927#.Y1JwOuzMKDU
    # Mesh Layer QGIS: https://gis.stackexchange.com/questions/357159/cannot-open-netcdf-file-in-qgis

    ### zonal statistics using "exactextractr"
    locations$cnt <- exact_extract(storm_surge, locations, "mean", progress = TRUE)
    locations$val <- locations$cnt * locations$pop
    return(locations)
}

S_EXP_CYC <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    # https://datacore.unepgrid.ch/geoserver/wesr_risk/wcs?service=WCS&Version=2.0.1&request=GetCoverage&coverageId=cy_physexp&outputCRS=EPSG:4326&format=GEOTIFF&compression=DEFLATE
    # population affected
    # cyclones <- rast("data/Hazards/Cyclones/cy_physexp.tif")

    # https://datacore.unepgrid.ch/geoserver/wesr_risk/wcs?service=WCS&Version=2.0.1&request=GetCoverage&coverageId=cy_valuency&outputCRS=EPSG:4326&format=GEOTIFF&compression=DEFLATE
    cyclones <- rast("data/Hazards/Cyclones/cy_frequency.tif")


    ### zonal statistics using "exactextractr"
    locations$cnt <- exact_extract(cyclones, locations, "mean", progress = TRUE)
    locations$val <- locations$cnt * locations$pop

    # Other dataset
    # https://risk.preventionweb.net/download/Cyclonic%20wind_RT100years_g152.zip
    return(locations)
}

# Drought data source Aqueduct
S_EXP_DRO <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    # drr: Drought risk
    drought <- map_aqueduct(locations, "drr")
    locations$val <- drought$val * locations$pop
    return(locations)
}


S_EXP_FLO <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    # data source: UNEP
    # https://wesr.unepgrid.ch/static.html?views=MX-JXZXA-MFZNN-LTXZ8&zoomToViews=true
    floods <- rast("data/Hazards/Floods/fl_hazard_100_yrp.tif")

    ### zonal statistics using "exactextractr"
    locations$cnt <- exact_extract(floods, locations, "mean", progress = TRUE)
    locations$val <- locations$cnt * locations$pop
    return(locations)
}

# Global Soil Salinity Map
#  https://doi.org/10.1016/j.rse.2019.111260
#  https://data.isric.org/geonetwork/srv/eng/catalog.search#/metadata/c59d0162-a258-4210-af80-777d7929c512
S_EXP_SAL <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    sal <- terra::rast("data/Soil/Salinity/salmap2016.vrt")

    ### zonal statistics using "exactextractr"
    locations$cnt <- exact_extract(sal, locations, "mean", progress = TRUE)
    locations$val <- locations$cnt * locations$pop
    return(locations)
}

social_exposure_indicators <- c(
    "S_EXP_COF", # Costal Floods, storm surges
    "S_EXP_CYC", # Cyclones
    "S_EXP_DRO", # Droughts
    "S_EXP_FLO", # Floods
    "S_EXP_SAL", # Salinity
    "S_EXP_COF_151_A", # EM-DAT: Deaths due to Costal Floods
    "S_EXP_CYC_151_A", # EM-DAT: Deaths due to Cyclones
    "S_EXP_FLO_151_A", # EM-DAT: Deaths due to Floods
    "S_EXP_COF_151_B", # EM-DAT: People affected by Costal Floods
    "S_EXP_CYC_151_B", # EM-DAT: People affected by Cyclones
    "S_EXP_FLO_151_B", # EM-DAT: People affected by Floods
    "S_EXP_COF_152", # EM-DAT: Cost of damages in adjusted USD due to Costal Floods
    "S_EXP_CYC_152", # EM-DAT: Cost of damages in adjusted USD due to Cyclones
    "S_EXP_FLO_152" # EM-DAT: Cost of damages in adjusted USD due to Floods
)

social_exposure <- function(locations) {
    return(
        process_indicators(
            locations,
            indicators = social_exposure_indicators,
            # output="output/exposure"
        )
    )
}
