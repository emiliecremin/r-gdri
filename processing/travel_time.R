# Travel time to closest city (mins)
# Nelson, Andy (2019). Travel time to cities and ports in the year 2015. figshare. Dataset. https://doi.org/10.6084/m9.figshare.7638134.v4
# https://figshare.com/articles/dataset/Travel_time_to_cities_and_ports_in_the_year_2015/7638134/4?file=14189852
S_SOC4 <- function(locations, ...) {
    msa <- rast("data/TravelTimeToCities-2015/travel_time_to_cities_12.tif") # nolint
    locations$val <- exact_extract(msa, locations, "mean", progress = TRUE)
    return(locations)
}
