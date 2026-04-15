library("tidyverse")
library("readxl")

# From Korte 2026 Zenodo
data_file <- "files/Repository.xlsx"

# 1. Overall changes per year (Fig 1)

#dynamically extract  time series rows
extract_fig1_data <- function(sheet_name, disc_name) {
  df <- read_xlsx(data_file, sheet = sheet_name)
  
  # Standardize the first column name to 'Variable' to allow safe pivoting
  colnames(df)[1] <- "Variable"
  
  df %>%
    filter(Variable %in% c("Programmes relative", "Pages relative")) %>%
    pivot_longer(cols = -Variable, names_to = "Year", values_to = "value") %>%
    mutate(
      Year = suppressWarnings(as.numeric(Year)),
      # FORCE VALUE TO BE NUMERIC HERE:
      value = suppressWarnings(as.numeric(value)),
      discipline = disc_name,
      measure = if_else(Variable == "Programmes relative", "Program results", "Page results")
    ) %>%
    filter(!is.na(Year) & Year > 1956) %>%
    select(Year, discipline, measure, value)
}

df_between <- bind_rows(
  extract_fig1_data("Ethnology", "Anthropology"),
  extract_fig1_data("Sociology", "Sociology"),
  extract_fig1_data("Economics", "Economics")
) %>%
  arrange(Year, discipline, measure)

write_rds(df_between, "files/df_between.RDS")

# -------------------------------------------------------------------------
# 2. Within-discipline statistics (Fig 3) - Calculated from raw Programmes
# -------------------------------------------------------------------------

# Helper function to dynamically calculate period percentages
extract_fig3_data <- function(sheet_name, disc_name) {
  df <- read_xlsx(data_file, sheet = sheet_name)
  colnames(df)[1] <- "Variable"
  
  df %>%
    # Isolate the raw Programmes counts
    filter(Variable == "Programmes") %>%
    pivot_longer(cols = -Variable, names_to = "Year", values_to = "count") %>%
    mutate(
      Year = suppressWarnings(as.numeric(Year)),
      count = suppressWarnings(as.numeric(count))
    ) %>%
    filter(!is.na(Year) & !is.na(count)) %>%
    # Assign years to their respective periods
    mutate(
      period = case_when(
        Year < 1970 ~ "Pre_1970",
        Year >= 1970 & Year <= 1989 ~ "1970_1989",
        Year >= 1990 & Year <= 2009 ~ "1990_2009",
        Year >= 2010 ~ "2010_2024"
      )
    ) %>%
    # 1. Add the total score of Programme for each period
    group_by(period) %>%
    summarise(period_sum = sum(count, na.rm = TRUE)) %>%
    ungroup() %>%
    # 2. Divide by the total for the discipline and multiply by 100
    mutate(
      total_sum = sum(period_sum, na.rm = TRUE),
      value = (period_sum / total_sum) * 100,
      discipline = disc_name,
      measure = "Program rates"
    ) %>%
    select(period, value, discipline, measure)
}

# Bind the calculated data for all three disciplines
df_fig3 <- bind_rows(
  extract_fig3_data("Ethnology", "Anth"),
  extract_fig3_data("Sociology", "Soc"),
  extract_fig3_data("Economics", "Econ")
) %>%
  # Lock in the factor levels so the x-axis plots in chronological order
  mutate(
    period = factor(period, levels = c("Pre_1970", "1970_1989", "1990_2009", "2010_2024")),
    discipline = factor(discipline, levels = c("Anth", "Soc", "Econ"))
  )

write_rds(df_fig3, "files/df_fig3.RDS")


# -------------------------------------------------------------------------
# 3. Participation (Fig 2) - Using ENROLLMENTS Data (3rd occurrence)
# -------------------------------------------------------------------------

df_enroll_raw <- read_xlsx(data_file, sheet = "VHS Statistics 1962-2017", skip = 1, .name_repair = "unique")
cols <- colnames(df_enroll_raw)

col_total_enr <- cols[grep("All courses", cols)][3]
col_econ_enr  <- cols[grep("Economy", cols)][3]
col_soc_enr   <- cols[grep("Sociology", cols)][3]
col_cult_enr  <- cols[grep("Country studies/Geography", cols)][3]

df_part <- df_enroll_raw %>%
  select(
    Year = 1, 
    Total_Enrollments = all_of(col_total_enr), 
    Econ_Enr = all_of(col_econ_enr), 
    Soc_Enr = all_of(col_soc_enr), 
    Cult_Enr = all_of(col_cult_enr)
  ) %>%
  mutate(
    Year = suppressWarnings(as.numeric(Year)),
    Total_Enrollments = suppressWarnings(as.numeric(Total_Enrollments)),
    Econ_Enr = suppressWarnings(as.numeric(Econ_Enr)),
    Soc_Enr = suppressWarnings(as.numeric(Soc_Enr)),
    Cult_Enr = suppressWarnings(as.numeric(Cult_Enr))
  ) %>%
  filter(!is.na(Year) & Year >= 1977 & Year <= 2017) %>%
  mutate(
    period = case_when(
      Year <= 1979 ~ "1977-1979",
      Year <= 1989 ~ "1980-1989",
      Year <= 1999 ~ "1990-1999",
      Year <= 2009 ~ "2000-2009",
      Year <= 2017 ~ "2010-2017"
    )
  ) %>%
  group_by(period) %>%
  summarise(
    Soc = mean(Soc_Enr / Total_Enrollments * 100, na.rm = TRUE),
    Econ = mean(Econ_Enr / Total_Enrollments * 100, na.rm = TRUE),
    Cultural = mean(Cult_Enr / Total_Enrollments * 100, na.rm = TRUE)
  ) %>%
  as.data.frame() %>%
  column_to_rownames("period")

df_part <- select(df_part, Cultural, Soc, Econ)
write_rds(df_part, "files/df_part.RDS")


# -------------------------------------------------------------------------
# 4. Absolute Means (Fig 4) - Using COURSES Data (1st occurrence)
# -------------------------------------------------------------------------

col_total_crs <- cols[grep("All courses", cols)][1]
col_econ_crs  <- cols[grep("Economy", cols)][1]
col_soc_crs   <- cols[grep("Sociology", cols)][1]
col_cult_crs  <- cols[grep("Country studies/Geography", cols)][1]

df_enroll <- df_enroll_raw %>%
  select(
    Year = 1,
    Total_Courses = all_of(col_total_crs),
    Economics = all_of(col_econ_crs), 
    Sociology = all_of(col_soc_crs),
    `Cultural studies` = all_of(col_cult_crs)
  ) %>%
  mutate(
    # columns to numeric
    Year = suppressWarnings(as.numeric(Year)),
    Total_Courses = suppressWarnings(as.numeric(Total_Courses)),
    Economics = suppressWarnings(as.numeric(Economics)),
    Sociology = suppressWarnings(as.numeric(Sociology)),
    `Cultural studies` = suppressWarnings(as.numeric(`Cultural studies`))
  ) %>%
  filter(!is.na(Year) & Year >= 1977 & Year <= 2017) %>%
  mutate(
    period = case_when(
      Year <= 1979 ~ "1977-1979",
      Year <= 1989 ~ "1980-1989",
      Year <= 1999 ~ "1990-1999",
      Year <= 2009 ~ "2000-2009",
      Year <= 2017 ~ "2010-2017"
    )
  ) %>%
  group_by(period) %>%
  summarise(
    # Calculate the mean number of courses per year for each period
    Soc = mean(Sociology, na.rm = TRUE),
    Econ = mean(Economics, na.rm = TRUE),
    Cultural = mean(`Cultural studies`, na.rm = TRUE)
  ) %>%
  as.data.frame() %>%
  column_to_rownames("period")

# Periods to match Figure 2 
df_enroll <- select(df_enroll, Cultural, Soc, Econ)

write_rds(df_enroll, "files/df_enroll.RDS")