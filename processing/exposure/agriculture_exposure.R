# data source: World Bank
# doi:10.1038/ncomms11969
# https://www.nature.com/articles/ncomms11969
# https://energydata.info/dataset/global-coastal-flood-hazard/resource/46904e08-7daa-4c58-8c62-f0c27407ba5c
# unit: extreme sea levels in meters caused by storm surges and high tides
A_INT_COF <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    storm_surge <- rast("data/Hazards/StormSurge/ss_muis_rp0100m.tif")
    agriculture <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_agriculture.tif"))
    storm_surge_cropped <- crop(storm_surge, agriculture)
    ### zonal statistics using "exactextractr"
    locations$val <- exact_extract(storm_surge_cropped, locations, "mean", progress = TRUE)
    locations$val[is.nan(locations$val)] <- 0
    return(locations)
}

# data source: World Bank
# doi:10.1038/ncomms11969
# https://www.nature.com/articles/ncomms11969
# https://energydata.info/dataset/global-coastal-flood-hazard/resource/46904e08-7daa-4c58-8c62-f0c27407ba5c
# unit: % of storm surge affected agriculture area on a 100 year return period
# km2 of storm surge affected agriculture / km2 of agriculture in the area
A_EXP_COF <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    storm_surge <- "data/Hazards/StormSurge/ss_muis_rp0100m.tif"
    agriculture <- glue::glue("objects/ESA_Landcover/{country_iso3}_agriculture.tif")
    storm_surge_masked <- mask_rasters(agriculture, storm_surge)
    locations <- raster_area_within_polygons(storm_surge_masked, locations)
    locations$cnt <- locations$area_raster_km2
    locations$val <- locations$area_raster_km2 / locations$agri_km2
    return(locations)
}

# Coalition for Disaster Resilient Infrastructure (CDRI)
# https://doi.org/10.59375/biennialreport.ed1
# https://giri.unepgrid.ch/map?list=explore&view=MX-UG0KA-OIQSJ-FIMNA
# unit: cyclone wind km/h (for a return period of 100 years)
A_INT_CYC <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    cyclones <- rast("data/Hazards/Cyclones/Wind_T100.tif")
    agriculture <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_agriculture.tif"))
    cyclones_cropped <- crop(cyclones, agriculture)
    ### zonal statistics using "exactextractr"
    locations$val <- exact_extract(cyclones_cropped, locations, "mean", progress = TRUE)
    locations$val[is.nan(locations$val)] <- 0
    return(locations)
}

# Coalition for Disaster Resilient Infrastructure (CDRI)
# https://doi.org/10.59375/biennialreport.ed1
# https://giri.unepgrid.ch/map?list=explore&view=MX-UG0KA-OIQSJ-FIMNA
# unit: cyclone wind km/h (for a return period of 100 years)
# unit: % of cyclone affected agriculture area on a 100 year return period
# km2 of cyclone affected agriculture / km2 of agriculture in the area
A_EXP_CYC <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    cyclones <- "data/Hazards/Cyclones/Wind_T100.tif"
    agriculture <- glue::glue("objects/ESA_Landcover/{country_iso3}_agriculture.tif")
    cyclones_masked <- mask_rasters(agriculture, cyclones)
    locations <- raster_area_within_polygons(cyclones_masked, locations)
    locations$cnt <- locations$area_raster_km2
    locations$val <- locations$area_raster_km2 / locations$agri_km2
    return(locations)
}

# Drought data source Aqueduct
# unit: score classification [Low (0.0-0.2), Low-medium (0.2-0.4), Medium (0.4-0.6), Medium-high (0.6-0.8), High (0.8-1.0)]
A_INT_DRO <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    # drr: Drought risk
    drought <- map_aqueduct(locations, "drr")
    locations$val <- drought$val
    return(locations)
}

# data source: UNEP
# https://wesr.unepgrid.ch/static.html?views=MX-JXZXA-MFZNN-LTXZ8&zoomToViews=true
# unit: % of flooded agriculture area on a 100 year return period
# km2 of flooded agriculture / km2 of agriculture in the area
A_EXP_FLO <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    floods <- "data/Hazards/Floods/fl_hazard_100_yrp.tif"
    agriculture <- glue::glue("objects/ESA_Landcover/{country_iso3}_agriculture.tif")
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

# Global Soil Salinity Map
#  https://doi.org/10.1016/j.rse.2019.111260
#  https://data.isric.org/geonetwork/srv/eng/catalog.search#/metadata/c59d0162-a258-4210-af80-777d7929c512
#  https://code.earthengine.google.com/d43e5a92ae1deed32a0929f57b572756
# unit: soil salinity score 0 to 4 [0: non-saline, 1: slightly, 2: moderately, 3: highly, 4: extremely]
A_INT_SAL <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    salinity <- rast("data/Soil/Salinity/salmap2016.vrt")
    agriculture <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_agriculture.tif"))
    salinity_cropped <- crop(salinity, agriculture)
    ### zonal statistics using "exactextractr"
    locations$val <- exact_extract(salinity_cropped, locations, "mean", progress = TRUE)
    locations$val[is.nan(locations$val)] <- 0
    return(locations)
}

# Global Soil Salinity Map
#  https://doi.org/10.1016/j.rse.2019.111260
#  https://data.isric.org/geonetwork/srv/eng/catalog.search#/metadata/c59d0162-a258-4210-af80-777d7929c512
#  https://code.earthengine.google.com/d43e5a92ae1deed32a0929f57b572756
# unit: soil salinity score 0 to 4 [0: non-saline, 1: slightly, 2: moderately, 3: highly, 4: extremely]
A_EXP_SAL <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    salinity <- "data/Soil/Salinity/salmap2016.vrt"
    agriculture <- glue::glue("objects/ESA_Landcover/{country_iso3}_agriculture.tif")
    salinity_masked <- mask_rasters(agriculture, salinity)
    locations <- raster_area_within_polygons(salinity_masked, locations)
    locations$cnt <- locations$area_raster_km2
    locations$val <- locations$area_raster_km2 / locations$agri_km2
    return(locations)
}

agriculture_exposure_indicators <- c(
    "A_EXP_COF", # Costal Floods, storm surges
    "A_INT_COF", # Costal Floods, storm surges
    "A_EXP_CYC", # Cyclones
    "A_INT_CYC", # Cyclones
    "A_INT_DRO", # Droughts
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
