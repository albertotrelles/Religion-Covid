global root "C:/Users/ALBERTO TRELLES/Dropbox/Religion-Covid"
global data "$root/Data"
global organized "$data/Organized"
global raw "$data/Data_collection/raw"
global demographic "$data/Demographic"
global temporal "$root/Temporal"
global tables "$root/Tables"
global figures "$root/Figures"
cd "$root"

global words "Faith God Meditation Prayer Religion Spirituality"
global subcategories "Astrology Buddhism Christianity Hinduism Islam Judaism Occult Paganism Worship Scientology Selfhelp Skeptics Spirituality Theology"
global covid L_cases L_deaths 

// -------------------------------------------------------------------------- //
// --- (1) Topics Estimation 											  --- //
// -------------------------------------------------------------------------- //
use "$organized/us_nocat_twfe.dta", clear

gen treat_date1 = ann_date
gen treat_date2 = ant_date

local matrices "twfe twfe_controls"
foreach A of local matrices{
	mat `A' = J(3,6,.)
	mat colnames `A' = $words
	mat rownames `A' = b ll ul
	mat list `A'
} 

est clear 
local k=1
foreach word of global words{
	
	local var = lower("`word'")
	
	forval j = 1/2{
		
		*--- TWFE ---*
		qui sum d_`var' if treat_date`j'!=. & year_post_treatment`j'==0
		local mean_control = r(mean)
		
		reghdfe d_`var' year_post_treatment`j' post_treatment`j' [pw=pop] if treat_date`j'!=., absorb(state_id year day dow) vce(cluster day)
		
		eststo twfe`j'_`var'
		estadd scalar meanc = `mean_control'
		estadd scalar pval = r(table)[4,1]
		estadd scalar obs = e(N)
		
		if `j'==1{
			mat twfe[1, `k'] = r(table)[1,1]
			mat twfe[2, `k'] = r(table)[5,1]	//ll
			mat twfe[3, `k'] = r(table)[6,1]	//ul
		}
		
		*--- BJS ---*
		did_imputation d_`var' state edate treat_date`j' [aw=pop] if treat_date`j'!=., fe(post_treatment`j' state_id year day dow) cluster(day) wtr(pop)
		
		eststo bjs`j'_`var'
		estadd scalar pval = r(table)[4,1]	
		estadd scalar omega0 = e(Nc)
		estadd scalar omega1 = e(N) - e(Nc)
	
	}
	
	*--- Covid controls ---*
	reghdfe d_`var' year_post_treatment1 post_treatment1 $covid [pw=pop] if treat_date1!=., absorb(state_id year day dow) vce(cluster day)
	eststo controls_twfe1_`var'
	
	mat twfe_controls[1, `k'] = r(table)[1,1]
	mat twfe_controls[2, `k'] = r(table)[5,1]	//ll
	mat twfe_controls[3, `k'] = r(table)[6,1]	//ul 
	
	local k=`k'+1
	
}


*--- Export tables ---*
*---------------------*

#d ;
estout twfe1_* using "$tables/us_twfe1.tex", style(tex) replace 
	cells( b(star fmt(%9.3f)) se(par) ) mlabels(none) label collabels(none) 
	stats(meanc pval obs, fmt(%9.2fc %9.3fc %9.0fc) labels("Mean: pre-lockdown" "p-value" "Observations")) prefoot(\\) 
	rename(year_post_treatment1 "ATT $(\gamma)$") drop(post_treatment1 _cons) starlevels(* 0.10 ** 0.05 *** 0.01);
#d cr

#d ;
estout bjs1_* using "$tables/us_bjs1.tex", style(tex) replace 
	cells( b(star fmt(%9.3f)) se(par) ) mlabels(none) label collabels(none) 
	stats(pval omega0 omega1, fmt(%9.3fc %9.0fc %9.0fc) labels("p-value" "Observations in $\Omega_0$" "Observations in $\Omega_1$")) prefoot(\\) 
	rename(tau "ATT $(\tau)$") starlevels(* 0.10 ** 0.05 *** 0.01);
#d cr

#d ;
estout twfe2_* using "$tables/us_twfe2.tex", style(tex) replace 
	cells( b(star fmt(%9.3f)) se(par) ) mlabels(none) label collabels(none) 
	stats(meanc pval obs, fmt(%9.2fc %9.3fc %9.0fc) labels("Mean: pre-lockdown" "p-value" "Observations")) prefoot(\\) 
	rename(year_post_treatment2 "ATT $(\gamma)$") drop(post_treatment2 _cons) starlevels(* 0.10 ** 0.05 *** 0.01);
#d cr

#d ;
estout bjs2_* using "$tables/us_bjs2.tex", style(tex) replace 
	cells( b(star fmt(%9.3f)) se(par) ) mlabels(none) label collabels(none) 
	stats(pval omega0 omega1, fmt(%9.3fc %9.0fc %9.0fc) labels("p-value" "Observations in $\Omega_0$" "Observations in $\Omega_1$")) prefoot(\\) 
	rename(tau "ATT $(\tau)$") starlevels(* 0.10 ** 0.05 *** 0.01);
#d cr



*-----------------------------------*
*--- Figure: TWFE covid controls ---*
*-----------------------------------*
clear
set obs 6
gen topic = _n

* Without controls
gen b_noc = .
gen ll_noc = .
gen ul_noc = .

* With controls
gen b_con = .
gen ll_con = .
gen ul_con = .

forvalues i = 1/6 {
    replace b_noc  = twfe[1,`i'] in `i'
    replace ll_noc = twfe[2,`i'] in `i'
    replace ul_noc = twfe[3,`i'] in `i'

    replace b_con  = twfe_controls[1,`i'] in `i'
    replace ll_con = twfe_controls[2,`i'] in `i'
    replace ul_con = twfe_controls[3,`i'] in `i'
}

gen topic_noc = topic - 0.075
gen topic_con = topic + 0.075


*--- Export graph ---*
*--------------------*

twoway ///
(rcap ll_noc ul_noc topic_noc, lcolor(navy)) ///
(scatter b_noc topic_noc, mcolor(navy) msymbol(O) ///
    mlabel(b_noc) mlabformat(%9.2f) mlabposition(9) mlabcolor(black)) ///
(rcap ll_con ul_con topic_con, lcolor(maroon)) ///
(scatter b_con topic_con, mcolor(maroon) msymbol(D) ///
    mlabel(b_con) mlabformat(%9.2f) mlabposition(5) mlabcolor(black)), ///
legend(order(2 "No Covid-19 controls" 4 "With Covid-19 controls") ///
       position(6) ring(1) cols(2) ///
       region(lstyle(none) margin(zero))) ///
xlabel(1 "Faith" 2 "God" 3 "Meditation" 4 "Prayer" 5 "Religion" 6 "Spirituality", angle(45)) ///
xscale(range(0.5 6.5)) ///
yline(0, lpattern(dash) lcolor(gs8)) ///
xtitle("") ///
ytitle("TWFE estimate") ///
graphregion(color(white) margin(b+4)) ///
plotregion(color(white))

graph export "$root/Figures/covid_controls.png", replace



// -------------------------------------------------------------------------- //
// --- (2) Subcategory Estimation 										  --- //
// -------------------------------------------------------------------------- //

use "$organized/us_subcat_dynamic.dta", clear

gen treat_date1 = ann_date
gen treat_date2 = ant_date

mat twfe_subcat = J(3,14,.)
mat colnames twfe_subcat = $subcategories
mat rownames twfe_subcat = b ll ul

local k=1
foreach subcat of global subcategories{
	local var = lower("`subcat'")
	
	reghdfe d_`var' year_post_treatment1 post_treatment1 $covid [pw=pop] if treat_date1!=., absorb(state_id year day dow) vce(cluster day)
	
	mat twfe_subcat[1, `k'] = r(table)[1,1]
	mat twfe_subcat[2, `k'] = r(table)[5,1]		//ll
	mat twfe_subcat[3, `k'] = r(table)[6,1]		//ul
	
	local k=`k'+1
	
}


*--- Coef plot ---*
*-----------------*
mat twfe_subcat_t = twfe_subcat'

clear
svmat double twfe_subcat_t, names(col)

gen id = _n
label define subcat ///
    1  "Astrology" ///
    2  "Buddhism" ///
    3  "Christianity" ///
    4  "Hinduism" ///
    5  "Islam" ///
    6  "Judaism" ///
    7  "Occult" ///
    8  "Paganism" ///
    9  "Worship" ///
    10 "Scientology" ///
    11 "Self-help" ///
    12 "Skeptics" ///
    13 "Spirituality" ///
    14 "Theology"

label values id subcat
decode id, gen(subcat)

*Sort by coefficient 
gsort -b
gen id_sort = _n

capture label drop subcat_sorted
forvalues i = 1/`=_N' {
    if `i' == 1 {
        label define subcat_sorted `i' "`=subcat[`i']'"
    }
    else {
        label define subcat_sorted `i' "`=subcat[`i']'", add
    }
}

label values id_sort subcat_sorted

*Plot 
twoway ///
    (rcap ll ul id_sort, lcolor(navy)) ///
    (scatter b id_sort, mcolor(navy) msymbol(O)), ///
    xlabel(1/14, valuelabel angle(45)) ///
    yline(0, lpattern(dash) lcolor(gs8)) ///
    ytitle("TWFE estimate") ///
    xtitle("") ///
    graphregion(color(white)) ///
    plotregion(color(white)) ///
	legend(off)
	
graph export "$root/Figures/subcat_coef.png"





