global root "C:/Users/ALBERTO TRELLES/Dropbox/Religion-Covid"
global output "$root/Output"
global input "$root/Input"
global data "$root/Data"
global organized "$data/Organized"
global raw "$data/Data_collection/raw"
global demographic "$data/Demographic"
global temporal "$root/Temporal"
global tables "$root/Tables"
global figures "$root/Figures"
cd "$root"

// -------------------------------------------------------------------------- //
// --- (1) TWFE															  --- //
// -------------------------------------------------------------------------- //

use "$organized/us_nocat_twfe.dta", clear

global covid L_deaths_avg	//no big changes with different covid covariates 
global words "Faith God Meditation Prayer Religion Spirituality"

*gen D = post_treatment
*replace D = post_treatment = 

local i = 1
foreach word of global words {
	
	local var = lower("`word'")
	
	*---------------------*
	*---(1) Without NT ---*
	*---------------------*
	
	qui sum d_`var' if ann_date!=.
	local mean_sample = r(mean)
	
	*--- TWFE ---*
	reghdfe d_`var' year_post_treatment $covid [pw=pop] if ann_date!=., absorb(state year week dow) vce(cluster day)
	
	eststo a`i'
	estadd scalar obs = e(N)
	estadd scalar pval = r(table)[4,1] 
	estadd scalar mean_s = `mean_sample'	
	
	*--- Het TWFE ---*
	reghdfe d_`var' year_post_treatment post_treatment $covid [pw=pop] if ann_date!=., absorb(state year week dow) vce(cluster day)
	
	eststo b`i'
	estadd scalar obs = e(N)
	estadd scalar pval = r(table)[4,1] 
	estadd scalar mean_s = `mean_sample'
	
	*------------------*
	*---(2) With NT ---*
	*------------------*	
	
	qui sum d_`var'
	local mean_sample = r(mean)
	
	*--- TWFE ---*
	reghdfe d_`var' year_post_treatment $covid [pw=pop], absorb(state year week dow) vce(cluster day)
	
	eststo c`i'
	estadd scalar obs = e(N)
	estadd scalar pval = r(table)[4,1] 
	estadd scalar mean_s = `mean_sample'	
	
	*--- Het TWFE ---*
	reghdfe d_`var' year_post_treatment post_treatment $covid [pw=pop], absorb(state year week dow) vce(cluster day)
	
	eststo d`i'
	estadd scalar obs = e(N)
	estadd scalar pval = r(table)[4,1] 	
	estadd scalar mean_s = `mean_sample'	
	
	local i = `i'+1
	
}

*--------------*
*--- Export ---*
*--------------*

#d ;
estout a? using "$tables/us_twfe.tex", style(tex) replace 
	cells( b(star fmt(%9.3f)) se(par) ) mlabels(none) label collabels(none) 
	stats(mean_s pval obs, fmt(%9.2fc %9.3fc %9.0fc) labels("Mean" "p-value" "Observations")) prefoot(\\) 
	rename(year_post_treatment "T $ \times $ Year") drop(L_deaths_avg _cons) starlevels(* 0.10 ** 0.05 *** 0.01);
#d cr

#d ;
estout b? using "$tables/us_htwfe.tex", style(tex) replace 
	cells( b(star fmt(%9.3f)) se(par) ) mlabels(none) label collabels(none) 
	stats(mean_s pval obs, fmt(%9.2fc %9.3fc %9.0fc) labels("Mean" "p-value" "Observations")) prefoot(\\) 
	rename(year_post_treatment "T $ \times $ Year") drop(post_treatment L_deaths_avg _cons) starlevels(* 0.10 ** 0.05 *** 0.01);
#d cr

#d ;
estout c? using "$tables/us_twfe_nt.tex", style(tex) replace 
	cells( b(star fmt(%9.3f)) se(par) ) mlabels(none) label collabels(none) 
	stats(mean_s pval obs, fmt(%9.2fc %9.3fc %9.0fc) labels("Mean" "p-value" "Observations")) prefoot(\\) 
	rename(year_post_treatment "T $ \times $ Year") drop(L_deaths_avg _cons) starlevels(* 0.10 ** 0.05 *** 0.01);
#d cr

#d ;
estout d? using "$tables/us_htwfe_nt.tex", style(tex) replace 
	cells( b(star fmt(%9.3f)) se(par) ) mlabels(none) label collabels(none) 
	stats(mean_s pval obs, fmt(%9.2fc %9.3fc %9.0fc) labels("Mean" "p-value" "Observations")) prefoot(\\) 
	rename(year_post_treatment "T $ \times $ Year") drop(post_treatment L_deaths_avg _cons) starlevels(* 0.10 ** 0.05 *** 0.01);
#d cr


// -------------------------------------------------------------------------- //
// --- (2) Descriptive Time-series										  --- //
// -------------------------------------------------------------------------- //

*--------------------*
*--- 2019 vs 2020 ---*
*--------------------*
use "$organized/us_nocat_twfe.dta", clear
collapse (mean) d_* [pw=pop] , by(year day)

foreach word of global words {
	
	local var = lower("`word'")
	
	twoway ///
		(connected d_`var' day if year == 2019, lcolor("140 170 225") mcolor("140 170 225")) ///
		(connected d_`var' day if year == 2020, lcolor("225 140 140") mcolor("225 140 140")), ///
		legend(order(1 "2019" 2 "2020")) ///
		xtitle("Day") ytitle("RSI (mean)")
	
	graph export "$figures/descriptive/us_`var'_series.png", replace height(1440) width(2560)
	
}

*--------------------------------*
*--- NT vs Eventually Treated ---*
*--------------------------------*
use "$organized/us_nocat_twfe.dta", clear
gen nt = (ann_date==.)	//Never-treated observations 

collapse (mean) d_* [pw=pop] , by(nt year day)
replace day=day-101 if year==2019

foreach word of global words {
	
	local var = lower("`word'")
	
	twoway ///
		(connected d_`var' day if nt == 1, lcolor("140 170 225") mcolor("140 170 225")) ///
		(connected d_`var' day if nt == 0, lcolor("225 140 140") mcolor("225 140 140")), ///
		legend(order(1 "Never-treated" 2 "Eventually Treated")) ///
		xtitle("Day") ytitle("RSI (mean)")
	
	graph export "$figures/descriptive/us_`var'_series_nt.png", replace height(1440) width(2560)
	
}

*---------------------------------------------*
*--- Not yet treated vs Eventually Treated ---*
*---------------------------------------------* 
use "$organized/us_nocat_twfe.dta", clear

gen dayssincetreat = noyear_edate - ann_date	//NA for NT. Duplicated values for paired 2019 days 
replace dayssincetreat=. if year==2019

gen nyt = (dayssincetreat<0 | dayssincetreat==.)

collapse (mean) d_* [pw=pop] , by(nyt year day)
replace day=day-101 if year==2019

foreach word of global words {
	
	local var = lower("`word'")
	
	twoway ///
		(connected d_`var' day if nyt == 1, lcolor("140 170 225") mcolor("140 170 225")) ///
		(connected d_`var' day if nyt == 0, lcolor("225 140 140") mcolor("225 140 140")), ///
		legend(order(1 "Never-treated" 2 "Currently Treated")) ///
		xtitle("Day") ytitle("RSI (mean)")
	
	graph export "$figures/descriptive/us_`var'_series_nyt.png", replace height(1440) width(2560)
	
}















