# Freshwater scarcity - ES_DES2
library(ncdf4)

# paper: https://gmd.copernicus.org/articles/14/1037/2021/#section5
# data source: https://doi.pangaea.de/10.1594/PANGAEA.918447?format=html#download
# tuto: https://rpubs.com/boyerag/297592
# dataset search: https://datasetsearch.research.google.com/search?ref=TDJjdk1URnViWEp0ZWpONk1RPT0sTDJjdk1URnVaekIyZHpJME5BPT0sTDJjdk1URnlhbUpuTXpJNE9RPT0%3D&src=0&query=Global%20fresh%20water%20resources&docid=L2cvMTFtcDl5Xzk1NQ%3D%3D

# UNEP-WCMC 2014: https://www2.unep-wcmc.org/system/dataset_file_fields/files/000/000/232/original/NCR-LR_Mixed.pdf?1406906252
# https://www.unep-wcmc.org/en/news/towards-a-global-map-of-natural-capital
# used in GDRI paper: https://www.mdpi.com/2073-4441/13/4/577/htm

nc_data <- nc_open('data/Water/watergap_22d_WFDEI-GPCC_histsoc_tws_monthly_1901_2016.nc4')
# Save the print(nc) dump to a text file
{
  sink('data/Water/watergap_22d_WFDEI-GPCC_histsoc_tws_monthly_1901_2016_metadata.txt')
  print(nc_data)
  sink()
}

lon <- ncvar_get(nc_data, "lon")
lat <- ncvar_get(nc_data, "lat", verbose = F)
t <- ncvar_get(nc_data, "time")

tws.array <- ncvar_get(nc_data, "tws") # store the data in a 3-dimensional array
dim(tws.array)

fillvalue <- ncatt_get(nc_data, "tws", "_FillValue") # fillvalue is 0


nc_close(nc_data)