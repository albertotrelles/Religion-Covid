global root "C:/Users/ALBERTO TRELLES/Dropbox/Religion-Covid"
global output "$root/Output"
global input "$root/Input"
global data "$root/Data"
global organized "$data/Organized"
global raw "$data/Data_collection/raw"
global demographic "$data/Demographic"
global temporal "$root/Temporal"
cd "$root"

// -------------------------------------------------------------------------- //
// --- (1) Topics														  --- //
// -------------------------------------------------------------------------- //

global words "Faith God Meditation Prayer Religion Spirituality"
global covid L_deaths_avg	//no big changes with different covid covariates 

use "$organized/us_nocat_dynamic.dta", clear

gen treat_date1 = ann_date
gen treat_date2 = city_date
gen treat_date3 = ant_date


*by state: gen day_id = _n

local j=3
local var prayer 
reghdfe d_`var' ypre*_t`j' pre*_t`j' [pw=pop] if year_post_treatment`j'==0 & treat_date`j'!=., absorb(post_treatment`j' state_id year day dow) vce(cluster day)


*------------------*
*--- Brodeur FE ---*
*------------------*
est clear

foreach word of global words{
	local var = lower("`word'")
	
	forval j = 1/3{
		
		*--- TWFE ---*
		reghdfe d_`var' ypre*_t`j' pre*_t`j' [pw=pop] if year_post_treatment`j'==0 & treat_date`j'!=., absorb(post_treatment`j' state_id year week_id dow) vce(cluster day)
		mat `word'`j' = r(table)[1,1..12]' , r(table)[5,1..12]', r(table)[6,1..12]'
				
	}
	
	mat `word'_fe1 = `word'1 \ `word'2 \ `word'3 

}


*----------------------*         //maybe not include dow? I think its better for prayer, let's see later 
*--- Day of year FE ---*
*----------------------*
est clear

foreach word of global words{
	local var = lower("`word'")
	
	forval j = 1/3{
		reghdfe d_`var' ypre*_t`j' pre*_t`j' [pw=pop] if year_post_treatment`j'==0 & treat_date`j'!=., absorb(post_treatment`j' state_id year day dow) vce(cluster day)
		mat `word'`j' = r(table)[1,1..12]' , r(table)[5,1..12]', r(table)[6,1..12]'
	}
	
	mat `word'_fe2 = `word'1 \ `word'2 \ `word'3 

}

*--------------------*
*--- State-day FE ---*
*--------------------*
est clear

foreach word of global words{
	local var = lower("`word'")
	
	forval j = 1/3{
		reghdfe d_`var' ypre*_t`j' pre*_t`j' $covid [pw=pop] if year_post_treatment`j'==0 & treat_date`j'!=., absorb(post_treatment`j' state_id#day year dow) vce(cluster day)
		mat `word'`j' = r(table)[1,1..12]' , r(table)[5,1..12]', r(table)[6,1..12]'
	}

	mat `word'_fe3 = `word'1 \ `word'2 \ `word'3 
	
}

*-----------------*
*--- Coef Plot ---*
*-----------------*

foreach word of global words{
	forval i = 1/3{
	
		clear
		svmat double `word'_fe`i', names(col)
		gen row = _n

		gen t = .
		replace t = 1 if row <= 12
		replace t = 2 if row > 12 & row <= 24
		replace t = 3 if row > 24

		gen event_time = mod(row-1,12) + 1
		replace event_time = (-1)*event_time

		gen event_time_t1 = event_time - 0.185
		gen event_time_t2 = event_time
		gen event_time_t3 = event_time + 0.185

		#d ;
		twoway
			(rcap ll ul event_time_t1 if t==1, lwidth(thin) lcolor(blue))
			(scatter b event_time_t1 if t==1, msymbol(O) mcolor(blue))

			(rcap ll ul event_time_t2 if t==2, lwidth(thin) lcolor(red))
			(scatter b event_time_t2 if t==2, msymbol(O) mcolor(red))

			(rcap ll ul event_time_t3 if t==3, lwidth(thin) lcolor(green))
			(scatter b event_time_t3 if t==3, msymbol(O) mcolor(green)),

			yline(0, lcolor(gs8))
			xlabel(-12(1)-1)
			xscale(range(-12.5 -0.5))
			xtitle("Weeks relative to treatment")
			title("Pre-trends: `word'")
			legend(off);
		#d cr
		
		graph export "$root/Overleaf/Figures/pretrends_`word'_fe`i'.png"

	}
}


// -------------------------------------------------------------------------- //
// --- (2) Subcategories												  --- //
// -------------------------------------------------------------------------- //

global subcategories "Astrology Buddhism Christianity Hinduism Islam Judaism Occult Paganism Worship Scientology Selfhelp Skeptics Spirituality Theology"
global covid L_deaths_avg	//no big changes with different covid covariates 

use "$organized/us_subcat_dynamic.dta", clear

gen treat_date1 = ann_date
gen treat_date2 = city_date
gen treat_date3 = ant_date

*------------------*
*--- Brodeur FE ---*
*------------------*
est clear

foreach subcat of global subcategories{
	local var = lower("`subcat'")
	
	forval j = 1/3{
		
		*--- TWFE ---*
		reghdfe d_`var' ypre*_t`j' pre*_t`j' [pw=pop] if year_post_treatment`j'==0 & treat_date`j'!=., absorb(post_treatment`j' state_id year week_id dow) vce(cluster day)
		mat `subcat'`j' = r(table)[1,1..12]' , r(table)[5,1..12]', r(table)[6,1..12]'
				
	}
	
	mat `subcat'_fe1 = `subcat'1 \ `subcat'2 \ `subcat'3 

}


*----------------------*         //maybe not include dow? I think its better for prayer, let's see later 
*--- Day of year FE ---*
*----------------------*
est clear

foreach subcat of global subcategories{
	local var = lower("`subcat'")
	
	forval j = 1/3{
		reghdfe d_`var' ypre*_t`j' pre*_t`j' [pw=pop] if year_post_treatment`j'==0 & treat_date`j'!=., absorb(post_treatment`j' state_id year day dow) vce(cluster day)
		mat `subcat'`j' = r(table)[1,1..12]' , r(table)[5,1..12]', r(table)[6,1..12]'
	}
	
	mat `subcat'_fe2 = `subcat'1 \ `subcat'2 \ `subcat'3 

}

*--------------------*
*--- State-day FE ---*
*--------------------*
est clear

foreach subcat of global subcategories{
	local var = lower("`subcat'")
	
	forval j = 1/3{
		reghdfe d_`var' ypre*_t`j' pre*_t`j' $covid [pw=pop] if year_post_treatment`j'==0 & treat_date`j'!=., absorb(post_treatment`j' state_id#day year dow) vce(cluster day)
		mat `subcat'`j' = r(table)[1,1..12]' , r(table)[5,1..12]', r(table)[6,1..12]'
	}

	mat `subcat'_fe3 = `subcat'1 \ `subcat'2 \ `subcat'3 
	
}

*-----------------*
*--- Coef Plot ---*
*-----------------*

foreach subcat of global subcategories{
	forval i = 1/3{
	
		clear
		svmat double `subcat'_fe`i', names(col)
		gen row = _n

		gen t = .
		replace t = 1 if row <= 12
		replace t = 2 if row > 12 & row <= 24
		replace t = 3 if row > 24

		gen event_time = mod(row-1,12) + 1
		replace event_time = (-1)*event_time

		gen event_time_t1 = event_time - 0.185
		gen event_time_t2 = event_time
		gen event_time_t3 = event_time + 0.185

		#d ;
		twoway
			(rcap ll ul event_time_t1 if t==1, lwidth(thin) lcolor(blue))
			(scatter b event_time_t1 if t==1, msymbol(O) mcolor(blue))

			(rcap ll ul event_time_t2 if t==2, lwidth(thin) lcolor(red))
			(scatter b event_time_t2 if t==2, msymbol(O) mcolor(red))

			(rcap ll ul event_time_t3 if t==3, lwidth(thin) lcolor(green))
			(scatter b event_time_t3 if t==3, msymbol(O) mcolor(green)),

			yline(0, lcolor(gs8))
			xlabel(-12(1)-1)
			xscale(range(-12.5 -0.5))
			xtitle("Weeks relative to treatment")
			title("Pre-trends: `subcat'")
			legend(off);
		#d cr
		
		graph export "$root/Overleaf/Figures/pretrends_`subcat'_fe`i'_subcat.png"

	}
}














/*
clear
svmat double Religion, names(col)
gen row = _n

gen t = .
replace t = 1 if row <= 12
replace t = 2 if row > 12 & row <= 24
replace t = 3 if row > 24

gen event_time = mod(row-1,12) + 1
replace event_time = (-1)*event_time

gen event_time_t1 = event_time - 0.185
gen event_time_t2 = event_time
gen event_time_t3 = event_time + 0.185

#d ;
twoway
    (rcap ll ul event_time_t1 if t==1, lwidth(thin) lcolor(blue))
    (scatter b event_time_t1 if t==1, msymbol(O) mcolor(blue))

    (rcap ll ul event_time_t2 if t==2, lwidth(thin) lcolor(red))
    (scatter b event_time_t2 if t==2, msymbol(O) mcolor(red))

    (rcap ll ul event_time_t3 if t==3, lwidth(thin) lcolor(green))
    (scatter b event_time_t3 if t==3, msymbol(O) mcolor(green)),

    yline(0, lcolor(gs8))
    xlabel(-12(1)-1)
    xscale(range(-12.5 -0.5))
    xtitle("Weeks relative to treatment")
    ytitle("Change in searches")
    title("Pre-trends: Prayer")
	legend(off)
;
#d cr

	
twoway ///
    (rcap ll ul event_time if t==1 & inrange(event_time,-12,-1), lwidth(thin)) ///
    (scatter b event_time if t==1 & inrange(event_time,-12,-1), msymbol(O)) ///
    (rcap ll ul event_time if t==2 & inrange(event_time,-12,-1), lwidth(thin)) ///
    (scatter b event_time if t==2 & inrange(event_time,-12,-1), msymbol(D)) ///
    (rcap ll ul event_time if t==3 & inrange(event_time,-12,-1), lwidth(thin)) ///
    (scatter b event_time if t==3 & inrange(event_time,-12,-1), msymbol(T)), ///
    yline(0, lcolor(gs8)) ///
    xlabel(-12(1)-1) ///
    xscale(range(-12 -1)) ///
    xtitle("Weeks relative to treatment") ///
    ytitle("Change in searches") ///
    legend(order(2 "t1: Announcement" 4 "t2: City" 6 "t3: Anticipation") rows(1)) ///
    title("Pre-trends: Prayer")

/*
mat list Prayer


mat betas = A[1,1..12]
mat ll = A[5,1..12]
mat ul = A[6,1..12]

matrix betas_c = betas'
matrix ll_c    = ll'
matrix ul_c    = ul'
matrix coef_Plots3 = betas_c , ll_c , ul_c
mat list coef_Plots3

matrix coef_Plots3 = betas \ ll \ ul

mat list coef_Plots3



mat A = r(table) //variables: 1-12 columns; (beta, ll, ul)


local prelabels ///
    ypre12_t# = "-12" ///
    ypre11_t# = "-11" ///
    ypre10_t# = "-10" ///
    ypre9_t#  = "-9" ///
    ypre8_t#  = "-8" ///
    ypre7_t#  = "-7" ///
    ypre6_t#  = "-6" ///
    ypre5_t#  = "-5" ///
    ypre4_t#  = "-4" ///
    ypre3_t#  = "-3" ///
    ypre2_t#  = "-2" ///
    ypre1_t#  = "-1"

coefplot ///
    (Prayer1, keep(ypre*_t1) label("Announcement")) ///
    (Prayer2, keep(ypre*_t2) label("City")) ///
    (Prayer3, keep(ypre*_t3) label("Anticipation")), ///
    
    coeflabels(`prelabels') ///
    yline(0, lcolor(gs8)) ///
    level(95) ///
    
    legend(order(1 2 3) rows(1)) ///
    xtitle("Weeks relative to treatment") ///
    ytitle("Change in searches") ///
    title("Pre-trends: Prayer") ///
    name(pre_Prayer, replace)



*This one is perfect 
local var prayer
local j = 3
reghdfe d_`var' ypre*_t`j' pre*_t`j' [pw=pop] if year_post_treatment`j'==0 & treat_date`j'!=., absorb(post_treatment`j' state_id#day dow year) vce(cluster day)  //computationally the same with aw & pw 
*test ypre1_t`j' ypre2_t`j' ypre3_t`j' ypre4_t`j' ypre5_t`j' ypre6_t`j' ypre7_t`j' ypre8_t`j' ypre9_t`j' ypre10_t`j' ypre11_t`j' ypre12_t`j'

mat A = r(table) //variables: 1-12 columns; (beta, ll, ul)

mat list A

mat betas = A[1,1..12]
mat ll = A[5,1..12]
mat ul = A[6,1..12]

matrix betas_c = betas'
matrix ll_c    = ll'
matrix ul_c    = ul'
matrix coef_Plots3 = betas_c , ll_c , ul_c
mat list coef_Plots3

matrix coef_Plots3 = betas \ ll \ ul

mat list coef_Plots3

mat list ll



*Good BJS too, maybe just cut DOW 
did_imputation d_prayer state edate treat_date1 [aw=pop] if treat_date1!=., fe(post_treatment1 year state_id#day) cluster(day) wtr(pop) autosample 


reghdfe d_prayer ypre*_t1 pre*_t1 [aw=pop] if year_post_treatment1==0 & treat_date1!=., absorb(post_treatment1 state year day) vce(cluster day)

reghdfe d_prayer ypre*_t1 pre*_t1 [aw=pop] if year_post_treatment1==0 & treat_date1!=., absorb(post_treatment1 state year week_id dow) vce(cluster day)


did_imputation d_prayer state edate treat_date1 [aw=pop] if treat_date1!=., fe(post_treatment1 year state_id day) cluster(day) wtr(pop) autosample nose

reghdfe d_prayer ypre*_t1 pre*_t1 [aw=pop] if year_post_treatment1==0 & treat_date1!=., absorb(year state_id#day week_id dow) vce(cluster day)
