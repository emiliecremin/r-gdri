locations <- st_read("objects/ADMIN/villages_bgd.gpkg")
locations <- locations[, (names(locations) %in% keep_cols)]
pop_exp_sal <- POP_EXP_SAL(locations)
locations$POP_EXP_SAL_cnt <- pop_exp_sal$cnt
locations$POP_EXP_SAL_val <- pop_exp_sal$val
locations$A_INT_SAL_val <- A_INT_SAL(locations)$val
a_exp_sal <- A_AFF_SAL(locations)
locations$A_AFF_SAL_cnt <- a_exp_sal$cnt
locations$A_AFF_SAL_val <- a_exp_sal$val
locations$E_INT_SAL_val <- E_INT_SAL(locations)$val
e_exp_sal <- E_AFF_SAL(locations)
locations$E_AFF_SAL_cnt <- e_exp_sal$cnt
locations$E_AFF_SAL_val <- e_exp_sal$val
write.csv(locations %>% st_drop_geometry(), "bgd_locations.csv")

locations <- st_read("objects/ADMIN/villages_vnm.gpkg")
locations <- locations[, (names(locations) %in% keep_cols)]
pop_exp_sal <- POP_EXP_SAL(locations)
locations$POP_EXP_SAL_cnt <- pop_exp_sal$cnt
locations$POP_EXP_SAL_val <- pop_exp_sal$val
locations$A_INT_SAL_val <- A_INT_SAL(locations)$val
a_exp_sal <- A_AFF_SAL(locations)
locations$A_AFF_SAL_cnt <- a_exp_sal$cnt
locations$A_AFF_SAL_val <- a_exp_sal$val
locations$E_INT_SAL_val <- E_INT_SAL(locations)$val
e_exp_sal <- E_AFF_SAL(locations)
locations$E_AFF_SAL_cnt <- e_exp_sal$cnt
locations$E_AFF_SAL_val <- e_exp_sal$val
write.csv(locations %>% st_drop_geometry(), "vnm_locations.csv")

locations <- st_read("objects/ADMIN/villages_ind.gpkg")
locations <- locations[, (names(locations) %in% keep_cols)]
locations$geo_id <- as.character(locations$geo_id)
pop_exp_sal <- POP_EXP_SAL(locations)
locations$POP_EXP_SAL_cnt <- pop_exp_sal$cnt
locations$POP_EXP_SAL_val <- pop_exp_sal$val
locations$A_INT_SAL_val <- A_INT_SAL(locations)$val
a_exp_sal <- A_AFF_SAL(locations)
locations$A_AFF_SAL_cnt <- a_exp_sal$cnt
locations$A_AFF_SAL_val <- a_exp_sal$val
locations$E_INT_SAL_val <- E_INT_SAL(locations)$val
e_exp_sal <- E_AFF_SAL(locations)
locations$E_AFF_SAL_cnt <- e_exp_sal$cnt
locations$E_AFF_SAL_val <- e_exp_sal$val
write.csv(locations %>% st_drop_geometry(), "ind_locations.csv")

quick_map(locations, "POP_EXP_SAL_val")
quick_map(locations, "POP_EXP_SAL_cnt")

quick_map(locations, "A_INT_SAL_val")
quick_map(locations, "A_AFF_SAL_val")
quick_map(locations, "A_AFF_SAL_cnt")

quick_map(locations, "E_INT_SAL_val")
quick_map(locations, "E_AFF_SAL_val")
quick_map(locations, "E_AFF_SAL_cnt")