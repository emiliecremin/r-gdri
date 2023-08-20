"
Exploration of Census of India
Based on 2001 shapefile
Difficulties to merge urbanised areas between 2001 and 2011
Found another shapefile from ESRI that we now use
The following is just here for reference.
"

# India Village-Level Geospatial Socio-Economic Data Set, v1 (1991, 2001)
# https://doi.org/10.7927/H4CN71ZJ
#  india-village-census-2001-WB.shp
admin_ind <- st_read(
    "data/ADMIN/INDIA/CENSUS-2001/india-india-village-level-geospatial-socio-econ-1991-2001-wb-2001-shp/india-village-census-2001-WB.shp"
) %>% st_make_valid()
# admin_ind$country_iso3 <- "IND"
# admin_ind$geo_id <- admin_ind$C_CODE01
# admin_ind$pop <- as.numeric(admin_ind$TOT_P)
# admin_ind$area <- units::set_units(st_area(admin_ind), km^2)
# admin_ind$density <- admin_ind$pop / as.numeric(admin_ind$area)


# Metadata and Data Standards (MDDS) CENSUS codes 2001 and 2011
# West Bengal urban - 2011
# https://censusindia.gov.in/nada/index.php/catalog/7093
# West Bengal rural - 2011
# https://censusindia.gov.in/nada/index.php/catalog/7058
urban <- read_excel(
    "data/ADMIN/INDIA/CODES_2001-2011/Udir_2001_MDDS_19.xls",
    skip = 1
)
rural <- read_excel(
    "data/ADMIN/INDIA/CODES_2001-2011/Rdir_2001_MDDS_19.xls",
    skip = 1
)
colnames(urban)
colnames(rural)
urban$TRU <- "Urban"
rural$TRU <- "Rural"
setnames(rural, old = colnames(rural), new = colnames(urban))
codes <- rbind(urban, rural)
colnames(codes)
codes$C_CODE01 <- paste(
    codes$`ST_2001`, codes$`DT_2001`, codes$`SDT_2001`, codes$`Town_2001`,
    sep = ""
)

length(codes$C_CODE01)
length(unique(codes$C_CODE01))

length(codes$C_CODE11)
length(unique(codes$C_CODE11))

codes$C_CODE11 <- paste(
    codes$`ST Code`, codes$`DT Code`, codes$`SDT Code`, codes$`Town Code`,
    sep = ""
)
c <- codes %>% dplyr::filter(`Town Code` == "801731")
c$`C_CODE11`
write.csv(codes, "data/ADMIN/INDIA/codes_2001-2011.csv")

admin_ind_2011 <- admin_ind
admin_ind_2011$`NAME_01` <- admin_ind_2011$`NAME`
admin_ind_2011$`TRU_01` <- admin_ind_2011$`TRU`

keep_cols <- c("C_CODE01", "NAME_01", "TRU_01", "TRU", "UID", "geometry")
admin_ind_2011 <- admin_ind_2011[, keep_cols]

left_admin_ind_2011 <- dplyr::left_join(admin_ind_2011, codes, "C_CODE01")

na_2001 <- dplyr::filter(left_admin_ind_2011, is.na(C_CODE01))

mismatch <- dplyr::filter(
    left_admin_ind_2011,
    is.na(C_CODE11) & !is.na(C_CODE01)
)
st_write(
    mismatch,
    "data/admin/INDIA/mismatch_step1.gpkg",
    append = FALSE
)

# Ex: Contai
# 1915004741521000
# 1915000041521000
# sdt_zero <- dplyr::filter(codes, SDT_2001 == "0000")
substr(mismatch$C_CODE01, 5, 9) <- "0000"
mismatch <- within(mismatch, rm("C_CODE11"))
mismatch <- dplyr::left_join(mismatch, codes, "C_CODE01")
matching <- dplyr::filter(mismatch, !is.na(C_CODE11))
mismatch <- dplyr::filter(mismatch, is.na(C_CODE11))
st_write(
    mismatch,
    "data/admin/INDIA/mismatch_step_2.gpkg",
    append = FALSE
)

# Urbanisation
# Rural or NA code disapeared
# ST_2001	DT_2001	SDT_2001 + Town_2001 = 00000000


setdiff(left_admin_ind_2011$C_CODE11, codes$C_CODE11)
setdiff(codes$C_CODE11, left_admin_ind_2011$C_CODE11)

rural_codes <- dplyr::filter(codes, TRU == "Rural")
urban_codes <- dplyr::filter(codes, TRU == "Urban")

rural_admin_ind_2011 <- dplyr::filter(admin_ind_2011, TRU == "Rural")
length(rural_admin_ind_2011$C_CODE01)
length(unique(rural_admin_ind_2011$C_CODE01))
length(rural_admin_ind_2011$C_CODE11)
length(unique(rural_admin_ind_2011$C_CODE11))
rural_admin_ind_2011$C_CODE11 <- rural_admin_ind_2011 %>%
    pull(C_CODE01) %>%
    plyr::mapvalues(., rural_codes$C_CODE01, rural_codes$C_CODE11)

urban_admin_ind_2011 <- dplyr::filter(admin_ind_2011, TRU == "Urban")
length(urban_admin_ind_2011$C_CODE01)
length(unique(urban_admin_ind_2011$C_CODE01))
length(urban_admin_ind_2011$C_CODE11)
length(unique(urban_admin_ind_2011$C_CODE11))
urban_admin_ind_2011$C_CODE11 <- urban_admin_ind_2011 %>%
    pull(C_CODE01) %>%
    plyr::mapvalues(., urban_codes$C_CODE01, urban_codes$C_CODE11)

na_admin_ind_2011 <- dplyr::filter(admin_ind_2011, is.na(TRU))
length(na_admin_ind_2011$C_CODE01)
length(unique(na_admin_ind_2011$C_CODE01))
na_admin_ind_2011$C_CODE11 <- na_admin_ind_2011 %>%
    pull(C_CODE01) %>%
    plyr::mapvalues(., codes$C_CODE01, codes$C_CODE11)

districts_admin_ind_2011 <- dplyr::filter(admin_ind_2011, TRU == "Total")
length(districts_admin_ind_2011$C_CODE01)
length(unique(districts_admin_ind_2011$C_CODE01))
districts_admin_ind_2011$C_CODE11 <- districts_admin_ind_2011 %>%
    pull(C_CODE01) %>%
    plyr::mapvalues(., codes$C_CODE01, codes$C_CODE11)

all_admin_ind_2011 <- rbind(
    na_admin_ind_2011,
    districts_admin_ind_2011,
    urban_admin_ind_2011,
    rural_admin_ind_2011
)

length(all_admin_ind_2011$C_CODE11)
length(unique(all_admin_ind_2011$C_CODE11))

length(all_admin_ind_2011$C_CODE01)
length(unique(all_admin_ind_2011$C_CODE01))

st_write(
    all_admin_ind_2011,
    "data/admin/INDIA/all_admin_ind_2011.gpkg",
    append = FALSE
)

unique(pca11_wb$TRU)
pca11_wb$C_CODE11 <- paste(
    pca11_wb$`State`, pca11_wb$`District`, pca11_wb$`Subdistt`, pca11_wb$`Town/Village`,
    sep = ""
)

setdiff(pca11_wb$C_CODE11, codes$C_CODE11)
intersect(all_admin_ind_2011$C_CODE11, all_admin_ind_2011$C_CODE01)
mismatch <- setdiff(codes$C_CODE11, all_admin_ind_2011$C_CODE11)
mismatch <- setdiff(all_admin_ind_2011$C_CODE11, codes$C_CODE11)
all_admin_ind_2011$C_CODE11

write.csv(all_admin_ind_2011 %>% st_drop_geometry(), "data/ADMIN/INDIA/all.csv")

mismatch <- dplyr::filter(all_admin_ind_2011, C_CODE11 %in% as.numeric(mismatch))
st_write(
    mismatch,
    "data/admin/INDIA/mismatch.gpkg",
    append = FALSE
)

# Rong Chong Khasmahal = 2 distinct polygons for 1 village
# pca11_wb[2145,]$C_CODE11

# Taherpur(NA + OG) / Taherpur(NA) = 2 distinc census entries for 1 polygon
# all_admin_ind_2011[3099,]$C_CODE01
# all_admin_ind_2011[3099, ]$C_CODE11
pca_2011_right <- pca11_wb %>%
    dplyr::right_join(y = all_admin_ind_2011, by = c("C_CODE11")) %>%
    st_as_sf()

st_write(
    pca_2011_right,
    "data/ADMIN/INDIA/pca_2011_right.gpkg",
    append = FALSE
)

t <- merge(all_admin_ind_2011, pca11_wb, by = "C_CODE11", all = TRUE)
st_write(
    t,
    "data/admin/INDIA/pca_2011_merge.gpkg",
    append = FALSE
)
# Female Headed Households per District (urban/rural)
# PC11_PCA-FH/PCA-0000.xlsx
# https://censusindia.gov.in/nada/index.php/catalog/7036/
# https://censusindia.gov.in/nada/index.php/catalog/7036/download/10149/PCA-0000.xlsx


"
Exploration Comments:

# Merge
# UID
# 285324 - 285338
# Salkumarhat - Forest

# 284250 - 284266 (no data)
# Senchal Forest

# 299649 - 299815 (no data)
# Sonda (P) - Forest


length(admin_ind$UID)
length(unique(admin_ind$UID))

length(admin_ind$C_CODE01)
length(unique(admin_ind$C_CODE01))
"
# Basic Population Figures of India/State/District/Sub-District/Town - 2011
# 2011-IndiaStateDistSbDistTwnWrd-0000.xlsx
# https://censusindia.gov.in/nada/index.php/catalog/42560

# PCA TV - Town Village - per district
# https://censusindia.gov.in/nada/index.php/catalog/?tab_type=table&page=1&sk=PCA-TV%20village%20west%20bengal&tag%5B%5D=Census-2011&sort_by=popularity&sort_order=desc&ps=30

# https://censusindia.gov.in/nada/index.php/catalog/6534
# DDW_PCA1917_2011_MDDS with UI.xlsx

data <- ind
ind$S_SOC3
ind[["S_SOC3n"]]
ind$S_INF2
ind[["S_INF2n"]]
