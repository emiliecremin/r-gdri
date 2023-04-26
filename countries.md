# From one to multi countries

1. Each admin geopackage should have common column names 
   1. geo_id (GEOLEV2 for IPUMS, uid for Census of India)
   2. area
   3. pop
2. generate coastal buffer for each zone
3. landcover for each zone
4. pass the admin gpkg and/or landcover as parameters for each indicator
   1. use append TRUE to add each zone per indicator
   2. create country specific files for some indicators when data is different (ex: social)
5. Normalize each indicator at the end when computing the GDRI