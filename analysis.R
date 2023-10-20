install.packages("GGally")
install.packages("hrbrthemes")
install.packages("reshape2")
source("common/libraries.R")

library(ggplot2)
library(GGally)
library(hrbrthemes)
library(reshape)
library(viridis)
hrbrthemes::import_roboto_condensed()

gdri <- st_read("gdri.gpkg")
gdri <- gdri %>%
    st_drop_geometry() %>%
    dplyr::select(contains("_val"))
colnames(gdri)

melt_data <- melt(gdri) %>%
    dplyr::mutate(category = case_when(
        str_detect(variable, "^S_") ~ "Social Susceptibility",
        str_detect(variable, "^C_") ~ "Coping and Adaptation",
        str_detect(variable, "^A_") ~ "Coping and Adaptation",
        str_detect(variable, "^ES_") ~ "Ecosystem Sensitivity",
        str_detect(variable, "^ER_") ~ "Ecosystem Robustness",
        str_detect(variable, "_EXP_") ~ "Exposure"
    ))

# p <- ggplot(melt_data, aes(x = factor(variable), y = value, fill = category)) +
#     scale_fill_brewer(palette = "Dark2")
# p + geom_boxplot() + facet_wrap(~variable, scale = "free")

# melt_data %>%
#     ggplot(aes(x = factor(variable), y = value, fill = category)) +
#     geom_boxplot() +
#     scale_fill_viridis(discrete = TRUE, alpha = 0.6) +
#     geom_jitter(color = "black", size = 0.4, alpha = 0.9) +
#     theme_ipsum() +
#     theme(
#         legend.position = "none",
#         plot.title = element_text(size = 11)
#     ) +
#     ggtitle("A boxplot with jitter") +
#     xlab("") +
#     facet_wrap(~variable, scale = "free")


melt_data %>%
    ggplot(aes(x = factor(variable), y = value, fill = category)) +
    geom_violin() +
    scale_fill_viridis(discrete = TRUE, alpha = 0.6, option = "A") +
    theme_ipsum() +
    theme(
        legend.position = "none",
        plot.title = element_text(size = 11)
    ) +
    ggtitle("Violin chart") +
    xlab("") +
    facet_wrap(~variable, scale = "free")


ggcorr(
    gdri,
    geom = "circle",
    angle = -45,
    hjust = 0.75, size = 2, layout.exp = 1
)

devtools::install_github("hannet91/ggcor")
library(ggcor)
quickcor(gdri, type = "lower", grid.size = 0.1) + geom_circle2()
