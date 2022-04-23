library(tidyverse)
library(rvest)
library(janitor)

parse_table <- function(year) {
    url_base <- "https://www.oica.net/category/production-statistics/"
    url <- paste0(url_base, year, "-statistics/")
    df <- read_html(url) %>%
        html_table(header = TRUE, trim = TRUE)
    df <- clean_names(df[[1]]) %>%
        mutate(year = year)
    return(df)
}

tables <- lapply(seq(2006, 2021), parse_table)

production <- do.call(rbind, tables) %>%
    mutate(
        country = str_to_title(country_region),
        pv = parse_number(cars),
        cv = parse_number(commercial_vehicles, na = c("N.A.", "-"))) %>%
    select(year, country, pv, cv) %>%
    filter(! country %in% c("Total", "Totals")) %>%
    pivot_longer(
        names_to = "type",
        values_to = "n",
        pv:cv
    ) %>%
    # Harmonize some country names
    mutate(
        country = case_when(
            country == "Czech Rep." ~ "Czech Republic",
            country == "Usa" ~ "USA",
            country == "Uk" ~ "United Kingdom",
            country == "Supplementary" ~ "Others",
            TRUE ~ country
        )
    )

# Save as csv
write_csv(production, file.path("data-raw", "production.csv"))

# Save the datasets
usethis::use_data(production, overwrite = TRUE)
