********************************************************************
***COVID-19, Lockdowns and Well-Being: Evidenc from Google Trends***
********************************************************************

* This do-file creates the final datasets for the US

	*Change path below
	
	global data "/Users/Data/US"
	global results "/Users/Results"

	**********************************************************
	*****			CREATE DATABASE						******
	**********************************************************

	local varlist "Boredom Contentment Impairment Irritability Loneliness Panic Sadness Sleep Stress Suicide Wellbeing Worry Divorce Antidepressant"

	foreach var of local varlist {
		
	/* Merge Weekly and Daily DataBases*/

	forvalues i=0/50 {
	global sub_file "Google-trends-`var'-US/`i'"

	insheet using "$data/$sub_file/multiTimeline_w(`i').csv", delimiter(",") clear
	drop in 1/2
	rename v1 date
	label var date "Date (String)"
	rename v2 w_`var'_18_20
	label var w_`var'_18_20 "Weekly queries: 18-20"
	save "$data/$sub_file/weekly_search_18_20_(`i').dta", replace

	insheet using "$data/$sub_file/multiTimeline_(`i')_18_19.csv", delimiter(",") clear
	drop in 1/2
	rename v1 date
	label var date "Date (String)"
	rename v2 d_`var'_18_19
	label var d_`var'_18_19 "Daily queries: 18-19"
	save "$data/$sub_file/daily_search_18_19_(`i').dta", replace

	insheet using "$data/$sub_file/multiTimeline_(`i')_19_20.csv", delimiter(",") clear
	drop in 1/2
	rename v1 date
	label var date "Date (String)"
	rename v2 d_`var'_19_20
	label var d_`var'_19_20 "Daily queries: 19-20"
	save "$data/$sub_file/daily_search_19_20_(`i').dta", replace

	use "$data/$sub_file/weekly_search_18_20_(`i').dta", clear
	merge 1:1 date using "$data/$sub_file/daily_search_18_19_(`i').dta"
	drop _merge
	merge 1:1 date using "$data/$sub_file/daily_search_19_20_(`i').dta"
	drop _merge
	sort date
	drop if d_`var'_18_19=="" & d_`var'_19_20==""
	replace w_`var'_18_20=w_`var'_18_20[_n-1] if w_`var'_18_20==""
	destring *`var'*, replace
	save "$data/$sub_file/daily_search_18_20_(`i').dta", replace
	}

	/* Create State, Year, Month, Week, Day Variables*/

	forvalues i=0/50 {
	global sub_file "Google-trends-`var'-US/`i'"

	use "$data/$sub_file/daily_search_18_20_(`i').dta", clear
	gen edate=date(date, "YMD")
	format edate %d
	gen year=year(edate)
	gen month=month(edate)
	gen week=week(edate)

	sort year date
	bysort year week: gen day_w=_n

	drop if month==12 /*Keep from January 1st to April 10th*/
	drop if date=="2020-02-29" /* 2020: bissextile*/

	sort year date
	bysort year: gen day=_n

	label var year "Year"
	label var month "Month"
	label var week "Week"
	label var day "Day"
	label var day_w "Day of the week"
	drop edate

	gen state=`i'
	label var state "Country"

	save "$data/$sub_file/daily_search_18_20_(`i').dta", replace
	}

	/* Rescale Daily data using Weekly Data*/

	forvalues i=0/50 {
	global sub_file "Google-trends-`var'-US/`i'"

	use "$data/$sub_file/daily_search_18_20_(`i').dta", clear
	replace d_`var'_18_19=. if d_`var'_18_19==0
	replace d_`var'_19_20=. if d_`var'_19_20==0
	replace w_`var'_18_20=. if w_`var'_18_20==0

		bysort week: egen m_d_`var'_18_19=mean(d_`var'_18_19)
		bysort week: egen m_d_`var'_19_20=mean(d_`var'_19_20)
		
		gen d_`var'_18_20=.
		replace d_`var'_18_20=d_`var'_18_19*(w_`var'_18_20/m_d_`var'_18_19)
		replace d_`var'_18_20=d_`var'_19_20*(w_`var'_18_20/m_d_`var'_19_20) if d_`var'_18_20==.
		
		egen max_d_`var'_18_20=max(d_`var'_18_20)
		
		replace d_`var'_18_20=[d_`var'_18_20/max_d_`var'_18_20]*100
		drop max_* m_*
		label var d_`var'_18_20 "Daily queries (adjusted): 18-20" 

	save "$data/$sub_file/daily_search_18_20_(`i').dta", replace
	}


	/* Merge All States */

	use "$data/Google-trends-`var'-US/0/daily_search_18_20_(0).dta", clear

	forvalues i=1/50 {
	global sub_file "Google-trends-`var'-US/`i'"
	append using "$data/$sub_file/daily_search_18_20_(`i').dta"
	}

	order state date year month week day day_w d_`var'_18_20 d_`var'_18_19 d_`var'_19_20 w_`var'_18_20

	/* Merge with Dates of Lockdown for all Countries */

	merge m:1 state using "$data/Lockdown_US.dta"
	drop _merge
	order state_name state date year month week day date_* d_`var'_18_20 d_`var'_18_19 d_`var'_19_20 w_`var'_18_20
	sort state year day

	gen lockdown_day=day if date==date_announced
	bysort state: egen m_lockdown_day=mean(lockdown_day)
	replace lockdown_day=m_lockdown_day
	drop m_lockdown_day
	bysort state: gen dayssincelockdown=day-lockdown_day 
	drop lockdown_day
	label var dayssincelockdown "Days elapsed since the stay-at-home order"
	gen post_lockdown=0 
	replace post_lockdown=1 if dayssincelockdown>=0 & dayssincelockdown!=.
	label var post_lockdown "Period after lockdown"

	order state_name state date year month week day day_w date_* dayssincelockdown post_lockdown d_`var'_18_20 d_`var'_18_19 d_`var'_19_20 w_`var'_18_20
	sort state year day

	/* Merge with Deaths from COVID-19 for all States */

	merge m:1 state day using "$data/Death-US/daily-deaths-covid-19.dta"
	drop if _merge ==2
	drop _merge
	replace dailyconfirmeddeathsdeaths=0 if dailyconfirmeddeathsdeaths==.
	bysort state: egen m_pop=mean(pop)
	replace pop=m_pop if pop==.
	drop m_pop
	order state_name state date year month week day day_w date_* dayssincelockdown post_lockdown d_`var'_18_20 d_`var'_18_19 d_`var'_19_20 w_`var'_18_20
	sort state year day

	save "$data/Google-trends-`var'-US/daily_`var'_18_20_all_full.dta", replace

	}

