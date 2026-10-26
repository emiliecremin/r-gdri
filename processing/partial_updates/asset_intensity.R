#!/usr/bin/env Rscript
#
# Recomputes the eight hazard-intensity indicators over the ASSET area (review B14):
#   E_INT_{CYC,FLO,SAL}, A_INT_{CYC,FLO,SAL}, AQ_INT_{CYC,FLO}
# with asset_weighted_mean() (common/helpers.R), for every unit of one country, in chunks
# (BGD: district, VNM: province, IND: district of the GBM-I study area) so that the raster
# crops stay small. Each chunk is saved; units already computed are skipped on re-run.
#
# usage (from the r-gdri repo root): Rscript processing/partial_updates/asset_intensity.R BGD|VNM|IND
# output: output/partial_update/asset_intensity/<ISO>_<chunk>.csv, then <ISO>_all.csv

source("common/libraries.R")
source("common/helpers.R")
cyclone_wind_speed <- 118 # km/h
for (f in c("ecosystem", "agriculture", "aquaculture")) source(sprintf("processing/exposure/%s_exposure.R", f))

iso <- commandArgs(trailingOnly = TRUE)[1]
stopifnot(iso %in% c("BGD", "VNM", "IND"))
out_dir <- "output/partial_update/asset_intensity"
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

gbmi_districts <- c("24 Paraganas South", "24 Paraganas North", "Medinipur East", "Howrah", "Kolkata")
gpkg <- c(BGD = "villages_bgd", VNM = "villages_vnm", IND = "villages_ind")[[iso]]
units <- st_read(sprintf("objects/ADMIN/%s.gpkg", gpkg), quiet = TRUE)
units$geo_id <- as.character(units$geo_id)
units$country_iso3 <- iso
if (iso == "IND") units <- units[units$adm2_name %in% gbmi_districts, ]
units$chunk <- if (iso == "VNM") units$adm1_name else units$adm2_name
cat(iso, "units:", nrow(units), " chunks:", length(unique(units$chunk)), "\n")

indicators <- c("E_INT_CYC", "E_INT_FLO", "E_INT_SAL", "A_INT_CYC", "A_INT_FLO", "A_INT_SAL", "AQ_INT_CYC", "AQ_INT_FLO")
chunks <- sort(unique(units$chunk))
for (i in seq_along(chunks)) {
  # units already computed in an earlier run are skipped (chunk files are named by index)
  done <- unlist(lapply(
    list.files(out_dir, pattern = paste0("^", iso, "_.*\\.csv$"), full.names = TRUE),
    function(p) if (grepl("_all\\.csv$", p)) character(0) else read.csv(p, colClasses = c(geo_id = "character"))$geo_id
  ))
  u <- units[units$chunk == chunks[i] & !(units$geo_id %in% done), ]
  if (nrow(u) == 0) next
  t0 <- Sys.time()
  res <- data.frame(geo_id = u$geo_id)
  for (ind in indicators) res[[paste0(ind, "_val")]] <- get(ind)(u)$val
  write.csv(res, file.path(out_dir, sprintf("%s_c%02d.csv", iso, i)), row.names = FALSE)
  cat(chunks[i], nrow(u), "units", format(round(difftime(Sys.time(), t0, units = "mins"), 1)), "\n")
}
all <- do.call(rbind, lapply(list.files(out_dir, pattern = paste0("^", iso, "_.*\\.csv$"), full.names = TRUE), function(p) {
  if (grepl("_all\\.csv$", p)) return(NULL)
  read.csv(p, colClasses = c(geo_id = "character"))
}))
write.csv(all, file.path(out_dir, sprintf("%s_all.csv", iso)), row.names = FALSE)
cat(iso, "done:", nrow(all), "units\n")
