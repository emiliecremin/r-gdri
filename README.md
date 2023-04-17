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

| Value | Color  | Description                | Forests | Ecosystems | Agrosystem |
| ----- | ------ | -------------------------- | ------- | ---------- | ---------- |
| 10    | 006400 | Trees                      | ✅      | ✅         |            |
| 20    | ffbb22 | Shrubland                  |         | ✅         |            |
| 30    | ffff4c | Grassland                  |         | ✅         |            |
| 40    | f096ff | Cropland                   |         |            | ✅         |
| 50    | fa0000 | Built-up                   |         |            |            |
| 60    | b4b4b4 | Barren / sparse vegetation |         |            |            |
| 70    | f0f0f0 | Snow and ice               |         |            |            |
| 80    | 0064c8 | Open water                 |         | ✅         |            |
| 90    | 0096a0 | Herbaceous wetland         |         | ✅         |            |
| 95    | 00cf75 | Mangroves                  | ✅      | ✅         |            |
| 100   | fae6a0 | Moss and lichen            |         | ✅         |            |

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
| S_EXP_COF | pop exposed to storm surges | ✅           | to do        | to do   |
| S_EXP_CYC | pop exposed to cyclones     | ✅           | to do        | to do   |
| S_EXP_DRO | pop exposed to drought      | ✅           | to do        | to do   |
| S_EXP_FLO | pop exposed to floods       | ✅           | to do        | to do   |
| S_EXP_SAL | pop exposed to salinity     | 🚫 (nodat a) | to do        | to do   |

### Ecosystem Exposure

| indicator | description                       | Vietnam      | Bangladesh | India |
| --------- | --------------------------------- | ------------ | ---------- | ----- |
| E_EXP_COF | ecosystem exposed to storm surges | ✅           | to do        | to do   |
| E_EXP_CYC | ecosystem exposed to cyclones     | ✅           | to do        | to do   |
| E_EXP_DRO | ecosystem exposed to drought      | ✅           | to do        | to do   |
| E_EXP_FLO | ecosystem exposed to floods       | ✅           | to do        | to do   |
| E_EXP_SAL | ecosystem exposed to salinity     | 🚫 (no data) | to do        | to do   |


### Agrosystem Exposure

| indicator | description                       | Vietnam      | Bangladesh | India |
| --------- | --------------------------------- | ------------ | ---------- | ----- |
| E_EXP_COF | ecosystem exposed to storm surges | ✅           | to do        | to do   |
| E_EXP_CYC | ecosystem exposed to cyclones     | ✅           | to do        | to do   |
| E_EXP_DRO | ecosystem exposed to drought      | ✅           | to do        | to do   |
| E_EXP_FLO | ecosystem exposed to floods       | ✅           | to do        | to do   |
| E_EXP_SAL | ecosystem exposed to salinity     | 🚫 (no data) | to do        | to do   |


Additional  
| indicator | description | Vietnam | Bangladesh | India |
| --------- | ------------------------------- | ------- | ---------- | ----- |
| E_EXP_SUB | ecosystem exposed to subisdence | to do| to do| to do|
| S_EXP_SUB | pop exposed to subisdence | to do| to do| to do|

Other hazards can be extracted from the results of INVEST model
Other data can be extracted from GDIS + EM-DAT

## ECOSYSTEM

### Ecosystem susceptibility

| indicator  | description                                       | Vietnam | Bangladesh | India | data source                                           |
| ---------- | ------------------------------------------------- | ------- | ---------- | ----- | ----------------------------------------------------- |
| ES_BIO1a   | Species richness adjusted by intactness           | to do    | to do        | to do     | https://www.unep-wcmc.org                             |
| ES_DEG1    | Water quality of freshwater bodies                | ✅      | to do        | to do   | http://www.wri.org                                    |
| ES_DEG2    | Groundwater quality                               | ✅      | to do         | to do   | http://geodata.grid.unep.ch                           |
| ES_DEG4    | Waterstress                                       | ✅      | to do         | to do   | http://www.wri.org                                    |
| ES_DEG4    | Return Flow Ratio                                 | to do    | to do         | to do   | http://www.wri.org                                    |
| ES_DEG6    | Soil organic matter                               | to do     | to do         | to do   | https://www.soilgrids.org                             |
| ES_DEG9    | Cation exchange capacity                          | to do   | to do          | to do   | https://www.soilgrids.org                             |
| ES_DEG_GTD | Ground Table Depletion                            | ✅      | to do         | to do   | http://www.wri.org                                    |
| ES_DES2    | Freshwater scarcity                               | ✅      | to do         | to do   | [unep-wcmc](<[unep-wcmc](https://www.unep-wcmc.org)>) |
| ES_DES3    | deforested area (%) GFC                           | ✅      | to do         | to do   |                                                       |
| ES_FRA2    | River connectivity (River basin scale)            | to do   | to do        | to do   |                                                       |
| ES_FRA3    | Forest connectivity GFC                           | to do      | to do        | to do   |                                                       |
| ES_FRG1    | Percentage of area covered by “problem soils” (%) | to do    | to do        | to do   | http://geodata.grid.unep.ch                           |

### Ecosystem robustness

| indicator | description                                                    | Vietnam | Bangladesh | India | data source                                        |
| --------- | -------------------------------------------------------------- | ------- | ---------- | ----- | -------------------------------------------------- |
| ER_CON1512   | Forest area protected, conservation of biodiversity (%)      | ✅      | to do        | to do   | http://www.wri.org https://www.protectedplanet.net |
| ER_RES2   | Percentage of forest area restored (%) GFC  = forest gain       | ✅      | to do        | to do   | http://www.wri.org                                 |
| ER_POL2   | Policies supporting biodiversity conservation (National)       | ✅      | to do        | to do   | https://www.cbd.int/                               |
| ER_TRE1   | Participation in treaties - CBD, CITES, CMS, RAMSAR (National) | ✅      | to do        | to do   |                                                    |
| ER_BIO2   | Mean Species Abundance (MSA)                                   | Coming soon    | to do        | to do   | - To do                                            |
| ER_ECO1   | Ecosystem Functionality Index (EFI)                            | to do     | to do        | to do   | - to do                                            |
| ER_FUN2   | Donor aid for adaptation (local)                               | to do   | to do        | to do   | http://aiddata.org/gis - to do                     |

- TODO: Need data sources

## SOCIAL

### Lack of adaptative capacity

| indicator | description                                                                     | Vietnam | Bangladesh | India | data source                                |
| --------- | ------------------------------------------------------------------------------- | ------- | ---------- | ----- | ------------------------------------------ |
| C_EWS1   | Access to telecommunications: TV, Radio, internet, mobile phone, other (EWS)     | ✅      | to do        | to do   | Census or UNISDR - http://www.preventionweb.net    or https://data.apps.fao.org/catalog/dataset/6943b543-12b5-4722-b38d-0415ab0adac0
| C_EWS2    | Existence of early warning systems (EWS)                                        | ✅      | to do        | to do   | UNISDR - http://www.preventionweb.net      |
| C_SHE1    | Access to shelter: Density of schools km2 / 100k inhab.                         | ✅      | to do        | to do   | http://www.openstreetmap.org               |
| C_TRA1    | Access to transportation network: roads, waterways / 100k inhab.                | ✅      | to do        | to do   | http://www.openstreetmap.org               |
| C_TRA2    | Percentage of households without individual car or motorcycle (%)               | ✅      | to do        | to do   |                       
| C_GOV1    | Poor governance (National?): Corruption Perception Index (CPI)                  | To do   | to do        | to do   | http://www.transparency.org |
| C_GOV2    | Access to emergency services: hospitals, fire brigades, police                  | ✅      | to do        | to do   | http://www.openstreetmap.org   |
| C_GOV3    | to donational food reserves available (binary) (National?)                      | To do   | to do        | to do   | projects.worldbank.org / foodgrainsbank.ca |
| A_GOV4    | Foreign Direct Investment (FDI) (National)                                      | ✅      | to do        | to do   | http://data.worldbank.org                  |
| A_GOV6    | Donor aid for adaptation (local)                                                | To do   | to do        | to do   | http://aiddata.org/gis                     |
| C_HEA1    | Number of hospital beds per 1,000 inhabitants                                   | To do   | to do        | to do   | bbs.gov.bd / wbhealth.gov.in / gso.gov.vn  |
| C_HEA3    | Public health expenditure (% of GDP)                                            | To do   | to do        | to do   | http://data.worldbank.org/                 |
| C_HEA4    | Private health expenditure (% of GDP)                                           | To do   | to do        | to do   | http://data.worldbank.org/                 |
| C_SAV1    | Percentage of households without gross savings (%)                              | To do   | to do        | to do   | http://datatopics.worldbank.org            |
| C_SAV2    | Percentage of households without access to bank loans / (micro-) credits (%)    | To do   | to do        | to do   | http://datatopics.worldbank.org            |
| C_SAV3    | Lending interest rate (%) (National)                                            | To do   | to do        | to do   | http://data.worldbank.org                  |
| C_INS1    | Percentage of households with insurance – excluding health insurance (National) | ✅     | to do        | to do   | http://www.worldmapofmicroinsurance.org    |
| A_IIR1    | Percentage of GDP spent on innovation and research (%) (National)               | ✅      | to do        | to do   | http://data.uis.unesco.org                 |

### Social susceptibility

| indicator           | description                                                | Vietnam | Bangladesh | India | data source                                              |
| ------------------- | ---------------------------------------------------------- | ------- | ---------- | ----- | -------------------------------------------------------- |
| S_ECO1              | Population below national poverty line (%)                 | To do   | to do        | to do   | For bangladesh: http://www.worldbank.org/en/news/feature/2014/09/30/poverty-maps                                                        |
| S_ECO2              | Dependency ratio (%) below 15 and above 64 years old       | ✅      | to do        | to do   | ipums census                                             |
| S_ECO4              | GINI index (national level?)                               | ✅       | to do        | to do   | [UNDP](http://hdr.undp.org) |
| S_OCU1              | Dependency on agriculture / forestry / fisheries (%) Part of agricultural sector in the GDP       | ✅      | to do        | to do   |   National level  |
| S_SOC3              | Percentage female-headed households (%)                    | ✅      | to do        | to do   | ipums census |
| S_SOC4              | Travel time to closest city (mins)                         | ✅      | to do        | to do   | OSM or [JRC](https://forobs.jrc.ec.europa.eu/products/gam/) or AidDataGeoQuery |
| S_SOC5              | Percentage of population with disabilities (%)             | ✅      | to do        | to do   | ipums census |
| S_SOC8              | Percentage of illiterate population (%)                    | ✅      | to do        | to do   | ipums census |
| S_INF1 / S_INF1_621 | Population without access to (improved) sanitation (%)     | ✅      | to do        | to do   | ipums census |
| S_INF2 / S_INF2_611 | Population without access to clean water (%)               | ✅      | to do        | to do   | ipums census |
| S_INF1_631          | Proportion of wastewater flows safely treated              | ✅    | to do   | WRI AQUEDUCT  |
| S_INF3              | Population without access to electricity (%)               | ✅      | to do        | to do   | ipums census |
| C_EWS1              | Percentage of households without access to information (%) | ✅      | to do        | to do   | ipums census | S
|C_STA1              | Prevalence of violence (%): Homicides per 100k inhab.      | To do   | to do        | to do   | homicide.igarape.org.br / visionofhumanity.org           |
|S_GOV1 | Bribe      | To do   | ✅        | to do   | homicide.igarape.org.br / visionofhumanity.org           |
Additional

Undernutrition: The undernutrition maps produced by the World Food Program (WFP) are available at the following link: https://www.wfp.org/content/undernutrition-maps-bangladesh-2012



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
