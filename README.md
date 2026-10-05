# The waning role of sociology in adult learning?

**Comparative disciplinary language in course offerings at German adult education centers since the 1950s**

Nate Breznau and Jasper Korte
German Institute for Adult Education – Leibniz Centre for Lifelong Learning (DIE), Bonn, Germany

This repository contains the code and data to reproduce the figures in the paper. The paper compares how often sociology, economics and anthropology appear in the program brochures of German adult education centers (Volkshochschulen, VHS) from 1957 to 2024, and how many people enrolled in courses in those fields from 1977 to 2017.

## Data

All analyses use one source dataset:

> Korte, Jasper. 2026. *VHS Mining Ethnology, Sociology, and Economics.* Zenodo. https://doi.org/10.5281/zenodo.19063510

It combines two DIE data infrastructures:

- **VHS programme archive** ([Programmplanarchiv](https://www.die-bonn.de/weiterbildung/archive/Programmplanarchive/default.aspx)): yearly counts of brochures and pages that contain discipline-specific vocabulary, from text mining about 6,100 digitized brochures, 1946–2024. Files `Ethnology.csv`, `Sociology.csv`, `Economics.csv`.
- **VHS statistics** ([VHS-Statistik](https://www.die-bonn.de/weiterbildung/statistik/vhs-statistik)): national yearly courses, teaching hours and enrollments by subject field. Files `Courses_*.csv`, `Hours_*.csv`, `Enrollments_*.csv`. Subject fields are reported from 1977 and change in 2018, so the paper uses 1977–2017.

The data are not stored in this repository. `00_Get_Data.R` downloads them from Zenodo into `files/zenodo/` and checks every file against Zenodo's checksums.

**While the Zenodo record is unpublished**, it can only be read with a share-link token. Ask the authors for the link, then set the token (the part after `token=`) before running the scripts. Never commit it.

```r
Sys.setenv(ZENODO_TOKEN = "<token>")
```

Once the record is published, no token is needed.

## Reproducing the figures

Requirements: R (4.1 or later) with the packages `tidyverse`, `jsonlite`, `zoo`, `viridis`, `ragg`, `ggpubr`, `knitr` and `rmarkdown`.

Open `vhs_sociology.Rproj` in RStudio, then run:

```r
source("run_all.R")
```

or step by step:

| Step | Script | Input | Output |
| --- | --- | --- | --- |
| 1 | `00_Get_Data.R` | Zenodo record 19063511 | `files/zenodo/*.csv`, `zenodo_manifest.txt` |
| 2 | `01_Data_Import.R` | `files/zenodo/*.csv` | `files/df_*.RDS` |
| 3 | `02_Visual_Analysis.Rmd` | `files/df_*.RDS` | `results/Fig1.png` to `Fig4.png` |

| Figure | Shows | Data |
| --- | --- | --- |
| Fig. 1 | Share of brochures and pages with discipline vocabulary per year, 1957–2024 (4-year rolling mean) | `Ethnology.csv`, `Sociology.csv`, `Economics.csv` |
| Fig. 2 | Enrollments in sociology, economics and country studies as a percent of enrollments, by period, 1977–2017 | `Enrollments_1962-2017.csv` |
| Fig. 3 | Each discipline's brochure hits split across four periods, 1946–2024 | `Ethnology.csv`, `Sociology.csv`, `Economics.csv` |
| Fig. 4 | Mean courses per year in each field, by period, 1977–2017 | `Courses_1962-2017.csv` |

## Repository layout

```
00_Get_Data.R            download source data from Zenodo
01_Data_Import.R         build analysis data
02_Visual_Analysis.Rmd   draw the figures
run_all.R                run all three steps
files/                   derived .RDS files
files/zenodo/            downloaded Zenodo files (not tracked)
archive/                 files no longer used by the pipeline
results/                 figures used in the paper
```

## License

Code and derived data are released under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). The source data are released on Zenodo under CC BY 4.0.

## Citation

Breznau, Nate, and Jasper Korte. *The waning role of sociology in adult learning? Comparative disciplinary language in course offerings at German adult education centers since the 1950s.* Working paper.
