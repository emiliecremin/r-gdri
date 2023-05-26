library(magrittr)
library(dplyr) 

ipums_data <- read.csv(file = "data/IPUMS/ipumsi_00005.csv")
# bangladesh <- dplyr::filter(ipums_data, COUNTRY == 50)
# india <- dplyr::filter(ipums_data, COUNTRY == 356)
# vietnam <- dplyr::filter(ipums_data, COUNTRY == 704)
# dplyr::distinct(as.data.frame(vietnam_2009$YEAR))

country <- data.frame(name = "Vietnam", iso = "VNM", code = 704)
vietnam_2009 <- dplyr::filter(ipums_data, YEAR == 2009 & COUNTRY == 704)
saveRDS(vietnam_2009, "objects/vnm_ipums.rds")
write.csv(vietnam_2009, file = "data/Vietnam/vietnam_2009.csv")
# Mekong
# 704082 Tien Giang [Province: Vietnam]
# 704083 Ben Tre [Province: Vietnam]
# 704084 Tra Vinh, Vinh Long [Province: Vietnam]
# 704087 Dong Thap [Province: Vietnam]
# 704089 An Giang [Province: Vietnam]
# 704091 Kien Giang [Province: Vietnam]
# 704092 Can Tho city, Hau Giang, Soc Trang [Province: Vietnam]
# 704095 Bac Lieu, Ca Mau [Province: Vietnam]
mekong <- dplyr::filter(vietnam_2009, GEOLEV1 >= 704082 & GEOLEV1 <= 704095)
# write.csv(mekong, file = "./output/Vietnam/mekong.csv")

# Red River
# 704001 Ha Noi, Hoa Binh, Phu Tho, Vinh Phuc [Province: Vietnam]
# 704002 Ha Giang, Tuyen Quang [Province: Vietnam]
# 704004 Bac Kan, Cao Bang, Thai Nguyen [Province: Vietnam]
# 704010 Dien Bien, Lai Chau, Lao Cai, Son La, Yen Bai [Province: Vietnam]
# 704020 Lang Son [Province: Vietnam]
# 704022 Quang Ninh [Province: Vietnam]
# 704024 Bac Giang, Bac Ninh [Province: Vietnam]
# 704030 Hai Dong, Hung Yen [Province: Vietnam]
# 704031 Hai Phong City [Province: Vietnam]
# 704034 Thai Binh [Province: Vietnam]
# 704035 Ha Nam, Ninh Binh, Ninh Dinh [Province: Vietnam]
# 704038 Thanh Hoa [Province: Vietnam]

red_river <- dplyr::filter(vietnam_2009, GEOLEV1 >= 704001 & GEOLEV1 <= 704038)
# write.csv(red_river, file = "./output/Vietnam/red_river.csv")

vn_deltas <- rbind(mekong, red_river)
write.csv(vn_deltas, file = "data/Vietnam/vn_deltas.csv")

bangladesh_2011 <- dplyr::filter(ipums_data, YEAR == 2011 & COUNTRY == 50)
saveRDS(bangladesh_2011, "objects/bgd_ipums.rds")
write.csv(bangladesh_2011, file = "data/Bangladesh/bangladesh_2011.csv")

