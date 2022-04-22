setwd('/Users/jhelvy/Dropbox/research/data/cars/oica/production/')

library(jhelvyr)
multiLibrary(c("ggplot2", "dplyr", "tidyr"))

# Import data
pcDataFile    ='./data/pcByCountry.csv'
totalDataFile ='./data/totalByCountry.csv'
pcData        = read.csv(pcDataFile, header=T, stringsAsFactors=F)
totalData     = read.csv(totalDataFile, header=T, stringsAsFactors=F)

# Format data for plotting
pcData = pcData %>%
    gather(year, pcProduction, X1999:X2016) %>%
    separate(year, into=c('drop', 'year'), sep='X') %>%
    select(-drop)
totalData = totalData %>%
    gather(year, totalProduction, X1999:X2016) %>%
    separate(year, into=c('drop', 'year'), sep='X') %>%
    select(-drop)
data = pcData %>%
    left_join(totalData) %>%
    mutate(cvProduction=totalProduction - pcProduction) %>%
    select(country, year, pcProduction, cvProduction, totalProduction)

write.csv(data, file='./data/productionData.csv', row.names=F)







# Save the datasets
usethis::use_data(cars_us, overwrite = TRUE)
usethis::use_data(cars_china, overwrite = TRUE)
