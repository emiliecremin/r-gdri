# Area Exposure = affected_area / total_area
# Area Intensity = mean meters of flood

# data source: Climate Central https://coastal.climatecentral.org/
# https://doi.org/10.1016/j.rse.2017.12.026
# https://www.sciencedirect.com/science/article/abs/pii/S0034425717306016?via%3Dihub
# unit: km2 of storm surge prone agriculture
# based on digital elevation model (DEM) threshold 2m above sea level
# km2 of storm surge prone agriculture / km2 of agriculture in the area
AREA_EXP_COF <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    coastal_dem_filtered <- get_coastal_dem(locations)
    country_iso3 <- unique(locations$country_iso3)[1]
    coastal_dem_cropped <- crop(coastal_dem_filtered, ext(locations))
    locations <- raster_area_within_polygons(coastal_dem_cropped, locations)
    locations$cnt <- locations$area_raster_km2
    locations$val <- locations$area_raster_km2 / locations$area
    return(locations)
}

# data source: World Bank
# doi:10.1038/ncomms11969
# https://www.nature.com/articles/ncomms11969
# https://energydata.info/dataset/global-coastal-flood-hazard/resource/46904e08-7daa-4c58-8c62-f0c27407ba5c
# unit: extreme sea levels in meters caused by storm surges and high tides
AREA_INT_SURGE <- function(locations, ...) {
    storm_surge <- rast("data/Hazards/StormSurge/ss_muis_rp0100m.tif")
    storm_surge_cropped <- crop(storm_surge, ext(locations))
    ### zonal statistics using "exactextractr"
    locations$val <- exact_extract(storm_surge_cropped, locations, "mean", progress = TRUE)
    locations$val[is.nan(locations$val)] <- 0
    return(locations)
}

# Coalition for Disaster Resilient Infrastructure (CDRI)
# https://doi.org/10.59375/biennialreport.ed1
# https://giri.unepgrid.ch/map?list=explore&view=MX-UG0KA-OIQSJ-FIMNA
# unit: cyclone wind in km/h (wind > 150 km/h for a return period of 100 years)
AREA_INT_CYC <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    cyclones <- rast("data/Hazards/Cyclones/Wind_T100.tif")
    cyclones_cropped <- crop(cyclones, ext(locations))
    cyclones_filtered <- cyclones_cropped
    cyclones_filtered[cyclones_filtered < 150] <- NA
    ### zonal statistics using "exactextractr"
    locations$val <- exact_extract(cyclones_filtered, locations, "mean", progress = TRUE)
    locations$val[is.nan(locations$val)] <- 0
    return(locations)
}

# Coalition for Disaster Resilient Infrastructure (CDRI)
# https://doi.org/10.59375/biennialreport.ed1
# https://giri.unepgrid.ch/map?list=explore&view=MX-UG0KA-OIQSJ-FIMNA
# unit: cyclone wind km/h (for a return period of 100 years)
# unit: % of cyclone affected area (wind > 150 km/h) on a 100 year return period
# km2 of cyclone affected area / km2 in the area
AREA_EXP_CYC <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    cyclones <- rast("data/Hazards/Cyclones/Wind_T100.tif")
    cyclones_cropped <- crop(cyclones, ext(locations))
    cyclones_filtered <- cyclones_cropped
    cyclones_filtered[cyclones_filtered < 150] <- NA
    locations <- raster_area_within_polygons(cyclones_filtered, locations)
    locations$cnt <- locations$area_raster_km2
    locations$val <- locations$area_raster_km2 / locations$area
    return(locations)
}

# Drought data source Aqueduct
# unit: score classification [Low (0.0-0.2), Low-medium (0.2-0.4), Medium (0.4-0.6), Medium-high (0.6-0.8), High (0.8-1.0)]
AREA_INT_DRO <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    # drr: Drought risk
    drought <- map_aqueduct(locations, "drr")
    locations$val <- drought$val
    return(locations)
}

# data source: UNEP
# https://wesr.unepgrid.ch/static.html?views=MX-JXZXA-MFZNN-LTXZ8&zoomToViews=true
# unit: % of flooded area on a 100 year return period
# km2 of flooded area / km2 in the area
AREA_EXP_FLO <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    floods <- rast("data/Hazards/Floods/fl_hazard_100_yrp.tif")
    floods_cropped <- crop(floods, ext(locations))
    locations <- raster_area_within_polygons(floods_cropped, locations)
    locations$cnt <- locations$area_raster_km2
    locations$val <- locations$area_raster_km2 / locations$area
    return(locations)
}

# data source: UNEP
# https://wesr.unepgrid.ch/static.html?views=MX-JXZXA-MFZNN-LTXZ8&zoomToViews=true
# unit: cm of flood on a 100 year return period
AREA_INT_FLO <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    floods <- rast("data/Hazards/Floods/fl_hazard_100_yrp.tif")
    floods_cropped <- crop(floods, ext(locations))
    ### zonal statistics using "exactextractr"
    locations$val <- exact_extract(floods_cropped, locations, "mean", progress = TRUE)
    locations$val[is.nan(locations$val)] <- 0
    return(locations)
}

# Global Soil Salinity Map
#  https://doi.org/10.1016/j.rse.2019.111260
#  https://data.isric.org/geonetwork/srv/eng/catalog.search#/metadata/c59d0162-a258-4210-af80-777d7929c512
#  https://code.earthengine.google.com/d43e5a92ae1deed32a0929f57b572756
# unit: soil salinity score 0 to 4 [0: non-saline, 1: slightly, 2: moderately, 3: highly, 4: extremely]
AREA_INT_SAL <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    salinity <- rast("data/Soil/Salinity/salmap2016.vrt")
    salinity_cropped <- crop(salinity, ext(locations))
    ### zonal statistics using "exactextractr"
    locations$val <- exact_extract(salinity_cropped, locations, "mean", progress = TRUE)
    locations$val[is.nan(locations$val)] <- 0
    return(locations)
}

# Global Soil Salinity Map
# https://doi.org/10.1016/j.rse.2019.111260
# https://data.isric.org/geonetwork/srv/eng/catalog.search#/metadata/c59d0162-a258-4210-af80-777d7929c512
# https://code.earthengine.google.com/d43e5a92ae1deed32a0929f57b572756
# soil salinity score 0 to 4 [0: non-saline, 1: slightly, 2: moderately, 3: highly, 4: extremely]
# unit: % of area affected by salinity slightly (1) to extremely (4)
AREA_EXP_SAL <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    salinity <- rast("data/Soil/Salinity/salmap2016.vrt")
    salinity_cropped <- crop(salinity, ext(locations))
    salinity_filtered <- salinity_cropped
    salinity_filtered[salinity_filtered < 1] <- NA
    locations <- raster_area_within_polygons(salinity_filtered, locations)
    locations$cnt <- locations$area_raster_km2
    locations$val <- locations$area_raster_km2 / locations$area
    return(locations)
}


area_exposure_indicators <- c(
    "AREA_EXP_COF", # Costal Floods, storm surges
    "AREA_INT_SURGE", # storm surges
    "AREA_EXP_CYC", # Cyclones
    "AREA_INT_CYC", # Cyclones
    "AREA_INT_DRO", # Droughts
    "AREA_EXP_FLO", # Floods
    "AREA_INT_FLO", # Floods
    "AREA_EXP_SAL", # Salinity
    "AREA_INT_SAL" # Salinity
)

area_exposure <- function(locations) {
    return(
        process_indicators(
            locations,
            indicators = area_exposure_indicators,
            # output="output/exposure"
        )
    )
}
