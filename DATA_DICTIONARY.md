# Data dictionary

The application retrieves annual observations for Pakistan (World Bank country code `PAK`) through the World Bank World Development Indicators API.

| Dashboard label | WDI series code | Description | Unit |
|---|---|---|---|
| GDP growth (annual %) | NY.GDP.MKTP.KD.ZG | Annual percentage growth of GDP at market prices based on constant local currency | Percent |
| Inflation, consumer prices (annual %) | FP.CPI.TOTL.ZG | Annual percentage change in the cost to the average consumer of acquiring a basket of goods and services | Percent |
| Unemployment, total (% of total labor force) | SL.UEM.TOTL.ZS | Share of the labor force without work but available for and seeking employment | Percent |
| Exports of goods and services (% of GDP) | NE.EXP.GNFS.ZS | Exports of goods and services as a share of GDP | Percent of GDP |
| Imports of goods and services (% of GDP) | NE.IMP.GNFS.ZS | Imports of goods and services as a share of GDP | Percent of GDP |
| Population, total | SP.POP.TOTL | Total population | People |

## Fields returned by the app

- `year`: calendar year of the observation.
- `country`: country name returned by the WDI package.
- The six indicator columns above: numeric values; unavailable observations are `NA`.

## Data handling

No interpolation, extrapolation or imputation is performed. The dashboard's statistical calculations use available finite observations. Different indicators may cover different year ranges. WDI data can be revised after publication; record the access date and save the exact CSV extract for reproducibility.
