global root "C:/Users/ALBERTO TRELLES/Dropbox/Religion-Covid"
global data "$root/Data"
global organized "$data/Organized"
global raw "$data/Data_collection/raw"
global demographic "$data/Demographic"
global temporal "$root/Temporal"
cd "$root"

global datasets "us_nocat us_subcat"


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

	/**--- T2: City lockdown ---*
	gen city_date=date(city_enactedfirst, "YMD")
	format city_date %d

	by state: gen post_treatment2 = (noyear_edate >= city_date)
	gen year_post_treatment2 = dyear*post_treatment2*/

	*--- T2: 1 week anticipation ---*
	gen ant_date=date(date_announced, "YMD") - 7  //anticipation date 
	format ant_date %d

	by state: gen post_treatment2 = (noyear_edate >= ant_date)
	gen year_post_treatment2 = dyear*post_treatment2

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
	*gen dayssincetreat2 = noyear_edate - city_date
	gen dayssincetreat2 = noyear_edate - ant_date

	*--- Event-time dummies ---*
	forval j=1/2{
	
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
		gen post2_t`j' = (dayssincetreat`j'>=14 & dayssincetreat`j'!=.)
		*gen post2_t`j' = (inrange(dayssincetreat`j', 14, 20))
		*gen post3_t`j' = (inrange(dayssincetreat`j', 21, 27))
		*gen post4_t`j' = (dayssincetreat`j'>=28 & dayssincetreat`j'!=.)
		
		forval i = 0/2{
			gen ypost`i'_t`j' = dyear*post`i'_t`j'
			label variable ypost`i'_t`j' "$\mathds{1}[2020] \times E_{`i'}$"
		}
		
	}	

	*Note: In Brodeur2021 they set -4 as the base category and drop any observations with relative week < -4
	save "$organized/`dataset'_dynamic.dta", replace

}

















