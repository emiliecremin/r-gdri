install.packages("terra")
# install.packages("maptools")
# Install gfcanalysis package
install.packages("gfcanalysis")

# Load the gfcanalysis package
library(gfcanalysis)
library(terra)

###############################################################################
# Download data from Google server for a given AOI
###############################################################################
create_gfc <- function(roi, region_name, output, forest_threshold = 20) {
  # Define an Area Of Interest
  # Not sure if transform needed
  aoi <- st_transform(roi, 4326)
  # Calculate the google server URLs for the tiles needed to cover the AOI
  tiles <- gfcanalysis::calc_gfc_tiles(aoi)

  # Check to see if these tiles are already present locally, and download them if
  # they are not.
  cat("Downloading Global Forest Cover tiles can take some time...\n")
  options(timeout = 1800) # set the timeout to 30 minutes
  download_tiles(tiles, output)

  # Extract the GFC data for this AOI from the downloaded GFC tiles, mosaicing
  # multiple tiles as necessary (if needed to cover the AOI), and saving  the
  # output data to a GeoTIFF (can also save in ENVI format, Erdas format, etc.).
  gfc_data <- extract_gfc(
    aoi,
    output,
    filename = glue::glue("{output}/gfc_extract_{region_name}.tif")
  )

  ###############################################################################
  # Performing thresholding and calculate basic statistics
  ###############################################################################

  # Calculate and save a thresholded version of the GFC product
  gfc_thresholded <- threshold_gfc(
    gfc_data,
    forest_threshold,
    filename = glue::glue("{output}/gfc_extract_thresholded_{region_name}.tif"),
    overwrite = TRUE
  )
}

output <- "data/Forests/GFC"
mkdirs(output)

roi <- terra::vect("data/ADMIN/admin_vnm_with_buffer.gpkg")
create_gfc(roi, "VNM", output)

roi <- terra::vect("data/ADMIN/admin_ind.gpkg")
create_gfc(roi, "IND", output)

roi <- terra::vect("data/ADMIN/admin_bgd_with_buffer.gpkg")
create_gfc(roi, "BGD", output)

###############################################################################
# Make visualization of forest change
###############################################################################

# Calculate and save a thresholded annual layer stack from the GFC product
# (useful for simple visualizations, etc.)
# gfc_thresholded_annual <- annual_stack(gfc_thresholded)
# writeRaster(
#    gfc_thresholded_annual,
#    filename = "output/forest/gfc_extract_thresholded_annual.tif"
# )

# Save a simple visualization of the thresholded annual layer stack (this is
# just an example, and is using the data in WGS84. The data should be projected
# for this).
# animate_annual(aoi, gfc_thresholded_annual)
