rm(list = ls())
.rs.restartR()

devtools::load_all()
devtools::test()

# Create the documentation for the package
devtools::document()

# Install the package
devtools::install(force = TRUE)

# Run all examples to save results
source(here::here("inst", "example", "examples.R"))

# Build the pkgdown site
pkgdown::build_site()

# Check package
devtools::check()
devtools::check_win_release()
devtools::check_win_devel()
rhub::check_for_cran()

# Load the package and view the summary
library(oica)
help(package = 'oica')

# Install from github
devtools::install_github('jhelvy/oica')

# Submit to CRAN
devtools::release(check = TRUE)
