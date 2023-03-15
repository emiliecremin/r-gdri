install.packages("terra")
# install.packages("maptools")
# Install gfcanalysis package
install.packages("gfcanalysis")

# Load the gfcanalysis package
library(gfcanalysis)
library(terra)

# Indicate where we want to save GFC tiles   downloaded from Google. For any
# given AOI, the script will first check to see if these tiles are available
# locally (in the below folder) before downloading them from the server - so I
# recommend storing ALL of your GFC tiles in the same folder. For this example
# we will save files in the current working directory folder.
data_folder <- "data/Forests/GFC"
mkdirs(data_folder)

###############################################################################
# Download data from Google server for a given AOI
###############################################################################

# Define an Area Of Interest
# Not sure if transform needed
aoi <- st_transform(admin_shp, 4326)
# Calculate the google server URLs for the tiles needed to cover the AOI
tiles <- gfcanalysis::calc_gfc_tiles(aoi)

# Check to see if these tiles are already present locally, and download them if
# they are not.
options(timeout = 1800) # set the timeout to 30 minutes
download_tiles(tiles, data_folder)

# Extract the GFC data for this AOI from the downloaded GFC tiles, mosaicing
# multiple tiles as necessary (if needed to cover the AOI), and saving  the
# output data to a GeoTIFF (can also save in ENVI format, Erdas format, etc.).
gfc_data <- extract_gfc(
  aoi,
  data_folder,
  filename = "data/Forests/GFC/gfc_extract.tif"
)

###############################################################################
# Performing thresholding and calculate basic statistics
###############################################################################

# Calculate and save a thresholded version of the GFC product
gfc_thresholded <- threshold_gfc(
  gfc_data,
  forest_threshold = 20,
  filename = "data/Forests/GFC/gfc_extract_thresholded.tif", overwrite = TRUE
)


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