install.packages("Hmisc")
install.packages("ggcorrplot")
library(ggcorrplot)
library(Hmisc)
mkdirs("output/correlations")

gdri <- read.csv("output/GDRI.csv")
colnames(gdri)
gdri_norm <- gdri %>% dplyr::select(contains(c("geo_id", "_norm")))
gdri_val <- gdri %>% dplyr::select(contains(c("geo_id", "_val", "_cnt")))
colnames(gdri_val)
gdri_analysis <- gdri_val
colnames(gdri_analysis)

soc <- gdri_analysis %>% dplyr::select(matches("^S_"))
cor(soc)
cop_adapt <- gdri_analysis %>% dplyr::select(
  matches("^C_") | matches("^A_") &
    !matches("_INT_") & !matches("_EXP_") & !matches("_AFF_")
)
cor(cop_adapt)
colnames(cop_adapt)
es <- gdri_analysis %>% dplyr::select(matches("^ES_"))
er <- gdri_analysis %>% dplyr::select(matches("^ER_"))
agri_exp <- gdri_analysis %>% dplyr::select(contains("A_INT_") | contains("A_EXP_") | contains("A_AFF_"))
aqua_exp <- gdri_analysis %>% dplyr::select(contains("AQ_INT_") | contains("AQ_EXP_") | contains("AQ_AFF_"))
eco_exp <- gdri_analysis %>% dplyr::select(contains("E_INT_") | contains("E_EXP_") | contains("E_AFF_"))
pop_exp <- gdri_analysis %>% dplyr::select(matches("^POP_") | matches("^B_"))

generate_correlations(soc, "Social Susceptibility")
generate_correlations(cop_adapt, "Coping and Adaptation")
generate_correlations(es, "Ecosystems Sensitivity")
generate_correlations(er, "Ecosystems Robustness")

generate_correlations(agri_exp, "Argiculture Exposure")
generate_correlations(aqua_exp, "Aquaculture Exposure")
generate_correlations(eco_exp, "Ecosystems Exposure")
generate_correlations(pop_exp, "Population Exposure")
# ggcorr(
#     soc,
#     geom = "circle",
#     angle = -45,
#     hjust = 0.5, size = 2, layout.exp = 1
# )

# devtools::install_github("hannet91/ggcor")
# library(ggcor)
# quickcor(aqua_exp, cor.test = TRUE, type = "lower", grid.size = 0.1) + geom_circle2()

# correlation_matrix <- cor(aqua_exp, use = "complete.obs", method = "pearson")
# print(correlation_matrix)

# if (!require(corrplot)) install.packages("corrplot")
# library(corrplot)

# # Compute and visualize correlation matrix
# correlation_matrix <- cor(aqua_exp)
# corrplot(correlation_matrix, method = "circle", type = "upper", tl.col = "black", tl.cex = 0.8)

# Install and load ggcorrplot
if (!require(ggcorrplot)) install.packages("ggcorrplot")
library(ggcorrplot)

# ggcorrplot(correlation_matrix,
#     method = "circle",
#     type = "lower",
#     lab = TRUE,
#     lab_size = 3,
#     colors = c("blue", "white", "red"),
# )


# Function to get correlation coefficients and p-values
get_correlations <- function(df) {
  correlation_results <- rcorr(as.matrix(df), type = "pearson") # Compute correlations and p-values
  list(correlation_matrix = correlation_results$r, p_values = correlation_results$P)
}

# Compute and visualize correlation matrix
generate_correlations <- function(df, category = "") {
  # Get correlation coefficients and p-values
  results <- get_correlations(df)
  correlation_matrix <- results$correlation_matrix
  # p_matrix <- results$p_values

  p <- ggcorrplot(correlation_matrix,
    method = "circle",
    type = "lower",
    # p.mat = p_matrix,
    lab = TRUE,
    lab_size = 3, # Label size for the coefficients
    colors = c("blue", "white", "red"), # Color gradient
    ggtheme = ggplot2::theme_minimal()
  ) +
    ggplot2::theme(
      axis.text = ggplot2::element_text(size = 12), # Increase axis label size
      legend.text = ggplot2::element_text(size = 12)
    ) +
    ggplot2::scale_size(
      range = c(10, 20) # Increase circle sizes
    ) +
    ggplot2::labs(
      title = glue::glue("Correlation Matrix {category}"),
      subtitle = "Visualizing Relationships Between Variables"
    )

  ggsave(file = glue::glue("output/correlations/{category}.svg"), plot = p)
}


# Install and load Hmisc
if (!require(Hmisc)) install.packages("Hmisc")
library(Hmisc)

# Compute correlation matrix with p-values
correlation_results <- rcorr(as.matrix(aqua_exp))
correlation_matrix <- correlation_results$r
p_values <- correlation_results$P
print(correlation_matrix)
print(p_values)
