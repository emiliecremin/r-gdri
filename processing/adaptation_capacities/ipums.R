source("common/helpers.R")

# C_EWS1
# Percentage of households without access to information (%)
# Proxy: Percentage of households without radio or TV (%)
C_EWS1 <- function(social, append = FALSE, normalize = FALSE, plot = FALSE, output = "") { # nolint
  tv_radio <- filter(social, RADIO != 9 & RADIO != 0 & TV != 00 & TV != 99) %>%
    group_by(GEOLEV2, RADIO, TV) %>%
    summarise(cnt = n()) %>%
    mutate(val = (cnt / sum(cnt) * 100))
  no_tv_radio <- tv_radio %>%
    filter(RADIO == 1 & TV == 10)
  return(
    process_indicator(
      "C_EWS1", no_tv_radio,
      append, normalize, plot, "output/adaptation_capacities"
    )
  )
}

# Mobile
# https://www.gsma.com/mobileeconomy/wp-content/uploads/2021/08/GSMA_ME_APAC_2021_Web_Singles.pdf
# https://www.gsma.com/mobilefordevelopment/wp-content/uploads/2021/03/Achieving-mobile-enabled-digital-inclusion-in-Bangladesh.pdf
# https://www.gsma.com/mobilefordevelopment/
# https://www.gsma.com/betterfuture/wp-content/uploads/2019/08/Mobile-Economic-Impact-2019-Vietnam.pdf
# https://www.nperf.com/fr/about-us/
# https://www.gsmaintelligence.com/data/
# https://www.itu.int/en/ITU-D/Statistics/Pages/stat/default.aspx
# https://www.itu.int/itu-d/sites/statistics/

# Data sources
# http://hdr.undp.org/en/content/human-development-report-office-statistical-data-api
# http://hdr.undp.org/en/statistics/understanding/sources
