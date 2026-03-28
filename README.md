# Religion-Covid

This repository studies the effect of COVID-19 lockdowns on religiosity using Google Trends data across US states. It compares 2019 vs. 2020 daily search interest around state-level lockdown announcements using difference-in-differences (DiD) methods.

A working paper is available at `working_paper.pdf`.

## Repository Structure

```
Religion-Covid/
├── Data/
│   ├── Data_collection/          # Python scripts + raw Google Trends CSVs
│   │   ├── gt_functions.py       # Helper functions (URL builder, VPN, download)
│   │   ├── main_us.py            # Downloads topic data (6 topics × 50 states)
│   │   ├── us_main_subcat.py     # Downloads subcategory data (14 cats × 50 states)
│   │   ├── gallup_religiosity_2017.dta  # Gallup state religiosity shares (2017)
│   │   └── raw/US/               # ~5,000+ downloaded CSV files
│   │       ├── nocat/{STATE}/    # daily19, daily20, weekly CSVs per topic
│   │       └── subcat/{STATE}/   # daily19, daily20, weekly CSVs per subcategory
│   ├── Demographic/US/           # Cleaned auxiliary datasets (population, lockdown dates, COVID)
│   └── Organized/                # Final analysis datasets (.dta)
├── Dofiles/                      # Stata do-files (analysis pipeline)
│   ├── 0-master.do               # Runs entire pipeline in order
│   └── old/                      # Deprecated scripts
├── Figures/                      # Output figures (PNG)
├── Tables/                       # Output LaTeX tables (.tex)
├── Temporal/                     # Intermediate/temporary files
```

## Analysis Pipeline

Run Stata do-files in order (or use `Dofiles/0-master.do` to run all steps):

| Step | File | Description |
|------|------|-------------|
| 1a | `Dofiles/1a-us_clean.do` | Cleans raw data (COVID cases, demographics, lockdown dates, Google Trends CSVs). Rescales daily GT data using weekly benchmarks to produce unified RSI. Outputs `us_nocat.dta` and `us_subcat.dta`. |
| 1b | `Dofiles/1b-us_did_setup.do` | Constructs DiD variables: treatment indicators, weekly event-time dummies, lagged COVID controls. Outputs `*_twfe.dta` and `*_dynamic.dta`. |
| 2 | `Dofiles/2-us_descriptive.do` | Descriptive figures: RSI evolution plots by year around lockdown dates. |
| 3a | `Dofiles/3a-us_twfe.do` | Main estimation: TWFE regressions and BJS imputation estimator. Exports LaTeX tables and coefficient plots. |
| 3b | `Dofiles/3b-us_dynamic.do` | Pre-trends tests and dynamic/event-study specs with 500-iteration bootstrapped BJS estimates. |
| 4a | `Dofiles/4a-us_het_religion_twfe.do` | Heterogeneous effects by baseline religiosity (Gallup 2017). Merges `gallup_religiosity_2017.dta`, splits states into high/low religiosity above the median share of "very religious", and estimates triple-DiD interactions. Exports `us_het1.tex`. |
| 4b | `Dofiles/4b-us_het_religion_eventstudy.do` | Pre-trends and BJS event-study estimates split by high/low religiosity group (500 bootstrap iterations). Exports `eventstudy_het_<topic>.png` for God, Prayer, and Meditation. |

Step 1c (`Dofiles/1c-us_adj_lockdown.do`) is a supplementary file that builds adjacency spillover variables. It is not part of the main pipeline but can be run independently for spillover robustness checks.

## Data Collection

`Data/Data_collection/` automates Google Trends CSV downloads using `pyautogui` for browser automation and NordVPN CLI for IP rotation (to avoid Google rate limits).

**Search terms collected for all 50 US states:**
- **Topics (nocat):** Faith, God, Meditation, Prayer, Religion, Spirituality
- **Subcategories (subcat):** Astrology, Buddhism, Christianity, Hinduism, Islam, Judaism, Occult, Paganism, Worship, Scientology, Selfhelp, Skeptics, Spirituality, Theology

**Date ranges collected:**
- Daily 2019: 2018-12-30 to 2019-04-13
- Daily 2020: 2019-12-29 to 2020-04-11
- Weekly: 2018-12-30 to 2020-04-05

## Estimation Design

- **Unit:** State-day panel (50 US states, ~200 days per state)
- **Treatment:** Staggered lockdown announcement dates (vary by state)
- **Fixed effects:** State, year, day-of-sample, day-of-week
- **Weights:** State population
- **Clustering:** By calendar day
- **Treatment definitions:** (1) announcement date; (2) 1-week anticipation window
- **COVID controls:** Lagged cases/deaths (`L_cases`, `L_deaths`, `L_cases_avg`, `L_deaths_avg`)
- **Estimators:** TWFE (`reghdfe`) and BJS imputation (`did_imputation`)

## Requirements

**Stata packages:**
```stata
ssc install reghdfe
ssc install did_imputation
ssc install estout
```

**Python packages (data collection only):**
```
pyautogui, pandas, openpyxl
```
NordVPN CLI must be installed and authenticated.
