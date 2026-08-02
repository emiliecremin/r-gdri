# Area Exposure = affected_area / total_area
# Area Intensity = mean meters of flood

# data source: Climate Central https://coastal.climatecentral.org/
# https://doi.org/10.1016/j.rse.2017.12.026
# https://www.sciencedirect.com/science/article/abs/pii/S0034425717306016?via%3Dihub
# unit: km2 of storm surge prone agriculture
# based on digital elevation model (DEM) threshold 2m above sea level
# km2 of storm surge prone agriculture / km2 of agriculture in the area
AREA_AFF_COF <- function(locations, ...) {
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
AREA_AFF_CYC <- function(locations, ...) {
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
AREA_AFF_FLO <- function(locations, ...) {
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

# Soil quality (Global - ~1 km) - GAEZ v5 - UN FAO
# https://data.apps.fao.org/catalog//iso/476ffbd9-4af5-4429-bf99-2df6a34b5733
# https://console.cloud.google.com/storage/browser/fao-gismgr-gaez-v5-data/DATA/GAEZ-V5/MAPSET/SQX
# 0: Ocean
# soil salinity score 1 to 10 [1: extremely saline, 10: non-saline]
# 11: Steep terrain slopes
# 12: Permafrost, Glacier
# 13: Miscellaneous Unit, No information
# 14: Freshwater
# r_rev 1-10: 1 = non-saline, 10 = extremely saline
# unit: mean salinity score of the area
AREA_INT_SAL <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    salinity <- rast("data/Soil/Salinity/HWSD v2.01/DATA_GAEZ-V5_MAPSET_SQX_GAEZ-V5.SQX.SQ5.HIM.tif")
    salinity_cropped <- crop(salinity, ext(locations))
    salinity_filtered <- salinity_cropped
    salinity_filtered[salinity_filtered == 0] <- NA
    salinity_filtered[salinity_filtered > 10] <- NA
    r_rev <- 11 - salinity_filtered
    ### zonal statistics using "exactextractr"
    locations$val <- exact_extract(r_rev, locations, "mean", progress = TRUE)
    locations$val[is.nan(locations$val)] <- 0
    return(locations)
}

# Soil quality (Global - ~1 km) - GAEZ v5 - UN FAO
# https://data.apps.fao.org/catalog//iso/476ffbd9-4af5-4429-bf99-2df6a34b5733
# https://console.cloud.google.com/storage/browser/fao-gismgr-gaez-v5-data/DATA/GAEZ-V5/MAPSET/SQX
# 0: Ocean
# soil salinity score 1 to 10 [1: extremely saline, 10: non-saline]
# 11: Steep terrain slopes
# 12: Permafrost, Glacier
# 13: Miscellaneous Unit, No information
# 14: Freshwater
# r_rev 1-10: 1 = non-saline, 10 = extremely saline
# Threshold > 2 is affected by salinisation (moderate hazard or worse)
# unit: % of area affected by salinity
AREA_AFF_SAL <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    salinity <- rast("data/Soil/Salinity/HWSD v2.01/DATA_GAEZ-V5_MAPSET_SQX_GAEZ-V5.SQX.SQ5.HIM.tif")
    salinity_cropped <- crop(salinity, ext(locations))
    salinity_filtered <- salinity_cropped
    salinity_filtered[salinity_filtered == 0] <- NA
    salinity_filtered[salinity_filtered > 10] <- NA
    r_rev <- 11 - salinity_filtered
    SAL_AFF_THRESHOLD <- 2
    r_rev[r_rev < SAL_AFF_THRESHOLD] <- NA
    locations <- raster_area_within_polygons(r_rev, locations)
    locations$cnt <- locations$area_raster_km2
    locations$val <- locations$area_raster_km2 / locations$area
    return(locations)
}

area_exposure_indicators <- c(
    "AREA_AFF_COF", # Costal Floods, storm surges
    "AREA_INT_SURGE", # storm surges
    "AREA_AFF_CYC", # Cyclones
    "AREA_INT_CYC", # Cyclones
    "AREA_INT_DRO", # Droughts
    "AREA_AFF_FLO", # Floods
    "AREA_INT_FLO", # Floods
    "AREA_AFF_SAL", # Salinity
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
