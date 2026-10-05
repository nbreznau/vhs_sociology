# The waning role of sociology in adult learning?

**Comparative disciplinary language in course offerings at German adult education centers since the 1950s**

Nate Breznau and Jasper Korte
German Institute for Adult Education – Leibniz Centre for Lifelong Learning (DIE), Bonn, Germany

This repository contains the code and data to reproduce the figures in the paper. The paper compares how often sociology, economics and anthropology appear in the program brochures of German adult education centers (Volkshochschulen, VHS) from 1957 to 2024, and how many people enrolled in courses in those fields from 1977 to 2017.

## Data

All analyses use one source dataset:

> Korte, Jasper. 2026. *VHS Mining Ethnology, Sociology, and Economics.* Zenodo. https://doi.org/10.5281/zenodo.19063510

It combines two DIE data infrastructures:

- **VHS programme archive** ([Programmplanarchiv](https://www.die-bonn.de/weiterbildung/archive/Programmplanarchive/default.aspx)): yearly counts of brochures and pages that contain discipline-specific vocabulary, from text mining about 6,100 digitized brochures. Sheets `Ethnology`, `Sociology` and `Economics`.
- **VHS statistics** ([VHS-Statistik](https://www.die-bonn.de/weiterbildung/statistik/vhs-statistik)): national yearly courses, teaching hours and enrollments by subject field. Sheets `VHS Statistics 1962-2017` and `VHS Statistics 2018-2024`. Subject fields change in 2018, so the paper uses 1977–2017.

`00_Get_Data.R` downloads the current Zenodo version into `files/zenodo/` and checks it against Zenodo's checksums. `files/Repository.xlsx` is a frozen copy of an earlier Zenodo version, kept so the code runs offline; `01_Data_Import.R` uses it only when no downloaded workbook is present.

## Reproducing the figures

Requirements: R (4.1 or later) with the packages `tidyverse`, `readxl`, `jsonlite`, `zoo`, `viridis`, `ragg`, `ggpubr`, `knitr`, `rmarkdown` and `pacman`.

Open `vhs_sociology.Rproj` in RStudio, then run:

```r
source("run_all.R")
```

or step by step:

| Step | Script | Input | Output |
| --- | --- | --- | --- |
| 1 | `00_Get_Data.R` | Zenodo record | `files/zenodo/*.xlsx`, `zenodo_manifest.txt` |
| 2 | `01_Data_Import.R` | the workbook from step 1 (or `files/Repository.xlsx`) | `files/df_*.RDS` |
| 3 | `02_Visual_Analysis.Rmd` | `files/df_*.RDS` | `results/Fig1.png` to `Fig4.png` |

| Figure | Shows | Data |
| --- | --- | --- |
| Fig. 1 | Share of brochures and pages with discipline vocabulary per year, 1957–2024 (4-year rolling mean) | Programme archive |
| Fig. 2 | Enrollments in sociology, economics and country studies as a percent of enrollments, by period, 1977–2017 | VHS statistics |
| Fig. 3 | Each discipline's brochure hits split across four periods | Programme archive |
| Fig. 4 | Mean courses per year in each field, by period, 1977–2017 | VHS statistics |

## Repository layout

```
00_Get_Data.R            download source data from Zenodo
01_Data_Import.R         build analysis data
02_Visual_Analysis.Rmd   draw the figures
run_all.R                run all three steps
files/                   Repository.xlsx snapshot and derived .RDS files
files/zenodo/            downloaded Zenodo files (not tracked)
results/                 figures used in the paper
```

## License

Code and derived data are released under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). The source data are subject to the license stated on the Zenodo record.

## Citation

Breznau, Nate, and Jasper Korte. *The waning role of sociology in adult learning? Comparative disciplinary language in course offerings at German adult education centers since the 1950s.* Working paper.
