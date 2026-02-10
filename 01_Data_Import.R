library("tidyverse")
library("readxl")

rows1 <- c(
  "Number of adult education centers",
  "Number of years",
  "Number of programs",
  "Number of pages",
  "Total occurrences",
  "Total dependencies",
  "Total collocations",
  "Programs per year",
  "Pages per program",
  "Occurrences per page",
  "Dependencies per occurrence",
  "Collocations per occurrence"
)

# Anthropology
df_anthro <- as.data.frame(read_xlsx("files/Ergebnis_Eingehen_Sowi_VHS.xlsx", sheet = "Ethnologie", 
                       skip = 1, col_names = T, range = "D2:K14"))

rownames(df_anthro) <- rows1
colnames(df_anthro) <- c(colnames(df_anthro)[1], "pct1", colnames(df_anthro)[3], "pct2", 
                         colnames(df_anthro)[5], "pct3", colnames(df_anthro)[7], "pct4")

#Sociology
df_soc <- as.data.frame(read_xlsx("files/Ergebnis_Eingehen_Sowi_VHS.xlsx", sheet = "Soziologie", 
                                     skip = 1, col_names = T, range = "D2:K14"))

rownames(df_soc) <- rows1
colnames(df_soc) <- c(colnames(df_soc)[1], "pct1", colnames(df_soc)[3], "pct2", 
                      colnames(df_soc)[5], "pct3", colnames(df_soc)[7], "pct4")

#Economics
df_econ <- as.data.frame(read_xlsx("files/Ergebnis_Eingehen_Sowi_VHS.xlsx", sheet = "Ökonomik", 
                                  skip = 1, col_names = T, range = "D2:K14"))

rownames(df_econ) <- rows1
colnames(df_econ) <- c(colnames(df_econ)[1], "pct1", colnames(df_econ)[3], "pct2", 
                       colnames(df_econ)[5], "pct3", colnames(df_econ)[7], "pct4")

#Participation
df_part <- as.data.frame(read_xlsx("files/Ergebnis_Eingehen_Sowi_VHS.xlsx", sheet = "Tabellen_VHS_Statistik", 
                                   col_names = T, range = "E16:G21")) %>%
  #extract percentage and convert to numeric
  mutate(across(
    everything(),
    ~ .x %>%
      str_extract("\\(([^%]+)%\\)") %>%   # extract number inside ()
      str_remove_all("[()]") %>%           # remove parentheses
      readr::parse_number(
        locale = locale(decimal_mark = ",", grouping_mark = ".")
      )
  ))

rownames(df_part) <- c("1977-1979",
                       "1980-1989",
                       "1990-1999",
                       "2000-2009",
                       "2010-2017")

colnames(df_part) <- c("Soc", "Econ", "Cultural")

df_part <- select(df_part, Cultural, Soc, Econ)

write_rds(df_anthro, "files/df_anthro.RDS")
write_rds(df_soc, "files/df_soc.RDS")
write_rds(df_econ, "files/df_econ.RDS")
write_rds(df_part, "files/df_part.RDS")

