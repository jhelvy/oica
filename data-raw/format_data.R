library(tidyverse)
library(rvest)
library(janitor)
library(readxl)
options(dplyr.width = Inf)

# Standard country / area codes from UN

world_regions <- read_excel(
    file.path('data-raw', 'raw', 'un_country_data.xlsx')) %>%
    clean_names() %>%
    select(
        country = country_or_area,
        region = region_name,
        subregion = sub_region_name,
        intermediate_region = intermediate_region_name,
        least_developed = least_developed_countries_ldc,
        land_locked_developing = land_locked_developing_countries_lldc,
        small_island_developing = small_island_developing_states_sids,
        code_region = region_code,
        code_subregion = sub_region_code,
        code_intermediate_region = intermediate_region_code,
        code_m49 = m49_code,
        code_iso_alpha2 = iso_alpha2_code,
        code_iso_alpha3 = iso_alpha3_code
    ) %>%
    mutate(
        least_developed = ifelse(is.na(least_developed), 0, 1),
        land_locked_developing = ifelse(is.na(land_locked_developing), 0, 1),
        small_island_developing = ifelse(is.na(small_island_developing), 0, 1)
    ) %>%
    # Make column for mis-matching country names to match OICA names
    mutate(
        country_oica = case_when(
            country == 'Bolivia (Plurinational State of)' ~ 'Bolivia',
            country == 'Bosnia and Herzegovina' ~ 'Bosnia',
            country == 'Brunei Darussalam' ~ 'Brunei',
            country == 'China, Hong Kong Special Administrative Region' ~ 'Hong Kong',
            country == 'Czechia' ~ 'Czech Republic',
            country == 'Iran (Islamic Republic of)' ~ 'Iran',
            country == "Lao People's Democratic Republic" ~ 'Laos',
            country == 'Republic of Korea' ~ 'South Korea',
            country == 'Republic of Moldova' ~ 'Moldova',
            country == 'Réunion' ~ 'Reunion',
            country == 'Russian Federation' ~ 'Russia',
            country == 'State of Palestine' ~ 'Palestine',
            country == 'Syrian Arab Republic' ~ 'Syria',
            country == 'United Kingdom of Great Britain and Northern Ireland' ~ 'United Kingdom',
            country == 'United Republic of Tanzania' ~ 'Tanzania',
            country == 'United States of America' ~ 'USA',
            country == 'Venezuela (Bolivarian Republic of)' ~ 'Venezuela',
            country == 'Viet Nam' ~ 'Vietnam',
            TRUE ~ country
        )
    ) %>%
    # Add Taiwan
    rbind(data.frame(
        country = 'Taiwan',
        region = 'Asia',
        subregion = 'Eastern Asia',
        intermediate_region = NA,
        least_developed = 0,
        land_locked_developing = 0,
        small_island_developing = 0,
        code_region = 142,
        code_subregion = 30,
        code_intermediate_region = NA,
        code_m49 = NA,
        code_iso_alpha2 = 'CN-TW',
        code_iso_alpha3 = 'TWN',
        country_oica = 'Taiwan'
    ))

write_csv(world_regions, file.path("data-raw", "world_regions.csv"))




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
    ) %>%
    # Join region data
    left_join(
        world_regions %>%
            select(-country) %>%
            rename(country = country_oica),
        by = 'country')

# Save as csv
write_csv(production, file.path("data-raw", "production.csv"))



# Sales Data ----

# Raw data downloaded from
# https://www.oica.net/category/sales-statistics/

# pc = passenger cars
# cv = commercial vehicles

# 2005 - 2019

pc <- read_excel(file.path('data-raw', 'raw', 'pc-sales-2019.xlsx'), skip = 5)
pc$country <- str_to_title(pc$'REGIONS/COUNTRIES')
pc <- pc %>%
    gather(year, sales, '2005':'2019') %>%
    select(country, year, sales) %>%
    mutate(type = 'pc')
cv <- read_excel(file.path('data-raw', 'raw', 'cv-sales-2019.xlsx'), skip = 5)
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
pc <- read_excel(file.path('data-raw', 'raw', 'pc-sales-2021.xlsx'), skip = 3)
pc$country <- str_to_title(pc$'REGIONS/COUNTRIES')
pc <- pc %>%
    gather(year, sales, 'Q1-Q4 2019':'Q1-Q4 2021') %>%
    select(country, year, sales) %>%
    mutate(type = 'pc')
cv <- read_excel(file.path('data-raw', 'raw', 'cv-sales-2021.xlsx'), skip = 3)
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

# Merge years and fix country name irregularities
df <- rbind(df_05_19, df_20_21) %>%
    mutate(
        country = case_when(
            country == 'Switzerland (+Fl)' ~ 'Switzerland',
            country == 'Congo Kinshasa' ~ 'Congo',
            country == 'Moldavia' ~ 'Moldova',
            country == 'United States Of America' ~ 'USA',
            country == 'Azerbaidjan' ~ 'Azerbaijan',
            country == 'Cambodge' ~ 'Cambodia',
            country == 'Hong-Kong' ~ 'Hong Kong',
            country == 'Irak' ~ 'Iraq',
            country == 'Kazakstan' ~ 'Kazakhstan',
            country == 'Kirghizistan' ~ 'Kyrgyzstan',
            country == 'Tadjikistan' ~ 'Tajikistan',
            country == 'Tahiti French Polynesia' ~ 'French Polynesia',
            country == 'Tahiti' ~ 'French Polynesia',
            country == 'Tukmenistan' ~ 'Turkmenistan',
            country == 'Trinidad' ~ 'Trinidad and Tobago',
            country == 'Burkina' ~ 'Burkina Faso',
            country == 'Guiana (French)' ~ 'French Guiana',
            country == 'Guiana' ~ 'French Guiana',
            country == 'Bulgaria1' ~ 'Bulgaria',
            country == 'Mexico2' ~ 'Mexico',
            TRUE ~ country
        )
    )

# Join region data
df <- df %>%
    left_join(
    world_regions %>%
        select(-country) %>%
        rename(country = country_oica),
    by = 'country') %>%
    select(year, country, type, n = sales, everything())

# Separate out countries and regions
sales_region <- df %>%
    filter(is.na(region) == TRUE) %>%
    select(year, region = country, type, n) %>%
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
