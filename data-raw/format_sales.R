library(tidyverse)
library(readxl)
options(dplyr.width = Inf)

# 2005 - 2019
# Read in and merge the two data frames  
pc <- read_excel(file.path('salesData', 'raw', 'pc-sales-2019.xlsx'), skip = 5)
pc$country <- str_to_title(pc$'REGIONS/COUNTRIES')
pc <- pc %>%
    gather(year, sales, '2005':'2019') %>%
    select(country, year, sales) %>%
    mutate(type = 'pc')
cv <- read_excel(file.path('salesData', 'raw', 'cv-sales-2019.xlsx'), skip = 5)
cv$country <- str_to_title(cv$'REGIONS/COUNTRIES')
cv <- cv %>%
    gather(year, sales, '2005':'2019') %>%
    select(country, year, sales) %>%
    mutate(type = 'cv')
df19 <- rbind(pc, cv) %>%
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
pc <- read_excel(file.path('salesData', 'raw', 'pc-sales-2021.xlsx'), skip = 3)
pc$country <- str_to_title(pc$'REGIONS/COUNTRIES')
pc <- pc %>%
    gather(year, sales, 'Q1-Q4 2019':'Q1-Q4 2021') %>%
    select(country, year, sales) %>%
    mutate(type = 'pc')
cv <- read_excel(file.path('salesData', 'raw', 'cv-sales-2021.xlsx'), skip = 3)
cv$country <- str_to_title(cv$'REGIONS/COUNTRIES')
cv <- cv %>%
    gather(year, sales, 'Q1-Q4 2019':'Q1-Q4 2021') %>%
    select(country, year, sales) %>%
    mutate(type = 'cv')
df21 <- rbind(pc, cv) %>%
    filter(is.na(country)==F) %>%
    mutate(
        country = str_replace(country, '\\*', ''), 
        year = as.numeric(str_replace(year, "Q1-Q4 ", ""))) %>% 
    filter(year > 2019)

# Merge years
df <- rbind(df19, df21)

# Fix country name typos
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
worldRegions <- read_csv(file.path('regionsData', 'worldRegions.csv'))
df <- df %>%
    left_join(worldRegions, by = "country") %>%
    arrange(year, country)

# Separate out countries and regions
regions <- df %>%
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
countries <- df %>%
    filter(is.na(region) == F) %>% 
    arrange(country)

# Save data frames
write_csv(countries, file.path('salesData', 'salesDataByCountry.csv'))
write_csv(regions, file.path('salesData', 'salesDataByRegion.csv'))







# Save the datasets
usethis::use_data(cars_us, overwrite = TRUE)
usethis::use_data(cars_china, overwrite = TRUE)
