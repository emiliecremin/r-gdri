#!/usr/bin/env Rscript
#
# S_ECO1 / S_ECO4 for the units that carried the country median because WorldPop gave them
# fewer than one inhabitant (or no RWI data nearby): own RWI tile first, then the district mean.
#
#   S_ECO1: plain mean of the RWI pixels of the unit (rwi_unit_stats, unweighted when WorldPop < 1),
#           then the nearest RWI tile within 20 km, then the mean of the district's valid units.
#   S_ECO4: population-weighted SD of RWI in a 10 km window around the centroid (20 km if fewer than
#           5 tiles), then the nearest valid unit within 20 km, then the mean of the district's valid units.
#
# Only the units flagged as imputed in output/partial_update/S_ECO1_rwi_S_ECO4_paper_units_imputed.csv
# and still carrying a value in the dataset are recomputed (ecosystem-only units stay blank).
# Run from the r-gdri repo root (expects ../gdri_correlations/data/GDRI_2025_across_deltas.csv).
# Output: output/partial_update/rwi_unpopulated_fill.csv and rwi_unpopulated_fill_check.csv

source("common/libraries.R")
source("common/helpers.R")
source("processing/rwi.R")

mkdirs("output/partial_update")
imp <- read.csv("output/partial_update/S_ECO1_rwi_S_ECO4_paper_units_imputed.csv", colClasses = c(geo_id = "character"))
cur <- read.csv("../gdri_correlations/data/GDRI_2025_across_deltas.csv", check.names = FALSE,
                colClasses = c(geo_id = "character"))
cur <- cur[, c("geo_id", "country_iso3", "adm1_name", "adm2_name", "S_ECO1_val", "S_ECO4_val")]
d <- merge(cur, imp[, c("geo_id", "S_ECO1_imputed", "S_ECO4_imputed")], by = "geo_id")
stopifnot(nrow(d) == nrow(cur))
d$aff1 <- d$S_ECO1_imputed == 1 & !is.na(d$S_ECO1_val)
d$aff4 <- d$S_ECO4_imputed == 1 & !is.na(d$S_ECO4_val)
cat("affected S_ECO1:", sum(d$aff1), " S_ECO4:", sum(d$aff4), "\n")

villages <- c(VNM = "objects/ADMIN/villages_vnm.gpkg", BGD = "objects/ADMIN/villages_bgd.gpkg", IND = "objects/ADMIN/villages_ind.gpkg")
d$S_ECO1_new <- NA_real_; d$S_ECO1_method <- NA_character_
d$S_ECO4_new <- NA_real_; d$S_ECO4_method <- NA_character_
check <- list()

district_mean <- function(df, col, valid) {
    # mean of the valid values of the same adm1 + adm2, then adm1; NA if none
    key <- paste(df$adm1_name, df$adm2_name, sep = "|")
    dm <- tapply(df[[col]][valid], key[valid], mean)
    pm <- tapply(df[[col]][valid], df$adm1_name[valid], mean)
    out <- unname(dm[key]); meth <- rep("district mean", nrow(df))
    nap <- is.na(out)
    out[nap] <- unname(pm[df$adm1_name[nap]]); meth[nap] <- "province mean"
    list(val = out, method = meth)
}

for (iso in names(villages)) {
    sf_all <- st_read(villages[[iso]], quiet = TRUE)
    sf_all$geo_id <- as.character(sf_all$geo_id)
    sf_all$country_iso3 <- iso
    di <- d[d$country_iso3 == iso, ]
    sf_i <- sf_all[match(di$geo_id, sf_all$geo_id), ]
    stopifnot(!anyNA(sf_i$geo_id))
    sf_i$adm1_name <- di$adm1_name; sf_i$adm2_name <- di$adm2_name

    # ---- reproduction check on units that were NOT imputed (S_ECO1)
    set.seed(1)
    ok_ids <- di$geo_id[di$S_ECO1_imputed == 0 & !is.na(di$S_ECO1_val)]
    smp <- sf_i[sf_i$geo_id %in% sample(ok_ids, min(150, length(ok_ids))), ]
    st <- rwi_unit_stats(smp)
    ref <- di$S_ECO1_val[match(smp$geo_id, di$geo_id)]
    check[[iso]] <- data.frame(country = iso, n = nrow(smp), max_abs_diff_S_ECO1 = max(abs(-st$rwi_mean - ref), na.rm = TRUE),
                               n_na = sum(is.na(st$rwi_mean)))
    print(check[[iso]])

    # ---- S_ECO1 for the affected units
    a1 <- di$geo_id[di$aff1]
    if (length(a1) > 0) {
        st1 <- rwi_unit_stats(sf_i[sf_i$geo_id %in% a1, ])
        idx <- match(st1$geo_id, d$geo_id)
        d$S_ECO1_new[idx] <- -st1$rwi_mean
        d$S_ECO1_method[idx] <- ifelse(is.na(st1$rwi_mean), NA, ifelse(st1$rwi_fallback, "nearest tile", ifelse(st1$rwi_unweighted, "own tile (unweighted)", "own tile (population-weighted)")))
    }
    # ---- S_ECO4 for the affected units
    a4 <- di$geo_id[di$aff4]
    if (length(a4) > 0) {
        sub4 <- sf_i[sf_i$geo_id %in% a4, ]
        w10 <- rwi_window_stats(sub4, RWI_WINDOW_KM)
        v <- w10$rwi_sd_window; meth <- ifelse(is.na(v), NA, "10 km window")
        miss <- which(is.na(v))
        if (length(miss) > 0) {
            w20 <- rwi_window_stats(sub4[miss, ], RWI_WINDOW_KM_FALLBACK)
            v[miss] <- w20$rwi_sd_window; meth[miss] <- ifelse(is.na(w20$rwi_sd_window), NA, "20 km window")
        }
        still <- which(is.na(v))
        if (length(still) > 0) {
            pool_ok <- which(di$S_ECO4_imputed == 0 & !is.na(di$S_ECO4_val))
            cen_all <- suppressWarnings(st_centroid(st_transform(sf_i, 4326)))
            cen_sub <- suppressWarnings(st_centroid(st_transform(sub4[still, ], 4326)))
            nearest <- st_nearest_feature(cen_sub, cen_all[pool_ok, ])
            km <- as.numeric(st_distance(cen_sub, cen_all[pool_ok[nearest], ], by_element = TRUE)) / 1000
            use <- km <= RWI_MAX_FALLBACK_KM
            v[still[use]] <- di$S_ECO4_val[pool_ok[nearest[use]]]; meth[still[use]] <- "nearest valid unit"
        }
        idx <- match(sub4$geo_id, d$geo_id)
        d$S_ECO4_new[idx] <- v; d$S_ECO4_method[idx] <- meth
    }
}

# ---- district mean for what is still empty (valid pool = units with their own value)
for (k in c("S_ECO1", "S_ECO4")) {
    aff <- d[[paste0("aff", substr(k, 6, 6))]]
    own <- ifelse(aff, d[[paste0(k, "_new")]], ifelse(d[[paste0(k, "_imputed")]] == 0, d[[paste0(k, "_val")]], NA_real_))
    tmp <- d; tmp$own <- own
    valid <- !is.na(own)
    need <- which(aff & is.na(d[[paste0(k, "_new")]]))
    if (length(need) > 0) {
        dm <- district_mean(tmp, "own", valid)
        d[[paste0(k, "_new")]][need] <- dm$val[need]
        d[[paste0(k, "_method")]][need] <- dm$method[need]
    }
}
out <- d[d$aff1 | d$aff4, c("geo_id", "country_iso3", "adm1_name", "adm2_name",
                            "S_ECO1_val", "S_ECO1_new", "S_ECO1_method", "S_ECO4_val", "S_ECO4_new", "S_ECO4_method")]
write.csv(out, "output/partial_update/rwi_unpopulated_fill.csv", row.names = FALSE)
write.csv(do.call(rbind, check), "output/partial_update/rwi_unpopulated_fill_check.csv", row.names = FALSE)
print(table(out$country_iso3, out$S_ECO1_method, useNA = "ifany"))
print(table(out$country_iso3, out$S_ECO4_method, useNA = "ifany"))
