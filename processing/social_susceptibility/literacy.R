library(magrittr)
library(dplyr)
library(formattable)

mekong <- read.csv(file = "data/Vietnam/mekong.csv")
red_river <- read.csv(file = "data/Vietnam/red_river.csv")

vn_deltas <- rbind(mekong, red_river)

literacy_vn_deltas <- filter(vn_deltas, LIT == 1 | LIT == 2) %>%
  group_by(GEOLEV2, LIT) %>%
  summarise(cnt = n()) %>%
  mutate(val = (cnt / sum(cnt) * 100))
head(literacy_vn_deltas)

illiterate_vn_deltas <- literacy_vn_deltas %>%
  filter(LIT == 1) %>%
  arrange(desc(val))

# https://stackoverflow.com/a/47051133/6081943
# https://medium.com/swlh/data-normalisation-with-r-6ef1d1947970#:~:text=Min%2DMax%20Normalization%20transforms%20x,been%20between%20%2D1%20and%201.
normalize_minmax <- function(x, ...) {
  return((x - min(x, ...)) / (max(x, ...) - min(x, ...)))
}
illiterate_vn_deltas$norm <- normalize_minmax(illiterate_vn_deltas$val, na.rm = TRUE)

write.csv(illiterate_vn_deltas, file = "./data/Vietnam/illiterate_vn_deltas.csv")
