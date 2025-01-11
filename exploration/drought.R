locations <- bgd_villages
locations <- locations %>% st_transform(4326)
country_iso3 <- unique(locations$country_iso3)[1]
drought <- "data/Hazards/Drought/spei12.nc"
agriculture <- glue::glue("objects/ESA_Landcover/{country_iso3}_agriculture.tif")
r_drought <- rast(drought)
# Define the months you want (Oct–May) and the years (2000–2024)
# valid_months <- c(10, 11, 12, 1, 2, 3, 4, 5)
valid_years <- 2000:2024

# Create a logical vector, one TRUE/FALSE per layer
keep_index <- (
    # as.numeric(format(time(r_drought), "%m")) %in% valid_months &
    as.numeric(format(time(r_drought), "%Y")) %in% valid_years
)
# Use subset() with that logical vector
r_sub <- subset(r_drought, keep_index)

r_filtered <- r_sub
r_filtered[r_filtered > -1.99] <- NA

# Pixel-wise mean
mean_terra <- app(r_filtered, mean, na.rm = TRUE)
plot(mean_terra)

writeRaster(mean_terra, "data/Hazards/Drought/mean.tif", overwrite = TRUE)
# https://en.wikipedia.org/wiki/Standardised_Precipitation_Evapotranspiration_Index
drought_masked <- mask_rasters(agriculture, mean_terra)
plot(drought_masked)
