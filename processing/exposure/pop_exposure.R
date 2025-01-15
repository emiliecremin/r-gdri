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
# unit: % of population cyclone affected (wind > 150 km/h) on a 100 year return period
POP_EXP_CYC <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- tolower(unique(locations$country_iso3)[1])
    locations <- get_world_pop(locations)
    world_pop <- rast(glue::glue("data/Population/WorldPop/{country_iso3}_ppp_2020_UNadj_constrained.tif"))
    cyclones <- rast("data/Hazards/Cyclones/Wind_T100.tif")
    cyclones_cropped <- crop(cyclones, locations)
    cyclones_filtered <- cyclones_cropped
    cyclones_filtered[cyclones_filtered < 150] <- NA
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

# Global Soil Salinity Map
# https://doi.org/10.1016/j.rse.2019.111260
# https://data.isric.org/geonetwork/srv/eng/catalog.search#/metadata/c59d0162-a258-4210-af80-777d7929c512
# https://code.earthengine.google.com/d43e5a92ae1deed32a0929f57b572756
# soil salinity score 0 to 4 [0: non-saline, 1: slightly, 2: moderately, 3: highly, 4: extremely]
# unit: % of population affected by salinity slightly (1) to extremely (4)
POP_EXP_SAL <- function(locations, ...) {
    locations <- locations %>% st_transform(4326)
    country_iso3 <- tolower(unique(locations$country_iso3)[1])
    locations <- get_world_pop(locations)
    world_pop <- rast(glue::glue("data/Population/WorldPop/{country_iso3}_ppp_2020_UNadj_constrained.tif"))
    salinity <- rast("data/Soil/Salinity/salmap2016.vrt")
    salinity_cropped <- crop(salinity, world_pop)
    salinity_filtered <- salinity_cropped
    salinity_filtered[salinity_filtered < 1] <- NA
    salinity_masked <- mask_rasters(world_pop, salinity_filtered)
    locations$cnt <- exact_extract(salinity_masked, locations, "sum", progress = TRUE)
    locations$val <- locations$cnt / locations$world_pop
    return(locations)
}

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
