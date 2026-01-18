global root "C:/Users/ALBERTO TRELLES/Dropbox/Religion-Covid"
global output "$root/Output"
global input "$root/Input"
global organized "$root/Organized"
global data "$root/Data"
global temporal "$root/Temporal"
global tables "$root/Tables"
cd "$root"

est clear


//----------------------------------------------------------------------------//
//-- Category 59															--//
//----------------------------------------------------------------------------//

local words "Religion Spirituality Prayer God Meditation" 

foreach word of local words{
	
	local var = strlower("`word'")

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
	reghdfe d_`var' post_lockdown_year post_lockdown L_dailyconfirmeddeathsdeaths [pw=pop] if country!=6, absorb(country year week day_w) vce(cluster day)
	
	eststo did_`var'_59
	estadd scalar obs=e(N)
	estadd scalar pval=r(table)[4,1]
	
	*Standardized 
	reghdfe std_d_`var' post_lockdown_year post_lockdown L_dailyconfirmeddeathsdeaths [pw=pop] if country!=6, absorb(country year week day_w) vce(cluster day)
	
	eststo did_`var'_59_std
	estadd scalar obs=e(N)
	estadd scalar pval=r(table)[4,1]	

}

stop 

//----------------------------------------------------------------------------//
//-- Category 0																--//
//----------------------------------------------------------------------------//

local words "Religion Spirituality Prayer God Meditation Faith"

foreach word of local words{
	
	local var = strlower("`word'")

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
	reghdfe d_`var' post_lockdown_year post_lockdown L_dailyconfirmeddeathsdeaths [pw=pop] if country!=6, absorb(country year week day_w) vce(cluster day)
	
	eststo did_`var'_0
	estadd scalar obs=e(N)
	estadd scalar pval=r(table)[4,1]
	
	*Standardized 
	reghdfe std_d_`var' post_lockdown_year post_lockdown L_dailyconfirmeddeathsdeaths [pw=pop] if country!=6, absorb(country year week day_w) vce(cluster day)
	
	eststo did_`var'_0_std
	estadd scalar obs=e(N)
	estadd scalar pval=r(table)[4,1]	

}

reg d_faith, nocons
eststo e

//----------------------------------------------------------------------------//
//-- Subcategories	 														--//
//----------------------------------------------------------------------------//

local words "Astrology Buddhism Christianity Hinduism Islam Judaism Paranormal Pagan Places Scientology Selfhelp Skeptic Spirituality Theology"

foreach word of local words{
	
	local var = strlower("`word'")

	use "$organized/daily_full_`word'_subcat.dta", clear
	sort country year day
	
	drop if dayssincelockdown==0
	keep if dayssincelockdown!=.	//only countries that adopted full-lockdown 
	replace year = year-2019		//year dummy 
	
	gen post_lockdown_year = post_lockdown*year
	label var post_lockdown_year "Period after lockdown * Year"
	
	gen L_dailyconfirmeddeathsdeaths = dailyconfirmeddeathsdeaths[_n-1] if country==country[_n-1]
	by country: egen std_d_`var' = std(d_`var')
	
	*Non-standardized
	reghdfe d_`var' post_lockdown_year post_lockdown L_dailyconfirmeddeathsdeaths [pw=pop] if country!=6, absorb(country year week day_w) vce(cluster day)
	
	eststo did_`var'_subcat
	estadd scalar obs=e(N)
	estadd scalar pval=r(table)[4,1]
	
	*Standardized 
	reghdfe std_d_`var' post_lockdown_year post_lockdown L_dailyconfirmeddeathsdeaths [pw=pop] if country!=6, absorb(country year week day_w) vce(cluster day)
	
	eststo did_`var'_subcat_std
	estadd scalar obs=e(N)
	estadd scalar pval=r(table)[4,1]	

}

reg d_theology, nocons
eststo e

*Subcat results
#d ;
estout did_astrology_subcat did_buddhism_subcat did_christianity_subcat did_hinduism_subcat did_islam_subcat did_judaism_subcat did_paranormal_subcat using "$tables/did_subcat1.tex", style(tex) replace 
	cells( b(star fmt(%9.3f)) se(par) ) mlabels(none) label collabels(none) 
	stats(pval obs, fmt(%9.3fc %9.0fc) labels("p-value" "Observations")) prefoot(\\) 
	rename(post_lockdown_year "T $ \times $ Year") drop(post_lockdown L_dailyconfirmeddeathsdeaths _cons)
	starlevels(* 0.10 ** 0.05 *** 0.01);
#d cr

#d ;
estout did_astrology_subcat_std did_buddhism_subcat_std did_christianity_subcat_std did_hinduism_subcat_std did_islam_subcat_std did_judaism_subcat_std did_paranormal_subcat_std using "$tables/did_subcat1_std.tex", style(tex) replace 
	cells( b(star fmt(%9.3f)) se(par) ) mlabels(none) label collabels(none) 
	stats(pval obs, fmt(%9.3fc %9.0fc) labels("p-value" "Observations")) prefoot(\\) 
	rename(post_lockdown_year "T $ \times $ Year") drop(post_lockdown L_dailyconfirmeddeathsdeaths _cons)
	starlevels(* 0.10 ** 0.05 *** 0.01);
#d cr


#d ;
estout did_pagan_subcat did_places_subcat did_scientology_subcat did_selfhelp_subcat did_skeptic_subcat did_spirituality_subcat did_theology_subcat using "$tables/did_subcat2.tex", style(tex) replace 
	cells( b(star fmt(%9.3f)) se(par) ) mlabels(none) label collabels(none) 
	stats(pval obs, fmt(%9.3fc %9.0fc) labels("p-value" "Observations")) prefoot(\\) 
	rename(post_lockdown_year "T $ \times $ Year") drop(post_lockdown L_dailyconfirmeddeathsdeaths _cons)
	starlevels(* 0.10 ** 0.05 *** 0.01);
#d cr

#d ;
estout did_pagan_subcat_std did_places_subcat_std did_scientology_subcat_std did_selfhelp_subcat_std did_skeptic_subcat_std did_spirituality_subcat_std did_theology_subcat_std using "$tables/did_subcat2_std.tex", style(tex) replace 
	cells( b(star fmt(%9.3f)) se(par) ) mlabels(none) label collabels(none) 
	stats(pval obs, fmt(%9.3fc %9.0fc) labels("p-value" "Observations")) prefoot(\\) 
	rename(post_lockdown_year "T $ \times $ Year") drop(post_lockdown L_dailyconfirmeddeathsdeaths _cons)
	starlevels(* 0.10 ** 0.05 *** 0.01);
#d cr





#d ;
estout did_*_subcat using "$tables/did_subcat1.tex", style(tex) replace 
	cells( b(star fmt(%9.3f)) se(par) ) mlabels(none) label collabels(none) 
	stats(pval obs, fmt(%9.3fc %9.0fc) labels("p-value" "Observations")) prefoot(\\) 
	rename(post_lockdown_year "T $ \times $ Year") drop(post_lockdown L_dailyconfirmeddeathsdeaths _cons)
	starlevels(* 0.10 ** 0.05 *** 0.01);
#d cr

#d ;
estout did_*_subcat_std e using "$tables/did_subcat_std.tex", style(tex) replace 
	cells( b(star fmt(%9.3f)) se(par) ) mlabels(none) label collabels(none) 
	stats(pval obs, fmt(%9.3fc %9.0fc) labels("p-value" "Observations")) prefoot(\\) 
	rename(post_lockdown_year "T $ \times $ Year") drop(post_lockdown L_dailyconfirmeddeathsdeaths _cons)
	starlevels(* 0.10 ** 0.05 *** 0.01);
#d cr















*---------------*
*---Tables------*
*---------------*

#d ;
estout did_*_0 using "$tables/did_cat0.tex", style(tex) replace 
	cells( b(star fmt(%9.3f)) se(par) ) mlabels(none) label collabels(none) 
	stats(pval obs, fmt(%9.3fc %9.0fc) labels("p-value" "Observations")) prefoot(\\) 
	rename(post_lockdown_year "T $ \times $ Year") drop(post_lockdown L_dailyconfirmeddeathsdeaths _cons)
	starlevels(* 0.10 ** 0.05 *** 0.01);
#d cr

#d ;
estout did_*_0_std using "$tables/did_cat0_std.tex", style(tex) replace 
	cells( b(star fmt(%9.3f)) se(par) ) mlabels(none) label collabels(none) 
	stats(pval obs, fmt(%9.3fc %9.0fc) labels("p-value" "Observations")) prefoot(\\) 
	rename(post_lockdown_year "T $ \times $ Year") drop(post_lockdown L_dailyconfirmeddeathsdeaths _cons)
	starlevels(* 0.10 ** 0.05 *** 0.01);
#d cr

#d ;
estout did_*_59 e using "$tables/did_cat59.tex", style(tex) replace 
	cells( b(star fmt(%9.3f)) se(par) ) mlabels(none) label collabels(none) 
	stats(pval obs, fmt(%9.3fc %9.0fc) labels("p-value" "Observations")) prefoot(\\) 
	rename(post_lockdown_year "T $ \times $ Year") drop(post_lockdown L_dailyconfirmeddeathsdeaths _cons)
	starlevels(* 0.10 ** 0.05 *** 0.01);
#d cr

#d ;
estout did_*_59_std e using "$tables/did_cat59_std.tex", style(tex) replace 
	cells( b(star fmt(%9.3f)) se(par) ) mlabels(none) label collabels(none) 
	stats(pval obs, fmt(%9.3fc %9.0fc) labels("p-value" "Observations")) prefoot(\\) 
	rename(post_lockdown_year "T $ \times $ Year") drop(post_lockdown L_dailyconfirmeddeathsdeaths _cons)
	starlevels(* 0.10 ** 0.05 *** 0.01);
#d cr





























********************************************************************************
use "$organized/daily_full_prayer.dta", clear
br if dayssincelockdown==.  //Germany, Netherlands, and Switzerland didn't enforce full-lockdowns 














