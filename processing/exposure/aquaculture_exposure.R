# data source: Climate Central https://coastal.climatecentral.org/
# https://doi.org/10.1016/j.rse.2017.12.026
# https://www.sciencedirect.com/science/article/abs/pii/S0034425717306016?via%3Dihub
# unit: km2 of storm surge prone aquaculture
# based on digital elevation model (DEM) threshold 2m above sea level
# km2 of storm surge prone aquaculture / km2 of aquaculture in the area
AQ_AFF_COF <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    coastal_dem_filtered <- get_coastal_dem(locations)
    country_iso3 <- unique(locations$country_iso3)[1]
    aquaculture <- rast(glue::glue("objects/aquaculture_sentinel2/{country_iso3}_aquaculture.tif"))
    coastal_dem_masked <- mask_rasters(aquaculture, coastal_dem_filtered)
    locations <- raster_area_within_polygons(coastal_dem_masked, locations)
    locations$cnt <- locations$area_raster_km2
    locations$val <- locations$area_raster_km2 / locations$aqua_km2
    return(locations)
}

# Coalition for Disaster Resilient Infrastructure (CDRI)
# https://doi.org/10.59375/biennialreport.ed1
# https://giri.unepgrid.ch/map?list=explore&view=MX-UG0KA-OIQSJ-FIMNA
# unit: cyclone wind km/h (wind > 118 km/h for a return period of 100 years)
AQ_INT_CYC <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    cyclones <- rast("data/Hazards/Cyclones/Wind_T100.tif")
    aquaculture <- rast(glue::glue("objects/aquaculture_sentinel2/{country_iso3}_aquaculture.tif"))
    cyclones_cropped <- crop(cyclones, aquaculture)
    cyclones_filtered <- cyclones_cropped
    cyclones_filtered[cyclones_filtered < cyclone_wind_speed] <- NA
    ### zonal statistics using "exactextractr"
    locations$val <- exact_extract(cyclones_filtered, locations, "mean", progress = TRUE)
    locations$val[is.nan(locations$val)] <- 0
    return(locations)
}

# Coalition for Disaster Resilient Infrastructure (CDRI)
# https://doi.org/10.59375/biennialreport.ed1
# https://giri.unepgrid.ch/map?list=explore&view=MX-UG0KA-OIQSJ-FIMNA
# unit: cyclone wind km/h (for a return period of 100 years)
# unit: % of cyclone affected aquaculture (wind > 118 km/h) area on a 100 year return period
# km2 of cyclone affected aquaculture / km2 of aquaculture in the area
AQ_AFF_CYC <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    cyclones <- rast("data/Hazards/Cyclones/Wind_T100.tif")
    aquaculture <- rast(glue::glue("objects/aquaculture_sentinel2/{country_iso3}_aquaculture.tif"))
    cyclones_cropped <- crop(cyclones, aquaculture)
    cyclones_filtered <- cyclones_cropped
    cyclones_filtered[cyclones_filtered < cyclone_wind_speed] <- NA
    cyclones_masked <- mask_rasters(aquaculture, cyclones_filtered)
    locations <- raster_area_within_polygons(cyclones_masked, locations)
    locations$cnt <- locations$area_raster_km2
    locations$val <- locations$area_raster_km2 / locations$aqua_km2
    return(locations)
}

# data source: UNEP
# https://wesr.unepgrid.ch/static.html?views=MX-JXZXA-MFZNN-LTXZ8&zoomToViews=true
# unit: % of flooded aquaculture area on a 100 year return period
# km2 of flooded aquaculture / km2 of aquaculture in the area
AQ_AFF_FLO <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    floods <- "data/Hazards/Floods/fl_hazard_100_yrp.tif"
    aquaculture <- rast(glue::glue("objects/aquaculture_sentinel2/{country_iso3}_aquaculture.tif"))
    floods_masked <- mask_rasters(aquaculture, floods)
    locations <- raster_area_within_polygons(floods_masked, locations)
    locations$cnt <- locations$area_raster_km2
    locations$val <- locations$area_raster_km2 / locations$aqua_km2
    return(locations)
}

# data source: UNEP
# https://wesr.unepgrid.ch/static.html?views=MX-JXZXA-MFZNN-LTXZ8&zoomToViews=true
# unit: cm of flood on a 100 year return period
AQ_INT_FLO <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    floods <- rast("data/Hazards/Floods/fl_hazard_100_yrp.tif")
    aquaculture <- rast(glue::glue("objects/aquaculture_sentinel2/{country_iso3}_aquaculture.tif"))
    floods_cropped <- crop(floods, aquaculture)
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
AQ_INT_SAL <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    salinity <- rast("data/Soil/Salinity/salmap2016.vrt")
    aquaculture <- rast(glue::glue("objects/aquaculture_sentinel2/{country_iso3}_aquaculture.tif"))
    salinity_cropped <- crop(salinity, aquaculture)
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
# unit: % of aquaculture area affected by salinity slightly (1) to extremely (4)
AQ_AFF_SAL <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    salinity <- rast("data/Soil/Salinity/salmap2016.vrt")
    aquaculture <- rast(glue::glue("objects/aquaculture_sentinel2/{country_iso3}_aquaculture.tif"))
    salinity_cropped <- crop(salinity, aquaculture)
    salinity_filtered <- salinity_cropped
    salinity_filtered[salinity_filtered < 1] <- NA
    salinity_masked <- mask_rasters(aquaculture, salinity_filtered)
    locations <- raster_area_within_polygons(salinity_masked, locations)
    locations$cnt <- locations$area_raster_km2
    locations$val <- locations$area_raster_km2 / locations$aqua_km2
    return(locations)
}

aquaculture_exposure_indicators <- c(
    "AQ_AFF_COF", # Costal Floods, storm surges
    "AQ_AFF_CYC", # Cyclones
    "AQ_INT_CYC", # Cyclones
    "AQ_AFF_FLO", # Floods
    "AQ_INT_FLO", # Floods
    "AQ_AFF_SAL", # Salinity
    "AQ_INT_SAL" # Salinity
)

aquaculture_exposure <- function(locations) {
    return(
        process_indicators(
            locations,
            indicators = aquaculture_exposure_indicators,
            # output="output/exposure"
        )
    )
}
