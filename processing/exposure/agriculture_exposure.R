# data source: Climate Central https://coastal.climatecentral.org/
# https://doi.org/10.1016/j.rse.2017.12.026
# https://www.sciencedirect.com/science/article/abs/pii/S0034425717306016?via%3Dihub
# unit: km2 of storm surge prone agriculture
# based on digital elevation model (DEM) threshold 2m above sea level
# km2 of storm surge prone agriculture / km2 of agriculture in the area
A_EXP_COF <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    coastal_dem_filtered <- get_coastal_dem(locations)
    country_iso3 <- unique(locations$country_iso3)[1]
    agriculture <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_agriculture.tif"))
    coastal_dem_masked <- mask_rasters(agriculture, coastal_dem_filtered)
    locations <- raster_area_within_polygons(coastal_dem_masked, locations)
    locations$cnt <- locations$area_raster_km2
    locations$val <- locations$area_raster_km2 / locations$agri_km2
    return(locations)
}

# Coalition for Disaster Resilient Infrastructure (CDRI)
# https://doi.org/10.59375/biennialreport.ed1
# https://giri.unepgrid.ch/map?list=explore&view=MX-UG0KA-OIQSJ-FIMNA
# unit: cyclone wind km/h (wind > 150 km/h for a return period of 100 years)
A_INT_CYC <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    cyclones <- rast("data/Hazards/Cyclones/Wind_T100.tif")
    agriculture <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_agriculture.tif"))
    cyclones_cropped <- crop(cyclones, agriculture)
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
# unit: % of cyclone affected agriculture (wind > 150 km/h) area on a 100 year return period
# km2 of cyclone affected agriculture / km2 of agriculture in the area
A_EXP_CYC <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    cyclones <- rast("data/Hazards/Cyclones/Wind_T100.tif")
    agriculture <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_agriculture.tif"))
    cyclones_cropped <- crop(cyclones, agriculture)
    cyclones_filtered <- cyclones_cropped
    cyclones_filtered[cyclones_filtered < 150] <- NA
    cyclones_masked <- mask_rasters(agriculture, cyclones_filtered)
    locations <- raster_area_within_polygons(cyclones_masked, locations)
    locations$cnt <- locations$area_raster_km2
    locations$val <- locations$area_raster_km2 / locations$agri_km2
    return(locations)
}

# data source: UNEP
# https://wesr.unepgrid.ch/static.html?views=MX-JXZXA-MFZNN-LTXZ8&zoomToViews=true
# unit: % of flooded agriculture area on a 100 year return period
# km2 of flooded agriculture / km2 of agriculture in the area
A_EXP_FLO <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    floods <- rast("data/Hazards/Floods/fl_hazard_100_yrp.tif")
    agriculture <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_agriculture.tif"))
    floods_masked <- mask_rasters(agriculture, floods)
    locations <- raster_area_within_polygons(floods_masked, locations)
    locations$cnt <- locations$area_raster_km2
    locations$val <- locations$area_raster_km2 / locations$agri_km2
    return(locations)
}

# data source: UNEP
# https://wesr.unepgrid.ch/static.html?views=MX-JXZXA-MFZNN-LTXZ8&zoomToViews=true
# unit: cm of flood on a 100 year return period
A_INT_FLO <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    floods <- rast("data/Hazards/Floods/fl_hazard_100_yrp.tif")
    agriculture <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_agriculture.tif"))
    floods_cropped <- crop(floods, agriculture)
    ### zonal statistics using "exactextractr"
    locations$val <- exact_extract(floods_cropped, locations, "mean", progress = TRUE)
    locations$val[is.nan(locations$val)] <- 0
    return(locations)
}

# Soil quality (Global - ~1 km) - GAEZ v5 - UN FAO
# https://data.apps.fao.org/catalog//iso/476ffbd9-4af5-4429-bf99-2df6a34b5733
# https://console.cloud.google.com/storage/browser/fao-gismgr-gaez-v5-data/DATA/GAEZ-V5/MAPSET/SQX
# soil salinity score 1 to 10 [1: extremely high, 10: extremely low] - 0 is Ocean
# 0: Ocean
# soil salinity score 1 to 10 [1: extremely saline, 10: non-saline]
# 11: Steep terrain slopes
# 12: Permafrost, Glacier
# 13: Miscellaneous Unit, No information
# 14: Freshwater
# r_rev 1-10: 1 = non-saline, 10 = extremely saline
A_INT_SAL <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    salinity <- rast("data/Soil/Salinity/HWSD v2.01/DATA_GAEZ-V5_MAPSET_SQX_GAEZ-V5.SQX.SQ5.HIM.tif")
    agriculture <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_agriculture.tif"))
    salinity_cropped <- crop(salinity, agriculture)
    salinity_filtered <- salinity_cropped
    salinity_filtered[salinity_filtered == 0] <- NA
    salinity_filtered[salinity_filtered > 10] <- NA
    r_rev <- 11 - salinity_filtered
    ## restrict to agricultural land so mean is over ag pixels only
    r_rev_agri <- mask_rasters(r_rev, agriculture)
    ### zonal statistics using "exactextractr"
    locations$val <- exact_extract(r_rev_agri, locations, "mean", progress = TRUE)
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
# unit: % of agriculture area affected by salinity
A_EXP_SAL <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    salinity <- rast("data/Soil/Salinity/HWSD v2.01/DATA_GAEZ-V5_MAPSET_SQX_GAEZ-V5.SQX.SQ5.HIM.tif")
    agriculture <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_agriculture.tif"))
    salinity_cropped <- crop(salinity, agriculture)
    salinity_filtered <- salinity_cropped
    salinity_filtered[salinity_filtered == 0] <- NA
    salinity_filtered[salinity_filtered > 10] <- NA
    r_rev <- 11 - salinity_filtered
    SAL_EXP_THRESHOLD <- 2
    r_rev[r_rev < SAL_EXP_THRESHOLD] <- NA
    salinity_masked <- mask_rasters(agriculture, r_rev)
    locations <- raster_area_within_polygons(salinity_masked, locations)
    locations$cnt <- locations$area_raster_km2
    locations$val <- locations$area_raster_km2 / locations$agri_km2
    return(locations)
}

agriculture_exposure_indicators <- c(
    "A_EXP_COF", # Costal Floods, storm surges
    "A_EXP_CYC", # Cyclones
    "A_INT_CYC", # Cyclones
    "A_EXP_FLO", # Floods
    "A_INT_FLO", # Floods
    "A_EXP_SAL", # Salinity
    "A_INT_SAL" # Salinity
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
