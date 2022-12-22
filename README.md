
<!-- README.md is generated from README.Rmd. Please edit that file -->

# oica <a href='https://jhelvy.github.io/oica/'><img src='man/figures/logo.png' align="right" style="height:139px;"/></a>

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/oica)](https://CRAN.R-project.org/package=oica)
<!-- badges: end -->

This package contains some tidy formatted data on vehicle production and
sales from the [Organisation Internationale des Constructeurs
d’Automobiles (OICA)](https://www.oica.net/) (English Name:
“International Organization of Motor Vehicle Manufacturers”). The data
sets are also merged with standard country / area codes come from the
[United Nations Statistics
Division](https://unstats.un.org/unsd/methodology/m49/overview/). The
package contains the following data sets:

| Name            | Description                                                                                               |
|-----------------|-----------------------------------------------------------------------------------------------------------|
| `production`    | Vehicle [production statistics](https://www.oica.net/category/production-statistics/) by country and type |
| `sales_country` | Vehicle [sales statistics](https://www.oica.net/category/sales-statistics/) by country and type           |
| `sales_region`  | Vehicle [sales statistics](https://www.oica.net/category/sales-statistics/) by region and type            |

## Installation

The current version is not yet on CRAN, but you can install it from
Github using the {remotes} library:

``` r
# install.packages("remotes")
remotes::install_github("jhelvy/oica")
```

Load the library with:

``` r
library("oica")
```

## Usage

Once loaded, you can work with any of the three data sets. You can find
out more about each data set using `?`, e.g., `?production`.

Here is a quick preview of each data frame:

``` r
head(production)
#>   year   country type      n   region                       subregion
#> 1 2006 Argentina   pv 263120 Americas Latin America and the Caribbean
#> 2 2006 Argentina   cv 168981 Americas Latin America and the Caribbean
#> 3 2006 Australia   pv 270000  Oceania       Australia and New Zealand
#> 4 2006 Australia   cv  60900  Oceania       Australia and New Zealand
#> 5 2006   Austria   pv 248059   Europe                  Western Europe
#> 6 2006   Austria   cv  26873   Europe                  Western Europe
#>   intermediate_region least_developed land_locked_developing
#> 1       South America               0                      0
#> 2       South America               0                      0
#> 3                <NA>               0                      0
#> 4                <NA>               0                      0
#> 5                <NA>               0                      0
#> 6                <NA>               0                      0
#>   small_island_developing code_region code_subregion code_intermediate_region
#> 1                       0          19            419                        5
#> 2                       0          19            419                        5
#> 3                       0           9             53                       NA
#> 4                       0           9             53                       NA
#> 5                       0         150            155                       NA
#> 6                       0         150            155                       NA
#>   code_m49 code_iso_alpha2 code_iso_alpha3
#> 1       32              AR             ARG
#> 2       32              AR             ARG
#> 3       36              AU             AUS
#> 4       36              AU             AUS
#> 5       40              AT             AUT
#> 6       40              AT             AUT
head(sales_country)
#>   year country type    n region       subregion intermediate_region
#> 1 2005 Albania   pc  800 Europe Southern Europe                <NA>
#> 2 2006 Albania   pc  800 Europe Southern Europe                <NA>
#> 3 2007 Albania   pc 1600 Europe Southern Europe                <NA>
#> 4 2008 Albania   pc 1600 Europe Southern Europe                <NA>
#> 5 2009 Albania   pc 1000 Europe Southern Europe                <NA>
#> 6 2010 Albania   pc 1600 Europe Southern Europe                <NA>
#>   least_developed land_locked_developing small_island_developing code_region
#> 1               0                      0                       0         150
#> 2               0                      0                       0         150
#> 3               0                      0                       0         150
#> 4               0                      0                       0         150
#> 5               0                      0                       0         150
#> 6               0                      0                       0         150
#>   code_subregion code_intermediate_region code_m49 code_iso_alpha2
#> 1             39                       NA        8              AL
#> 2             39                       NA        8              AL
#> 3             39                       NA        8              AL
#> 4             39                       NA        8              AL
#> 5             39                       NA        8              AL
#> 6             39                       NA        8              AL
#>   code_iso_alpha3
#> 1             ALB
#> 2             ALB
#> 3             ALB
#> 4             ALB
#> 5             ALB
#> 6             ALB
head(sales_region)
#>   year region type      n
#> 1 2005 Africa   pc 784237
#> 2 2005 Africa   cv 328780
#> 3 2006 Africa   pc 926966
#> 4 2006 Africa   cv 387309
#> 5 2007 Africa   pc 939201
#> 6 2007 Africa   cv 382773
```

## Author, Version, and License Information

- Author: *John Paul Helveston* <https://www.jhelvy.com/>
- Date First Written: *Friday April 22, 2022*
- License: [MIT](https://github.com/jhelvy/oica/blob/master/LICENSE.md)

## Citation Information

If you use this package for in a publication, I would greatly appreciate
it if you cited it - you can get the citation by typing
`citation("oica")` into R:

``` r
citation("oica")
#> 
#> To cite oica in publications use:
#> 
#>   John Paul Helveston (2022). oica: Data on Vehicle Production and
#>   Sales from the OICA.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {oica: Data on Vehicle Production and Sales from the OICA},
#>     author = {John Paul Helveston},
#>     year = {2022},
#>     note = {R package version 0.0.1},
#>     url = {https://jhelvy.github.io/oica/},
#>   }
```
