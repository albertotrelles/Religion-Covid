# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Empirical economics research studying the effect of COVID-19 lockdowns on religiosity using Google Trends data across US states. The analysis compares 2019 vs 2020 daily search interest (RSI) around state-level lockdown announcements using difference-in-differences (DiD) methods.

## Pipeline

The project runs sequentially through numbered Stata do-files:

1. **`Dofiles/1a-us_clean.do`** — Cleans and merges all raw data: COVID-19 cases, state demographics, lockdown dates, and Google Trends CSVs. Produces unified RSI series by rescaling daily GT data using weekly benchmarks. Outputs `Data/Organized/us_nocat.dta` (topics) and `us_subcat.dta` (subcategories).
2. **`Dofiles/1b-us_did_setup.do`** — Constructs DiD variables: treatment indicators (lockdown announcement, 1-week anticipation), event-time dummies (weekly bins), lagged COVID controls. Outputs `*_twfe.dta` and `*_dynamic.dta` datasets.
3. **`Dofiles/1c-us_adj_lockdown.do`** — Supplementary: builds adjacency spillover variables. Hardcodes all US state border pairs, computes the earliest adjacent-state lockdown date per state, and creates `adj_lockdown` and `year_adj_lockdown` dummies for spillover DiD. Alaska and Hawaii are handled as special cases (no land neighbors).
4. **`Dofiles/2-us_descriptive.do`** — Descriptive figures: RSI evolution plots by year around lockdown dates (exports `us_evolution1_<topic>.png` and `us_evolution2_<topic>.png`).
5. **`Dofiles/3a-us_twfe.do`** — Main estimation: TWFE regressions and Borusyak-Jaravel-Spiess (BJS) imputation estimator (`did_imputation`). Exports LaTeX tables (`us_twfe1.tex`, `bjs1.tex`, `us_twfe2.tex`, `bjs2.tex`) and coefficient plots.
6. **`Dofiles/3b-us_dynamic.do`** — Pre-trends tests and dynamic/event-study specifications with bootstrapped BJS estimates (500 bootstrap iterations with cluster resampling). Exports `pretrends_<topic>.png` and `eventstudy_<topic>.png`.

Files in `Dofiles/old/` are deprecated.

## Data Collection (Python)

`Data/Data_collection/` contains three Python scripts that automate Google Trends CSV downloads via browser automation (`pyautogui`) and NordVPN IP rotation:

- **`gt_functions.py`** — Helper functions: URL construction, browser download automation, VPN connect/reconnect, and handling of corrupted/empty GT responses.
- **`main_us.py`** — Downloads topic data (6 topics × 50 states): daily 2019, daily 2020, and weekly CSVs. Saves to `raw/US/nocat/{STATE}/`.
- **`us_main_subcat.py`** — Downloads subcategory data (14 subcategories × 50 states). Saves to `raw/US/subcat/{STATE}/`. Maps subcategory names to Google Trends numeric IDs (e.g., 864 = Christianity, 868 = Islam).

Raw CSVs follow the naming convention `daily19_<term>_<STATE>.csv`, `daily20_<term>_<STATE>.csv`, `weekly_<term>_<STATE>.csv`.

## Key Globals (set at top of every do-file)

```stata
global root "C:/Users/ALBERTO TRELLES/Dropbox/Religion-Covid"
global data "$root/Data"
global organized "$data/Organized"
global raw "$data/Data_collection/raw"
global demographic "$data/Demographic"
global temporal "$root/Temporal"
global tables "$root/Tables"
global figures "$root/Figures"
```

## Search Terms

- **Topics (nocat):** Faith, God, Meditation, Prayer, Religion, Spirituality
- **Subcategories (subcat):** Astrology, Buddhism, Christianity, Hinduism, Islam, Judaism, Occult, Paganism, Worship, Scientology, Selfhelp, Skeptics, Spirituality, Theology

## Estimation Details

- Unit of analysis: state-day panel (50 US states, ~200 days per state)
- Treatment: staggered lockdown announcement dates (vary by state)
- Fixed effects: state, year, day-of-sample, day-of-week
- Weights: state population (`[pw=pop]`)
- Clustering: by calendar day (`vce(cluster day)`)
- Two treatment definitions: (1) announcement date, (2) 1-week anticipation
- COVID controls: lagged cases/deaths (`L_cases`, `L_deaths`, `L_cases_avg`, `L_deaths_avg`)
- Required Stata packages: `reghdfe`, `did_imputation`, `estout`

## Datasets

All final datasets live in `Data/Organized/`:

- `us_nocat.dta` / `us_subcat.dta` — Cleaned panel with RSI + demographics (pre-estimation)
- `*_twfe.dta` — Adds treatment indicators and FE variables
- `*_dynamic.dta` — Adds event-time dummies for pre-trends/event studies
- `csdid.dta` — Cross-sectional DiD dataset
- RSI variables are named `d_<topic>` (e.g., `d_prayer`, `d_christianity`)

Intermediate demographic/auxiliary datasets live in `Data/Demographic/US/`: `us_demographic_clean.dta`, `us_lockdown_clean.dta`, `us_pop_clean.dta`, `us_covid19_clean.dta`.

## Running Stata Do-Files

All do-files assume `$root` is set to the Dropbox project path. Run them in order (1a → 1b → [1c optional] → 2 → 3a → 3b). Step 1c (adjacency spillovers) is supplementary and can be skipped for the main analysis.
