# Administrative boundaries

## UN OCHA

https://data.humdata.org/dataset/cod-ab-vnm
It has an ADM2_PCODE matching the GEOLEVEL2 from IPUMS
Polygons match Geoboundaries

## IPUMS

https://international.ipums.org/international/geography_variables_list.shtml
code = 050 010 001
<country><ADM_1><ADM2> = ADM2_PCODE
Each level needs padding zeros to be on 3 digits

## Geoboundaries

https://www.geoboundaries.org/index.html#getdata

# Landcover

ESA 2020 landcover  
Get the Macro tile from ESA worldcover 2020 https://worldcover2020.esa.int/downloader  
direct link for Asia: https://worldcover2020.esa.int/data/archive/ESA_WorldCover_10m_2020_v100_60deg_macrotile_S30E060.zip

## All classes

| Value | Color  | Description                | Forests | Ecosystems |
| ----- | ------ | -------------------------- | ------- | ---------- |
| 10    | 006400 | Trees                      | ✅      | ✅         |
| 20    | ffbb22 | Shrubland                  |         | ✅         |
| 30    | ffff4c | Grassland                  |         | ✅         |
| 40    | f096ff | Cropland                   |         | ✅         |
| 50    | fa0000 | Built-up                   |
| 60    | b4b4b4 | Barren / sparse vegetation |
| 70    | f0f0f0 | Snow and ice               |
| 80    | 0064c8 | Open water                 |         | ✅         |
| 90    | 0096a0 | Herbaceous wetland         |         | ✅         |
| 95    | 00cf75 | Mangroves                  | ✅      | ✅         |
| 100   | fae6a0 | Moss and lichen            |         | ✅         |

# GDRI

## Categories

### Ecosystem

- Ecosystem exposure: E_EXP
- Ecosystem susceptibility: E_SUS
- Ecosystem robustness: ER\_

### Social

- Social exposure: S_EXP
- Social susceptibility: S\_
- Social Lack of coping capacity: CA\_

# Status

## EXPOSURE

### Social Exposure

| indicator | description                 | Vietnam      | Bangladesh | India |
| --------- | --------------------------- | ------------ | ---------- | ----- |
| S_EXP_COF | pop exposed to storm surges | ✅           | no         | no    |
| S_EXP_CYC | pop exposed to cyclones     | ✅           | no         | no    |
| S_EXP_DRO | pop exposed to drought      | ✅           | no         | no    |
| S_EXP_FLO | pop exposed to floods       | ✅           | no         | no    |
| S_EXP_SAL | pop exposed to salinity     | 🚫 (no data) | no         | no    |

### Ecosystem Exposure

| indicator | description                       | Vietnam      | Bangladesh | India |
| --------- | --------------------------------- | ------------ | ---------- | ----- |
| E_EXP_COF | ecosystem exposed to storm surges | ✅           | no         | no    |
| E_EXP_CYC | ecosystem exposed to cyclones     | ✅           | no         | no    |
| E_EXP_DRO | ecosystem exposed to drought      | ✅           | no         | no    |
| E_EXP_FLO | ecosystem exposed to floods       | ✅           | no         | no    |
| E_EXP_SAL | ecosystem exposed to salinity     | 🚫 (no data) | no         | no    |

Additional  
S_EXP_SUB Subsidence  
E_EXP_SUB Subsidence

Risks from GDIS + EM-DAT

## ECOSYSTEM

### Ecosystem susceptibility

ES_DES2 Freshwater scarcity https://www.unep-wcmc.org

ES_DES3 Percentage of deforested area (%) GFC -> done for Vietnam

ES_FRA2 River connectivity (River basin scale)
ES_FRA3 Forest connectivity GFC
ES_DEG1 Water quality of freshwater bodies http://www.wri.org
ES_DEG2 Groundwater quality http://geodata.grid.unep.ch

ES_DEG4 Return Flow Ratio http://www.wri.org
ES_DEG6 Soil organic matter https://www.soilgrids.org
ES_DEG9 Cation exchange capacity https://www.soilgrids.org
ES_FRG1 Percentage of area covered by “problem soils” (%) (laocl: raster) http://geodata.grid.unep.ch
ES_BIO1a Species richness adjusted by intactness https://www.unep-wcmc.org

New
ES_DEG4 Waterstress http://www.wri.org
ES_DEG_GTD Ground Table Depletion http://www.wri.org

### Ecosystem robustness

ER_CON1 Percentage of forest area protected and designated for the conservation of biodiversity (%) https://www.protectedplanet.net - done for vietnam
ER_RES2 Percentage of forest area restored (%) GFC - done for Vietnam

ER_POL2 Policies supporting biodiversity conservation (National) https://www.cbd.int/
ER_TRE1 Participation in treaties - CBD, CITES, CMS, RAMSAR (National)

ER_BIO2 Mean Species Abundance (MSA) - To do
ER_ECO1 Ecosystem Functionality Index (EFI) - to do
ER_FUN2 Donor aid for adaptation (local) http://aiddata.org/gis - to do

- TODO: Need data sources

## SOCIAL - Lack of adaptative capacity

C_EWS2 Existence of early warning systems (EWS) - todo
UNISDR - http://www.preventionweb.net
Level of progress in EWS according to UNISDR

C_SHE1 Access to shelter places (Shelter places per 1,000 people) -> Vietnam - check
Proxy: Density of schools km2 per 100,000 inhabitants
http://www.openstreetmap.org
**source: osm**

C_INF1 Percentage of households without access to waste/water treatment (%) -> todo
Proxy: Percentage of households without access to sewage drainage system (%)

C_GOV2 Access to emergency services: hospitals, fire brigades, police stations -> Vietnam - check
Proxy: Density of emergency services: hospitals, fire brigades, police stations per 100,000 inhabitants
http://www.openstreetmap.org
**source: osm**

C_TRA1 Access to transportation network -> Vietnam - check
Proxy: Density of transportation network: roads (highways, trunks, primary / secondary / tertiary), waterways (rivers / canals / streams), ferry stations per 100,000 inhabitants
http://www.openstreetmap.org
**source: osm**

C_TRA2 Percentage of households without individual means of transportation: car or motorcycle (%)
Proxy: Percentage of households without individual means of transportation: car or motorcycle (%)

C_GOV1 Poor governance (National?)
Corruption Perception Index (CPI)
http://www.transparency.org

C_GOV3 No national food reserves available (binary) (National?)
http://projects.worldbank.org/
http://www.foodgrainsbank.ca

C_HEA1 Number of hospital beds per 1,000 inhabitants
Proxy: Number of doctors per 1000 inhabitants; access to hospitals (travel time); number of hospitals per 1,000 people
http://www.bbs.gov.bd
http://www.wbhealth.gov.in
https://www.gso.gov.vn

C_HEA3 Public health expenditure (% of GDP)
http://data.worldbank.org/
**source: worldbank**

C_HEA4 Private health expenditure (% of GDP)
http://data.worldbank.org/
**source: worldbank**

C_SAV1 Percentage of households without gross savings (%)
Proxy: Population (age 15+) who has not saved any money in the last year (%)
http://datatopics.worldbank.org

C_SAV2 Percentage of households without access to bank loans / (micro-) credits (%)
Proxy: Population (age 15+) who has not borrowed any money in the last year (%)
http://datatopics.worldbank.org

C_SAV3 Lending interest rate (%) (National)
http://data.worldbank.org

C_INS1 Percentage of households with insurance – excluding health insurance (National)
Proxy: Microinsurance penetration (%)
http://www.worldmapofmicroinsurance.org

A_GOV4 Foreign Direct Investment (FDI) (National)
Proxy: Net inflow in US$ (% of GDP)
http://data.worldbank.org
**source: worldbank**

A_GOV6 Donor aid for adaptation (local)
Proxy: Density of aid projects (governance, DRM) in the past 10 years per km2
http://aiddata.org/gis

A_IIR1 Percentage of GDP spent on innovation and research (%) (National)
http://data.uis.unesco.org

## Social susceptibility

S_SOC3 Percentage female-headed households (%) -> done Vietnam
**source: ipums census**

S_SOC4 Travel time to closest city (mins)
European Commission Joint Research Centre (JRC) - http://forobs.jrc.ec.europa.eu
**source: AidDataGeoQuery**

S_SOC5 Percentage of population with disabilities (%)-> done Vietnam
**source: ipums census**

S_SOC8 Percentage of illiterate population (%) -> done Vietnam
**source: ipums census**

S_INF1 / S_INF1_621 Percentage of population without access to (improved) sanitation (%)-> done Vietnam
**source: ipums census**

S_INF2 / S_INF2_611 Percentage of population without access to clean water (%) -> done Vietnam
**source: ipums census**

New
S_INF1_631 Proportion of domestic and industrial wastewater flows safely treated -> done Vietnam

S_INF3 Percentage of population without access to electricity (%) -> done Vietnam
**source: ipums census**

C_EWS1 Percentage of households without access to information (%) -> done Vietnam
Radio, TV, phone, internet
Proxy: Percentage of households without access to internet (%)
(Digital divide)
**source: ipums census**

S_ECO1 Percentage of population below national poverty line (%) -> to do
Bangladesh Bureau of Statistics (BD) - http://www.bbs.gov.bd
Tendulkar Poverty Definition (IN) - http://www.livemint.com
General Statistics Office of Vietnam (VN) - https://www.gso.gov.vn

S_ECO2 Dependency ratio (%) -> done Vietnam
The dependency ratio indicates the proportion of economically dependent population to the income generating population.
The indicator gives an insight into the amount of people in non-working age (children and elderly), compared to the number of those in working age, which is defined by the World Bank as 15 to 64 years.
**source: ipums census**

S_ECO4 GINI index (national level?)
United Nations Development Programme (UNDP) - http://hdr.undp.org

S_OCU1 Dependency on agriculture / forestry / fisheries for livelihood (%) (TODO)
Or PROXY  
Percentage of contribution of agriculture / forestry / fisheries to GPD (%) per province

S_STA1 Prevalence of population who experience violence (%) (TODO)
Or PROXY  
Homicide rate per 100,000 inhabitants
http://homicide.igarape.org.br
http://www.visionofhumanity.org

Additional

- Malnutrition ...

### DONE: 15

- 8 ipums census
- 4 worldbank
- 3 OSM

### DOING: 2

2 AidDataGeoQuery

- S_SOC4 Travel time to closest city (mins)
- A_GOV6 Donor aid for adaptation

### TODO: 15

- S_ECO1 Percentage of population below national poverty line (%)
- S_ECO4 GINI index (national level?)
- S_OCU1 Dependency on agriculture / forestry / fisheries for livelihood (%)
- S_STA1 Prevalence of population who experience violence (%)
- C_EWS2 Existence of early warning systems (EWS)
- C_INF1 Percentage of households without access to waste/water treatment (%)
- C_TRA2 Percentage of households without individual means of transportation: car or motorcycle (%)
- C_GOV1 (National?) Poor governance - Corruption Perception Index (CPI)
- C_GOV3 (National?) No national food reserves available (binary)
- C_HEA1 Number of hospital beds per 1,000 inhabitants
- C_SAV1 Percentage of households without gross savings (%)
- C_SAV2 Percentage of households without access to bank loans / (micro-) credits (%)
- C_SAV3 Lending interest rate (%)
- C_INS1 Percentage of households with insurance – excluding health insurance
- A_IIR1 Percentage of GDP spent on innovation and research (%)

- MALNUTRITION ???

## Indicators

## Data sources

### Bangladesh

http://redatam.bbs.gov.bd/redbin/RpWebEngine.exe/Portal
https://redatam.org/en

# Census data analysis

## Sources of data

<a href="https://international.ipums.org" target="_blank">https://international.ipums.org</a>

### What is IPUMS?

IPUMS provides census and survey data from around the world integrated across time and space. IPUMS integration and documentation makes it easy to study change, conduct comparative research, merge information across data types, and analyze individuals within family and community context. Data and services available free of charge.

### Select data

Selected samples: Bangladesh, Vietnam
Selected harmonized variables

## Preparation of data

Extract from the downloaded archive

```
gzip -c -d ipumsi_00002.csv.gz > ipumsi_00002.csv
```

## Select Geographical area of interest

### Documentation

- <a href="./doc/geolevel1.pdf" target="_blank">geolevel1.pdf</a>
- <a href="./doc/geolevel2.pdf" target="_blank">geolevel2.pdf</a>

### Vietnam

#### Mekong

- 704082 Tien Giang [Province: Vietnam]
- 704083 Ben Tre [Province: Vietnam]
- 704084 Tra Vinh, Vinh Long [Province: Vietnam]
- 704087 Dong Thap [Province: Vietnam]
- 704089 An Giang [Province: Vietnam]
- 704091 Kien Giang [Province: Vietnam]
- 704092 Can Tho city, Hau Giang, Soc Trang [Province: Vietnam]
- 704095 Bac Lieu, Ca Mau [Province: Vietnam]

#### Red River

- 704001 Ha Noi, Hoa Binh, Phu Tho, Vinh Phuc [Province: Vietnam]
- 704002 Ha Giang, Tuyen Quang [Province: Vietnam]
- 704004 Bac Kan, Cao Bang, Thai Nguyen [Province: Vietnam]
- 704010 Dien Bien, Lai Chau, Lao Cai, Son La, Yen Bai [Province: Vietnam]
- 704020 Lang Son [Province: Vietnam]
- 704022 Quang Ninh [Province: Vietnam]
- 704024 Bac Giang, Bac Ninh [Province: Vietnam]
- 704030 Hai Dong, Hung Yen [Province: Vietnam]
- 704031 Hai Phong City [Province: Vietnam]
- 704034 Thai Binh [Province: Vietnam]
- 704035 Ha Nam, Ninh Binh, Ninh Dinh [Province: Vietnam]
- 704038 Thanh Hoa [Province: Vietnam]

# Open Street Map

https://towardsdatascience.com/calculating-building-density-in-r-with-osm-data-e9d85c701e19

https://rspatialdata.github.io/osm.html#Retrieving_the_osmdata_object

lagos_hospitals <- lagos_bb %>%
opq() %>%
add_osm_feature(key = "amenity", value = "hospital") %>%
osmdata_sf()

OSM data from 2021
Population census from 2009
Ex: hospital per 1000 hab.
Bias can be mesured by population growth between 2009 and 2021
