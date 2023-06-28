# Biodiversity Intactness Index (BII)
# Tim Newbold; Lawrence Hudson; Andy Arnell; Sara Contu et al. (2016). Global map of the Biodiversity Intactness Index, from Newbold et al. (2016) Science [Data set]. Natural History Museum.
# doi: https://doi.org/10.5519/0009936
# data: https://data.nhm.ac.uk/dataset/global-map-of-the-biodiversity-intactness-index-from-newbold-et-al-2016-science
# visual: https://resourcewatch.org/data/explore/bio_014-Biodiversity-Intactness
ES_BIO1a <- function(locations, ...) {
    bii <- rast("data/Biodiversity/Biodiversity_Intactness_Index/BII.asc") # nolint
    locations$cnt <- exact_extract(bii, locations, "sum", progress = TRUE)
    locations$val <- locations$cnt / locations$area
    # my_map(data = aoi, "ADM2_EN", "norm", "ES_BIO1a Biodiversity Intactness", "Greens")
    return(locations)
}

# Mean Species Abundance (MSA)
# https://www.globio.info/globio-data-downloads
# https://dataportaal.pbl.nl/downloads/GLOBIO/Schipper_etal_2020/2015/Globio4_TerrestrialMSA_10sec_2015.zip
ER_BIO2 <- function(locations, ...) {
    msa <- rast("data/Biodiversity/Globio4_TerrestrialMSA_10sec_2015/TerrestrialMSA_2015_World.tif") # nolint
    locations$cnt <- exact_extract(msa, locations, "sum", progress = TRUE)
    locations$val <- locations$cnt / locations$area
    return(locations)
}

# Ecosystem Functionality Index (EFI)
# Paper: https://www.sciencedirect.com/science/article/abs/pii/S1476945X12000669
# doi: https://doi.org/10.1016/j.ecocom.2012.08.002
# https://catalog.ipbes.net/assessments/200
ER_ECO1 <- function(locations, ...) {
    efi <- rast("data/Biodiversity/Ecosystem_Functionality_Index/EFI.tif") # nolint
    locations$cnt <- exact_extract(efi, locations, "sum", progress = TRUE)
    locations$val <- locations$cnt / locations$area
    return(locations)
}

# Other data sources

# Endangered species
# https://www.iucnredlist.org/search/map?permalink=db4ccf05-aea7-4657-8e08-23a4f6c565b9

# Protected Areas
# https://api.protectedplanet.net/documentation

# Key Biodiversity Areas
# https://www.keybiodiversityareas.org/kba-data/request
