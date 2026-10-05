# Archive

Files no longer used by the pipeline, kept for reference.

- `df_anthro.RDS`, `df_econ.RDS`, `df_soc.RDS`: period summaries built from the old `Ergebnis_Eingehen_Sowi_VHS.xlsx` workbook (removed in commit 7e67b1d; still in git history). Nothing in the current code reads them.
- `Repository.xlsx`: an earlier Excel copy of the Korte (2026) Zenodo data. Replaced by the CSV files that `00_Get_Data.R` downloads from Zenodo. Compared on 2026-10-05: every value matches the current Zenodo CSVs; the only difference is a single 1932 Sociology brochure that Zenodo no longer includes.
