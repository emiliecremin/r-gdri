# SDGs at Admin Level 2 (Zila) for Bangladesh
# source: worldbank
# https://www.worldbank.org/en/news/feature/2022/03/14/spatial-database-indicators-by-sdg
# https://thedocs.worldbank.org/en/doc/9c1d0b1657e3694b19dbd37c6f488acb-0310012022/original/Zila-SDG-v2.xlsx
bgd_water_supply <- function(locations) {
    bgd_sdg <- read_excel("data/ADMIN/BGD/Zila-SDG-v2.xlsx", sheet = "SDG6")
    water_supply <- bgd_sdg %>% filter(Indicator == "Households has access to water supply (Percent)")
    locations <- locations %>% collapse::join(water_supply, on = c("adm2_name" = "Zila"))
    locations$val <- 100 - locations$Estimate
    return(locations)
}
