# Statistical Analysis of Pakistan Economic Indicators

An interactive **R Shiny** dashboard for exploring Pakistan's key economic indicators using data from the [World Bank World Development Indicators (WDI)](https://databank.worldbank.org/source/world-development-indicators).

## Indicators

- GDP growth (annual %)
- Inflation, consumer prices (annual %)
- Unemployment, total (% of total labor force)
- Exports of goods and services (% of GDP)
- Imports of goods and services (% of GDP)
- Population, total

The app retrieves the latest available observations for Pakistan from the World Bank API when it loads. Availability can differ by indicator and year; missing observations are not imputed.

## Project structure

```
.
├── app.R
├── R/
│   └── data.R
├── .gitignore
└── README.md
```

## Requirements

- R (4.1 or later recommended)
- Internet connection (to retrieve WDI data)

## Run locally

1. Clone or download this repository.
2. Open the project folder in RStudio.
3. Install the required packages:

```r
install.packages(c("shiny", "WDI", "dplyr", "tidyr", "ggplot2", "DT", "scales"))
```

4. Start the dashboard:

```r
shiny::runApp()
```

## How to use

1. Choose a year range in the sidebar.
2. Select an economic indicator.
3. Explore its trend chart and descriptive statistics.
4. Review the underlying annual observations in the data table.

## Data source and attribution

Data are retrieved from the World Bank's World Development Indicators database through the R package **WDI**. Please cite the World Bank WDI database when reusing the data. The World Bank may revise historical observations, so results can change when the app is run again.

## Notes and limitations

- This is a descriptive analysis dashboard, not a causal economic model.
- The latest year differs across indicators because source data are not always published at the same time.
- Missing values are retained as missing; the app does not fabricate or interpolate observations.

## Future improvements

- Add downloadable CSV reports.
- Add indicator comparisons and correlation analysis.
- Add a country comparison mode.
- Add an automated data refresh and deployment workflow.

## License

No license has been specified yet. All underlying data remain subject to the World Bank's data terms and attribution requirements.
