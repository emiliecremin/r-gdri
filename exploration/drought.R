locations <- bgd_villages
locations <- locations %>% st_transform(4326)
country_iso3 <- unique(locations$country_iso3)[1]
drought <- rast("data/Hazards/Drought/spei12.nc")
agriculture <- glue::glue("objects/ESA_Landcover/{country_iso3}_agriculture.tif")
r_drought <- crop(drought, ext(locations))
plot(r_drought)
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
below_threshold <- r_sub < -1.99
plot(below_threshold)
writeRaster(below_threshold, "data/Hazards/Drought/below_threshold.tif", overwrite = TRUE)
# Sum the number of times each pixel is below 1.50 across bands
count_below_threshold <- app(below_threshold, sum, na.rm = TRUE)
plot(count_below_threshold)
locations$drought_below <- exact_extract(count_below_threshold, locations, "mean", progress = TRUE)
plot(locations["drought_below"])

# Function to calculate the maximum consecutive streak
calculate_streak <- function(pixel_values) {
    if (any(is.na(pixel_values))) {
        return(NA)
    }
    runs <- rle(pixel_values)
    valid_streaks <- runs$lengths[runs$values == 1 & runs$lengths >= 3] # Example: minimum 3 months
    max_streak <- ifelse(length(valid_streaks) > 0, max(valid_streaks), 0)
    return(max_streak)
}

# Apply the streak calculation to each pixel
consecutive_below <- app(below_threshold, calculate_streak)
plot(consecutive_below)

locations$drought_3months_below <- exact_extract(consecutive_below, locations, "mean", progress = TRUE)
plot(locations["drought_3months_below"])

writeRaster(mean_terra, "data/Hazards/Drought/mean.tif", overwrite = TRUE)
# https://en.wikipedia.org/wiki/Standardised_Precipitation_Evapotranspiration_Index
drought_masked <- mask_rasters(agriculture, count_below_threshold)
plot(drought_masked)
