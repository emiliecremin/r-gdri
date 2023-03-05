# https://www.nature.com/articles/s41597-021-00846-6
# https://sedac.ciesin.columbia.edu/data/set/pend-gdis-1960-2018/data-download
# https://public.emdat.be/data

library(dplyr)
library(sf)

## ____________________________________________________________________________________ ##
## Load GDIS data (rdata or other format)
load("./data/Disasters/pend-gdis-1960-2018-disasterlocations-rdata/pend-gdis-1960-2018-disasterlocations.rdata")

# List all of the variable names in RData:
# head(filter(GDIS_disasterlocations, country == "Vietnam"))

# Load EM-DAT 
disasterlist <- read.csv(file="data/Disasters/EM-DAT/emdat_public_2021_11_21_query_uid-p2SG4N.csv")

## for versions of EM-DAT data that added the ISO3 country code to the disasterno, use this code to remove the ISO3 code to enable merge with GDIS
## rename the variable "Dis No" from EMDAT and remove the three-letter ISO from the disasterno identifier
emdat <- disasterlist%>%
  mutate(disasterno=substr(`Dis.No`,1,nchar(`Dis.No`)-4))

## Filter countries of interest (VNM, BGD, IND)
iso_countries <- c("VNM", "BGD", "IND")
emdat_filtered <- filter(emdat, ISO %in% iso_countries)
GDIS_disasterlocations_filtered <- filter(GDIS_disasterlocations, iso3 %in% iso_countries)

## Join GDIS and EM-DAT by disasterno
disasterdata <- left_join(GDIS_disasterlocations_filtered, emdat_filtered)

## ____________________________________________________________________________________ ##
## Remove geography to ease data operations
disasterlocations <- GDIS_disasterlocations_filtered %>% 
  as_tibble() %>% 
  select(-geometry) %>%
  as.data.frame()


