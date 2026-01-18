# Religion-Covid

This repository studies the effect of COVID-19 lockdowns on religiosity using Google Trends data. It tracks all scripts used for data collection, cleaning, estimation, and the production of tables and figures.

## Folder structure

### Data/Data_collection
Contains Python scripts that automate the download of Google Trends data. These scripts use NordVPN to rotate IP addresses and bypass Google Trends’ “too many requests” limitations.

### Dofiles/
Contains all Stata do-files used in the project, covering the full workflow from data cleaning and dataset construction to estimation and the export of tables and figures in `.tex` format.
