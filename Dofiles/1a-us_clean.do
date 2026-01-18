global root "C:/Users/ALBERTO TRELLES/Dropbox/Religion-Covid"
global output "$root/Output"
global input "$root/Input"
global data "$root/Data"
global organized "$data/Organized"
global raw "$data/Data_collection/raw"
global demographic "$data/Demographic"
global temporal "$root/Temporal"
cd "$root"


**# Bookmark #1
// -------------------------------------------------------------------------- //
// --- (1) Covid-19 Data												  --- //
// -------------------------------------------------------------------------- //

*---State codes---* 
use "$demographic/US/us_idfile.dta", clear
ren (STUSPS NAME) (state state_name)
keep state state_name
save "$demographic/US/us_idfile_clean.dta", replace

*---Covid-19 cases---* 
import delimited "$demographic/US/us_covid19.csv", clear
ren state state_name 

gen edate=date(date, "YMD")
format edate %d

qui sum edate if date=="2020-04-10"
keep if edate <= r(max)
sort state_name edate

keep (state_name cases_avg deaths_avg cases deaths edate)
merge m:1 state_name using "$demographic/US/us_idfile_clean.dta"
drop if _merge!=3
drop _merge

order state state_name edate
save "$demographic/US/us_covid19_clean.dta", replace

*---US population---*
use "$demographic/US/us_pop.dta", clear
keep state_name pop
duplicates drop

merge 1:1 state_name using "$demographic/US/us_idfile_clean.dta"
drop if _merge!=3
drop _merge

order (state state_name pop)
save "$demographic/US/us_pop_clean.dta", replace

*---Lockdown_US---*
use "$demographic/US/us_lockdown.dta", clear
drop state

merge 1:1 state_name using "$demographic/US/us_idfile_clean.dta"
drop if _merge!=3
drop _merge

order (state state_name)
save "$demographic/US/us_lockdown_clean.dta", replace 

*---Merge US demographics---*
use "$demographic/US/us_pop_clean.dta", clear
merge 1:1 state state_name using "$demographic/US/us_lockdown_clean.dta", nogen
merge 1:m state state_name using "$demographic/US/us_covid19_clean.dta"
drop if _merge!=3	//Drop Guan & Puerto Rico 
drop _merge

order (state state_name edate)
sort state edate
save "$demographic/US/us_demographic_clean.dta", replace


**# Bookmark #2
// -------------------------------------------------------------------------- //
// --- (2) GT Data 														  --- //
// -------------------------------------------------------------------------- //

global ll19 = date("2018-12-30", "YMD")
global ul19 = date("2019-04-13", "YMD")
global ll20 = date("2019-12-29", "YMD")
global ul20 = date("2020-04-11", "YMD")
global states "AL AK AZ AR CA CO CT DE FL GA HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT VT VA WA WV WI WY"

*------------------*
*--- 2A. Topics ---*
*------------------*
global words "Faith God Meditation Prayer Religion Spirituality"

foreach word of global words {
    local var = lower("`word'") 

    foreach state of global states {

		*---(1) Clean & Merge series ---*
		*-------------------------------*		
        frame change default

        *---Weekly queries---*
        cap frame drop weekly
        frame create weekly
        frame weekly: insheet using "$raw/US/nocat/`state'/weekly_`word'_`state'.csv", delimiter(",") nonames clear
        frame weekly: drop in 1/2 
        frame weekly: rename (v1 v2) (date w_`var')
        frame weekly: label var w_`var' "Weekly queries"

        *---2019 queries---*
        cap frame drop d19
        frame create d19
        frame d19: insheet using "$raw/US/nocat/`state'/daily19_`word'_`state'.csv", delimiter(",") nonames clear
        frame d19: drop in 1/2 
        frame d19: rename (v1 v2) (date d_`var'_19)
        frame d19: label var d_`var'_19 "Daily queries 2019"

        *---2020 queries---*
        cap frame drop d20
        frame create d20
        frame d20: insheet using "$raw/US/nocat/`state'/daily20_`word'_`state'.csv", delimiter(",") nonames clear
        frame d20: drop in 1/2 
        frame d20: rename (v1 v2) (date d_`var'_20)
        frame d20: label var d_`var'_20 "Daily queries 2020"

        *---Merge---*
		tempfile d19file d20file
        frame d19: save `d19file'
        frame d20: save `d20file'
		
        frame change weekly
        merge 1:1 date using `d19file', nogen
        merge 1:1 date using `d20file', nogen
		
		sort date 
		gen edate=date(date, "YMD")
		format edate %d
		keep if inrange(edate, ${ll19}, ${ul19}) | inrange(edate, ${ll20}, ${ul20})	//Keep relevant days for escaling 
		
		replace w_`var'=w_`var'[_n-1] if w_`var'==""
		destring *`var'*, replace
		gen state="`state'"

        save "$temporal/clean_`state'_`word'.dta", replace
		
		*---(2) Unify RSI ---*
		*--------------------*
        use "$temporal/clean_`state'_`word'.dta", clear
		
		*---Dates---*
		gen year=year(edate)  
		gen month=month(edate)
		gen dow = dow(edate)+1   				//Day of week (1:Sunday-7:Saturday)
		gen week_id = floor((_n - 1) / 7) + 1	//Week FE (1-30) (Later week of year)
		
		*---Unify Series---*
		bysort week_id: egen div19 = sum(d_`var'_19)
		bysort week_id: egen div20 = sum(d_`var'_20)
		
		gen c_`var'_19 = (d_`var'_19/div19)*w_`var'		//Comparable 2019 series
		gen c_`var'_20 = (d_`var'_20/div20)*w_`var'		//Comaprable 2020 series 
		
		gen d_`var'=. 
		replace d_`var' = c_`var'_19 if c_`var'_19!=.	
		replace d_`var' = c_`var'_20 if c_`var'_20!=.
		
		qui sum d_`var'
		local max = r(max)
		replace d_`var' = (d_`var'/`max')*100			//1-100 unified RSI 
		
		*---Dates for regression---*
		drop if inlist(date, "2018-12-30", "2018-12-31", "2019-04-11", "2019-04-12", "2019-04-13")	//2019 extra days 
		drop if inlist(date, "2019-12-29", "2019-12-30", "2019-12-31", "2020-04-11")				//2020 extra days 
		drop if date=="2020-02-29"																	//29-feb in 2020 
		
		save "$temporal/RSI_`state'_`word'.dta", replace
		
    }
}

*--- (3) Merge data ---*
*----------------------*

*---Append states---*
foreach word of global words{
	local var = lower("`word'") 
	foreach state of global states{
		if ("`state'"=="AL"){
			use "$temporal/RSI_`state'_`word'", clear
		}
		else{
			append using "$temporal/RSI_`state'_`word'"
		}
	}
	drop (w_`var' d_`var'_19 d_`var'_20 div19 div20 c_`var'_19 c_`var'_20)
	save "$temporal/us_nocat_`word'.dta", replace
}

*---Merge words---*
foreach word of global words{
	if ("`word'"=="Faith"){
		use "$temporal/us_nocat_`word'.dta", clear
	}
	else{
		merge 1:1 state date edate using "$temporal/us_nocat_`word'.dta"
		drop _merge 
	}
}
cap drop _merge 
save "$temporal/us_nocat_nodem.dta", replace

*---Merge demographics---* 
use "$temporal/us_nocat_nodem.dta", clear
merge 1:1 state edate using "$demographic/US/us_demographic_clean.dta"

*Fill-in missings 
gsort state -_merge //demographics appear first 

foreach var in state_name pop date_lockdown date_announced city_enactedfirst{
	by state: replace `var' = `var'[_n-1] if missing(`var')
}

foreach var in cases_avg deaths_avg cases deaths{
	replace `var'=0 if `var'==.
}

sort state year edate
gen pre_covid = (_merge==1)

save "$organized/us_nocat.dta", replace


*-------------------------*
*--- 2B. Subcategories ---*
*-------------------------*
global subcategories "Astrology Buddhism Christianity Hinduism Islam Judaism Occult Paganism Worship Scientology Selfhelp Skeptics Spirituality Theology"

foreach subcat of global subcategories {
    local var = lower("`subcat'") 

    foreach state of global states {
		
		*-------------------------------*
		*---(1) Clean & Merge series ---*
		*-------------------------------*		
        frame change default

        *---Weekly queries---*
        cap frame drop weekly
        frame create weekly
        frame weekly: insheet using "$raw/US/subcat/`state'/weekly_`subcat'_`state'.csv", delimiter(",") nonames clear
        frame weekly: drop in 1/2 
        frame weekly: rename (v1 v2) (date w_`var')
        frame weekly: label var w_`var' "Weekly queries"

        *---2019 queries---*
        cap frame drop d19
        frame create d19
        frame d19: insheet using "$raw/US/subcat/`state'/daily19_`subcat'_`state'.csv", delimiter(",") nonames clear
        frame d19: drop in 1/2 
        frame d19: rename (v1 v2) (date d_`var'_19)
        frame d19: label var d_`var'_19 "Daily queries 2019"

        *---2020 queries---*
        cap frame drop d20
        frame create d20
        frame d20: insheet using "$raw/US/subcat/`state'/daily20_`subcat'_`state'.csv", delimiter(",") nonames clear
        frame d20: drop in 1/2 
        frame d20: rename (v1 v2) (date d_`var'_20)
        frame d20: label var d_`var'_20 "Daily queries 2020"

        *---Merge---*
		tempfile d19file d20file
        frame d19: save `d19file'
        frame d20: save `d20file'
		
        frame change weekly
        merge 1:1 date using `d19file', nogen
        merge 1:1 date using `d20file', nogen
		
		sort date 
		gen edate=date(date, "YMD")
		format edate %d
		keep if inrange(edate, ${ll19}, ${ul19}) | inrange(edate, ${ll20}, ${ul20})	//Keep relevant days for escaling 
		
		replace w_`var'=w_`var'[_n-1] if w_`var'==""
		destring *`var'*, replace
		gen state="`state'"

        save "$temporal/clean_`state'_`subcat'_subcat.dta", replace
		
		*--------------------*
		*---(2) Unify RSI ---*
		*--------------------*
        use "$temporal/clean_`state'_`subcat'_subcat.dta", clear
		
		*---Dates---*
		gen year=year(edate)  
		gen month=month(edate)
		gen dow = dow(edate)+1   				//Day of week (1:Sunday-7:Saturday)
		gen week_id = floor((_n - 1) / 7) + 1	//Week FE (1-30) (Later week of year)
		
		*---Unify Series---*
		bysort week_id: egen div19 = sum(d_`var'_19)
		bysort week_id: egen div20 = sum(d_`var'_20)
		
		gen c_`var'_19 = (d_`var'_19/div19)*w_`var'		//Comparable 2019 series
		gen c_`var'_20 = (d_`var'_20/div20)*w_`var'		//Comaprable 2020 series 
		
		gen d_`var'=. 
		replace d_`var' = c_`var'_19 if c_`var'_19!=.	
		replace d_`var' = c_`var'_20 if c_`var'_20!=.
		
		qui sum d_`var'
		local max = r(max)
		replace d_`var' = (d_`var'/`max')*100			//1-100 unified RSI 
		
		*---Dates for regression---*
		drop if inlist(date, "2018-12-30", "2018-12-31", "2019-04-11", "2019-04-12", "2019-04-13")	//2019 extra days 
		drop if inlist(date, "2019-12-29", "2019-12-30", "2019-12-31", "2020-04-11")				//2020 extra days 
		drop if date=="2020-02-29"																	//29-feb in 2020 
		
		save "$temporal/RSI_`state'_`subcat'_subcat.dta", replace
		
    }
}

*--- (3) Merge data ---*
*----------------------*

*---Append states---*
foreach subcat of global subcategories{
	local var = lower("`subcat'") 
	foreach state of global states{
		if ("`state'"=="AL"){
			use "$temporal/RSI_`state'_`subcat'_subcat.dta", clear
		}
		else{
			append using "$temporal/RSI_`state'_`subcat'_subcat.dta"
		}
	}
	drop (w_`var' d_`var'_19 d_`var'_20 div19 div20 c_`var'_19 c_`var'_20)
	save "$temporal/us_subcat_`subcat'.dta", replace
}

*---Merge words---*
foreach subcat of global subcategories{
	if ("`subcat'"=="Astrology"){
		use "$temporal/us_subcat_`subcat'.dta", clear
	}
	else{
		merge 1:1 state date edate using "$temporal/us_subcat_`subcat'.dta"
		drop _merge 
	}
}
cap drop _merge 
save "$temporal/us_subcat_nodem.dta", replace

*---Merge demographics---* 
use "$temporal/us_subcat_nodem.dta", clear
merge 1:1 state edate using "$demographic/US/us_demographic_clean.dta"

*Fill-in missings 
gsort state -_merge //demographics appear first 

foreach var in state_name pop date_lockdown date_announced city_enactedfirst{
	by state: replace `var' = `var'[_n-1] if missing(`var')
}

foreach var in cases_avg deaths_avg cases deaths{
	replace `var'=0 if `var'==.
}

sort state year edate
gen pre_covid = (_merge==1)

save "$organized/us_subcat.dta", replace



/*

**# Bookmark #3
// -------------------------------------------------------------------------- //
// --- (3) DiD Panel													  --- //
// -------------------------------------------------------------------------- //
use "$organized/us_nocat.dta", clear
sort state year edate
by state year: gen day=_n

gen ann_date=date(date_announced, "YMD")
format ann_date %d

*Post_treatment (=1 for 2019 paired days)
gen noyear_edate = edate
replace noyear_edate = edate + 365 if year==2019 
replace noyear_edate = noyear_edate+1 if year==2019 & noyear_edate>=21974	//handle bissextile year 
format noyear_edate %d
by state: gen post_treatment = (noyear_edate >= ann_date)
*drop noyear_edate

*Year dummy
gen dyear=(year==2020)

*Year x post_treatment 
gen year_post_treatment = dyear*post_treatment

*Lagged covid variables
foreach var in cases_avg deaths_avg cases deaths{
	gen L_`var' = `var'[_n-1] if state==state[_n-1]
	replace L_`var' = 0 if L_`var' & state!=state[_n-1]
}

*Week of year 
replace week_id=week_id-15 if year==2020

*Relative time 
gen dayssincetreat = noyear_edate - ann_date	//NA for NT. Duplicated values for paired 2019 days 


drop if _merge==2
save "$organized/us_nocat_twfe.dta", replace


	
*any set of covid19 controls is good for results (prayer at least)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	


