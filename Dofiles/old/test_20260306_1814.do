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
// --- Pre-trend HTE by Baseline Religiosity (Gallup 2017)                 --- //
// -------------------------------------------------------------------------- //

use "$organized/us_nocat_dynamic.dta", clear
capture drop _merge

gen treat_date1 = ann_date

merge m:1 state using "$data/Data_collection/gallup_religiosity_2017.dta"
drop if _merge == 2
drop _merge

qui sum pct_very_religious, detail
gen high_religion = (pct_very_religious > r(p50))


// -------------------------------------------------------------------------- //
// --- Pre-trend Estimation: God, Prayer, Meditation                       --- //
// -------------------------------------------------------------------------- //

foreach word in God Prayer Meditation {

	local var = lower("`word'")

	*--- Low religion ---*
	reghdfe d_`var' ypre*_t1 pre*_t1 [pw=pop] ///
		if year_post_treatment1==0 & treat_date1!=. & high_religion==0, ///
		absorb(post_treatment1 state_id day year dow) vce(cluster day)
	mat low_`word' = r(table)[1,1..12]', r(table)[5,1..12]', r(table)[6,1..12]'

	*--- High religion ---*
	reghdfe d_`var' ypre*_t1 pre*_t1 [pw=pop] ///
		if year_post_treatment1==0 & treat_date1!=. & high_religion==1, ///
		absorb(post_treatment1 state_id day year dow) vce(cluster day)
	mat high_`word' = r(table)[1,1..12]', r(table)[5,1..12]', r(table)[6,1..12]'

}


// -------------------------------------------------------------------------- //
// --- Plots: pre-periods only, blue = low, red = high religion            --- //
// -------------------------------------------------------------------------- //

foreach word in God Prayer Meditation {

	clear
	mat pre_het_`word' = low_`word' \ high_`word'
	svmat double pre_het_`word', names(col)

	gen row = _n
	gen group = 1 if row <= 12		// low religion
	replace group = 2 if row > 12	// high religion

	gen event_time = mod(row-1, 12) + 1
	replace event_time = (-1) * event_time

	gen event_time_low  = event_time - 0.125
	gen event_time_high = event_time + 0.125

	#d ;
	twoway
		(rcap ll ul event_time_low  if group==1, lwidth(thin) lcolor("140 170 225"))
		(scatter b  event_time_low  if group==1, msymbol(O)  mcolor("140 170 225"))
		(rcap ll ul event_time_high if group==2, lwidth(thin) lcolor("225 140 140"))
		(scatter b  event_time_high if group==2, msymbol(O)  mcolor("225 140 140")),
		yline(0, lcolor(gs8))
		xlabel(-12(1)-1)
		xscale(range(-12.5 -0.5))
		xtitle("Weeks relative to lockdown announcement")
		ytitle("DiD coefficient")
		legend(order(2 "Low religion" 4 "High religion") position(6) ring(1) cols(2))
		graphregion(color(white)) plotregion(color(white));
	#d cr

	graph export "$root/Figures/pretrends_het_`word'.png", replace

}
