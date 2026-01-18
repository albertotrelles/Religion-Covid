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

use "$organized/us_nocat_twfe.dta", clear

gen treat_date1 = ann_date
gen treat_date2 = city_date
gen treat_date3 = ant_date

/*
by state: gen day_id = _n


local var faith
local j = 1

did_imputation d_`var' state edate treat_date`j' [aw=pop] if treat_date`j'!=., fe(post_treatment`j' state_id day_id) cluster(day) wtr(pop) autosample

reghdfe d_`var' year_post_treatment`j' post_treatment`j' $covid [pw=pop] if treat_date`j'!=., absorb(state_id state_id day_id) vce(cluster day)
*/


*------------------*
*--- Brodeur FE ---*
*------------------*
est clear

foreach word of global words{
	local var = lower("`word'")
	
	forval j = 1/3{
		
		*--- TWFE ---*
		reghdfe d_`var' year_post_treatment`j' post_treatment`j' $covid [pw=pop] if treat_date`j'!=., absorb(state_id year week_id dow) vce(cluster day)
		eststo `word'`j'_twfe_fe1
		
		*--- BJS ---*
		did_imputation d_`var' state edate treat_date`j' [aw=pop] if treat_date`j'!=., fe(post_treatment`j' state_id year week_id dow) cluster(day) wtr(pop)
		eststo `word'`j'_bjs_fe1
		
	}
	
	#d ;
	estout `word'*_twfe_fe1 `word'*_bjs_fe1 using "$root/Overleaf/Tables/`var'_fe1.tex", style(tex) replace
		cells( b(star fmt(%9.3f)) se(par) p(par([ ])) ) mlabels(none) label collabels(none) 
		rename(year_post_treatment1 "`word'" year_post_treatment2 "`word'" year_post_treatment3 "`word'" tau "`word'") 
		drop(post_treatment? $covid _cons) starlevels(* 0.10 ** 0.05 *** 0.01);
	#d cr
	
}

*----------------------*
*--- Day of year FE ---*
*----------------------*
est clear

foreach word of global words{
	local var = lower("`word'")
	
	forval j = 1/3{
		
		*--- TWFE ---*
		reghdfe d_`var' year_post_treatment`j' post_treatment`j' $covid [pw=pop] if treat_date`j'!=., absorb(state_id year day dow) vce(cluster day)
		eststo `word'`j'_twfe_fe2 
		
		*--- BJS ---*
		did_imputation d_`var' state edate treat_date`j' [aw=pop] if treat_date`j'!=., fe(post_treatment`j' state_id year day dow) cluster(day) wtr(pop)
		eststo `word'`j'_bjs_fe2 
		
	}
	
	#d ;
	estout `word'*_twfe_fe2 `word'*_bjs_fe2 using "$root/Overleaf/Tables/`var'_fe2.tex", style(tex) replace
		cells( b(star fmt(%9.3f)) se(par) p(par([ ])) ) mlabels(none) label collabels(none) 
		rename(year_post_treatment1 "`word'" year_post_treatment2 "`word'" year_post_treatment3 "`word'" tau "`word'") 
		drop(post_treatment? $covid _cons) starlevels(* 0.10 ** 0.05 *** 0.01);
	#d cr
	
}

*--------------------*
*--- State-day FE ---*
*--------------------*
est clear

foreach word of global words{
	local var = lower("`word'")
	
	forval j = 1/3{
		
		*--- TWFE ---*
		reghdfe d_`var' year_post_treatment`j' post_treatment`j' $covid [pw=pop] if treat_date`j'!=., absorb(year state_id#day dow) vce(cluster day)
		eststo `word'`j'_twfe_fe3 
		
		*--- BJS ---*
		did_imputation d_`var' state edate treat_date`j' [aw=pop] if treat_date`j'!=., fe(post_treatment`j' year state_id#day dow) cluster(day) wtr(pop) autosample //autosample option needed. Cannot compute FE for some obs. otherwise 
		eststo `word'`j'_bjs_fe3 
		
	}
	
	#d ;
	estout `word'*_twfe_fe3 `word'*_bjs_fe3 using "$root/Overleaf/Tables/`var'_fe3.tex", style(tex) replace
		cells( b(star fmt(%9.3f)) se(par) p(par([ ])) ) mlabels(none) label collabels(none) 
		rename(year_post_treatment1 "`word'" year_post_treatment2 "`word'" year_post_treatment3 "`word'" tau "`word'") 
		drop(post_treatment? $covid _cons) starlevels(* 0.10 ** 0.05 *** 0.01);
	#d cr
	
}



// -------------------------------------------------------------------------- //
// --- (2) Subcategories												  --- //
// -------------------------------------------------------------------------- //

global subcategories "Astrology Buddhism Christianity Hinduism Islam Judaism Occult Paganism Worship Scientology Selfhelp Skeptics Spirituality Theology"
global covid L_deaths_avg	//no big changes with different covid covariates 

use "$organized/us_subcat_twfe.dta", clear

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
		reghdfe d_`var' year_post_treatment`j' post_treatment`j' $covid [pw=pop] if treat_date`j'!=., absorb(state_id year week_id dow) vce(cluster day)
		eststo `subcat'`j'_twfe_fe1
		
		*--- BJS ---*
		did_imputation d_`var' state edate treat_date`j' [aw=pop] if treat_date`j'!=., fe(post_treatment`j' state_id year week_id dow) cluster(day) wtr(pop)
		eststo `subcat'`j'_bjs_fe1
		
	}
	
	#d ;
	estout `subcat'*_twfe_fe1 `subcat'*_bjs_fe1 using "$root/Overleaf/Tables/`var'_subcat_fe1.tex", style(tex) replace
		cells( b(star fmt(%9.3f)) se(par) p(par([ ])) ) mlabels(none) label collabels(none) 
		rename(year_post_treatment1 "`subcat'" year_post_treatment2 "`subcat'" year_post_treatment3 "`subcat'" tau "`subcat'") 
		drop(post_treatment? $covid _cons) starlevels(* 0.10 ** 0.05 *** 0.01);
	#d cr
	
}

*----------------------*
*--- Day of year FE ---*
*----------------------*
est clear

foreach subcat of global subcategories{
	local var = lower("`subcat'")
	
	forval j = 1/3{
		
		*--- TWFE ---*
		reghdfe d_`var' year_post_treatment`j' post_treatment`j' $covid [pw=pop] if treat_date`j'!=., absorb(state_id year day dow) vce(cluster day)
		eststo `subcat'`j'_twfe_fe2 
		
		*--- BJS ---*
		did_imputation d_`var' state edate treat_date`j' [aw=pop] if treat_date`j'!=., fe(post_treatment`j' state_id year day dow) cluster(day) wtr(pop)
		eststo `subcat'`j'_bjs_fe2 
		
	}
	
	#d ;
	estout `subcat'*_twfe_fe2 `subcat'*_bjs_fe2 using "$root/Overleaf/Tables/`var'_subcat_fe2.tex", style(tex) replace
		cells( b(star fmt(%9.3f)) se(par) p(par([ ])) ) mlabels(none) label collabels(none) 
		rename(year_post_treatment1 "`subcat'" year_post_treatment2 "`subcat'" year_post_treatment3 "`subcat'" tau "`subcat'") 
		drop(post_treatment? $covid _cons) starlevels(* 0.10 ** 0.05 *** 0.01);
	#d cr
	
}

*--------------------*
*--- State-day FE ---*
*--------------------*
est clear

foreach subcat of global subcategories{
	local var = lower("`subcat'")
	
	forval j = 1/3{
		
		*--- TWFE ---*
		reghdfe d_`var' year_post_treatment`j' post_treatment`j' $covid [pw=pop] if treat_date`j'!=., absorb(year state_id#day dow) vce(cluster day)
		eststo `subcat'`j'_twfe_fe3 
		
		*--- BJS ---*
		did_imputation d_`var' state edate treat_date`j' [aw=pop] if treat_date`j'!=., fe(post_treatment`j' year state_id#day dow) cluster(day) wtr(pop) autosample //autosample option needed. Cannot compute FE for some obs. otherwise 
		eststo `subcat'`j'_bjs_fe3 
		
	}
	
	#d ;
	estout `subcat'*_twfe_fe3 `subcat'*_bjs_fe3 using "$root/Overleaf/Tables/`var'_subcat_fe3.tex", style(tex) replace
		cells( b(star fmt(%9.3f)) se(par) p(par([ ])) ) mlabels(none) label collabels(none) 
		rename(year_post_treatment1 "`subcat'" year_post_treatment2 "`subcat'" year_post_treatment3 "`subcat'" tau "`subcat'") 
		drop(post_treatment? $covid _cons) starlevels(* 0.10 ** 0.05 *** 0.01);
	#d cr
	
}



















