# World Bank indicator metadata and reusable analysis helpers

indicator_codes <- c(
  "GDP growth (annual %)" = "NY.GDP.MKTP.KD.ZG",
  "Inflation, consumer prices (annual %)" = "FP.CPI.TOTL.ZG",
  "Unemployment, total (% of total labor force)" = "SL.UEM.TOTL.ZS",
  "Exports of goods and services (% of GDP)" = "NE.EXP.GNFS.ZS",
  "Imports of goods and services (% of GDP)" = "NE.IMP.GNFS.ZS",
  "Population, total" = "SP.POP.TOTL"
)

indicator_units <- c(
  "GDP growth (annual %)" = "Percent",
  "Inflation, consumer prices (annual %)" = "Percent",
  "Unemployment, total (% of total labor force)" = "Percent",
  "Exports of goods and services (% of GDP)" = "Percent of GDP",
  "Imports of goods and services (% of GDP)" = "Percent of GDP",
  "Population, total" = "People"
)

fetch_pakistan_indicators <- function(start_year = 2000,
                                      end_year = as.integer(format(Sys.Date(), "%Y"))) {
  if (!requireNamespace("WDI", quietly = TRUE)) {
    stop("Package 'WDI' is required. Install it with install.packages('WDI').")
  }
  if (length(start_year) != 1 || length(end_year) != 1 ||
      is.na(start_year) || is.na(end_year) ||
      start_year > end_year) {
    stop("Provide valid start_year and end_year values with start_year <= end_year.")
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

  source_columns <- unname(indicator_codes)
  present_columns <- intersect(source_columns, names(raw))
  if (length(present_columns) == 0) {
    stop("The World Bank response did not contain the expected indicator columns.")
  }

  rename_map <- setNames(names(indicator_codes), source_columns)
  names(raw)[match(present_columns, names(raw))] <- rename_map[present_columns]

  expected <- names(indicator_codes)
  for (column in setdiff(expected, names(raw))) raw[[column]] <- NA_real_

  raw |>
    dplyr::select(year, country, dplyr::all_of(expected)) |>
    dplyr::arrange(year)
}

summarise_indicator <- function(data, indicator_name) {
  if (!indicator_name %in% names(data)) {
    stop("Unknown indicator: ", indicator_name)
  }
  values <- data[[indicator_name]]
  values <- values[is.finite(values)]

  if (length(values) == 0) {
    return(data.frame(
      observations = 0L, mean = NA_real_, median = NA_real_,
      minimum = NA_real_, maximum = NA_real_, standard_deviation = NA_real_
    ))
  }

  data.frame(
    observations = length(values),
    mean = mean(values),
    median = stats::median(values),
    minimum = min(values),
    maximum = max(values),
    standard_deviation = if (length(values) > 1) stats::sd(values) else NA_real_
  )
}
