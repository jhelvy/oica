library(tidyverse)
library(rvest)
library(janitor)
library(readxl)
options(dplyr.width = Inf)

# Production Data ----

# Function for scraping the production data table out of the web page
# for a given year
parse_table <- function(year) {
    url_base <- "https://www.oica.net/category/production-statistics/"
    url <- paste0(url_base, year, "-statistics/")
    df <- read_html(url) %>%
        html_table(header = TRUE, trim = TRUE)
    df <- clean_names(df[[1]]) %>%
        mutate(year = year)
    return(df)
}

# Get all the tables
tables <- lapply(seq(2006, 2021), parse_table)

# Make the data frame
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



# Sales Data ----

# Raw data downloaded from
# https://www.oica.net/category/sales-statistics/

# pc = passenger cars
# cv = commercial vehicles

# 2005 - 2019

pc <- read_excel(file.path('data-raw', 'sales', 'pc-sales-2019.xlsx'), skip = 5)
pc$country <- str_to_title(pc$'REGIONS/COUNTRIES')
pc <- pc %>%
    gather(year, sales, '2005':'2019') %>%
    select(country, year, sales) %>%
    mutate(type = 'pc')
cv <- read_excel(file.path('data-raw', 'sales', 'cv-sales-2019.xlsx'), skip = 5)
cv$country <- str_to_title(cv$'REGIONS/COUNTRIES')
cv <- cv %>%
    gather(year, sales, '2005':'2019') %>%
    select(country, year, sales) %>%
    mutate(type = 'cv')
df_05_19 <- rbind(pc, cv) %>%
    filter(is.na(country)==F) %>%
    mutate(
        country = str_replace(country, '\\*', ''),
        year = as.numeric(year)) %>%
    # Drop footnote rows
    filter(
        country != '1 Only Lv',
        country != '2 Including Heavy Trucks, Buses And Coaches'
    )

# 2020 - 2021
pc <- read_excel(file.path('data-raw', 'sales', 'pc-sales-2021.xlsx'), skip = 3)
pc$country <- str_to_title(pc$'REGIONS/COUNTRIES')
pc <- pc %>%
    gather(year, sales, 'Q1-Q4 2019':'Q1-Q4 2021') %>%
    select(country, year, sales) %>%
    mutate(type = 'pc')
cv <- read_excel(file.path('data-raw', 'sales', 'cv-sales-2021.xlsx'), skip = 3)
cv$country <- str_to_title(cv$'REGIONS/COUNTRIES')
cv <- cv %>%
    gather(year, sales, 'Q1-Q4 2019':'Q1-Q4 2021') %>%
    select(country, year, sales) %>%
    mutate(type = 'cv')
df_20_21 <- rbind(pc, cv) %>%
    filter(is.na(country)==F) %>%
    mutate(
        country = str_replace(country, '\\*', ''),
        year = as.numeric(str_replace(year, "Q1-Q4 ", ""))) %>%
    filter(year > 2019)

# Merge years
df <- rbind(df_05_19, df_20_21)

# Fix country name irregularities
countryNames <- data.frame(
    country = c(
        'Switzerland (+Fl)', 'Congo Kinshasa', 'Moldavia',
        'United States Of America', 'Azerbaidjan', 'Cambodge',
        'Hong-Kong', 'Irak', 'Kazakstan', 'Kirghizistan', 'Tadjikistan',
        'Tahiti', 'Tukmenistan', 'Burkina', 'Guiana (French)', 'Guiana',
        'Bulgaria1', 'Mexico2'),
    goodName = c(
        'Switzerland', 'Congo', 'Moldova', 'United States',
        'Azerbaijan', 'Cambodia', 'Hong Kong', 'Iraq', 'Kazakhstan',
        'Kyrgyzstan', 'Tajikistan', 'French Polynesia',
        'Turkmenistan', 'Burkina Faso', 'French Guiana', 'French Guiana',
        'Bulgaria', 'Mexico'))
df <- df %>%
    left_join(countryNames, by = "country") %>%
    mutate(
        goodName=ifelse(is.na(goodName), country, as.character(goodName)),
        country=goodName) %>%
    select(-goodName)

# Add region and continent data
worldRegions <- read_csv(file.path('data-raw', 'worldRegions.csv'))
df <- df %>%
    left_join(worldRegions, by = "country") %>%
    arrange(year, country)

# Separate out countries and regions
sales_region <- df %>%
    filter(is.na(region) == T) %>%
    mutate(region = country) %>%
    select(region, year, sales, type) %>%
    mutate(
        region = ifelse(
            region %in% c(
                "Eu 27 Countries + Efta + Uk", "Eu 28 Countries + Efta"),
            "EU", region
        )
    ) %>%
    filter(! region %in% c('Eu 15 Countries + Efta', 'Europe New Members')) %>%
    arrange(region, year)

sales_country <- df %>%
    filter(is.na(region) == F) %>%
    arrange(country)

# Save data frames
write_csv(sales_country, file.path('data-raw', 'sales_country.csv'))
write_csv(sales_region, file.path('data-raw', 'sales_region.csv'))



# Save the datasets
usethis::use_data(production, overwrite = TRUE)
usethis::use_data(sales_country, overwrite = TRUE)
usethis::use_data(sales_region, overwrite = TRUE)
