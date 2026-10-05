library("tidyverse")

# Source data: Korte (2026), Zenodo, doi:10.5281/zenodo.19063510.
# Run 00_Get_Data.R first; it downloads the CSV files into files/zenodo/.
zenodo_dir <- "files/zenodo"

zenodo_file <- function(name) {
  path <- file.path(zenodo_dir, name)
  if (!file.exists(path)) stop(path, " not found. Run 00_Get_Data.R first.", call. = FALSE)
  path
}

# Zenodo CSVs are semicolon-separated, UTF-8 with BOM, decimal comma
zenodo_locale <- locale(decimal_mark = ",", encoding = "UTF-8")

# Text-mining tables: one row per measure, one column per year (1946-2024)
read_mining <- function(name) {
  read_delim(zenodo_file(name), delim = ";", locale = zenodo_locale,
             col_types = cols(.default = col_character()), name_repair = "minimal") %>%
    rename(Variable = 1)
}

# VHS statistics tables: one row per year, one column per subject field
read_stats <- function(name) {
  read_delim(zenodo_file(name), delim = ";", locale = zenodo_locale,
             col_types = cols(.default = col_double()))
}

assign_period <- function(Year) {
  case_when(
    Year <= 1979 ~ "1977-1979",
    Year <= 1989 ~ "1980-1989",
    Year <= 1999 ~ "1990-1999",
    Year <= 2009 ~ "2000-2009",
    Year <= 2017 ~ "2010-2017"
  )
}

mining <- list(
  Anthropology = read_mining("Ethnology.csv"),
  Sociology    = read_mining("Sociology.csv"),
  Economics    = read_mining("Economics.csv")
)

# Long format: Year, discipline, Variable, value (numeric rows only)
mining_long <- imap_dfr(mining, function(df, disc) {
  df %>%
    filter(Variable %in% c("Programmes", "Programmes relative", "Pages", "Pages relative")) %>%
    pivot_longer(-Variable, names_to = "Year", values_to = "value") %>%
    mutate(
      Year = as.numeric(Year),
      value = parse_double(value, locale = zenodo_locale),
      discipline = disc
    )
})

# -------------------------------------------------------------------------
# 1. Overall changes per year (Fig 1)
# -------------------------------------------------------------------------

df_between <- mining_long %>%
  filter(Variable %in% c("Programmes relative", "Pages relative"), Year > 1956) %>%
  mutate(measure = if_else(Variable == "Programmes relative", "Program results", "Page results")) %>%
  select(Year, discipline, measure, value) %>%
  arrange(Year, discipline, measure)

write_rds(df_between, "files/df_between.RDS")

# -------------------------------------------------------------------------
# 2. Within-discipline statistics (Fig 3) - Calculated from raw Programmes
# -------------------------------------------------------------------------

# Share of each discipline's brochure hits (all years, 1946-2024) that falls
# in each period
df_fig3 <- mining_long %>%
  filter(Variable == "Programmes", !is.na(value)) %>%
  mutate(
    period = case_when(
      Year < 1970 ~ "Pre_1970",
      Year <= 1989 ~ "1970_1989",
      Year <= 2009 ~ "1990_2009",
      TRUE ~ "2010_2024"
    ),
    discipline = recode(discipline, Anthropology = "Anth", Sociology = "Soc", Economics = "Econ")
  ) %>%
  group_by(discipline, period) %>%
  summarise(period_sum = sum(value), .groups = "drop_last") %>%
  mutate(
    value = period_sum / sum(period_sum) * 100,
    measure = "Program rates"
  ) %>%
  ungroup() %>%
  select(period, value, discipline, measure) %>%
  # Lock in the factor levels so the x-axis plots in chronological order
  mutate(
    period = factor(period, levels = c("Pre_1970", "1970_1989", "1990_2009", "2010_2024")),
    discipline = factor(discipline, levels = c("Anth", "Soc", "Econ"))
  ) %>%
  arrange(discipline, period)

write_rds(df_fig3, "files/df_fig3.RDS")

# -------------------------------------------------------------------------
# 3. Participation (Fig 2) - Enrollments, 1977-2017
# -------------------------------------------------------------------------

# Subject fields are only reported from 1977; field categories change in 2018
enroll <- read_stats("Enrollments_1962-2017.csv") %>%
  filter(Year >= 1977, Year <= 2017) %>%
  mutate(period = assign_period(Year))

# Percent of all VHS enrollments
df_part <- enroll %>%
  group_by(period) %>%
  summarise(
    Cultural = mean(`Country studies/Geography` / `All courses` * 100),
    Soc = mean(Sociology / `All courses` * 100),
    Econ = mean(Economy / `All courses` * 100)
  ) %>%
  as.data.frame() %>%
  column_to_rownames("period")

write_rds(df_part, "files/df_part.RDS")

# Percent of enrollments in the Society/Politics/Environment program area.
# These are the values the manuscript text currently quotes for Figure 2
# (about 5% for sociology in 1977-1989).
df_part_area <- enroll %>%
  group_by(period) %>%
  summarise(
    Cultural = mean(`Country studies/Geography` / `Society/Politics/Environment` * 100),
    Soc = mean(Sociology / `Society/Politics/Environment` * 100),
    Econ = mean(Economy / `Society/Politics/Environment` * 100)
  ) %>%
  as.data.frame() %>%
  column_to_rownames("period")

write_rds(df_part_area, "files/df_part_area.RDS")

# -------------------------------------------------------------------------
# 4. Absolute Means (Fig 4) - Courses, 1977-2017
# -------------------------------------------------------------------------

df_enroll <- read_stats("Courses_1962-2017.csv") %>%
  filter(Year >= 1977, Year <= 2017) %>%
  mutate(period = assign_period(Year)) %>%
  group_by(period) %>%
  summarise(
    # Mean number of courses per year in each period
    Cultural = mean(`Country studies/Geography`),
    Soc = mean(Sociology),
    Econ = mean(Economy)
  ) %>%
  as.data.frame() %>%
  column_to_rownames("period")

write_rds(df_enroll, "files/df_enroll.RDS")
