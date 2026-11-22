# Statistical Analysis of Pakistan Economic Indicators

An interactive R Shiny application for descriptive and exploratory statistical analysis of Pakistan's macroeconomic indicators. Data are retrieved from the World Bank World Development Indicators (WDI) database.

## Dashboard features

- Annual trends and descriptive statistics
- Pearson correlation analysis with confidence intervals and p-values
- Exploratory bivariate linear regression
- Linear time-trend test
- Year-range and indicator selection
- Interactive data table and CSV download

## Indicators and World Bank codes

| Indicator | WDI code | Unit |
|---|---|---|
| GDP growth (annual %) | NY.GDP.MKTP.KD.ZG | Percent |
| Inflation, consumer prices (annual %) | FP.CPI.TOTL.ZG | Percent |
| Unemployment, total (% of total labor force) | SL.UEM.TOTL.ZS | Percent |
| Exports of goods and services (% of GDP) | NE.EXP.GNFS.ZS | Percent of GDP |
| Imports of goods and services (% of GDP) | NE.IMP.GNFS.ZS | Percent of GDP |
| Population, total | SP.POP.TOTL | People |

## Repository structure

```
.
├── app.R
├── R/
│   └── data.R
├── tests/
│   └── testthat/
│       └── test-data.R
├── .gitignore
├── README.md
├── DATA_DICTIONARY.md
└── requirements.R
```

## Run locally

1. Install R (4.1 or later recommended) and RStudio.
2. Clone this repository.
3. Install packages:

```r
source("requirements.R")
```

4. Run the application from the repository root:

```r
shiny::runApp()
```

An internet connection is required because the application requests current WDI observations when it starts.

## Statistical methods

### Descriptive statistics
For each selected indicator, the dashboard reports the number of available observations, mean, median, minimum, maximum and standard deviation.

### Pearson correlation
The correlation tab calculates Pearson's product-moment correlation for paired, non-missing annual observations. It reports the correlation coefficient, 95% confidence interval and p-value.

### Linear regression
The regression tab fits an ordinary least squares model with one selected indicator as the outcome and another as the predictor. The output includes the standard R model summary.

### Linear time-trend test
The trend test fits `indicator ~ year` and reports the estimated annual slope, t statistic, p-value and R-squared.

## Important interpretation and limitations

- These analyses are descriptive and exploratory. Correlation and regression do not establish causation.
- The bivariate regression does not control for confounders, policy changes, external shocks or other macroeconomic variables.
- The ordinary least squares trend test does not adjust for autocorrelation, heteroskedasticity, non-stationarity or structural breaks. Its p-value should therefore be interpreted cautiously for time-series data.
- WDI series can have different latest available years. Missing values are retained as missing and are not imputed.
- World Bank historical data can be revised. Re-running the application later may produce updated results.
- The application fetches data live; no fixed snapshot is included in this repository. For reproducible academic work, export and archive the exact data extract and access date used in your analysis.

## Data source and attribution

World Bank, World Development Indicators: https://databank.worldbank.org/source/world-development-indicators

The R package WDI provides programmatic access to the World Bank API. Consult the World Bank's data terms and attribution guidance before redistributing extracts.

## Testing

Run the unit tests from the repository root:

```r
install.packages(c("testthat", "dplyr", "WDI"))
testthat::test_dir("tests/testthat")
```

## Suggested academic extensions

- Compare Pakistan with peer economies.
- Add inflation-adjusted or per-capita indicators.
- Test for structural breaks and time-series stationarity.
- Explore multivariate models with carefully justified controls.

## License

No software license has been selected. Add a LICENSE file before inviting reuse or redistribution of the project code. World Bank data remain subject to their own terms.
