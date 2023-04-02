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
| 10    | 006400 | Trees                      | ✅       | ✅          |            |
| 20    | ffbb22 | Shrubland                  |         | ✅          |            |
| 30    | ffff4c | Grassland                  |         | ✅          |            |
| 40    | f096ff | Cropland                   |         |            | ✅          |
| 50    | fa0000 | Built-up                   |         |            |            |
| 60    | b4b4b4 | Barren / sparse vegetation |         |            |            |
| 70    | f0f0f0 | Snow and ice               |         |            |            |
| 80    | 0064c8 | Open water                 |         | ✅          |            |
| 90    | 0096a0 | Herbaceous wetland         |         | ✅          |            |
| 95    | 00cf75 | Mangroves                  | ✅       | ✅          |            |
| 100   | fae6a0 | Moss and lichen            |         | ✅          |            |

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

| indicator | description                 | Vietnam     | Bangladesh | India |
| --------- | --------------------------- | ----------- | ---------- | ----- |
| S_EXP_COF | pop exposed to storm surges | ✅           | no         | no    |
| S_EXP_CYC | pop exposed to cyclones     | ✅           | no         | no    |
| S_EXP_DRO | pop exposed to drought      | ✅           | no         | no    |
| S_EXP_FLO | pop exposed to floods       | ✅           | no         | no    |
| S_EXP_SAL | pop exposed to salinity     | 🚫 (no data) | no         | no    |

### Ecosystem Exposure

| indicator | description                       | Vietnam     | Bangladesh | India |
| --------- | --------------------------------- | ----------- | ---------- | ----- |
| E_EXP_COF | ecosystem exposed to storm surges | ✅           | no         | no    |
| E_EXP_CYC | ecosystem exposed to cyclones     | ✅           | no         | no    |
| E_EXP_DRO | ecosystem exposed to drought      | ✅           | no         | no    |
| E_EXP_FLO | ecosystem exposed to floods       | ✅           | no         | no    |
| E_EXP_SAL | ecosystem exposed to salinity     | 🚫 (no data) | no         | no    |

Additional  
| indicator | description                     | Vietnam | Bangladesh | India |
| --------- | ------------------------------- | ------- | ---------- | ----- |
| E_EXP_SUB | ecosystem exposed to subisdence | no      | no         | no    |
| S_EXP_SUB | pop exposed to subisdence       | no      | no         | no    |

Other hazards can be extracted from the results of INVEST model
Other data can be extracted from GDIS + EM-DAT

## ECOSYSTEM

### Ecosystem susceptibility

| indicator     | description                                                            | Vietnam  | Bangladesh | India | data source                                                                             |
| ------------- | ---------------------------------------------------------------------- | -------- | ---------- | ----- | --------------------------------------------------------------------------------------- |
| ES_BIO1a_1551 | Species richness adjusted by intactness                                | no       | no         | no    | [https://www.unep-wcmc.org  ](http://biodiversitymapping.org/wordpress/index.php/home/) |
| ES_BIO_1571   | Proportion of traded wildlife that was poached or illicitly trafficked | no       | no         | no    | https://www.unep-wcmc.org                                                               |
| ES_BIO2       | Mean Species Abundance (MSA)                                           | no       | no         | no    | http://www.globio.info                                                                  |
| ES_DEG_1411   | Coastal eutrophication and floating plastic                            | ✅        | no         | no    | http://www.wri.org                                                                      |
| ES_DEG_1431   | marine acidity (pH)                                                    | no       | no         | no    | http://www.wri.org                                                                      |
| ES_DEG_1531   | land degraded over total land area                                     | no       | no         | no    | http://www.wri.org                                                                      |
| ES_DEG1       | Water quality of freshwater bodies                                     | ✅        | no         | no    | http://www.wri.org                                                                      |
| ES_DEG2       | Ground water quality / arsenic in ground water                         | ✅        | no         | no    | http://www.wri.org                                                                      |
| ES_DEG4       | Return Flow Ratio                                                      | ✅        | no         | no    | http://www.wri.org                                                                      |
| ES_DEG4_642   | Waterstress                                                            | ✅        | no         | no    | http://www.wri.org                                                                      |
| ES_DEG6       | Soil organic matter                                                    | no       | no         | no    | https://www.soilgrids.org                                                               |
| ES_DEG9       | Cation exchange capacity                                               | no       | no         | no    | https://www.soilgrids.org                                                               |  |
| ES_DEG_GTD    | Ground Table Depletion                                                 | ✅        | no         | no    | http://www.wri.org                                                                      |
| ES_DES1_1511  | Forest area / total land                                               | ✅        | no         | no    |                                                                                         |
| ES_DES2       | Freshwater scarcity                                                    | on going | no         | no    | [unep-wcmc]([unep-wcmc](https://www.unep-wcmc.org))                                     |
| ES_DES3       | deforested area (%) GFC                                                | ✅        | no         | no    |                                                                                         |
| ES_FRA1       | Wetland connectivity                                                   | ✅        | no         | no    |                                                                                         |
| ES_FRA2       | River connectivity (River basin scale)                                 | ✅        | no         | no    |                                                                                         |
| ES_FRA3       | Forest connectivity GFC                                                | ✅        | no         | no    |                                                                                         |
| ES_FRA4       | Wetland drained                                                        | ✅        | no         | no    |                                                                                         |
| ES_FRG1       | Percentage of area covered by “problem soils” (%)                      | no       | no         | no    | http://geodata.grid.unep.ch                                                             |
| ES_FRG3       | area covered by critical stes for conservation                         | no       | no         | no    | http://geodata.grid.unep.ch                                                             |

### Ecosystem robustness
| indicator    | description                                                                | Vietnam | Bangladesh | India | data source                                        |
| ------------ | -------------------------------------------------------------------------- | ------- | ---------- | ----- | -------------------------------------------------- |
| ER_CON1_1512 | Forest area protected, conservation of biodiversity (%)                    | ✅       | no         | no    | http://www.wri.org https://www.protectedplanet.net |
| ER_CON2_15a1 | Developement assistance                                                    | check   | no         | no    | http://www.wri.org https://www.protectedplanet.net |
| ER_POL1_1591 | Progress towards national targets Aichi Biodiversity Target 2              | check   | no         | no    | https://www.cbd.int/                               |
| ER_POL2      | Policies supporting biodiversity conservation (National)                   | check   | no         | no    | https://www.cbd.int/                               |
| ER_POL3_1581 | Prevention or control of invasive alien species                            | check   | no         | no    | https://www.cbd.int/                               |
| ER_POL4_1541 | Coverage by protected areas of important sites for coastal biodiversity    | check   | no         | no    | https://www.cbd.int/                               |
| ER_POL_1421  | National exclusive economic zones managed using ecosystem-based approaches | check   | no         | no    | https://www.cbd.int/                               |
| ER_POL_1521  | Progress towards sustainable forest management                             | check   | no         | no    | https://www.cbd.int/                               |
| ER_TRE1      | Participation in treaties - CBD, CITES, CMS, RAMSAR (National)             | check   | no         | no    |                                                    |
| ER_BIO2      | Mean Species Abundance (MSA)                                               | to do   | no         | no    | - To do                                            |
| ER_ECO1      | Ecosystem Functionality Index (EFI)                                        | to do   | no         | no    | - to do                                            |
| ER_FUN2      | Donor aid for adaptation (local)                                           | check   | no         | no    | http://aiddata.org/gis - to do                     |
| ER_RES1      | wetland restored (%) GFC                                                   | check   | no         | no    | http://www.wri.org                                 |
| ER_RES2      | forest / Mangrove area restored (%) GFC                                    | check   | no         | no    | http://www.wri.org                                 |
| ER_WAT1_632  | Proportion of bodies of water with good ambient water quality              | check   | no         | no    | http://www.wri.org                                 |
| ER_WAT2_641  | Change in water use efficiency over time                                   | check   | no         | no    | http://www.wri.org                                 |
| ER_TRE       | Participation in treaties - CBD, CITES, CMS, RAMSAR                        | check   | no         | no    | http://www.wri.org                                 |
- TODO: Need data sources

## SOCIAL

### Lack of adaptative capacity

| indicator | description                                                                     | Vietnam | Bangladesh | India | data source                                |
| --------- | ------------------------------------------------------------------------------- | ------- | ---------- | ----- | ------------------------------------------ |
| C_EWS2    | Existence of early warning systems (EWS)                                        | ✅       | no         | no    | UNISDR - http://www.preventionweb.net      |
| C_SHE1    | Access to shelter: Density of schools km2 / 100k inhab.                         | ✅       | no         | no    | http://www.openstreetmap.org               |
| C_INF1    | Percentage of households without waste/water treatment (%)                      | To do   | no         | no    |                                            |
| C_GOV2    | Access to emergency services: hospitals, fire brigades, police                  | ✅       | no         | no    | http://www.openstreetmap.org               |
| C_TRA1    | Access to transportation network: roads, waterways / 100k inhab.                | ✅       | no         | no    | http://www.openstreetmap.org               |
| C_TRA2    | Percentage of households without individual car or motorcycle (%)               | ✅       | no         | no    |                                            |
| C_GOV1    | Poor governance (National?): Corruption Perception Index (CPI)                  | To do   | no         | no    | http://www.transparency.org                |
| C_GOV3    | No national food reserves available (binary) (National?)                        | To do   | no         | no    | projects.worldbank.org / foodgrainsbank.ca |
| C_HEA1    | Number of hospital beds per 1,000 inhabitants                                   | To do   | no         | no    | bbs.gov.bd / wbhealth.gov.in / gso.gov.vn  |
| C_HEA3    | Public health expenditure (% of GDP)                                            | To do   | no         | no    | http://data.worldbank.org/                 |
| C_HEA4    | Private health expenditure (% of GDP)                                           | To do   | no         | no    | http://data.worldbank.org/                 |
| C_SAV1    | Percentage of households without gross savings (%)                              | To do   | no         | no    | http://datatopics.worldbank.org            |
| C_SAV2    | Percentage of households without access to bank loans / (micro-) credits (%)    | To do   | no         | no    | http://datatopics.worldbank.org            |
| C_SAV3    | Lending interest rate (%) (National)                                            | To do   | no         | no    | http://data.worldbank.org                  |
| C_INS1    | Percentage of households with insurance – excluding health insurance (National) | To do   | no         | no    | http://www.worldmapofmicroinsurance.org    |
| A_GOV4    | Foreign Direct Investment (FDI) (National)                                      | To do   | no         | no    | http://data.worldbank.org                  |
| A_GOV6    | Donor aid for adaptation (local)                                                | To do   | no         | no    | http://aiddata.org/gis                     |
| A_IIR1    | Percentage of GDP spent on innovation and research (%) (National)               | To do   | no         | no    | http://data.uis.unesco.org                 |

### Social susceptibility
| indicator           | description                                            | Vietnam | Bangladesh | India | data source                                              |
| ------------------- | ------------------------------------------------------ | ------- | ---------- | ----- | -------------------------------------------------------- |
| S_SOC3              | Percentage female-headed households (%)                | ✅       | no         | no    | ipums census                                             |
| S_SOC4              | Travel time to closest city (mins)                     | ✅       | no         | no    | [JRC](http://forobs.jrc.ec.europa.eu) or AidDataGeoQuery |
| S_SOC5              | population with disabilities (%)                       | ✅       | no         | no    | ipums census                                             |
| S_SOC8              | illiterate population (%)                              | ✅       | no         | no    | ipums census                                             |
| S_INF1 / S_INF1_621 | Population without access to (improved) sanitation (%) | ✅       | no         | no    | ipums census                                             |
| S_INF2 / S_INF2_611 | Population without access to clean water (%)           | ✅       | no         | no    | ipums census                                             |
| S_INF1_631          | Proportion of wastewater flows safely treated          | ✅       | no         | no    | WRI AQUEDUCT                                             |
| S_INF3              | Population without access to electricity (%)           | ✅       | no         | no    | ipums census                                             |
| C_EWS1              | households without access to information (%)           | ✅       | no         | no    | ipums census                                             |
| S_ECO1              | Population below national poverty line (%)             | To do   | no         | no    |                                                          |
| S_ECO2              | Dependency ratio (%) below 15 and above 64 years old   | ✅       | no         | no    | ipums census                                             |
| S_ECO4              | GINI index (national level?)                           | ✅       | no         | no    | [UNDP](http://hdr.undp.org)                              |
| S_OCU1              | Dependency on agriculture / forestry / fisheries (%)   | To do   | no         | no    |                                                          |
| S_STA1              | Prevalence of violence (%): Homicides per 100k inhab.  | To do   | no         | no    | homicide.igarape.org.br / visionofhumanity.org           |

Additional

- Malnutrition ...


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
