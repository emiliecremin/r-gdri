# data source: Climate Central https://coastal.climatecentral.org/
# https://doi.org/10.1016/j.rse.2017.12.026
# https://www.sciencedirect.com/science/article/abs/pii/S0034425717306016?via%3Dihub
# unit: km2 of storm surge prone ecosystems
# based on digital elevation model (DEM) threshold 2m above sea level
# km2 of storm surge prone ecosystems / km2 of ecosystems in the area
E_AFF_COF <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    coastal_dem_filtered <- get_coastal_dem(locations)
    country_iso3 <- unique(locations$country_iso3)[1]
    ecosystems <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_ecosystems.tif"))
    coastal_dem_masked <- mask_rasters(ecosystems, coastal_dem_filtered)
    locations <- raster_area_within_polygons(coastal_dem_masked, locations)
    locations$cnt <- locations$area_raster_km2
    locations$val <- locations$area_raster_km2 / locations$ecosys_km2
    return(locations)
}

# Coalition for Disaster Resilient Infrastructure (CDRI)
# https://doi.org/10.59375/biennialreport.ed1
# Background paper: Multi-hazard Disaster Risk Model of Infrastructure and Buildings at the Global Level (2023). Cardona, O.D., Bernal, G.A., Villegas, C.P., Molina, J.F., Herrera, S.A., Marulanda, M.C., Rincón, D.F., Grajales, S., Marulanda, P.M., Gonzalez, D., Maskrey, A. (2023). 
# https://giri.unepgrid.ch/sites/default/files/2023-11/2.4-INGENIAR-CDRI-Background-Report-Risk-model.pdf
# https://giri.unepgrid.ch/map?list=explore&view=MX-UG0KA-OIQSJ-FIMNA
# unit: cyclone wind km/h (wind > 118 km/h for a return period of 100 years)
E_INT_CYC <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    cyclones <- rast("data/Hazards/Cyclones/Wind_T100.tif")
    ecosystems <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_ecosystems.tif"))
    cyclones_cropped <- crop(cyclones, ecosystems)
    cyclones_filtered <- cyclones_cropped
    cyclones_filtered[cyclones_filtered < cyclone_wind_speed] <- NA
    ### zonal statistics using "exactextractr"
    locations$val <- exact_extract(cyclones_filtered, locations, "mean", progress = TRUE)
    locations$val[is.nan(locations$val)] <- 0
    return(locations)
}

# Coalition for Disaster Resilient Infrastructure (CDRI)
# https://doi.org/10.59375/biennialreport.ed1
# Background paper: Multi-hazard Disaster Risk Model of Infrastructure and Buildings at the Global Level (2023). Cardona, O.D., Bernal, G.A., Villegas, C.P., Molina, J.F., Herrera, S.A., Marulanda, M.C., Rincón, D.F., Grajales, S., Marulanda, P.M., Gonzalez, D., Maskrey, A. (2023). 
# https://giri.unepgrid.ch/sites/default/files/2023-11/2.4-INGENIAR-CDRI-Background-Report-Risk-model.pdf
# https://giri.unepgrid.ch/map?list=explore&view=MX-UG0KA-OIQSJ-FIMNA
# unit: cyclone wind km/h (for a return period of 100 years)
# unit: % of cyclone affected ecosystems (wind > 118 km/h) on a 100 year return period
# km2 of cyclone affected ecosystems / km2 of ecosystems in the area
E_AFF_CYC <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    cyclones <- rast("data/Hazards/Cyclones/Wind_T100.tif")
    ecosystems <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_ecosystems.tif"))
    cyclones_cropped <- crop(cyclones, ecosystems)
    cyclones_filtered <- cyclones_cropped
    cyclones_filtered[cyclones_filtered < cyclone_wind_speed] <- NA
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
E_AFF_FLO <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    floods <- "data/Hazards/Floods/fl_hazard_100_yrp.tif"
    ecosystems <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_ecosystems.tif"))
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
E_INT_SAL <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    salinity <- rast("data/Soil/Salinity/HWSD v2.01/DATA_GAEZ-V5_MAPSET_SQX_GAEZ-V5.SQX.SQ5.HIM.tif")
    ecosystems <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_ecosystems.tif"))
    salinity_cropped <- crop(salinity, ecosystems)
    salinity_filtered <- salinity_cropped
    salinity_filtered[salinity_filtered == 0] <- NA
    salinity_filtered[salinity_filtered > 10] <- NA
    r_rev <- 11 - salinity_filtered
    ## restrict to ecosystems land so mean is over ecosystems pixels only
    r_rev_ecosys <- mask_rasters(r_rev, ecosystems)
    ### zonal statistics using "exactextractr"
    locations$val <- exact_extract(r_rev_ecosys, locations, "mean", progress = TRUE)
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
# unit: % of ecosystems area affected by salinity
E_AFF_SAL <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- unique(locations$country_iso3)[1]
    salinity <- rast("data/Soil/Salinity/HWSD v2.01/DATA_GAEZ-V5_MAPSET_SQX_GAEZ-V5.SQX.SQ5.HIM.tif")
    ecosystems <- rast(glue::glue("objects/ESA_Landcover/{country_iso3}_ecosystems.tif"))
    salinity_cropped <- crop(salinity, ecosystems)
    salinity_filtered <- salinity_cropped
    salinity_filtered[salinity_filtered == 0] <- NA
    salinity_filtered[salinity_filtered > 10] <- NA
    r_rev <- 11 - salinity_filtered
    SAL_AFF_THRESHOLD <- 2
    r_rev[r_rev < SAL_AFF_THRESHOLD] <- NA
    salinity_masked <- mask_rasters(ecosystems, r_rev)
    locations <- raster_area_within_polygons(salinity_masked, locations)
    locations$cnt <- locations$area_raster_km2
    locations$val <- locations$area_raster_km2 / locations$ecosys_km2
    return(locations)
}

ecosystems_exposure_indicators <- c(
    "E_AFF_COF", # Costal Floods, storm surges
    "E_AFF_CYC", # Cyclones
    "E_INT_CYC", # Cyclones
    "E_AFF_FLO", # Floods
    "E_INT_FLO", # Floods
    "E_AFF_SAL", # Salinity
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
