global root "C:/Users/ALBERTO TRELLES/Documents/Alberto/Religion-Covid"
global output "$root/Output"
global input "$root/Input"
global organized "$root/Organized"
global data "$root/Data"
global temporal "$root/Temporal"
cd "$root"


//multiTimeline(1)_18_19.csv
//multiTimeline(1)_19_20.csv 
//multiTimeline_w(1).csv

*local words "Religion Church"
local words "Religion Spirituality"

foreach word of local words {
	
	*Word in lowercase (for variable usage)
	*local var = strlower("`word'")
	
	*---Loop 1---* Cleaning and merging periods 
	*------------*
	forvalues i=0/11{
		
		insheet using "$data/Europe/`word'/weekly_`i'-`word'.csv", delimiter(",") nonames clear
		drop in 1
		local var = strlower("`word'")
		rename (v1 v2) (date w_`var')
		drop v3
		label var w_`var' "Weekly queries: 18-20"
		save "$temporal/weekly_`i'-`word'.dta", replace 
		
		insheet using "$data/Europe/`word'/daily19_`i'-`word'.csv", delimiter(",") nonames clear
		drop in 1
		local var = strlower("`word'")
		rename (v1 v2) (date d_`var'_19)
		drop v3
		label var d_`var'_19 "Daily queries: 18-19"
		save "$temporal/daily19_`i'-`word'.dta", replace  
		
		insheet using "$data/Europe/`word'/daily20_`i'-`word'.csv", delimiter(",") nonames clear
		drop in 1
		local var = strlower("`word'")
		rename (v1 v2) (date d_`var'_20)
		drop v3
		label var d_`var'_20 "Daily queries: 19-20"
		save "$temporal/daily20_`i'-`word'.dta", replace 
		
		use "$temporal/weekly_`i'-`word'.dta", clear
		merge 1:1 date using "$temporal/daily19_`i'-`word'.dta"
		drop _merge
		merge 1:1 date using "$temporal/daily20_`i'-`word'.dta"
		drop _merge
		sort date 
		drop if d_`var'_19=="" & d_`var'_20==""
		replace w_`var'=w_`var'[_n-1] if w_`var'==""
		destring *`var'*, replace
		save "$temporal/final_search_`i'-`word'.dta", replace
		
	}
	
	*---Loop 2---* Date variables
	*------------*
	forvalues i=0/11{
		
		use "$temporal/final_search_`i'-`word'.dta", clear 
		gen edate=date(date, "YMD")
		format edate %d
		gen year=year(edate)
		gen month=month(edate)
		gen week=week(edate)
		
		sort year date
		bysort year week: gen day_w=_n 
		drop if month==12 					//Keeps relevant period
		drop if date=="2020-02-29"			//2020 bissextile year
		
		sort year date
		bysort year: gen day=_n 
		
		label var year "Year"
		label var month "Month"
		label var week "Week"
		label var day "Day"
		label var day_w "Day of the week"
		drop edate
		
		gen country=`i'
		label var country "Country"
		
		save "$temporal/final_search_`i'-`word'.dta", replace 
		
	}
	
	
	*---Loop 3---* Rescaling daily data using weekly data
	*------------*
	forvalues i = 0/11{
		
		use "$temporal/final_search_`i'-`word'.dta", clear 
		replace d_`var'_19=. if d_`var'_19==0
		replace d_`var'_20=. if d_`var'_20==0
		replace w_`var'=. if w_`var'==0
		
		bysort week: egen m_d_`var'_19 = mean(d_`var'_19)
		bysort week: egen m_d_`var'_20 = mean(d_`var'_20)
		
		gen d_`var'=.
		replace d_`var' = d_`var'_19 * (w_`var' / m_d_`var'_19) if year==2019
		replace d_`var' = d_`var'_20 * (w_`var' / m_d_`var'_20) if year==2020
		
		*Max to homogenize between 0-100
		egen max_d_`var' = max(d_`var')
		replace d_`var' = (d_`var' / max_d_`var') * 100 
		drop max_* m_*
		label var d_`var' "Daily queries (adjusted): 18-20"
		sort date 
		
		save "$temporal/adjusted_`i'-`word'.dta", replace 
		
	}
	
	*---Loop 4---* Merging countries 
	*------------* 
	
	use "$temporal/adjusted_0-`word'.dta", clear 
	forvalues i = 1/11{
		append using "$temporal/adjusted_`i'-`word'.dta" 
	}
	order country date year month week day day_w d_`var'_19 d_`var'_20 d_`var' w_`var'
	
	
	*Lockdown dates
	merge m:1 country using "$data/Demographic/Lockdown_Europe.dta"
	drop _merge
	order country_name country date year month week day date_* d_`var'_19 d_`var'_20 d_`var' w_`var'
	sort country year day
	
	gen lockdown_day=day if date==date_lockdown_ann			//Working with announcement date 
	replace lockdown_day=. if date_partial_lockdown!="" /*only full lockdown*/
	bysort country: egen m_lockdown_day=mean(lockdown_day)  //fill up blanks 
	replace lockdown_day=m_lockdown_day
	drop m_lockdown_day
	bysort country: gen dayssincelockdown=day-lockdown_day  //-1 year for 2019 entries 
	drop lockdown_day
	label var dayssincelockdown "Days elapsed since the stay-at-home order"
	gen post_lockdown=0 
	replace post_lockdown=1 if dayssincelockdown>=0 & dayssincelockdown!=.
	label var post_lockdown "Period after lockdown"
	
	*Covid deaths
	merge 1:1 country_name year month week day day_w using "$data/Demographic/daily-deaths-europe-covid-19.dta"
	drop if _merge==2
	drop _merge 
	drop date1
	replace dailyconfirmeddeathsdeaths=0 if dailyconfirmeddeathsdeaths==.
	order country_name country date year month week day day_w date_* dayssincelockdown* post_lockdown* d_`var' d_`var'_19 d_`var'_20 w_`var'
	sort country year day
	
	save "$organized/daily_full_`word'.dta", replace 
}

stop 


use "$organized/daily_full_Religion.dta", clear

drop if dayssincelockdown==0
keep if dayssincelockdown!=.

replace year=year-2019
gen post_lockdown_year=post_lockdown*year

drop if country==6 //dropping Luxembourg (no data)



gen L_dailyconfirmeddeathsdeaths = dailyconfirmeddeathsdeaths[_n-1] if country==country[_n-1]

*reghdfe d_church post_lockdown_year post_lockdown L_dailyconfirmeddeathsdeaths [pw=pop], absorb(country year week day_w) vce(cluster day)
reghdfe d_religion post_lockdown_year post_lockdown L_dailyconfirmeddeathsdeaths [pw=pop], absorb(country year week day_w) vce(cluster day)


*---Std by country---*
*--------------------*

by country: egen std_d_religion = std(d_religion)

*egen std_d_religion = std(d_religion)


reghdfe std_d_religion post_lockdown_year post_lockdown L_dailyconfirmeddeathsdeaths [pw=pop], absorb(country year week day_w) vce(cluster day)




use "$organized/daily_full_Spirituality.dta", clear

drop if dayssincelockdown==0
keep if dayssincelockdown!=.

replace year=year-2019
gen post_lockdown_year=post_lockdown*year

drop if country==6 //dropping Luxembourg (no data)
gen L_dailyconfirmeddeathsdeaths = dailyconfirmeddeathsdeaths[_n-1] if country==country[_n-1]
reghdfe d_spirituality post_lockdown_year post_lockdown L_dailyconfirmeddeathsdeaths [pw=pop], absorb(country year week day_w) vce(cluster day)

by country: egen std_d_spirituality = std(d_spirituality)
reghdfe d_spirituality post_lockdown_year post_lockdown L_dailyconfirmeddeathsdeaths [pw=pop], absorb(country year week day_w) vce(cluster day)


/*


merge m:1 country using "$data/Demographic/Lockdown_Europe_short.dta"
drop _merge
local var "church"
order country_name country date year month week day date_* d_`var'_19 d_`var'_20 d_`var' w_`var'
sort country year day
	
gen lockdown_day=day if date==date_lockdown_ann //one single entry with the year day of lockdown (74 for AT)
replace lockdown_day=. if date_partial_lockdown!="" //only full lockdown (3 changes)
bysort country: egen m_lockdown_day=mean(lockdown_day)  //this fills up the missing values (mean of one number)
replace lockdown_day=m_lockdown_day
drop m_lockdown_day
bysort country: gen dayssincelockdown=day-lockdown_day //not exactly for 2019 period, but still it's there 
drop lockdown_day
label var dayssincelockdown "Days elapsed since the stay-at-home order"
gen post_lockdown=0 
replace post_lockdown=1 if dayssincelockdown>=0 & dayssincelockdown!=.
label var post_lockdown "Period after lockdown"












/*
insheet using "$data/Europe/Religion/weekly_0-Religion.csv", delimiter(",") nonames clear
		
		
		
local words "Religion Church"
foreach word of local words {
	
	forvalues i=0/9{
		
		display "`word'"
		local var = strlower("`word'")
		display "`var'"
		
		
		
		
	}
	
	
}







