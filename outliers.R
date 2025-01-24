# ~/.R/Makevars
# OBJCXX = clang + +-std = gnu + +17
# CFLAGS = -I / opt / homebrew / include
# CXXFLAGS = -I / opt / homebrew / include
install.packages("systemfonts")

withr::with_makevars(
    c(
        OBJCXX = "clang++ -std=gnu++17"
    ), install.packages("systemfonts")
)

install.packages("devtools")
library(devtools)
devtools::install_github("davidgohel/gdtools")
devtools::install_github("r-lib/svglite")
install.packages("GGally")
install.packages("hrbrthemes")
install.packages("reshape2")

source("common/libraries.R")
source("common/helpers.R")

library(ggplot2)
library(GGally)
library(hrbrthemes)
library(reshape2)
library(svglite)
library(viridis)
hrbrthemes::import_roboto_condensed()

gdri <- read.csv("output/GDRI.csv")
gdri_norm <- gdri %>% dplyr::select(contains(c("geo_id", "_norm")))
gdri_val <- gdri %>% dplyr::select(contains(c("geo_id", "_val")))
colnames(gdri_norm)
colnames(gdri_val)

mkdirs("output/outliers")
melt_data <- melt(gdri_val) %>%
    dplyr::mutate(category = case_when(
        str_detect(variable, "^S_") ~ "Social Susceptibility",
        str_detect(variable, "^C_") ~ "Coping and Adaptation",
        str_detect(variable, "^A_") & !str_detect(variable, "_EXP_") & !str_detect(variable, "_INT_") ~ "Coping and Adaptation",
        str_detect(variable, "^ES_") ~ "Ecosystem Sensitivity",
        str_detect(variable, "^ER_") ~ "Ecosystem Robustness",
        str_detect(variable, "_EXP_") ~ "Exposure",
        str_detect(variable, "_INT_") ~ "Exposure"
    ))

# Create the box plot
# ggplot(df, aes(x = variable, y = value)) +
#     geom_boxplot(outlier.colour = "red", outlier.shape = 16, outlier.size = 3) +
#     theme_minimal() +
#     labs(
#         title = "Box Plot of Outliers",
#         x = "variable",
#         y = "value"
#     )

generate_outliers <- function(melt_data, cat) {
    p <- ggplot(melt_data, aes(x = factor(variable), y = value, fill = category)) +
        scale_fill_brewer(palette = "Dark2") +
        geom_boxplot() +
        theme(
            legend.position = "bottom",
            plot.title = element_text(size = 11),
            strip.text = element_blank(), # Adjust facet label size
            panel.spacing = unit(2, "lines") # Add more space between facets
        ) +
        facet_wrap(~variable, scale = "free")
    ggsave(file = glue::glue("output/outliers/{cat}.svg"), plot = p)
}
generate_outliers(melt_data, "all")
generate_outliers(melt_data %>% dplyr::filter(category == "Social Susceptibility"), "Social Susceptibility")
generate_outliers(melt_data, "Coping and Adaptation")
generate_outliers(melt_data, "Ecosystem Sensitivity")
generate_outliers(melt_data, "Ecosystem Robustness")
generate_outliers(melt_data, "Exposure")

# melt_data %>%
#     dplyr::filter(category == "Social Susceptibility") %>%
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


p <- melt_data %>%
    ggplot(aes(x = factor(variable), y = value, fill = category)) +
    geom_violin() +
    scale_fill_viridis(discrete = TRUE, alpha = 0.6, option = "A") +
    theme(
        legend.position = "bottom",
        plot.title = element_text(size = 11),
        strip.text = element_blank(), # Adjust facet label size
        panel.spacing = unit(2, "lines") # Add more space between facets
    ) +
    ggtitle("Violin Chart") +
    xlab("") +
    facet_wrap(~variable, scales = "free")

ggsave(file = glue::glue("output/outliers/violin_charts.svg"), plot = p)
