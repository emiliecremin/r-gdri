# -------------------------------------------------------
# FOR MAC OS users
# -------------------------------------------------------
# brew install gdal
# brew install imagemagick
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
install_package <- function(package_name) {
    if (!requireNamespace(package_name, quietly = TRUE)) {
        install.packages(package_name)
    }
}
install_package("remotes")
install_package("collapse")
install_package("data.table")
install_package("dplyr")
install_package("exactextractr")
install_package("formattable")
install_package("ggmap")
install_package("landscapemetrics")
install_package("leaflet")
install_package("osmdata")
install_package("osmextract")
install_package("purrr")
install_package("readxl")
install_package("sf")
install_package("terra")
install_package("usethis")
install_package("wdpar")
install_package("writexl")
# install.packages("lwgeom")
# install from GitHub
remotes::install_github("azvoleff/gfcanalysis")
remotes::install_github("r-spatialecology/landscapetools")
remotes::install_github("statnmap/cartomisc")
