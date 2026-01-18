global root "C:/Users/ALBERTO TRELLES/Dropbox/Religion-Covid"
global output "$root/Output"
global input "$root/Input"
global organized "$root/Organized"
global data "$root/Data"
global temporal "$root/Temporal"
global tables "$root/Tables"
global figures "$root/Figures"
cd "$root"

est clear


//----------------------------------------------------------------------------//
//-- Category 0																--//
//----------------------------------------------------------------------------//

local words "Religion Spirituality Prayer God Meditation Faith"

foreach word of local words{
	
	local var = strlower("`word'")
	use "$organized/daily_full_`word'_cat0.dta", clear

	keep if dayssincelockdown!=.

	replace year=year-2019
	gen post_lockdown_year=post_lockdown*year
	label var post_lockdown_year "Period after lockdown *Year"
	
	*New vars
	gen lockdown_week=week if date==date_lockdown_ann
	bysort country: egen m_lockdown_week=mean(lockdown_week)
	replace lockdown_week=m_lockdown_week
	drop m_lockdown_week
	bysort country: gen weeksincelockdown=week-lockdown_week
	drop lockdown_week
		
	xi gen i.weeksincelockdown*year, noomit
		
	drop if weeksincelockdown<-4
		
	replace _IweeXyear_9=0 //omit week -4 
		
	sort country year day
	gen L_dailyconfirmeddeathsdeaths=dailyconfirmeddeathsdeaths[_n-1] if country==country[_n-1]
	
	reghdfe d_`var' _IweeXyear_9-_IweeXyear_17  _Iweeksince* L_dailyconfirmeddeathsdeaths [pw=pop] if country!=6, ///
	absorb(country year week day_w) vce(cluster day)
	
	eststo DID_event_`var'
	estadd local countryFE "Yes", replace
	estadd local timeFE "Yes", replace
	estadd local death "Yes", replace
		
			
	coefplot DID_event_`var', keep(_IweeXyear_*) recast(connected) color(cranberry) ciopts(lcolor(cranberry) ) vertical  ///
	label yline(0, lcolor(black))  ci(95) legend(off) xtitle("Weeks elapsed since the stay-at-home order") ///
	xline(5, lpattern(dash) lcolor(black)) ///
	rename(_IweeXyear_9= "-4" _IweeXyear_10= "-3" _IweeXyear_11="-2" _IweeXyear_12="-1" _IweeXyear_13="0" ///
	_IweeXyear_14="1" _IweeXyear_15="2" _IweeXyear_16="3" _IweeXyear_17="4") omitted ytitle("`var'") 
	
	graph export "$figures\cat0-`word'_event.png", replace height(1440) width(2560)
}


//----------------------------------------------------------------------------//
//-- Subcategories															--//
//----------------------------------------------------------------------------//

local words "Astrology Buddhism Christianity Hinduism Islam Judaism Paranormal Pagan Places Scientology Selfhelp Skeptic Spirituality Theology"

foreach word of local words{
	
	local var = strlower("`word'")
	use "$organized/daily_full_`word'_subcat.dta", clear

	keep if dayssincelockdown!=.

	replace year=year-2019
	gen post_lockdown_year=post_lockdown*year
	label var post_lockdown_year "Period after lockdown *Year"
	
	*New vars
	gen lockdown_week=week if date==date_lockdown_ann
	bysort country: egen m_lockdown_week=mean(lockdown_week)
	replace lockdown_week=m_lockdown_week
	drop m_lockdown_week
	bysort country: gen weeksincelockdown=week-lockdown_week
	drop lockdown_week
		
	xi gen i.weeksincelockdown*year, noomit
		
	drop if weeksincelockdown<-4
		
	replace _IweeXyear_9=0 //omit week -4 
		
	sort country year day
	gen L_dailyconfirmeddeathsdeaths=dailyconfirmeddeathsdeaths[_n-1] if country==country[_n-1]
	
	reghdfe d_`var' _IweeXyear_9-_IweeXyear_17  _Iweeksince* L_dailyconfirmeddeathsdeaths [pw=pop] if country!=6, ///
	absorb(country year week day_w) vce(cluster day)
	
	eststo DID_event_`var'
	estadd local countryFE "Yes", replace
	estadd local timeFE "Yes", replace
	estadd local death "Yes", replace
		
			
	coefplot DID_event_`var', keep(_IweeXyear_*) recast(connected) color(cranberry) ciopts(lcolor(cranberry) ) vertical  ///
	label yline(0, lcolor(black))  ci(95) legend(off) xtitle("Weeks elapsed since the stay-at-home order") ///
	xline(5, lpattern(dash) lcolor(black)) ///
	rename(_IweeXyear_9= "-4" _IweeXyear_10= "-3" _IweeXyear_11="-2" _IweeXyear_12="-1" _IweeXyear_13="0" ///
	_IweeXyear_14="1" _IweeXyear_15="2" _IweeXyear_16="3" _IweeXyear_17="4") omitted ytitle("`var'") 
	
	graph export "$figures\Subcat\subcat-`word'_event.png", replace height(1440) width(2560)
}



*saving("$figures/cat0-`word'_event.gph", replace)
























*---Prayer test---*
*-----------------*

use "$organized/daily_full_Prayer.dta", clear

drop if dayssincelockdown==0

keep if dayssincelockdown!=.

replace year=year-2019
gen post_lockdown_year=post_lockdown*year
label var post_lockdown_year "Period after lockdown *Year"

		
gen lockdown_week=week if date==date_lockdown_ann
bysort country: egen m_lockdown_week=mean(lockdown_week)
replace lockdown_week=m_lockdown_week
drop m_lockdown_week
bysort country: gen weeksincelockdown=week-lockdown_week
drop lockdown_week
		
xi gen i.weeksincelockdown*year, noomit
		
drop if weeksincelockdown<-4
		
replace _IweeXyear_9=0
		
sort country year day
gen L_dailyconfirmeddeathsdeaths=dailyconfirmeddeathsdeaths[_n-1] if country==country[_n-1]
		
reghdfe d_prayer _IweeXyear_9-_IweeXyear_17  _Iweeksince*  ///
L_dailyconfirmeddeathsdeaths [pw=pop] , ///
absorb(country year week day_w) vce(cluster day)


eststo DID_event_prayer
		estadd local countryFE "Yes", replace
		estadd local timeFE "Yes", replace
		estadd local death "Yes", replace
		
		coefplot DID_event_prayer, keep(_IweeXyear_*) recast(connected) color(cranberry) ciopts(lcolor(cranberry) ) vertical  ///
		label yline(0, lcolor(black))  ci(95) legend(off) xtitle("Weeks elapsed since the stay-at-home order") ///
		xline(5, lpattern(dash) lcolor(black)) ///
		rename(_IweeXyear_9= "-4" _IweeXyear_10= "-3" _IweeXyear_11="-2" _IweeXyear_12="-1" _IweeXyear_13="0" ///
		_IweeXyear_14="1" _IweeXyear_15="2" _IweeXyear_16="3" _IweeXyear_17="4") omitted ytitle("`var'") ///
		saving("$results/`var'/`var'_DID_Event.gph", replace)