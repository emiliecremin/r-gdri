#!/usr/bin/env Rscript
#
# Province-level check of the Sentinel-2 aquaculture layer against official statistics (review M6).
# Official: GSO/NSO table E06.58 "Harvested area of water surface for aquaculture by province"
# (thousand ha, 2020 and 2023; data/Aquaculture/VNM_E06.58.xlsx). Mapped: sum of the "Aquaculture
# area" column (km2) of the delta units in gdri_correlations/data/GDRI_2025_<delta>.csv, grouped by
# province (adm1_name). 1 thousand ha = 10 km2. The layer maps land whose Sentinel-2 signature is close
# to aquaculture ponds inside the 0-4 m coastal zone, so a ratio above 1 is expected where flooded
# land resembles ponds; the check shows where and by how much, and whether the spatial pattern agrees.
#
# Output: output/AQUACULTURE_OVERLAP/validation_by_province.csv, validation_summary.csv
# Run from the r-gdri repo root: Rscript processing/aquaculture/aquaculture_validation.R

suppressMessages({ library(readxl); library(stringi) })
csv_dir <- if (dir.exists("gdri_correlations/data")) "gdri_correlations/data" else "../gdri_correlations/data"
out_dir <- "output/AQUACULTURE_OVERLAP"; dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

norm <- function(x) tolower(trimws(gsub("\\s+", " ", stringi::stri_trans_general(x, "Latin-ASCII"))))
off <- as.data.frame(read_excel("data/Aquaculture/VNM_E06.58.xlsx", skip = 3, col_names = c("province", "y2020", "y2023")))
off$key <- norm(off$province)
off$y2020 <- suppressWarnings(as.numeric(off$y2020)); off$y2023 <- suppressWarnings(as.numeric(off$y2023))

mrd <- c("long an", "tien giang", "ben tre", "tra vinh", "vinh long", "dong thap", "an giang", "kien giang", "can tho", "hau giang", "soc trang", "bac lieu", "ca mau")
rrd <- c("ha noi", "vinh phuc", "bac ninh", "quang ninh", "hai duong", "hai phong", "hung yen", "thai binh", "ha nam", "nam dinh", "ninh binh")
sets <- list(MRD = mrd, RRD = rrd)

rows <- do.call(rbind, lapply(names(sets), function(dl) {
  d <- read.csv(file.path(csv_dir, sprintf("GDRI_2025_%s.csv", dl)), check.names = FALSE, stringsAsFactors = FALSE)
  d$key <- norm(d$adm1_name)
  mapped <- tapply(as.numeric(d[["Aquaculture area"]]), d$key, sum, na.rm = TRUE)
  units <- table(d$key)
  data.frame(delta = dl, province = sets[[dl]],
             mapped_km2 = as.numeric(mapped[sets[[dl]]]), units = as.integer(units[sets[[dl]]]),
             official_2020_km2 = 10 * off$y2020[match(sets[[dl]], off$key)],
             official_2023_km2 = 10 * off$y2023[match(sets[[dl]], off$key)])
}))
rows$ratio_2020 <- rows$mapped_km2 / rows$official_2020_km2
write.csv(rows, file.path(out_dir, "validation_by_province.csv"), row.names = FALSE)

sm <- function(d, label) data.frame(
  group = label, n_provinces = nrow(d), mapped_km2 = sum(d$mapped_km2), official_2020_km2 = sum(d$official_2020_km2),
  ratio = sum(d$mapped_km2) / sum(d$official_2020_km2), median_province_ratio = median(d$ratio_2020),
  spearman_2020 = cor(d$mapped_km2, d$official_2020_km2, method = "spearman"),
  spearman_2023 = cor(d$mapped_km2, d$official_2023_km2, method = "spearman"),
  log_pearson_2020 = cor(log(pmax(d$mapped_km2, 1)), log(d$official_2020_km2))
)
coastal_mrd <- c("ca mau", "kien giang", "bac lieu", "soc trang", "tra vinh", "ben tre")
summ <- rbind(sm(rows[rows$delta == "MRD", ], "MRD"), sm(rows[rows$delta == "RRD", ], "RRD"), sm(rows, "MRD + RRD"),
              sm(rows[rows$delta == "MRD" & rows$province %in% coastal_mrd, ], "MRD, six coastal shrimp provinces"),
              sm(rows[rows$delta == "MRD" & !rows$province %in% coastal_mrd, ], "MRD, seven other provinces"))
write.csv(summ, file.path(out_dir, "validation_summary.csv"), row.names = FALSE)
print(rows[order(rows$delta, -rows$official_2020_km2), c("delta", "province", "mapped_km2", "official_2020_km2", "ratio_2020")], digits = 3, row.names = FALSE)
print(summ, digits = 3, row.names = FALSE)
