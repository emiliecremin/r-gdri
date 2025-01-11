# data source: World Bank
# doi:10.1038/ncomms11969
# https://www.nature.com/articles/ncomms11969
# https://energydata.info/dataset/global-coastal-flood-hazard/resource/46904e08-7daa-4c58-8c62-f0c27407ba5c
# unit: extreme sea levels in meters caused by storm surges and high tides
E_INT_COF <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    storm_surge <- rast("data/Hazards/StormSurge/ss_muis_rp0100m.tif")
    ecosystems <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_ecosystems.tif"))
    storm_surge_cropped <- crop(storm_surge, ecosystems)
    ### zonal statistics using "exactextractr"
    locations$val <- exact_extract(storm_surge_cropped, locations, "mean", progress = TRUE)
    locations$val[is.nan(locations$val)] <- 0
    return(locations)
}

# data source: World Bank
# doi:10.1038/ncomms11969
# https://www.nature.com/articles/ncomms11969
# https://energydata.info/dataset/global-coastal-flood-hazard/resource/46904e08-7daa-4c58-8c62-f0c27407ba5c
# unit: % of storm surge affected ecosystems area on a 100 year return period
# km2 of storm surge affected ecosystems / km2 of ecosystems in the area
E_EXP_COF <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    storm_surge <- "data/Hazards/StormSurge/ss_muis_rp0100m.tif"
    ecosystems <- glue::glue("objects/ESA_Landcover/{country_iso3}_ecosystems.tif")
    storm_surge_masked <- mask_rasters(ecosystems, storm_surge)
    locations <- raster_area_within_polygons(storm_surge_masked, locations)
    locations$cnt <- locations$area_raster_km2
    locations$val <- locations$area_raster_km2 / locations$ecosys_km2
    return(locations)
}

# Coalition for Disaster Resilient Infrastructure (CDRI)
# https://doi.org/10.59375/biennialreport.ed1
# https://giri.unepgrid.ch/map?list=explore&view=MX-UG0KA-OIQSJ-FIMNA
# unit: cyclone wind km/h (wind > 150 km/h for a return period of 100 years)
E_INT_CYC <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    cyclones <- rast("data/Hazards/Cyclones/Wind_T100.tif")
    ecosystems <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_ecosystems.tif"))
    cyclones_cropped <- crop(cyclones, ecosystems)
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
# unit: % of cyclone affected ecosystems (wind > 150 km/h) on a 100 year return period
# km2 of cyclone affected ecosystems / km2 of ecosystems in the area
E_EXP_CYC <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    cyclones <- "data/Hazards/Cyclones/Wind_T100.tif"
    ecosystems <- glue::glue("objects/ESA_Landcover/{country_iso3}_ecosystems.tif")
    cyclones_cropped <- crop(cyclones, ecosystems)
    cyclones_filtered <- cyclones_cropped
    cyclones_filtered[cyclones_filtered < 150] <- NA
    cyclones_masked <- mask_rasters(ecosystems, cyclones_filtered)
    locations <- raster_area_within_polygons(cyclones_masked, locations)
    locations$cnt <- locations$area_raster_km2
    locations$val <- locations$area_raster_km2 / locations$ecosys_km2
    return(locations)
}

# data source: UNEP
# https://wesr.unepgrid.ch/static.html?views=MX-JXZXA-MFZNN-LTXZ8&zoomToViews=true
# unit: % of flooded ecosystems area on a 100 year return period
# km2 of flooded ecosystems / km2 of ecosystems in the area
E_EXP_FLO <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    floods <- "data/Hazards/Floods/fl_hazard_100_yrp.tif"
    ecosystems <- glue::glue("objects/ESA_Landcover/{country_iso3}_ecosystems.tif")
    floods_masked <- mask_rasters(ecosystems, floods)
    locations <- raster_area_within_polygons(floods_masked, locations)
    locations$cnt <- locations$area_raster_km2
    locations$val <- locations$area_raster_km2 / locations$ecosys_km2
    return(locations)
}

# data source: UNEP
# https://wesr.unepgrid.ch/static.html?views=MX-JXZXA-MFZNN-LTXZ8&zoomToViews=true
# unit: cm of flood on a 100 year return period
E_INT_FLO <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    floods <- rast("data/Hazards/Floods/fl_hazard_100_yrp.tif")
    ecosystems <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_ecosystems.tif"))
    floods_cropped <- crop(floods, ecosystems)
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
E_INT_SAL <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    salinity <- rast("data/Soil/Salinity/salmap2016.vrt")
    ecosystems <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_ecosystems.tif"))
    salinity_cropped <- crop(salinity, ecosystems)
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
# unit: % of ecosystems area affected by salinity slightly (1) to extremely (4)
E_EXP_SAL <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    salinity <- "data/Soil/Salinity/salmap2016.vrt"
    ecosystems <- glue::glue("objects/ESA_Landcover/{country_iso3}_ecosystems.tif")
    salinity_cropped <- crop(salinity, ecosystems)
    salinity_filtered <- salinity_cropped
    salinity_filtered[salinity_filtered < 1] <- NA
    salinity_masked <- mask_rasters(ecosystems, salinity_filtered)
    locations <- raster_area_within_polygons(salinity_masked, locations)
    locations$cnt <- locations$area_raster_km2
    locations$val <- locations$area_raster_km2 / locations$ecosys_km2
    return(locations)
}

ecosystems_exposure_indicators <- c(
    "E_EXP_COF", # Costal Floods, storm surges
    "E_INT_COF", # Costal Floods, storm surges
    "E_EXP_CYC", # Cyclones
    "E_INT_CYC", # Cyclones
    "E_EXP_FLO", # Floods
    "E_INT_FLO", # Floods
    "E_EXP_SAL", # Salinity
    "E_INT_SAL" # Salinity
)

ecosystems_exposure <- function(locations) {
    return(
        process_indicators(
            locations,
            indicators = ecosystems_exposure_indicators,
            # output="output/exposure"
        )
    )
}
