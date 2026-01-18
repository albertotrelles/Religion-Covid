cap cd "C:/Users/ALBERTO TRELLES/Dropbox/Religion-Covid"

global root "`c(pwd)'"
global output "$root/Output"
global input "$root/Input"
global organized "$root/Organized"
global data "$root/Data"
global temporal "$root/Temporal"

//----------------------------------------------------------------------------//
//-- (1) Clean each raw csv and merge 3 series								--//
//----------------------------------------------------------------------------//

*Weekly data: 2018-12-30 - 2020-04-05
insheet using "$data/Cat-0/Europe/Prayer/weekly_0-Prayer.csv", delimiter(",") nonames clear
drop in 1/2  //remove headers that were imported as rows
local var = strlower("Prayer")
rename (v1 v2) (date w_`var') //rename variables (proper headers)
label var w_`var' "Weekly queries: 18-20"
save "$temporal/weekly_0-Prayer.dta", replace

*2019 daily data: 2018-12-30 - 2019-04-10
insheet using "$data/Cat-0/Europe/Prayer/daily19_0-Prayer.csv", delimiter(",") nonames clear
drop in 1/2
local var = strlower("Prayer")
rename (v1 v2) (date d_`var'_19)
label var d_`var'_19 "Daily queries: 18-19"
save "$temporal/daily19_0-Prayer.dta", replace  

*2020 daily data: 2019-12-30 - 2020-04-07   
insheet using "$data/Cat-0/Europe/Prayer/daily20_0-Prayer.csv", delimiter(",") nonames clear
drop in 1/2
local var = strlower("Prayer")
rename (v1 v2) (date d_`var'_20)
label var d_`var'_20 "Daily queries: 19-20"
save "$temporal/daily20_0-Prayer.dta", replace 

*Mergin series
use "$temporal/weekly_0-Prayer.dta", clear
merge 1:1 date using "$temporal/daily19_0-Prayer.dta"
drop _merge
merge 1:1 date using "$temporal/daily20_0-Prayer.dta"
drop _merge
sort date 
drop if d_prayer_19=="" & d_prayer_20==""
replace w_prayer=w_prayer[_n-1] if w_prayer==""
destring *prayer*, replace
save "$temporal/final_search_0-Prayer_cat0.dta", replace

/* Keep only dates in period that are used in daily19 or daily20 series */
/* Fill in blanks accordingly of weekly series to have in daily frequency */


//----------------------------------------------------------------------------//
//-- (2) Date management and country id										--//
//----------------------------------------------------------------------------//

*Date management 
use "$temporal/final_search_0-Prayer_cat0.dta", clear 
gen edate=date(date, "YMD")
format edate %d
gen year=year(edate)		//2018, 2019, 2020
gen month=month(edate)		//1-4, 12 
gen week=week(edate)		//1-15, 52 (last week of year)


//test
bysort year week: gen day_w=_n	
bysort year: gen day=_n
		
		
		
sort year date
bysort year week: gen day_w=_n		//Monday-Sunday 1-7
drop if month==12 					//Keeps relevant period
drop if date=="2020-02-29"			//2020 bissextile year
		
sort year date
bysort year: gen day=_n		//1-100 date of year 
*(!!!) In Brodeur2021 replication, days 98-100 only appear once for 2019 but not for 2020. 8-10th april not included in 2020 series. On 7th april ends 2020's 14th week. 8-10th april would be week 15 of 2020 
		
label var year "Year"
label var month "Month"
label var week "Week"
label var day "Day"
label var day_w "Day of the week"
drop edate
		
gen country=0
label var country "Country"
		
save "$temporal/final_search_0-Prayer_cat0.dta", replace 





























local words Prayer
foreach word of local words{
	
	local var = strlower("`word'")  //*Word in lowercase (for variable usage)
	
	*---(1) CSV cleaning---*
	*----------------------*
	forvalues i=0/11{
		
		insheet using "$data/Cat-0/Europe/`word'/weekly_`i'-`word'.csv", delimiter(",") nonames clear
		drop in 1/2
		local var = strlower("`word'")
		rename (v1 v2) (date w_`var')
		label var w_`var' "Weekly queries: 18-20"
		save "$temporal/weekly_`i'-`word'.dta", replace 
		
		insheet using "$data/Cat-0/Europe/`word'/daily19_`i'-`word'.csv", delimiter(",") nonames clear
		drop in 1/2
		local var = strlower("`word'")
		rename (v1 v2) (date d_`var'_19)
		label var d_`var'_19 "Daily queries: 18-19"
		save "$temporal/daily19_`i'-`word'.dta", replace  
		
		insheet using "$data/Cat-0/Europe/`word'/daily20_`i'-`word'.csv", delimiter(",") nonames clear
		drop in 1/2
		local var = strlower("`word'")
		rename (v1 v2) (date d_`var'_20)
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
		save "$temporal/final_search_`i'-`word'_cat0.dta", replace
		
	}
	
	*---(2) Dates and country id---*
	*------------------------------*
	forvalues i=0/11{
		
		use "$temporal/final_search_`i'-`word'_cat0.dta", clear 
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
		
		save "$temporal/final_search_`i'-`word'_cat0.dta", replace 
		
	}
	
	
	*---(3) Reescaling data---*
	*-------------------------*
	forvalues i = 0/11{
		
		use "$temporal/final_search_`i'-`word'_cat0.dta", clear 
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
		
		save "$temporal/adjusted_`i'-`word'_cat0.dta", replace 
		
	}
	
	*---(4) Merge countries and demographics---*
	*------------------------------------------*
	
	use "$temporal/adjusted_0-`word'_cat0.dta", clear 
	forvalues i = 1/11{
		append using "$temporal/adjusted_`i'-`word'_cat0.dta" 
	}
	order country date year month week day day_w d_`var'_19 d_`var'_20 d_`var' w_`var'
	
	
	*Lockdown dates
	merge m:1 country using "$data/Demographic/Lockdown_Europe.dta"
	drop _merge
	order country_name country date year month week day date_* d_`var'_19 d_`var'_20 d_`var' w_`var'
	sort country year day
	
	gen lockdown_day=day if date==date_lockdown_ann			//Working with announcement date 
	replace lockdown_day=. if date_partial_lockdown!=""     /*only full lockdown*/
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
	
	save "$organized/daily_full_`word'_cat0.dta", replace 
}