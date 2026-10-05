# Reproduce all figures from the source data.
# Run from the project root (open vhs_sociology.Rproj in RStudio first).

source("00_Get_Data.R")      # download Korte (2026) from Zenodo into files/zenodo/
source("01_Data_Import.R")   # build the analysis data in files/*.RDS
rmarkdown::render("02_Visual_Analysis.Rmd")  # draw results/Fig1-4.png
