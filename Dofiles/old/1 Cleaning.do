global root "C:/Users/ALBERTO TRELLES/Dropbox/Religion-Covid"
global output "$root/Output"
global input "$root/Input"
global organized "$root/Organized"
global data "$root/Data"
global temporal "$root/Temporal"
cd "$root"

/*
local word "Religion"
local i = 0
local var = strlower("`word'")
		
insheet using "$data/Cat-59/Europe/`word'/weekly_`i'-`word'.csv", delimiter(",") nonames clear

drop in 1/2
rename (v1 v2) (date w_`var')
*/

**# Bookmark #1
//----------------------------------------------------------------------------//
//-- Category 59															--//
//----------------------------------------------------------------------------//

local words "Religion Spirituality Prayer God Meditation"  //not enough data for Faith overall (I could try if necessary)

foreach word of local words{
	
	local var = strlower("`word'")  //*Word in lowercase (for variable usage)
	
	*---(1) CSV cleaning---*
	*----------------------*
	forvalues i=0/11{
		
		insheet using "$data/Cat-59/Europe/`word'/weekly_`i'-`word'.csv", delimiter(",") nonames clear
		drop in 1/2
		local var = strlower("`word'")
		rename (v1 v2) (date w_`var')
		label var w_`var' "Weekly queries: 18-20"
		save "$temporal/weekly_`i'-`word'.dta", replace 
		
		insheet using "$data/Cat-59/Europe/`word'/daily19_`i'-`word'.csv", delimiter(",") nonames clear
		drop in 1/2
		local var = strlower("`word'")
		rename (v1 v2) (date d_`var'_19)
		label var d_`var'_19 "Daily queries: 18-19"
		save "$temporal/daily19_`i'-`word'.dta", replace  
		
		insheet using "$data/Cat-59/Europe/`word'/daily20_`i'-`word'.csv", delimiter(",") nonames clear
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
		save "$temporal/final_search_`i'-`word'.dta", replace
		
	}
	
	*---(2) Dates and country id---*
	*------------------------------*
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
	
	
	*---(3) Reescaling data---*
	*-------------------------*
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
	
	*---(4) Merge countries and demographics---*
	*------------------------------------------*
	
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
	
	save "$organized/daily_full_`word'.dta", replace 
}

stop 


**# Bookmark #2
//----------------------------------------------------------------------------//
//-- Category 0																--//
//----------------------------------------------------------------------------//

local words "Religion Spirituality Prayer God Meditation Faith"

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


**# Bookmark #3
//----------------------------------------------------------------------------//
//-- Subcategories	 														--//
//----------------------------------------------------------------------------//

local words "Astrology Buddhism Christianity Hinduism Islam Judaism Paranormal Pagan Places Scientology Selfhelp Skeptic Spirituality Theology"

foreach word of local words{
	
	local var = strlower("`word'")  //*Word in lowercase (for variable usage)
	
	*---(1) CSV cleaning---*
	*----------------------*
	
	forvalues i=0/11{
		display in red "Cleaning for `word' in country `i'"
		
		insheet using "$data/Subcat/Europe/`word'/weekly_`i'-`word'.csv", delimiter(",") nonames clear
		drop in 1/2
		local var = strlower("`word'")
		rename (v1 v2) (date w_`var')
		label var w_`var' "Weekly queries: 18-20"
		save "$temporal/weekly_`i'-`word'.dta", replace 
		
		insheet using "$data/Subcat/Europe/`word'/daily2019_`i'-`word'.csv", delimiter(",") nonames clear
		drop in 1/2
		local var = strlower("`word'")
		rename (v1 v2) (date d_`var'_19)
		label var d_`var'_19 "Daily queries: 18-19"
		save "$temporal/daily19_`i'-`word'.dta", replace  
		
		insheet using "$data/Subcat/Europe/`word'/daily2020_`i'-`word'.csv", delimiter(",") nonames clear
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
		save "$temporal/final_search_`i'-`word'_subcat.dta", replace
		
	}
	
	*---(2) Dates and country id---*
	*------------------------------*
	forvalues i=0/11{
		
		use "$temporal/final_search_`i'-`word'_subcat.dta", clear 
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
		
		save "$temporal/final_search_`i'-`word'_subcat.dta", replace 
		sleep 100
		
	}
	
	*---(3) Reescaling data---*
	*-------------------------*
	forvalues i = 0/11{
		
		use "$temporal/final_search_`i'-`word'_subcat.dta", clear 
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
		
		save "$temporal/adjusted_`i'-`word'_subcat.dta", replace 
		sleep 100
		
	}
	
	*---(4) Merge countries and demographics---*
	*------------------------------------------*
	
	use "$temporal/adjusted_0-`word'_subcat.dta", clear 
	forvalues i = 1/11{
		append using "$temporal/adjusted_`i'-`word'_subcat.dta" 
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
	
	save "$organized/daily_full_`word'_subcat.dta", replace 
	sleep 100
	
}























