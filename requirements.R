# Install all packages required by the dashboard and tests.
packages <- c(
  "shiny",
  "WDI",
  "dplyr",
  "ggplot2",
  "DT",
  "scales",
  "testthat"
)

missing_packages <- packages[
  !vapply(packages, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_packages) > 0) {
  install.packages(missing_packages)
}

message("All required packages are installed.")
