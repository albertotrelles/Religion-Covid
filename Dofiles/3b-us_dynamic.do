global root "C:/Users/ALBERTO TRELLES/Dropbox/Religion-Covid"
global output "$root/Output"
global input "$root/Input"
global data "$root/Data"
global organized "$data/Organized"
global raw "$data/Data_collection/raw"
global demographic "$data/Demographic"
global temporal "$root/Temporal"
global tables "$root/Tables"
global figures "$oot/Figures"
cd "$root"

global words "Faith God Meditation Prayer Religion Spirituality"
global covid L_deaths_avg	//no big changes with different covid covariates 


// -------------------------------------------------------------------------- //
// --- (1) PT Test														  --- //
// -------------------------------------------------------------------------- //

use "$organized/us_nocat_dynamic.dta", clear

gen treat_date1 = ann_date
gen treat_date2 = ant_date

est clear
foreach word of global words{
	local var = lower("`word'")
	
	forval j = 1/2{
		reghdfe d_`var' ypre*_t`j' pre*_t`j' [pw=pop] if year_post_treatment`j'==0 & treat_date`j'!=., absorb(post_treatment`j' state_id day year dow) vce(cluster day)
		mat `word'`j' = r(table)[1,1..12]' , r(table)[5,1..12]', r(table)[6,1..12]'
	}
	
	mat mat_`word' = `word'1 \ `word'2 

}


*--- Graph ---*
*-------------*

foreach word of global words{
	
	clear 
	svmat double mat_`word', names(col)

	gen row = _n
	gen t = .
	replace t = 1 if row <= 12
	replace t = 2 if row > 12 

	gen event_time = mod(row-1,12) + 1
	replace event_time = (-1)*event_time

	gen event_time_t1 = event_time - 0.125
	gen event_time_t2 = event_time + 0.125

	#d ;
	twoway
		(rcap ll ul event_time_t1 if t==1, lwidth(thin) lcolor("140 170 225"))
		(scatter b event_time_t1 if t==1, msymbol(O) mcolor("140 170 225"))
		(rcap ll ul event_time_t2 if t==2, lwidth(thin) lcolor("225 140 140"))
		(scatter b event_time_t2 if t==2, msymbol(O) mcolor("225 140 140")),
		yline(0, lcolor(gs8))
		xlabel(-12(1)-1)
		xscale(range(-12.5 -0.5))
		xtitle("Weeks relative to treatment")
		legend(order(2 "Announcement" 4 "1-week anticipation") position(6) ring(1) cols(2));
	#d cr
	
	graph export "$root/Figures/pretrends_`word'.png", replace
	
}


// -------------------------------------------------------------------------- //
// -- (2) BJS Dynamics													   -- //
// -------------------------------------------------------------------------- //


use "$organized/us_nocat_dynamic.dta", clear

gen treat_date1 = ann_date
gen treat_date2 = ant_date

local N = 2
mat Prayer = J(`N',6,.)

forval i = 1/`N' {

	di in red "Iteration `i'"

	*----------------------------------
    * Resample WITH replacement by day
    *----------------------------------
    preserve
    bsample, cluster(day)


    local var prayer
	forval i=1/2{
	
    did_imputation d_`var' state edate treat_date`j' ///
        [aw=pop] if treat_date`j' != ., ///
        fe(post_treatment`j' state_id year day dow) ///
        cluster(day) wtr(pop) ///
        saveestimates(att_`var')

    mean att_`var' [pw=pop] if ypost0_t1
    mat Prayer[`i',1] = r(table)[1,1]

    mean att_`var' [pw=pop] if ypost1_t1
    mat Prayer[`i',2] = r(table)[1,1]

    mean att_`var' [pw=pop] if ypost2_t1
    mat Prayer[`i',3] = r(table)[1,1]

	}
    restore
	
}


























use "$organized/us_nocat_dynamic.dta", clear

gen treat_date1 = ann_date
gen treat_date2 = ant_date


local N=1000
mat Prayer = J(`N',3,.)

*mat A = J(3,2,.)

forval i = 1/`N'{
	
local j=1	
local var prayer
did_imputation d_`var' state edate treat_date`j' [aw=pop] if treat_date`j'!=., fe(post_treatment`j' state_id year day dow) cluster(day) wtr(pop) saveestimates(att_`var')

mean att_`var' [pw=pop] if ypost0_t1
mat A[`i',1] = r(table)[1,1]
mean att_`var' [pw=pop] if ypost1_t1
mat A[`i',2] = r(table)[1,1]
mean att_`var' [pw=pop] if ypost2_t1
mat A[`i',3] = r(table)[1,1]

}



mean att_`var' [pw=pop] if ypost1_t1==1
mat A[1,1] = r(table)[1,1]
mat A[1,2] = r(table)[2,1]
mean att_`var' [pw=pop] if ypost2_t1==1
mat A[2,1] = r(table)[1,1]
mat A[2,2] = r(table)[2,1]
mean att_`var' [pw=pop] if ypost3_t1==1
mat A[3,1] = r(table)[1,1]
mat A[3,2] = r(table)[2,1]


return list
mat list r(table)


ypost1_t1 - ypost3_t1





local j=1
local var prayer
did_imputation d_`var' state edate treat_date`j' [aw=pop] if treat_date`j'!=., fe(post_treatment`j' year state_id day week_id dow) cluster(day) wtr(pop) autosample












*-------TEST

program define boot_att, rclass

    did_imputation d_prayer state edate treat_date1 ///
        [aw=pop] if treat_date1!=., ///
        fe(post_treatment1 state_id year day dow) ///
        cluster(day) wtr(pop) ///
        saveestimates(att_prayer)

    quietly mean att_prayer [pw=pop] if ypost1_t1==1
    return scalar m1 = r(table)[1,1]

    quietly mean att_prayer [pw=pop] if ypost2_t1==1
    return scalar m2 = r(table)[1,1]

    quietly mean att_prayer [pw=pop] if ypost3_t1==1
    return scalar m3 = r(table)[1,1]

end



set seed 12345

bootstrap ///
    m1 = r(m1) ///
    m2 = r(m2), ///
    reps(500) cluster(day): ///
    boot_att



























