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
// --- Event Study HTE by Baseline Religiosity (Gallup 2017)              --- //
// --- God, Prayer, Meditation — pre-periods + BJS post weeks 0, 1, 2    --- //
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
// --- (1) Pre-trend Estimation (TWFE): low vs. high religion             --- //
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
// --- (2) BJS Bootstrap (500 reps): post weeks 0, 1, 2                  --- //
// -------------------------------------------------------------------------- //

set seed 12345
local N = 500

foreach word in God Prayer Meditation {

	local var = lower("`word'")

	mat `word'_low  = J(`N', 3, .)
	mat `word'_high = J(`N', 3, .)
	mat colnames `word'_low  = "ypost0" "ypost1" "ypost2"
	mat colnames `word'_high = "ypost0" "ypost1" "ypost2"

	forval i = 1/`N' {

		set seed `i'
		preserve
		bsample, cluster(day)

		*--- Low religion ---*
		cap drop att_`var'_low
		did_imputation d_`var' state edate treat_date1 [aw=pop] ///
			if treat_date1!=. & high_religion==0, ///
			fe(post_treatment1 state_id year day dow) cluster(day) wtr(pop) ///
			saveestimates(att_`var'_low) nose minn(1)

		di "Rep `i', Low religion week0"	
			
		mean att_`var'_low [pw=pop] if ypost0_t1 & high_religion==0
		mat `word'_low[`i', 1] = r(table)[1,1]
		
		di "Rep `i', Low religion week1"	

		mean att_`var'_low [pw=pop] if ypost1_t1 & high_religion==0
		mat `word'_low[`i', 2] = r(table)[1,1]
		
		di "Rep `i', Low religion week2"	

		mean att_`var'_low [pw=pop] if ypost2_t1 & high_religion==0
		mat `word'_low[`i', 3] = r(table)[1,1]

		*--- High religion ---*
		cap drop att_`var'_high
		did_imputation d_`var' state edate treat_date1 [aw=pop] ///
			if treat_date1!=. & high_religion==1, ///
			fe(post_treatment1 state_id year day dow) cluster(day) wtr(pop) ///
			saveestimates(att_`var'_high) nose minn(1)
			
		di "Rep `i', High religion week0"		

		mean att_`var'_high [pw=pop] if ypost0_t1 & high_religion==1
		mat `word'_high[`i', 1] = r(table)[1,1]
		
		di "Rep `i', High religion week1"	

		mean att_`var'_high [pw=pop] if ypost1_t1 & high_religion==1
		mat `word'_high[`i', 2] = r(table)[1,1]
		
		di "Rep `i', High religion week2"	

		mean att_`var'_high [pw=pop] if ypost2_t1 & high_religion==1
		mat `word'_high[`i', 3] = r(table)[1,1]

		restore

	}

}


local var god 

		*cap drop att_`var'_low
		did_imputation d_`var' state edate treat_date1 [aw=pop] ///
			if treat_date1!=. & high_religion==0, ///
			fe(post_treatment1 state_id year day dow) cluster(day) wtr(pop) ///
			saveestimates(att_`var'_low) nose minn(1)
			
		mean att_`var'_high [pw=pop] if ypost0_t1 & high_religion==1
		mat `word'_high[`i', 1] = r(table)[1,1]

		mean att_`var'_high [pw=pop] if ypost1_t1 & high_religion==1
		mat `word'_high[`i', 2] = r(table)[1,1]

		mean att_`var'_high [pw=pop] if ypost2_t1 & high_religion==1
		mat `word'_high[`i', 3] = r(table)[1,1]


// -------------------------------------------------------------------------- //
// --- (3) Compile post-period matrices from bootstrap draws              --- //
// -------------------------------------------------------------------------- //

foreach word in God Prayer Meditation {

	local var = lower("`word'")

	*--- Save bootstrap draws ---*
	clear
	svmat `word'_low, names(col)
	save "$temporal/bootstrap_het_low_`var'.dta", replace

	clear
	svmat `word'_high, names(col)
	save "$temporal/bootstrap_het_high_`var'.dta", replace

}

foreach word in God Prayer Meditation {

	local var = lower("`word'")

	*--- Low: point estimate and 95% CI ---*
	use "$temporal/bootstrap_het_low_`var'.dta", clear

	mat post_low_`word' = J(3, 3, .)
	mat colnames post_low_`word' = "b" "ll" "ul"

	local k = 1
	foreach y in ypost0 ypost1 ypost2 {
		qui sum `y'
		mat post_low_`word'[`k', 1] = r(mean)
		mat post_low_`word'[`k', 2] = r(mean) - 1.96*r(sd)
		mat post_low_`word'[`k', 3] = r(mean) + 1.96*r(sd)
		local k = `k' + 1
	}

	*--- High: point estimate and 95% CI ---*
	use "$temporal/bootstrap_het_high_`var'.dta", clear

	mat post_high_`word' = J(3, 3, .)
	mat colnames post_high_`word' = "b" "ll" "ul"

	local k = 1
	foreach y in ypost0 ypost1 ypost2 {
		qui sum `y'
		mat post_high_`word'[`k', 1] = r(mean)
		mat post_high_`word'[`k', 2] = r(mean) - 1.96*r(sd)
		mat post_high_`word'[`k', 3] = r(mean) + 1.96*r(sd)
		local k = `k' + 1
	}

}


// -------------------------------------------------------------------------- //
// --- (4) Event Study Plots: blue = low, red = high religion             --- //
// -------------------------------------------------------------------------- //

foreach word in God Prayer Meditation {

	clear

	*--- Stack: 12 pre + 3 post for low (rows 1-15), same for high (rows 16-30) ---*
	mat event_het_`word' = low_`word' \ post_low_`word' \ high_`word' \ post_high_`word'
	svmat double event_het_`word', names(col)

	gen row = _n
	gen group = 1 if row <= 15		// low religion
	replace group = 2 if row > 15	// high religion

	bys group: gen num = _n

	*Pre-periods: num 1-12 → event_time -1 to -12
	gen event_time = mod(num-1, 12) + 1 if num <= 12
	replace event_time = (-1) * event_time if num <= 12

	*Post-periods: num 13-15 → event_time 0, 1, 2
	replace event_time = num - 13 if num > 12

	gen event_time_low  = event_time - 0.125
	gen event_time_high = event_time + 0.125

	#d ;
	twoway
		(rcap ll ul event_time_low  if group==1, lwidth(thin) lcolor("140 170 225"))
		(scatter b  event_time_low  if group==1, msymbol(O)  mcolor("140 170 225"))
		(rcap ll ul event_time_high if group==2, lwidth(thin) lcolor("225 140 140"))
		(scatter b  event_time_high if group==2, msymbol(O)  mcolor("225 140 140")),
		yline(0, lcolor(gs8))
		xline(0, lcolor(gs8))
		xlabel(-12(1)2)
		xscale(range(-12.5 2.5))
		xtitle("Weeks relative to lockdown announcement")
		ytitle("DiD coefficient")
		legend(order(2 "Low religion" 4 "High religion") position(6) ring(1) cols(2))
		graphregion(color(white)) plotregion(color(white));
	#d cr

	graph export "$root/Figures/eventstudy_het_`word'.png", replace

}
