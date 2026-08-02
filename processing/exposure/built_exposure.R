# Built-up Exposure = built_up_affected_area / built_up_total_area
# Built-up Intensity = mean meters of flood on built-up area

# data source: Climate Central https://coastal.climatecentral.org/
# https://doi.org/10.1016/j.rse.2017.12.026
# https://www.sciencedirect.com/science/article/abs/pii/S0034425717306016?via%3Dihub
# unit: km2 of storm surge prone built-up
# based on digital elevation model (DEM) threshold 2m above sea level
# km2 of storm surge prone built-up / km2 of built-up in the area
B_AFF_COF <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    coastal_dem_filtered <- get_coastal_dem(locations)
    country_iso3 <- unique(locations$country_iso3)[1]
    built <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_built.tif"))
    coastal_dem_masked <- mask_rasters(built, coastal_dem_filtered)
    locations <- raster_area_within_polygons(coastal_dem_masked, locations)
    locations$cnt <- locations$area_raster_km2
    locations$val <- locations$area_raster_km2 / locations$built_km2
    return(locations)
}

# Coalition for Disaster Resilient Infrastructure (CDRI)
# https://doi.org/10.59375/biennialreport.ed1
# https://giri.unepgrid.ch/map?list=explore&view=MX-UG0KA-OIQSJ-FIMNA
# unit: cyclone wind km/h (wind > 150 km/h for a return period of 100 years)
B_INT_CYC <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    cyclones <- rast("data/Hazards/Cyclones/Wind_T100.tif")
    built <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_built.tif"))
    cyclones_cropped <- crop(cyclones, built)
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
# unit: % of cyclone affected built area (wind > 150 km/h) on a 100 year return period
# km2 of cyclone affected built / km2 of built in the area
B_AFF_CYC <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    cyclones <- rast("data/Hazards/Cyclones/Wind_T100.tif")
    built <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_built.tif"))
    cyclones_cropped <- crop(cyclones, built)
    cyclones_filtered <- cyclones_cropped
    cyclones_filtered[cyclones_filtered < 150] <- NA
    cyclones_masked <- mask_rasters(built, cyclones_filtered)
    locations <- raster_area_within_polygons(cyclones_masked, locations)
    locations$cnt <- locations$area_raster_km2
    locations$val <- locations$area_raster_km2 / locations$built_km2
    return(locations)
}

# data source: UNEP
# https://wesr.unepgrid.ch/static.html?views=MX-JXZXA-MFZNN-LTXZ8&zoomToViews=true
# unit: % of flooded built area on a 100 year return period
# km2 of flooded built / km2 of built in the area
B_AFF_FLO <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    floods <- "data/Hazards/Floods/fl_hazard_100_yrp.tif"
    built <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_built.tif"))
    floods_masked <- mask_rasters(built, floods)
    locations <- raster_area_within_polygons(floods_masked, locations)
    locations$cnt <- locations$area_raster_km2
    locations$val <- locations$area_raster_km2 / locations$built_km2
    return(locations)
}

# data source: UNEP
# https://wesr.unepgrid.ch/static.html?views=MX-JXZXA-MFZNN-LTXZ8&zoomToViews=true
# unit: cm of flood on a 100 year return period
B_INT_FLO <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    floods <- rast("data/Hazards/Floods/fl_hazard_100_yrp.tif")
    built <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_built.tif"))
    floods_cropped <- crop(floods, built)
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
B_INT_SAL <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    salinity <- rast("data/Soil/Salinity/HWSD v2.01/DATA_GAEZ-V5_MAPSET_SQX_GAEZ-V5.SQX.SQ5.HIM.tif")
    built <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_built.tif"))
    salinity_cropped <- crop(salinity, built)
    salinity_filtered <- salinity_cropped
    salinity_filtered[salinity_filtered == 0] <- NA
    salinity_filtered[salinity_filtered > 10] <- NA
    r_rev <- 11 - salinity_filtered
    ## restrict to agricultural land so mean is over ag pixels only
    r_rev_built <- mask_rasters(r_rev, built)
    ### zonal statistics using "exactextractr"
    locations$val <- exact_extract(r_rev_built, locations, "mean", progress = TRUE)
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
# unit: % of built area affected by salinity
B_AFF_SAL <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    salinity <- rast("data/Soil/Salinity/HWSD v2.01/DATA_GAEZ-V5_MAPSET_SQX_GAEZ-V5.SQX.SQ5.HIM.tif")
    built <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_built.tif"))
    salinity_cropped <- crop(salinity, built)
    salinity_filtered <- salinity_cropped
    salinity_filtered[salinity_filtered == 0] <- NA
    salinity_filtered[salinity_filtered > 10] <- NA
    r_rev <- 11 - salinity_filtered
    SAL_AFF_THRESHOLD <- 2
    r_rev[r_rev < SAL_AFF_THRESHOLD] <- NA
    salinity_masked <- mask_rasters(built, r_rev)
    locations <- raster_area_within_polygons(salinity_masked, locations)
    locations$cnt <- locations$area_raster_km2
    locations$val <- locations$area_raster_km2 / locations$built_km2
    return(locations)
}

built_exposure_indicators <- c(
    "B_AFF_COF", # Costal Floods, storm surges
    "B_AFF_CYC", # Cyclones
    "B_INT_CYC", # Cyclones
    "B_AFF_FLO", # Floods
    "B_INT_FLO", # Floods
    "B_AFF_SAL", # Salinity
    "B_INT_SAL" # Salinity
)

built_exposure <- function(locations) {
    return(
        process_indicators(
            locations,
            indicators = built_exposure_indicators,
            # output="output/exposure"
        )
    )
}
