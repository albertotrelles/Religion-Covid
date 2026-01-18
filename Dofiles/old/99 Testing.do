global root "C:/Users/ALBERTO TRELLES/Documents/Alberto/Religion-Covid"
global output "$root/Output"
global input "$root/Input"
global organized "$root/Organized"
global data "$root/Data"
global temporal "$root/Temporal"
cd "$root"

est clear 
use "$organized/daily_full_religion_cat0.dta", clear

**# Bookmark #1
//----------------------------------------------------------------------------//
//-- Effects of full-lockdown												--//
//----------------------------------------------------------------------------//

local words "Religion Spirituality Prayer"

foreach word of local words{
	
	local var = strlower("`word'")
	
	*---No category---*
	*-----------------*
	use "$organized/daily_full_`word'_cat0.dta", clear
	sort country year day
	
	drop if dayssincelockdown==0
	keep if dayssincelockdown!=.	//only countries that adopted full-lockdown 
	replace year = year-2019		//year dummy 
	
	gen post_lockdown_year = post_lockdown*year
	label var post_lockdown_year "Period after lockdown * Year"
	
	gen L_dailyconfirmeddeathsdeaths = dailyconfirmeddeathsdeaths[_n-1] if country==country[_n-1]
	by country: egen std_d_`var' = std(d_`var')
	
	*Non-standardized
	reghdfe d_`var' post_lockdown_year post_lockdown L_dailyconfirmeddeathsdeaths [pw=pop], absorb(country year week day_w) vce(cluster day)
	
	eststo did_`var'_0
	estadd scalar obs=e(N)
	estadd scalar pval=r(table)[4,1]
	
	*Standardized 
	reghdfe std_d_`var' post_lockdown_year post_lockdown L_dailyconfirmeddeathsdeaths [pw=pop], absorb(country year week day_w) vce(cluster day)
	
	eststo did_`var'_std_0
	estadd scalar obs=e(N)
	estadd scalar pval=r(table)[4,1]
	
	
	*---Category 59---*
	*-----------------*
	use "$organized/daily_full_`word'.dta", clear
	sort country year day
	
	drop if dayssincelockdown==0
	keep if dayssincelockdown!=.	//only countries that adopted full-lockdown 
	replace year = year-2019		//year dummy 
	
	gen post_lockdown_year = post_lockdown*year
	label var post_lockdown_year "Period after lockdown * Year"
	
	gen L_dailyconfirmeddeathsdeaths = dailyconfirmeddeathsdeaths[_n-1] if country==country[_n-1]
	by country: egen std_d_`var' = std(d_`var')
	
	*Non-standardized
	reghdfe d_`var' post_lockdown_year post_lockdown L_dailyconfirmeddeathsdeaths [pw=pop], absorb(country year week day_w) vce(cluster day)
	
	eststo did_`var'_59
	estadd scalar obs=e(N)
	estadd scalar pval=r(table)[4,1]
	
	*Standardized 
	reghdfe std_d_`var' post_lockdown_year post_lockdown L_dailyconfirmeddeathsdeaths [pw=pop], absorb(country year week day_w) vce(cluster day)
	
	eststo did_`var'_std_59
	estadd scalar obs=e(N)
	estadd scalar pval=r(table)[4,1]	

}
stop 

************************************************************



































*---Religion---*
*--------------*
use "$organized/daily_full_Religion_cat0.dta", clear

drop if dayssincelockdown==0   //drop t0 and its counterpart at 2019
keep if dayssincelockdown!=.
replace year=year-2019
gen post_lockdown_year=post_lockdown*year
label var post_lockdown_year "Period after lockdown *Year"
sort country year day  	
gen L_dailyconfirmeddeathsdeaths = dailyconfirmeddeathsdeaths[_n-1] if country==country[_n-1]
by country: egen std_d_religion = std(d_religion)

*drop if country==6	//dropping Luxembourg (no data)

reghdfe d_religion post_lockdown_year post_lockdown L_dailyconfirmeddeathsdeaths [pw=pop], absorb(country year week day_w) vce(cluster day)

reghdfe d_religion post_lockdown_year post_lockdown L_dailyconfirmeddeathsdeaths [pw=pop], absorb(country year week day_w) cluster(day)

reghdfe std_d_religion post_lockdown_year post_lockdown L_dailyconfirmeddeathsdeaths [pw=pop], absorb(country year week day_w) vce(cluster day)


reghdfe d_religion post_lockdown_year post_lockdown L_dailyconfirmeddeathsdeaths [pw=pop], absorb(country day) 

*---Spirituality---*
*------------------*
use "$organized/daily_full_Spirituality.dta", clear

drop if dayssincelockdown==0
keep if dayssincelockdown!=.
replace year=year-2019
gen post_lockdown_year=post_lockdown*year
label var post_lockdown_year "Period after lockdown *Year"
sort country year day  	
gen L_dailyconfirmeddeathsdeaths = dailyconfirmeddeathsdeaths[_n-1] if country==country[_n-1]
by country: egen std_d_spirituality = std(d_spirituality)

*drop if country==6	//dropping Luxembourg (no data)

reghdfe d_spirituality post_lockdown_year post_lockdown L_dailyconfirmeddeathsdeaths [pw=pop], absorb(country year week day_w) vce(cluster day)

reghdfe std_d_spirituality post_lockdown_year post_lockdown L_dailyconfirmeddeathsdeaths [pw=pop], absorb(country year week day_w) vce(cluster day)


*---Prayer---*
*------------*
use "$organized/daily_full_Prayer_cat0.dta", clear

drop if dayssincelockdown==0
keep if dayssincelockdown!=.
replace year=year-2019
gen post_lockdown_year=post_lockdown*year
label var post_lockdown_year "Period after lockdown *Year"
sort country year day  	
gen L_dailyconfirmeddeathsdeaths = dailyconfirmeddeathsdeaths[_n-1] if country==country[_n-1]
by country: egen std_d_prayer = std(d_prayer)

drop if country==6	//dropping Luxembourg (no data)

reghdfe d_prayer post_lockdown_year post_lockdown L_dailyconfirmeddeathsdeaths [pw=pop], absorb(country year week day_w) vce(cluster day)

reghdfe std_d_prayer post_lockdown_year post_lockdown L_dailyconfirmeddeathsdeaths [pw=pop], absorb(country year week day_w) vce(cluster day)





