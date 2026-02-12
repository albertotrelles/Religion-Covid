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

// -------------------------------------------------------------------------- //
// --- Topics Evolution													  --- //
// -------------------------------------------------------------------------- //

*--- Announcement ---*
*--------------------*
use "$organized/us_nocat_dynamic.dta", clear

collapse (mean) d_* [pw=pop] , by(year dayssincetreat1)
drop if dayssincetreat1==.

foreach word of global words {
	
	local var = lower("`word'")
	
	twoway ///
    (connected d_`var' dayssincetreat1 if year == 2019 & inrange(dayssincetreat1, -56, 22), ///
        lcolor("140 170 225") mcolor("140 170 225")) ///
    (connected d_`var' dayssincetreat1 if year == 2020 & inrange(dayssincetreat1, -56, 22), ///
        lcolor("225 140 140") mcolor("225 140 140")), ///
    legend(order(1 "2019" 2 "2020") position(6) ring(1) cols(2)) ///
    xline(0, lpattern(dash) lcolor(gs8)) ///
    xlabel(-56(7)21) ///
    xscale(range(-56 22)) ///
    xtitle("Day relative to lockdown Announcement") ///
    ytitle("RSI (mean)") ///
    graphregion(color(white) margin(b-1)) ///
    plotregion(color(white))
	
	graph export "$figures/us_evolution1_`word'.png", replace 
	
}	
	

*--- 1-week anticipation ---*
*---------------------------*
use "$organized/us_nocat_dynamic.dta", clear

collapse (mean) d_* [pw=pop] , by(year dayssincetreat2)
drop if dayssincetreat2==.

foreach word of global words {
	
	local var = lower("`word'")
	
	twoway ///
    (connected d_`var' dayssincetreat2 if year == 2019 & inrange(dayssincetreat2, -56, 28), ///
        lcolor("140 170 225") mcolor("140 170 225")) ///
    (connected d_`var' dayssincetreat2 if year == 2020 & inrange(dayssincetreat2, -56, 28), ///
        lcolor("225 140 140") mcolor("225 140 140")), ///
    legend(order(1 "2019" 2 "2020") position(6) ring(1) cols(2)) ///
    xline(0, lpattern(dash) lcolor(gs8)) ///
    xlabel(-56(7)28) ///
    xscale(range(-56 28)) ///
    xtitle("Day relative to lockdown Announcement (1-week prior)") ///
    ytitle("RSI (mean)") ///
    graphregion(color(white) margin(b-1)) ///
    plotregion(color(white))
	
	graph export "$figures/us_evolution2_`word'.png", replace
	
}	
	
	