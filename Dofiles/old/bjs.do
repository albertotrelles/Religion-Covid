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

global words "Faith God Meditation Prayer Religion Spirituality"

local var "prayer"
did_imputation d_`var' state edate ann_date [aw=pop], fe(post_treatment state year week_id dow) wtr(pop) cluster(day) 

// -------------------------------------------------------------------------- //
// --- (1) BJS Static													  --- //
// -------------------------------------------------------------------------- //
use "$organized/us_nocat_twfe.dta", clear

local i = 1
foreach word of global words {
	
    local var = lower("`word'") 

	qui sum d_`var' if year_post_treatment==0
	local mean_sample = r(mean)
	
	*--- BJS ---*
	did_imputation d_`var' state edate ann_date [aw=pop], fe(post_treatment state year week_id dow) cluster(day) wtr(pop) saveestimates(y0_`var')
	
	eststo a`i'
	estadd scalar obs0 = e(N)
	estadd scalar obs1 = e(Nt)[1,1]
	estadd scalar pval = r(table)[4,1] 
	estadd scalar mean_s = `mean_sample'
	
	local i = `i'+1
}

*--------------*
*--- Export ---*
*--------------*

#d ;
estout a? using "$tables/us_bjs.tex", style(tex) replace 
	cells( b(star fmt(%9.3f)) se(par) ) mlabels(none) label collabels(none) 
	stats(mean_s pval obs0 obs1, fmt(%9.2fc %9.3fc %9.0fc) labels("Mean" "p-value" "Observations $\Omega_0$" "Observations $\Omega_1$")) prefoot(\\)
	rename(tau "ATT") starlevels(* 0.10 ** 0.05 *** 0.01);
#d cr


// -------------------------------------------------------------------------- //
// --- (2) Pretrends Test												  --- //
// -------------------------------------------------------------------------- //
use "$organized/us_nocat_twfe.dta", clear

cap drop pre*
cap drop ypre*
gen pre1 = (inrange(dayssincetreat, -7, -1))
gen pre2 = (inrange(dayssincetreat, -14, -8))
gen pre3 = (inrange(dayssincetreat, -21, -15))
gen pre4 = (inrange(dayssincetreat, -28, -22))
gen pre5 = (inrange(dayssincetreat, -35, -29))
gen pre6 = (inrange(dayssincetreat, -42, -36))
gen pre7 = (inrange(dayssincetreat, -49, -43))
gen pre8 = (inrange(dayssincetreat, -56, -50))
gen pre9 = (inrange(dayssincetreat, -63, -57))
gen pre10 = (inrange(dayssincetreat, -70, -64))
gen pre11 = (inrange(dayssincetreat, -77, -71))
gen pre12 = (dayssincetreat<=-78 & dayssincetreat!=.)

forval i = 1/12{
	gen ypre`i' = dyear*pre`i'
	label variable ypre`i' "$\mathds{1}[2020] \times E_{-`i'}$"
}

*------------*
*--- Test ---*
*------------*

local i = 1
foreach word of global words {
	
    local var = lower("`word'") 

	qui sum d_`var' if year_post_treatment==0 & dayssincetreat!=.
	local mean_sample = r(mean)
	
	*--- BJS ---*
	reghdfe d_`var' post_treatment ypre* pre* [aw=pop] if year_post_treatment==0 & dayssincetreat!=., absorb(state year week_id dow) vce(cluster day)
	
	eststo b`i'
	estadd scalar mean_s = `mean_sample'
	estadd scalar obs = e(N)
	
	test ypre1 ypre2 ypre3 ypre4 ypre5 ypre6 ypre7 ypre8 ypre9 ypre10 ypre11 ypre12
	estadd scalar pval = r(p)
	
	local i = `i'+1
}


*--------------*
*--- Export ---*
*--------------*

#d ;
estout b? using "$tables/us_bjs_pretrends.tex", style(tex) replace
	cells( b(star fmt(%9.3f)) se(par) p(par([ ])) ) mlabels(none) label collabels(none) 
	stats(mean_s pval obs, fmt(%9.2fc %9.3fc %9.0fc) labels("Mean" "p-value: Joint Significance" "Observations")) prefoot(\\)
	keep(ypre*) starlevels(* 0.10 ** 0.05 *** 0.01);
#d cr







#d ;
estout b?, replace
	cells( b(star fmt(%9.3f)) se(par) p(par([ ])) ) mlabels(none) label collabels(none) 
	stats(mean_s pval obs, fmt(%9.2fc %9.3fc %9.0fc) labels("Mean" "p-value: Joint Significance" "Observations"))
	keep(ypre*) starlevels(* 0.10 ** 0.05 *** 0.01);
#d cr










