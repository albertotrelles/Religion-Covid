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

global covid L_cases_avg L_cases_avg
global words "Faith God Meditation Prayer Religion Spirituality"

// -------------------------------------------------------------------------- //
// --- (1) Event-Study													  --- //
// -------------------------------------------------------------------------- //
use "$organized/us_nocat_twfe.dta", clear
drop if dayssincetreat==.

*Week of treatment 
gen treatment_week = week_id if edate==ann_date
bysort state: egen m_treatment_week=mean(treatment_week)
replace treatment_week=m_treatment_week
drop m_treatment_week

tab treatment_week

*Weeks since treatment 
bysort state: gen weekssincetreat = week_id - treatment_week	//-13,...3 

*--------------------------*
*--- Event-time dummies ---*
*--------------------------*

*E_it
forvalues i = -14/3 {
    if `i' < 0 {
        gen E_m`=abs(`i')' = (weekssincetreat == `i')
    }
    else {
        gen E_`i' = (weekssincetreat == `i')
    }
}

*Year X E_it
forvalues i = -14/3 {
    if `i' < 0 {
		gen yE_m`=abs(`i')' = dyear*E_m`=abs(`i')'
    }
    else {
		gen yE_`i' = dyear*E_`i'
    }
}

*------------------*
*--- Estimation ---*
*------------------*

*Base category -4
drop if weekssincetreat<-4
tab yE_m4
replace yE_m4 = 0
replace E_m4 = 0

*Figure 
foreach word of global words {
    local var = lower("`word'") 

	reghdfe d_`var' yE_m4-yE_3 E_m4-E_3 L_deaths_avg $covid [pw=pop], absorb(state year week_id dow) vce(cluster day)

	coefplot, keep(yE_*) recast(connected) color(cranberry) ciopts(lcolor(cranberry) ) vertical  ///
	label yline(0, lcolor(black)) xline(5, lpattern(dash) lcolor(black)) ci(99) ///  
	legend(off) xtitle("Weeks elapsed since the stay-at-home order") ///
	rename(yE_m4= "-4" yE_m3= "-3" yE_m2="-2" yE_m1="-1" yE_0="0" yE_1="1" yE_2="2" yE_3="3") omitted ytitle("`var'") 
	
	graph export "$figures/event-study/us_`var'_series_nyt.png", replace height(1440) width(2560)

}












/*

// -------------------------------------------------------------------------- //
// --- (1) TWFE	- City first 											  --- //
// -------------------------------------------------------------------------- //
use "$organized/us_nocat_twfe.dta", clear
drop if dayssincetreat==.

gen ann_date2=date(city_enactedfirst, "YMD")
format ann_date2 %d

gen dayssincetreat2 = noyear_edate - ann_date2


*Week of treatment 
gen treatment_week = week_id if edate==ann_date2
bysort state: egen m_treatment_week=mean(treatment_week)
replace treatment_week=m_treatment_week
drop m_treatment_week

tab treatment_week


*Weeks since treatment 
bysort state: gen weekssincetreat = week_id - treatment_week	//-13,...3 

*Event-time dummies 

forvalues i = -14/3 {
    if `i' < 0 {
        gen E_m`=abs(`i')' = (weekssincetreat == `i')
    }
    else {
        gen E_`i' = (weekssincetreat == `i')
    }
}


forvalues i = -14/3 {
    if `i' < 0 {
		gen yE_m`=abs(`i')' = dyear*E_m`=abs(`i')'
    }
    else {
		gen yE_`i' = dyear*E_`i'
    }
}



drop if weekssincetreat<-4
tab yE_m4
replace yE_m4 = 0
replace E_m4 = 0

gen E_infty_5 = (weekssincetreat<=-5)
gen yE_infty_5 = dyear*E_infty_5

replace E_infty_5=0
replace yE_infty_5=0


local var faith
reghdfe d_`var' yE_m4-yE_3 E_infty_5 E_m4-E_3 L_deaths_avg [pw=pop], absorb(state year week_id dow) vce(cluster day)


coefplot, keep(yE_*) recast(connected) color(cranberry) ciopts(lcolor(cranberry) ) vertical  ///
label yline(0, lcolor(black))  ci(99) legend(off) xtitle("Weeks elapsed since the stay-at-home order") ///
xline(5, lpattern(dash) lcolor(black)) ///
rename(yE_m4= "-4" yE_m3= "-3" yE_m2="-2" yE_m1="-1" yE_0="0" ///
yE_1="1" yE_2="2" yE_3="3") omitted ytitle("`var'") 



// -------------------------------------------------------------------------- //
// --- (1) TWFE															  --- //
// -------------------------------------------------------------------------- //

use "$organized/us_nocat_twfe.dta", clear
drop if dayssincetreat==.

reghdfe d_spirituality year_post_treatment post_treatment $covid [pw=pop], absorb(state year week dow) vce(cluster day)

*Week of treatment 
gen treatment_week = week_id if edate==ann_date
bysort state: egen m_treatment_week=mean(treatment_week)
replace treatment_week=m_treatment_week
drop m_treatment_week

tab treatment_week
tab state if treatment_week==15 //Only SC was treated at week 15. 
*replace treatment_week=14 if treatment_week==15	//>=3 week Bin 

*Weeks since treatment 
bysort state: gen weekssincetreat = week_id - treatment_week	//-13,...3 

*Event-time dummies 
tabulate weekssincetreat, generate(E_)

local j = 1
forvalues v = -13/3 {
    if `v' < 0 {
        rename E_`j' E_m`=abs(`v')'
    }
    else {
        rename E_`j' E_`v'
        // or rename E_`j' E_p`v'   if you want a "p" prefix
    }
    local j = `j'+1
}

*Event-time X year 
global E_dummies E_m13 E_m12 E_m11 E_m10 E_m9 E_m8 E_m7 E_m6 E_m5 E_m4 E_m3 E_m2 E_m1 E_0 E_1 E_2 E_3

global yearXEdummies 
foreach y of global E_dummies{
	gen yearX`y' = dyear*`y'
	global yearXEdummies $yearXEdummies yearX`y'
}

tab yearXE_m4

*********************
drop if weekssincetreat<-4

global E E_m3 E_m2 E_m1 E_0 E_1 E_2 E_3
global yXE yearXE_m3 yearXE_m2 yearXE_m1 yearXE_0 yearXE_1 yearXE_2 yearXE_3

replace yearXE_m4 = 0

tab yearXE_m4

local var faith
reghdfe d_`var' yearXE_m4-yearXE_3 E_m4-E_3 L_deaths_avg [pw=pop], absorb(state year week_id dow) vce(cluster day)

foreach y of global yXE{
	tab `y'
}


coefplot, keep(yearXE_*) recast(connected) color(cranberry) ciopts(lcolor(cranberry) ) vertical  ///
label yline(0, lcolor(black))  ci(95) legend(off) xtitle("Weeks elapsed since the stay-at-home order") ///
xline(4, lpattern(dash) lcolor(black)) ///
rename(yearXE_m4= "-4" yearXE_m3= "-3" yearXE_m2="-2" yearXE_m1="-1" yearXE_0="0" ///
yearXE_1="1" yearXE_2="2" yearXE_3="3") omitted ytitle("`var'") 

reghdfe d_faith year_post_treatment post_treatment $covid [pw=pop], absorb(state year week_id dow) vce(cluster day)

local var faith
reghdfe d_`var' year_post_treatment post_treatment $covid [pw=pop], absorb(state year week_id dow) vce(cluster day)
reghdfe d_`var' yearXE_m3-yearXE_3 E_m3-E_3 L_deaths_avg [pw=pop], absorb(state year week_id dow) vce(cluster day)


// - CSDID --- 
use "$organized/us_nocat_twfe.dta", clear
encode state, gen(state_id)
label drop state_id
drop if dayssincetreat==.
drop if year==2019
drop if week_id<=8

*Treatment week 
gen treatment_week = week_id if edate==ann_date
bysort state: egen m_treatment_week=mean(treatment_week)
replace treatment_week=m_treatment_week
drop m_treatment_week

tab treatment_week, m
replace treatment_week=14 if treatment_week==15

*Cohorts 
gen group = treatment_week if treatment_week==12
replace group = treatment_week if treatment_week==13
replace group = treatment_week if treatment_week==14

*Weekly data 
collapse (mean) d_* group pop (max) L_deaths_avg, by(state_id week_id)
gen post_treatment = (week_id>=group)

save "$organized/csdid.dta", replace









csdid d_prayer, ivar(state_id) time(week_id) gvar(group)




*csdid lemp , ivar(countyreal) time(year) gvar(first_treat)
*bys year state: gen ty_id = _n

tab treatment_week
tab state if treatment_week==15 //Only SC was treated at week 15. 
*replace treatment_week=14 if treatment_week==15	//>=3 week Bin 

*Weeks since treatment 
bysort state: gen weekssincetreat = week_id - treatment_week



































gen E_mm = (weekssincetreat<-4)
gen yearXE_mm = dyear*E_mm




local var prayer
reghdfe d_`var' $yXE yearXE_mm $E E_mm L_deaths_avg [pw=pop], absorb(state year week_id dow) vce(cluster day)





local var prayer
reghdfe d_`var' yearXE_m3-yearXE_3 E_m3-E_3 L_deaths_avg [pw=pop], absorb(state year week_id dow) vce(cluster day)

label yline(0, lcolor(black))  ci(95) legend(off) xtitle("Weeks elapsed since the stay-at-home order") ///
xline(5, lpattern(dash) lcolor(black)) ///
rename(yearXE_m4= "-4" yearXE_m3= "-3" yearXE_m2="-2" yearXE_m1="-1" yearXE_0="0" ///
yearXE_1="1" yearXE_2="2" yearXE_2="3") omitted ytitle("`var'") 




reghdfe d_`var' _IweeXyear_9-_IweeXyear_17  _Iweeksince* L_dailyconfirmeddeathsdeaths [pw=pop] if country!=6, ///
	absorb(country year week day_w) vce(cluster day)

























* mark untreated obs (pre-treatment or never treated)
gen byte untreated = (dayssincetreat < 0)       // adjust if using NA for never-treated

* estimate untreated outcome model on pre-treatment obs only
reghdfe d_faith post_treatment if untreated [pw=pop], absorb(state year week_id dow) vce(cluster day)

* predict linear prediction (includes absorbed FE)
predict double y0_hat, xb

* imputed tau only for treated-post observations (dayssincetreat >= 0)
gen double tau_hat = . 
replace tau_hat = d_faith - y0_hat if dayssincetreat >= 0

collapse (mean) ATT = tau_hat (count) N = tau_hat [pw=pop], by(dayssincetreat) 
list dayssincetreat ATT N


reghdfe d_faith if dayssincetreat<0, absorb(state year week_id dow) vce(cluster day)




use "$organized/us_nocat_twfe.dta", clear
drop if dayssincetreat==.

* 1. Estimate untreated potential outcomes in pre-period
reghdfe d_religion if dayssincetreat < 0 [pw=pop], ///
    absorb(state year week_id dow) vce(cluster day)

predict double y0_hat, xb

* 2. Build tau_hat only for treated-post
gen double tau_hat = d_religion - y0_hat if dayssincetreat >= 0

* 3. Get single aggregated ATT and SE
reghdfe tau_hat [pw=pop] if dayssincetreat >= 0, vce(cluster day)
























































































































br

gen dayssincetreat = noyear_edate - ann_date	//NA for NT. Duplicated values for paired 2019 days 


/*
DiD Event-Study:
Days since lockdown? --> To relativize everything 
Daily values averaged by year week (1-30)  | or actually I guess I average by days since lockdown groups of 7??? 
Covid controls: average? consider last (highest) value? 

CSDiD:
No days since lockdown
Use calendar week of year for cohorts 
Daily values averaged by year week (1-30)
Covid controls: average? consider last (highest) value? 

Use covid controls for cohorts' propensities 
Compare including NT and without NT as controls (i.e. NT vs not-yet-treated)
Aggregate dynamically and compare with twfe_nt and twfe respectively 

Example CSDiD python:
example_attgt = ATTgt(
    yname="Y",
    tname="period",
    idname="id",
    gname="G",
    xformla="Y~X",
    data=dta,
    clustervar="cluster"
).fit()
example_attgt.summ_attgt().summary2

*/

use "$organized/us_nocat_twfe.dta", clear

gen D = year_post_treatment
drop if year==2019


bys year state: gen ty_id = _n

global covid L_deaths_avg

reghdfe d_prayer D $covid [pw=pop], absorb(state week_id dow) vce(cluster day)
reghdfe d_prayer D $covid [pw=pop] if ann_date!=., absorb(state day) vce(cluster day)




reghdfe d_prayer D $covid [pw=pop] if ann_date!=. & year==2020, absorb(state ty_id) vce(cluster day)



reghdfe d_prayer D $covid [pw=pop] if ann_date!=., absorb(state ty_id) vce(cluster day)


reghdfe d_prayer D $covid [pw=pop] if ann_date!=. & year==2020, absorb(state ty_id) vce(cluster day)


*'t' is on a daily frequency. So I should have day FE.
*But since I have 2 years, should day 1 of 2019 and 2020 be a different FE value, or the same and just say I have day of year FEs to account for seasonality? 








// -------------------------------------------------------------------------- //
// --- (1) TWFE															  --- //
// -------------------------------------------------------------------------- //

use "$organized/us_nocat_twfe.dta", clear
drop if dayssincetreat==.

reghdfe d_spirituality year_post_treatment post_treatment $covid [pw=pop], absorb(state year week dow) vce(cluster day)

*Week of treatment 
gen treatment_week = week_id if edate==ann_date
bysort state: egen m_treatment_week=mean(treatment_week)
replace treatment_week=m_treatment_week
drop m_treatment_week

tab treatment_week
tab state if treatment_week==15 //Only SC was treated at week 15. 
*replace treatment_week=14 if treatment_week==15	//>=3 week Bin 

*Weeks since treatment 
bysort state: gen weekssincetreat = week_id - treatment_week	//-13,...3 

*Event-time dummies 
tabulate weekssincetreat, gen(wst_)

global wst wst_1 wst_2 wst_3 wst_4 wst_5 wst_6 wst_7 wst_8 wst_9 wst_10 wst_11 wst_12 wst_13 wst_14 wst_15 wst_16 wst_17 wst_18

foreach y of global wst{
	gen year_`y' = dyear*`y'
}

drop if weekssincetreat<-4

local var prayer
reghdfe d_`var' year_post_treatment post_treatment $covid [pw=pop], absorb(state year week_id dow) vce(cluster day)
reghdfe d_`var' year_wst_* wst_* $covid [pw=pop], absorb(state year week_id dow) vce(clusted day)



*********************
drop if weekssincetreat<-4

global E E_m3 E_m2 E_m1 E_0 E_1 E_2 E_3
global yXE yearXE_m3 yearXE_m2 yearXE_m1 yearXE_0 yearXE_1 yearXE_2 yearXE_3


local var faith
reghdfe d_`var' yearXE_m3-yearXE_3 E_m3-E_3 L_deaths_avg [pw=pop], absorb(state year week_id dow) vce(cluster day)

coefplot, keep(yearXE_*) recast(connected) color(cranberry) ciopts(lcolor(cranberry) ) vertical  ///
label yline(0, lcolor(black))  ci(95) legend(off) xtitle("Weeks elapsed since the stay-at-home order") ///
xline(4, lpattern(dash) lcolor(black)) ///
rename(yearXE_m4= "-4" yearXE_m3= "-3" yearXE_m2="-2" yearXE_m1="-1" yearXE_0="0" ///
yearXE_1="1" yearXE_2="2" yearXE_3="3") omitted ytitle("`var'") 

reghdfe d_faith year_post_treatment post_treatment $covid [pw=pop], absorb(state year week_id dow) vce(cluster day)

local var prayer
reghdfe d_`var' year_post_treatment post_treatment $covid [pw=pop], absorb(state year week_id dow) vce(cluster day)
reghdfe d_`var' year_wst_* wst_* $covid [pw=pop], absorb(state year week_id dow) vce(clusted day)


reghdfe d_`var' year_wst_* wst_* $covid [pw=pop] if year==2020, absorb(state year week_id dow) vce(clusted day)

reghdfe d_`var' yearXE_m3-yearXE_3 E_m3-E_3 L_deaths_avg [pw=pop], absorb(state year week_id dow) vce(cluster day)












*******************************************


encode state, gen (state_id)
label drop state_id



local var prayer
reghdfe d_`var'  yE_m4-yE_3 E_m4-E_3 L_deaths_avg [pw=pop], absorb(state_id##week_i##dow) vce(cluster day)

bys state year: gen yday = _n

local var prayer
reghdfe d_`var'  year_post_treatment post_treatment L_deaths_avg [pw=pop], absorb(state_id day) vce(cluster day)



*Not bad 
local var prayer
reghdfe d_`var'  yE_m4-yE_3 E_m4-E_3 L_deaths_avg [pw=pop] if year==2020, absorb(state_id year day) vce(cluster day)



by state: gen calday = _n


. reghdfe d_`var'  yE_m4-yE_3 E_m4-E_3 L_deaths_avg [pw=pop], absorb(state_id week_id##year##dow) vce(cluster day)





//--- COOKING ---//
use "$organized/us_nocat_twfe.dta", clear
drop if dayssincetreat==.

reghdfe d_spirituality year_post_treatment post_treatment $covid [pw=pop], absorb(state year week dow) vce(cluster day)

*Week of treatment 
gen treatment_week = week_id if edate==ann_date
bysort state: egen m_treatment_week=mean(treatment_week)
replace treatment_week=m_treatment_week
drop m_treatment_week

tab treatment_week


*Weeks since treatment 
bysort state: gen weekssincetreat = week_id - treatment_week	//-13,...3 

*Event-time dummies 

forvalues i = -14/3 {
    if `i' < 0 {
        gen E_m`=abs(`i')' = (weekssincetreat == `i')
    }
    else {
        gen E_`i' = (weekssincetreat == `i')
    }
}


forvalues i = -14/3 {
    if `i' < 0 {
		gen yE_m`=abs(`i')' = dyear*E_m`=abs(`i')'
    }
    else {
		gen yE_`i' = dyear*E_`i'
    }
}



drop if weekssincetreat<-4
tab yE_m4
replace yE_m1 = 0
replace E_m1 = 0



local var prayer
reghdfe d_`var'  yE_m4-yE_3 E_m4-E_3 L_deaths_avg [pw=pop], absorb(state year day) vce(cluster day)





coefplot, keep(yE_*) recast(connected) color(cranberry) ciopts(lcolor(cranberry) ) vertical  ///
label yline(0, lcolor(black))  ci(99) legend(off) xtitle("Weeks elapsed since the stay-at-home order") ///
xline(4, lpattern(dash) lcolor(black)) ///
rename(yE_m4= "-4" yE_m3= "-3" yE_m2="-2" yE_m1="-1" yE_0="0" ///
yE_1="1" yE_2="2" yE_3="3") omitted ytitle("`var'") 









***************
*OK SO LET'S SAY WE ALLOW ANTICIPATION BY ONE WEEK SINCE THAT'S PROB. THE TIME WERE PEOPLE WILL VOLUNTARLY STAY HOME WITH HIGHER PROB. SINCE THEY CAN SMELL THE STATE WILL ANNOUNCE LOCKDOWN. THIS IS SUPPORTED BY THE FACT THAN MANY COUNTIES IN STATES ANNOUNCED A LOCKDOWN BEFORE THE STATE 














