# Indicator metadata and World Bank WDI data helpers

indicator_codes <- c(
  "GDP growth (annual %)" = "NY.GDP.MKTP.KD.ZG",
  "Inflation, consumer prices (annual %)" = "FP.CPI.TOTL.ZG",
  "Unemployment, total (% of total labor force)" = "SL.UEM.TOTL.ZS",
  "Exports of goods and services (% of GDP)" = "NE.EXP.GNFS.ZS",
  "Imports of goods and services (% of GDP)" = "NE.IMP.GNFS.ZS",
  "Population, total" = "SP.POP.TOTL"
)

fetch_pakistan_indicators <- function(start_year = 2000, end_year = 2024) {
  if (!requireNamespace("WDI", quietly = TRUE)) {
    stop("Package 'WDI' is required. Install it with install.packages('WDI').")
  }

  raw <- WDI::WDI(
    country = "PAK",
    indicator = unname(indicator_codes),
    start = start_year,
    end = end_year,
    extra = FALSE,
    cache = NULL
  )

  if (nrow(raw) == 0) {
    stop("No observations were returned by the World Bank API. Please try again later.")
  }

  names(raw)[names(raw) %in% unname(indicator_codes)] <-
    names(indicator_codes)[match(names(raw)[names(raw) %in% unname(indicator_codes)],
                                 unname(indicator_codes))]

  raw |>
    dplyr::select(year, country, dplyr::all_of(names(indicator_codes))) |>
    dplyr::arrange(year)
}

summarise_indicator <- function(data, indicator_name) {
  values <- data[[indicator_name]]
  values <- values[!is.na(values)]

  if (length(values) == 0) {
    return(data.frame(
      observations = 0L,
      mean = NA_real_,
      median = NA_real_,
      minimum = NA_real_,
      maximum = NA_real_
    ))
  }

  data.frame(
    observations = length(values),
    mean = mean(values),
    median = stats::median(values),
    minimum = min(values),
    maximum = max(values)
  )
}
