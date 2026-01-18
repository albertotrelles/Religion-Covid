global root "C:/Users/ALBERTO TRELLES/Dropbox/Religion-Covid"
global output "$root/Output"
global input "$root/Input"
global data "$root/Data"
global organized "$data/Organized"
global raw "$data/Data_collection/raw"
global demographic "$data/Demographic"
global temporal "$root/Temporal"
cd "$root"

global datasets "us_nocat us_subcat"

**# Bookmark #1
// -------------------------------------------------------------------------- //
// --- (1) TWFE Variables												  --- //
// -------------------------------------------------------------------------- //

foreach dataset of global datasets{
	
	use "$organized/`dataset'.dta", replace
	sort state year edate
	by state year: gen day=_n

	//noyear_edate: equal to edate in 2020. For 2019, it equals the paired 2020 dates 
	gen noyear_edate = edate
	replace noyear_edate = edate + 365 if year==2019 
	replace noyear_edate = noyear_edate+1 if year==2019 & noyear_edate>=21974	//handle bissextile year 
	format noyear_edate %d

	*--- Unit & Time FEs ---*
	encode state, gen(state_id)
	gen dyear=(year==2020)
	replace week_id=week_id-15 if year==2020

	*--- T1: Announcement date ---*
	gen ann_date=date(date_announced, "YMD")
	format ann_date %d

	by state: gen post_treatment1 = (noyear_edate >= ann_date)
	gen year_post_treatment1 = dyear*post_treatment1

	*--- T2: City lockdown ---*
	gen city_date=date(city_enactedfirst, "YMD")
	format city_date %d

	by state: gen post_treatment2 = (noyear_edate >= city_date)
	gen year_post_treatment2 = dyear*post_treatment2

	*--- T3: 1 week anticipation ---*
	gen ant_date=date(date_announced, "YMD") - 7
	format ant_date %d

	by state: gen post_treatment3 = (noyear_edate >= ant_date)
	gen year_post_treatment3 = dyear*post_treatment3

	*--- Covid variables ---*
	foreach var in cases_avg deaths_avg cases deaths{
		gen L_`var' = `var'[_n-1] if state==state[_n-1]
		replace L_`var' = 0 if L_`var' & state!=state[_n-1]
	}

	drop if _merge==2
	save "$organized/`dataset'_twfe.dta", replace

}

// -------------------------------------------------------------------------- //
// --- (2) Event-Study variables										  --- //
// -------------------------------------------------------------------------- //

foreach dataset of global datasets{

	use "$organized/`dataset'_twfe.dta", clear

	*--- Relative time ---*
	gen dayssincetreat1 = noyear_edate - ann_date
	gen dayssincetreat2 = noyear_edate - city_date
	gen dayssincetreat3 = noyear_edate - ant_date

	*--- Event-time dummies ---*
	forval j=1/3{
	
		*Leads (pre)
		cap drop pre*_t`j'
		cap drop ypre*_t`j'
	
		gen pre1_t`j' = (inrange(dayssincetreat`j', -7, -1))
		gen pre2_t`j' = (inrange(dayssincetreat`j', -14, -8))
		gen pre3_t`j' = (inrange(dayssincetreat`j', -21, -15))
		gen pre4_t`j' = (inrange(dayssincetreat`j', -28, -22))
		gen pre5_t`j' = (inrange(dayssincetreat`j', -35, -29))
		gen pre6_t`j' = (inrange(dayssincetreat`j', -42, -36))
		gen pre7_t`j' = (inrange(dayssincetreat`j', -49, -43))
		gen pre8_t`j' = (inrange(dayssincetreat`j', -56, -50))
		gen pre9_t`j' = (inrange(dayssincetreat`j', -63, -57))
		gen pre10_t`j' = (inrange(dayssincetreat`j', -70, -64))
		gen pre11_t`j' = (inrange(dayssincetreat`j', -77, -71))
		gen pre12_t`j' = (dayssincetreat`j'<=-78 & dayssincetreat`j'!=.)

		forval i = 1/12{
			gen ypre`i'_t`j' = dyear*pre`i'_t`j'
			label variable ypre`i'_t`j' "$\mathds{1}[2020] \times E_{-`i'}$"
		}	
		
		*Lags (post)
		cap drop post*_t`j'
		cap drop ypost*_t`j'
		
		gen post0_t`j' = (inrange(dayssincetreat`j', 0, 6))
		gen post1_t`j' = (inrange(dayssincetreat`j', 7, 13))		
		gen post2_t`j' = (inrange(dayssincetreat`j', 14, 20))
		gen post3_t`j' = (inrange(dayssincetreat`j', 21, 27))
		gen post4_t`j' = (dayssincetreat`j'>=28 & dayssincetreat`j'!=.)
		
		forval i = 0/4{
			gen ypost`i'_t`j' = dyear*post`i'_t`j'
			label variable ypost`i'_t`j' "$\mathds{1}[2020] \times E_{`i'}$"
		}
		
	}	

	*Note: In Brodeur2021 they set -4 as the base category and drop any observations with relative week < -4
	save "$organized/`dataset'_dynamic.dta", replace

}





































reghdfe d_christianity post_treatment ypre*_t1 pre*_t1 [pw=pop] if year_post_treatment==0 & dayssincetreat!=., absorb(state year week_id dow) vce(cluster day)
reghdfe d_christianity post_treatment2 ypre*_t2 pre*_t2 [pw=pop] if year_post_treatment2==0 & dayssincetreat2!=., absorb(state year week_id dow) vce(cluster day)
reghdfe d_christianity post_treatment3 ypre*_t3 pre*_t3 [pw=pop] if year_post_treatment3==0 & dayssincetreat3!=., absorb(state year week_id dow) vce(cluster day)


encode state, gen(state_id)

did_imputation d_christianity state edate ann_date [aw=pop] if ann_date!=., fe(post_treatment day state year dow) cluster(day) wtr(pop)
reghdfe d_christianity post_treatment ypre*_t1 pre*_t1 [pw=pop] if year_post_treatment==0 & dayssincetreat!=., absorb(year state_id day) vce(cluster day)

test ypre1_t3 ypre2_t3 ypre3_t3 ypre4_t3 /// 
     ypre5_t3 ypre6_t3 ypre7_t3 ypre8_t3 ///
     ypre9_t3 ypre10_t3 ypre11_t3


reghdfe d_christianity post_treatment ypre*_t1 pre*_t1 [pw=pop] ///
    if year_post_treatment==0 & dayssincetreat!=., ///
    absorb(state year week_id dow) ///
    vce(cluster day)
	
*ssc install parmest, replace
parmest, norestore

keep if strpos(parm,"ypre") & strpos(parm,"_t1")

qqvalue p, method(simes) qvalue(myqval)

*--- Test ---*
*------------*

global important_vars "Buddhism Christianity Hinduism Islam Judaism Scientology Selfhelp Skeptics Theology"

local i = 1
foreach subcat of global important_vars {
	
    local var = lower("`subcat'") 

	*qui sum d_`var' if year_post_treatment==0 & dayssincetreat!=.
	*local mean_sample = r(mean)
	
	*--- BJS ---*
	did_imputation d_`var' state edate ann_date [aw=pop] if ann_date!=., fe(post_treatment state year week_id dow) cluster(day) wtr(pop)
	reghdfe d_`var' post_treatment ypre* pre* [pw=pop] if year_post_treatment==0 & dayssincetreat!=., absorb(state year week_id dow) vce(cluster day)
	*reghdfe d_`var' post_treatment ypre2-ypre12 pre* [pw=pop] if year_post_treatment==0 & dayssincetreat!=., absorb(state year week_id dow) vce(cluster day)
	
	*eststo b`i'
	*estadd scalar mean_s = `mean_sample'
	*estadd scalar obs = e(N)
	
	*test ypre1 ypre2 ypre3 ypre4 ypre5 ypre6 ypre7 ypre8 ypre9 ypre10 ypre11 ypre12
	*estadd scalar pval = r(p)
	
	local i = `i'+1
}



use "$organized/us_subcat_twfe.dta", clear

gen dayssincetreat = noyear_edate - ann_date
gen dayssincetreat2 = noyear_edate - city_date
gen dayssincetreat3 = noyear_edate - ant_date


cap drop pre*
cap drop ypre*
gen pre1 = (inrange(dayssincetreat3, -7, -1))
gen pre2 = (inrange(dayssincetreat3, -14, -8))
gen pre3 = (inrange(dayssincetreat3, -21, -15))
gen pre4 = (inrange(dayssincetreat3, -1000, -22))
gen pre5 = (inrange(dayssincetreat, -35, -29))
gen pre6 = (inrange(dayssincetreat, -42, -36))
gen pre7 = (inrange(dayssincetreat, -49, -43))
gen pre8 = (inrange(dayssincetreat, -56, -50))
gen pre9 = (inrange(dayssincetreat, -63, -57))
gen pre10 = (inrange(dayssincetreat, -70, -64))
gen pre11 = (inrange(dayssincetreat, -77, -71))
gen pre12 = (dayssincetreat<=-78 & dayssincetreat!=.)

forval i = 1/4{
	gen ypre`i' = dyear*pre`i'
	*label variable ypre`i' "$\mathds{1}[2020] \times E_{-`i'}$"
}

drop if dayssincetreat3<-28
reghdfe d_theology post_treatment ypre1-ypre4 pre1-pre4 [pw=pop] if year_post_treatment==0 & dayssincetreat!=., absorb(state year week_id dow) vce(cluster day)









****************************************************
























global covid L_deaths_avg
global subcategories "Astrology Buddhism Christianity Hinduism Islam Judaism Occult Paganism Worship Scientology Selfhelp Skeptics Spirituality Theology"

local i = 1
foreach subcat of global subcategories {
	
	local var = lower("`subcat'")
	reghdfe d_`var' year_post_treatment post_treatment $covid [pw=pop] if ann_date!=., absorb(state year week dow) vce(cluster day)
	
	eststo a`i'
	
	local i = `i'+1

}

local vars "Selfhelp"
local i = 1
foreach subcat of local vars {
	
	local var = lower("`subcat'")
	reghdfe d_`var' year_post_treatment post_treatment [pw=pop] if ann_date!=., absorb(state year week dow) vce(cluster day)
	did_imputation d_`var' state edate ann_date [aw=pop], fe(post_treatment state year week_id dow) cluster(day) wtr(pop)
	
	reghdfe d_`var' year_post_treatment2 post_treatment2 [pw=pop] if city_date!=., absorb(state year week dow) vce(cluster day)
	did_imputation d_`var' state edate city_date [aw=pop], fe(post_treatment2 state year week_id dow) cluster(day) wtr(pop)
	
	reghdfe d_`var' year_post_treatment3 post_treatment3 [pw=pop] if ant_date!=., absorb(state year week dow) vce(cluster day)
	did_imputation d_`var' state edate ant_date [aw=pop], fe(post_treatment3 state year week_id dow) cluster(day) wtr(pop)
	
	
	
	*eststo a`i'
	
	local i = `i'+1

}

local vars "Selfhelp"
local i = 1
foreach subcat of local vars {
	
	local var = lower("`subcat'")
	reghdfe d_`var' year_post_treatment post_treatment [pw=pop], absorb(state year week dow) vce(cluster day)
	reghdfe d_`var' year_post_treatment2 post_treatment2 [pw=pop], absorb(state year week dow) vce(cluster day)
	reghdfe d_`var' year_post_treatment3 post_treatment3 [pw=pop], absorb(state year week dow) vce(cluster day)
	
	*eststo a`i'
	
	local i = `i'+1

}


*THISSS I AM NO LONGER COOKED 
encode state, gen(state_id)
did_imputation d_theology state edate ann_date [aw=pop] if ann_date!=., fe(post_treatment year state_id#day dow) cluster(day) wtr(pop) autosample









reghdfe d_christianity year_post_treatment post_treatment L_deaths L_deaths_avg L_cases L_cases_avg [pw=pop], absorb(state_id#day year dow) vce(cluster day)


reghdfe d_christianity year_post_treatment $covid [pw=pop] if dyear!=., absorb(state dayfe year post_treatment dow week_id) vce(robust)  //doing just 2020 doesn't account for seasonality. Doing just calendar day doesn't pair each 2020 day-state observation with a 2019 day-state observation. 



by state: gen dayfe=_n

gen 



estout a*

















