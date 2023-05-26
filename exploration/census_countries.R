# TODO: explore https://github.com/ipums/ipumsr
# Tutorial: https://globalgovernanceprogramme.eui.eu/services-and-economic-development-in-africa-online-appendix/#ipums-cleaning-code

ipums_shp <- st_read("data/ADMIN/world_geolev2_2019/world_geolev2_2019.shp")
ipums_shp <- ipums_shp %>% dplyr::filter(CNTRY_NAME %in% c("Vietnam", "India", "Bangladesh"))

# install.packages("usethis")
# library(usethis)
# usethis::edit_r_environ()
# R_MAX_VSIZE=100Gb
# Error: vector memory exhausted (limit reached?)
# https://stackoverflow.com/questions/51295402/r-on-macos-error-vector-memory-exhausted-limit-reached

ipums_data <- read.csv(file = "data/IPUMS/ipumsi_00005.csv")
unique(ipums_data$COUNTRY)
unique(ipums_data$COUNTRY)

output_dir <- "output/social_susceptibility"
mkdirs(output_dir)

vnm <- ipums_data %>% dplyr::filter(COUNTRY == 704)
unique(vnm$SEX)
unique(vnm$RELATE)
unique(vnm$LIT)
unique(vnm$DISABLED)
unique(vnm$AGE)
unique(vnm$TOILET)
unique(vnm$WATSUP)
unique(vnm$ELECTRIC)
unique(vnm$RADIO)
unique(vnm$TV)

bgd <- ipums_data %>% dplyr::filter(COUNTRY == 50)
unique(bgd$SEX)
unique(bgd$RELATE)
unique(bgd$LIT)
unique(bgd$DISABLED)
unique(bgd$AGE)
unique(bgd$TOILET)
unique(bgd$WATSUP) # XXX
unique(bgd$ELECTRIC)
unique(bgd$RADIO) # XXX
unique(bgd$TV) # XXX

# CENSUS OF INDIA
# https://censusindia.gov.in/census.website/data/population-finder
# https://censusindia.gov.in/nada/index.php/catalog/42554/download/46180/2011-IndiaStateDistSbDistVill-0000.xlsx
india <- ipums_data %>% dplyr::filter(COUNTRY == 356)
unique(india$SEX)
unique(india$RELATE)
unique(india$LIT)
unique(india$DISABLED) # XXX
unique(india$AGE)
unique(india$TOILET) # XXX
unique(india$WATSUP) # XXX
unique(india$ELECTRIC) # XXX
unique(india$RADIO) # XXX
unique(india$TV) # XXX

# C-20: Disabled population by type of disability, age and sex
# https://censusindia.gov.in/nada/index.php/catalog/43388

# Female headed households / district
# PCA FH: Primary census abstract for female headed households
# https://censusindia.gov.in/nada/index.php/catalog/7036

# HL-14: Percentage of households to total households by amenities and assets
# https://censusindia.gov.in/nada/index.php/catalog/9635
# https://censusindia.gov.in/nada/index.php/catalog/9641
