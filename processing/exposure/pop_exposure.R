# Population Exposure = affected pop / world pop

# Bondarenko M., Kerr D., Sorichetta A., and Tatem, A.J. 2020.
# Census/projection-disaggregated gridded population datasets, adjusted to match the corresponding UNPD 2020 estimates,
# for 183 countries in 2020 using Built-Settlement Growth Model (BSGM) outputs. WorldPop, University of Southampton, UK. doi:10.5258/SOTON/WP00685
# DOI: 10.5258/SOTON/WP00685
# units are number of people per pixel with country totals adjusted to match the corresponding official United Nations population estimates
get_world_pop <- function(locations) {
    country_iso3 <- tolower(unique(locations$country_iso3)[1])
    world_pop <- rast(glue::glue("data/Population/WorldPop/{country_iso3}_ppp_2020_UNadj_constrained.tif"))
    locations$world_pop <- exact_extract(world_pop, locations, "sum", progress = TRUE)
    return(locations)
}

# data source: Climate Central https://coastal.climatecentral.org/
# https://doi.org/10.1016/j.rse.2017.12.026
# https://www.sciencedirect.com/science/article/abs/pii/S0034425717306016?via%3Dihub
# unit: population living in storm surge prone areas
# based on digital elevation model (DEM) threshold 2m above sea level
POP_EXP_COF <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- tolower(unique(locations$country_iso3)[1])
    locations <- get_world_pop(locations)
    world_pop <- rast(glue::glue("data/Population/WorldPop/{country_iso3}_ppp_2020_UNadj_constrained.tif"))
    coastal_dem_filtered <- get_coastal_dem(locations)
    coastal_dem_masked <- mask_rasters(world_pop, coastal_dem_filtered)
    locations$cnt <- exact_extract(coastal_dem_masked, locations, "sum", progress = TRUE)
    locations$val <- locations$cnt / locations$world_pop
    return(locations)
}

# Coalition for Disaster Resilient Infrastructure (CDRI)
# https://doi.org/10.59375/biennialreport.ed1
# https://giri.unepgrid.ch/map?list=explore&view=MX-UG0KA-OIQSJ-FIMNA
# unit: % of population cyclone affected (wind > 118 km/h) on a 100 year return period
POP_EXP_CYC <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- tolower(unique(locations$country_iso3)[1])
    locations <- get_world_pop(locations)
    world_pop <- rast(glue::glue("data/Population/WorldPop/{country_iso3}_ppp_2020_UNadj_constrained.tif"))
    cyclones <- rast("data/Hazards/Cyclones/Wind_T100.tif")
    cyclones_cropped <- crop(cyclones, locations)
    cyclones_filtered <- cyclones_cropped
    cyclones_filtered[cyclones_filtered < cyclone_wind_speed] <- NA
    cyclones_masked <- mask_rasters(world_pop, cyclones_filtered)
    locations$cnt <- exact_extract(cyclones_masked, locations, "sum", progress = TRUE)
    locations$val <- locations$cnt / locations$world_pop
    return(locations)
}

# data source: UNEP
# https://wesr.unepgrid.ch/static.html?views=MX-JXZXA-MFZNN-LTXZ8&zoomToViews=true
# unit: % of population flood affected on a 100 year return period
POP_EXP_FLO <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- tolower(unique(locations$country_iso3)[1])
    locations <- get_world_pop(locations)
    world_pop <- rast(glue::glue("data/Population/WorldPop/{country_iso3}_ppp_2020_UNadj_constrained.tif"))
    floods <- rast("data/Hazards/Floods/fl_hazard_100_yrp.tif")
    floods_masked <- mask_rasters(world_pop, floods)
    locations$cnt <- exact_extract(floods_masked, locations, "sum", progress = TRUE)
    locations$val <- locations$cnt / locations$world_pop
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
# unit: % of population affected by salinity
POP_EXP_SAL <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- tolower(unique(locations$country_iso3)[1])
    locations <- get_world_pop(locations)
    world_pop <- rast(glue::glue("data/Population/WorldPop/{country_iso3}_ppp_2020_UNadj_constrained.tif"))
    salinity <- rast("data/Soil/Salinity/HWSD v2.01/DATA_GAEZ-V5_MAPSET_SQX_GAEZ-V5.SQX.SQ5.HIM.tif")
    salinity_cropped <- crop(salinity, world_pop)
    salinity_filtered <- salinity_cropped
    salinity_filtered[salinity_filtered == 0] <- NA
    salinity_filtered[salinity_filtered > 10] <- NA
    r_rev <- 11 - salinity_filtered
    SAL_EXP_THRESHOLD <- 2
    r_rev[r_rev < SAL_EXP_THRESHOLD] <- NA
    salinity_masked <- mask_rasters(world_pop, r_rev)
    locations$cnt <- exact_extract(salinity_masked, locations, "sum", progress = TRUE)
    locations$val <- locations$cnt / locations$world_pop
    return(locations)
}

keep_cols <- c(
    "geo_id",
    "country_iso3",
    "CNTRY_NAME",
    "adm1_name",
    "adm2_name",
    "adm3_name",
    "adm4_name",
    "adm_level",
    "Name",
    "pop",
    "world_pop",
    "area",
    "agri_km2",
    "aqua_km2",
    "ecosys_km2",
    "built_km2"
)

population_exposure_indicators <- c(
    "POP_EXP_COF", # Costal Floods, storm surges
    "POP_EXP_CYC", # Cyclones
    "POP_EXP_FLO", # Floods
    "POP_EXP_SAL" # Salinity
)

population_exposure <- function(locations) {
    return(
        process_indicators(
            locations,
            indicators = population_exposure_indicators,
            # output="output/exposure"
        )
    )
}
