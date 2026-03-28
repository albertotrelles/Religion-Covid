global root "C:/Users/ALBERTO TRELLES/Dropbox/Religion-Covid"
global data "$root/Data"
global organized "$data/Organized"
global raw "$data/Data_collection/raw"
global demographic "$data/Demographic"
global temporal "$root/Temporal"
global tables "$root/Tables"
global figures "$root/Figures"
cd "$root"


// -------------------------------------------------------------------------- //
// --- Heterogeneous Effects by Baseline Religiosity (Gallup 2017)        --- //
// -------------------------------------------------------------------------- //

use "$organized/us_nocat_twfe.dta", clear
drop _merge

merge m:1 state using "$data/Data_collection/gallup_religiosity_2017.dta"
drop if _merge == 2
drop _merge

gen treat_date1 = ann_date

*--- Baseline religiosity: above-median share of "very religious" (Gallup 2017) ---*
qui sum pct_very_religious, detail
gen high_religion = (pct_very_religious > r(p50))

*--- Triple interaction terms ---*
gen lockdown_high      = post_treatment1 * high_religion
gen year_high          = dyear * high_religion
gen year_lockdown_high = year_post_treatment1 * high_religion

label var lockdown_high      "Post lockdown $\times$ High religion"
label var year_high          "Year 2020 $\times$ High religion"
label var year_lockdown_high "ATT $(\gamma_H - \gamma_L)$"


// -------------------------------------------------------------------------- //
// --- Estimation: God, Prayer, Meditation (in that order)                --- //
// -------------------------------------------------------------------------- //

est clear

foreach word in God Prayer Meditation {

	local var = lower("`word'")

	qui sum d_`var' if treat_date1 != . & year_post_treatment1 == 0
	local mean_control = r(mean)

	reghdfe d_`var' year_post_treatment1 year_lockdown_high /// DxY + DxY+HR 
		post_treatment1 lockdown_high year_high /// + D + DxHR + YxHR 
		[pw=pop] if treat_date1 != ., ///
		absorb(state_id year day dow) vce(cluster day)

	eststo het1_`var'
	estadd scalar meanc  = `mean_control'
	estadd scalar pval   = r(table)[4, 1]
	estadd scalar pval_h = r(table)[4, 2]
	estadd scalar obs    = e(N)

}


*--- Table ---*
*-------------*

#d ;
estout het1_god het1_prayer het1_meditation using "$tables/us_het1.tex",
	style(tex) replace
	cells( b(star fmt(%9.3f)) se(par) ) mlabels(none) label collabels(none)
	stats(meanc pval pval_h obs, fmt(%9.2fc %9.3fc %9.3fc %9.0fc)
		labels("Mean: pre-lockdown" "p-value: ATT" "p-value: Interaction" "Observations"))
	prefoot(\\)
	rename(year_post_treatment1 "ATT $(\gamma)$"
		   year_lockdown_high   "ATT $(\gamma_H - \gamma_L)$")
	drop(post_treatment1 lockdown_high year_high _cons)
	starlevels(* 0.10 ** 0.05 *** 0.01);
#d cr





/*
*--- Shares ---*
keep state pop pct_very_religious high_religion
duplicates drop 

gen percent = pct_very_religious/100

gen religious_ppl = pop*percent

bys high_religion: egen tot = sum(pop)
bys high_religion: egen tot_religious = sum(religious_ppl)

gen s_h = tot_religious/tot if high_religion==1
gen s_l = tot_religious/tot if high_religion==0

qui sum s_h
local s_h = r(max)

qui sum s_l 
local s_l = r(max)

local share_gap = `s_h'-`s_l'
display in red `share_gap'				//0.1221332
*/







