
# ES_DES2 - Freshwater scarcity
# Proxy: Baseline water stress from Aqueduct30

# tuto: https://inbo.github.io/tutorials/tutorials/spatial_standards_vector/#reading-a-geopackage-file

# datasource ---------------------
# Author: Rutger Hofste
# Date: 2019/07/12
# Version: 01
# S3 Path: s3://wri-projects/Aqueduct30/finalData/Y2019M07D12_Aqueduct30_V01
# Instructions: https://github.com/wri/aqueduct30_data_download/blob/master/metadata.md
# --------------------------------
library(sf)
library(tidyverse)

source("admin.R")

gp <- "data/Water/Y2019M07D12_Aqueduct30_V01/baseline/annual/y2019m07d11_aqueduct30_annual_v01.gpkg"
st_layers(gp)
baseline <- st_read(gp)
baseline_vnm <- baseline %>% dplyr::filter(gid_0 == "VNM")
baseline_vnm <- st_make_valid(baseline_vnm)

clp2 <- st_intersection(baseline_vnm %>% select(1:13), admin_shp)
st_write(clp2, "baseline/baseline_intersect.shp", append=FALSE)
