# https://www.nature.com/articles/s41597-021-00846-6
# https://sedac.ciesin.columbia.edu/data/set/pend-gdis-1960-2018/data-download
# https://public.emdat.be/data

library(dplyr)
library(sf)

locations <- bgd

## ____________________________________________________________________________________ ##
## Load GDIS data (rdata or other format)
load("./data/Disasters/pend-gdis-1960-2018-disasterlocations-rdata/pend-gdis-1960-2018-disasterlocations.rdata")

# List all of the variable names in RData:
# head(filter(GDIS_disasterlocations, country == "Vietnam"))

# Load EM-DAT 
disasterlist <- read.csv(file="data/Disasters/EM-DAT/emdat_public_2021_11_21_query_uid-p2SG4N.csv")

## for versions of EM-DAT data that added the ISO3 country code to the disasterno, use this code to remove the ISO3 code to enable merge with GDIS
## rename the variable "Dis No" from EMDAT and remove the three-letter ISO from the disasterno identifier
emdat <- disasterlist %>%
  mutate(disasterno=substr(`Dis.No`,1,nchar(`Dis.No`)-4))

get_emdat <- function(locations) {
  ## Filter countries of interest (VNM, BGD, IND)
  iso_countries <- unique(locations$country_iso3)
  emdat_filtered <- filter(emdat, ISO %in% iso_countries)

  disasterlocations_filtered <- GDIS_disasterlocations %>%
    filter(iso3 %in% iso_countries)

  ## Join GDIS and EM-DAT by disasterno
  colnames(emdat_filtered)
  disasterdata_since2000 <- left_join(
      disasterlocations_filtered,
      emdat_filtered,
      relationship = "many-to-many",
      by = "disasterno"
    ) %>%
    filter(Year >= 2000) %>%
    dplyr::select(-c(geo_id, Location, Country))

  ## Intersect with ADMIN locations
  sp_join <- st_intersection(st_centroid(disasterdata_since2000), locations) %>%
    group_by(disasterno, geo_id) %>%
    mutate(dupe = n() > 1) %>%
    filter(dupe == FALSE)
  unique(sp_join$disastertype)
  unique(sp_join$Disaster.Subtype)

  # Cyclones: "Tropical cyclone", "Convective storm"
  # Floods: "Flash flood", "Riverine flood"
  # Coastal floods: "Coastal flood"
  # ignore earthquakes: "Tsunami", "Ground movement"

  keep_cols <- c(
    "disasterno",
    "geo_id",
    "disastertype",
    "Disaster.Subtype",
    "Total.Deaths",
    "Total.Affected",
    "Total.Damages...000.US..",
    "Total.Damages..Adjusted...000.US.."
  )
  joint_codes <- sp_join[, keep_cols]

  return(joint_codes)
}

joint_codes <- get_emdat(locations)

# S_EXP_MH_151_A
deaths <- st_drop_geometry(joint_codes) %>%
  group_by(geo_id) %>%
  summarise(deaths = sum(Total.Deaths, na.rm = TRUE))

locations %>% left_join(deaths, by = "geo_id")

# S_EXP_MH_151_B
affected <- st_drop_geometry(joint_codes) %>%
  group_by(geo_id) %>%
  summarise(affected = sum(Total.Affected, na.rm = TRUE))

locations %>% left_join(affected, by = "geo_id")

# S_EXP_MH_152
damages <- st_drop_geometry(joint_codes) %>%
  group_by(geo_id) %>%
  summarise(damages = sum(Total.Damages..Adjusted...000.US.., na.rm = TRUE))

locations %>% left_join(damages, by = "geo_id")
