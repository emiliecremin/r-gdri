aoi <- st_read("output/ecosystem_sensitivity/ES_DEG6_Soil_organic_carbone.gpkg")
m <- my_map(data = aoi, "ADM2_EN", "norm", "ES_DEG6 Soil organic carbone", "Reds")
saveWidget(m, file = "html/ES_DEG6.html", selfcontained = FALSE)
