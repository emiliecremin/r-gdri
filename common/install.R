# -------------------------------------------------------
# FOR MAC OS users
# -------------------------------------------------------
# brew install gdal
# https://github.com/r-lib/usethis/issues/1970#issuecomment-2471529856
# brew install libgit2
# brew install udunits

# install.packages("sf", configure.args = c(
#     "--with-proj-include=/opt/homebrew/include",
#     "--with-proj-lib=/opt/homebrew/lib",
#     "--with-sqlite3-lib=/opt/homebrew/lib",
#     "--with-sqlite3-include=/opt/homebrew/include"
# ))
# install.packages("terra", configure.args = c(
#     "--with-proj-include=/opt/homebrew/include",
#     "--with-proj-lib=/opt/homebrew/lib",
#     "--with-sqlite3-lib=/opt/homebrew/lib",
#     "--with-sqlite3-include=/opt/homebrew/include"
# ))
# -------------------------------------------------------

install.packages("collapse")
install.packages("data.table")
install.packages("dplyr")
install.packages("exactextractr")
install.packages("formattable")
install.packages("gfcanalysis")
install.packages("ggmap")
install.packages("landscapemetrics")
install.packages("leaflet")
remotes::install_github("r-spatialecology/landscapetools") # Install landscapetools from GitHub
install.packages("osmdata")
install.packages("osmextract")
install.packages("purrr")
install.packages("readxl")
install.packages("remotes")
install.packages("sf")
remotes::install_github("statnmap/cartomisc")
install.packages("terra")
install.packages("usethis")
install.packages("wdpar")
install.packages("writexl")
# install.packages("lwgeom")
