********************************************************************
***COVID-19, Lockdowns and Well-Being: Evidenc from Google Trends***
********************************************************************

* This do-file performs some robustness checks

	clear
	set more off


	**********************************************************
	*****			EUROPE								******
	**********************************************************

	*Change path below

	global data "/Users/Data/Europe"
	global results "/Users/Results"

	local varlist "Boredom Contentment Impairment Irritability Loneliness Panic Sadness Sleep Stress Suicide Wellbeing Worry Divorce"
	foreach var of local varlist {
	

	/* Figure A5: Late Lockdown - Western European Countries: All Topics*/
				
	use "$data/Google-trends-`var'-Europe/daily_`var'_18_20_all_full.dta", clear
		replace year=year-2019
		drop if dayssincelockdown==0
		gen post_lockdown_year=post_lockdown*year
		label var post_lockdown_year "Period after lockdown *Year"
		keep if dayssincelockdown!=.
		
		sort country year day
		gen L_dailyconfirmeddeathsdeaths=dailyconfirmeddeathsdeaths[_n-1] if country==country[_n-1]
		
		gen late=0
		replace late=1 if date_lockdown_ann=="2020-03-19" 
		replace late=1 if date_lockdown_ann=="2020-03-23"
		replace late=1 if date_lockdown_ann=="2020-03-28"
		
		gen post_lockdown_year_late=post_lockdown_year*late 
		gen post_lockdown_late=post_lockdown*late

		reghdfe d_`var'_18_20 post_lockdown_year post_lockdown post_lockdown_year_late post_lockdown_late L_dailyconfirmeddeathsdeaths [pw=pop] , ///
		absorb(country year week day_w) vce(cluster day)
		eststo DID_`var'_late
		
		lincom post_lockdown_year_late+post_lockdown_year
		
	coefplot (DID_`var'_late, keep(post_lockdown_year) asequation(Only Full Lockdowns) ciopts(recast(rcap))) ///
	(DID_`var'_late, keep(post_lockdown_year_late) asequation(Only Full Lockdowns - Late) ciopts(recast(rcap))), ///
	label asequation swapnames recast(bar) ci(95) legend(off) xtitle("DID Estimates: `var'")  
	graph export "$results/All_figures_and_tables/DID_Estimates_`var'_late.png", replace
	}

	
	/* Figure A7: Full versus Partial Lockdown*/
	
	
	local varlist "Boredom Contentment Impairment Irritability Loneliness Panic Sadness Sleep Stress Suicide Wellbeing Worry Divorce"
	foreach var of local varlist {
	

	use "$data/Google-trends-`var'-Europe/daily_`var'_18_20_all_full.dta", clear
		replace year=year-2019
		drop if dayssincelockdown==0
		gen post_lockdown_year=post_lockdown*year
		label var post_lockdown_year "Period after lockdown *Year"
		keep if dayssincelockdown!=.
		
		sort country year day
		gen L_dailyconfirmeddeathsdeaths=dailyconfirmeddeathsdeaths[_n-1] if country==country[_n-1]

		reghdfe d_`var'_18_20 post_lockdown_year post_lockdown L_dailyconfirmeddeathsdeaths [pw=pop] , ///
		absorb(country year week day_w) vce(cluster day)
		eststo DID_`var'_1
		
		** Full + partial lockdown - all combined
		use "$data/Google-trends-`var'-Europe/daily_`var'_18_20_all_full&partial.dta", clear
		replace year=year-2019
		drop if dayssincelockdown==0
		gen post_lockdown_year=post_lockdown*year
		label var post_lockdown_year "Period after lockdown *Year"
		
		sort country year day
		gen L_dailyconfirmeddeathsdeaths=dailyconfirmeddeathsdeaths[_n-1] if country==country[_n-1]

		reghdfe d_`var'_18_20 post_lockdown_year post_lockdown L_dailyconfirmeddeathsdeaths [pw=pop] , ///
		absorb(country year week day_w) vce(cluster day)
		eststo DID_`var'_2
		
	coefplot (DID_`var'_1, keep(post_lockdown_year) asequation(Only Full Lockdowns) ciopts(recast(rcap))) ///
	(DID_`var'_2, keep(post_lockdown_year) asequation(Full+Partial Lockdowns Combined) ciopts(recast(rcap))), ///
	label asequation swapnames recast(bar) ci(95) legend(off) xtitle("DID Estimates: `var'")  
	graph export "$results/All_figures_and_tables/DID_Estimates_`var'.png", replace
	
	eststo clear
	}
	
	
	/*Table A2: The Effects of Stay-at-Home Orders - Implementation Date*/
	
	local varlist "Boredom Contentment Impairment Irritability Loneliness Panic Sadness Sleep Stress Suicide Wellbeing Worry Divorce"
	foreach var of local varlist {
	

	** Date of announcement 
	use "$data/Google-trends-`var'-Europe/daily_`var'_18_20_all_full.dta", clear
		replace year=year-2019
		drop if dayssincelockdown==0
		gen post_lockdown_year=post_lockdown*year
		label var post_lockdown_year "Period after lockdown *Year"
		keep if dayssincelockdown!=.
		
		sort country year day
		gen L_dailyconfirmeddeathsdeaths=dailyconfirmeddeathsdeaths[_n-1] if country==country[_n-1]

		reghdfe d_`var'_18_20 post_lockdown_year post_lockdown L_dailyconfirmeddeathsdeaths [pw=pop] , ///
		absorb(country year week day_w) vce(cluster day)
		eststo DID_`var'_3
		
	** Date of implementation
	use "$data/Google-trends-`var'-Europe/daily_`var'_18_20_all_full.dta", clear
		replace year=year-2019
		drop if dayssincelockdown==0
		
		gen lockdown_day=day if date==date_lockdown
		bysort country: egen m_lockdown_day=mean(lockdown_day)
		replace lockdown_day=m_lockdown_day
		drop m_lockdown_day
		bysort country: gen dayssincelockdown_c=day-lockdown_day
		drop lockdown_day
		label var dayssincelockdown_c "Days elapsed since lockdown first city"
		gen post_lockdown_c=0
		replace post_lockdown_c=1 if dayssincelockdown_c>=0 & dayssincelockdown_c!=.
		label var post_lockdown_c "Period after lockdown first city"
		
		gen post_lockdown_c_year=post_lockdown_c*year
		label var post_lockdown_c_year "Period after lockdown *Year"
		
		sort country year day
		gen L_dailyconfirmeddeathsdeaths=dailyconfirmeddeathsdeaths[_n-1] if country==country[_n-1]

		reghdfe d_`var'_18_20 post_lockdown_c_year post_lockdown_c L_dailyconfirmeddeathsdeaths [pw=pop] , ///
		absorb(country year week day_w) vce(cluster day)
		eststo DID_`var'_4
		estadd local countryFE "Yes", replace
		estadd local timeFE "Yes", replace
		estadd local death "Yes", replace

		}
		
	esttab DID_Boredom_4 DID_Contentment_4 DID_Divorce_4 DID_Impairment_4  ///
	using "$results/All_figures_and_tables/Table2_PanelB(1).tex", replace label keep(post_lockdown_c_year) ///
	b(2) se(2) r(3) booktabs sfmt(%12.0f) noconstant  nogaps ///
	coeflabel(post_lockdown_c_year "T_{i,c}*Year_i") ///
	mtitles("Boredom" "Contentment" "Divorce" "Impairment") ///
	stats(countryFE timeFE death N, fmt(. . . 0) ///
	label("Country FE" "Year, Week and Day FE" "Death" "Observations")) ///
	nonotes star(* 0.1 ** 0.05 *** 0.01) nonumbers
		
	esttab DID_Irritability_4 DID_Loneliness_4 DID_Panic_4 DID_Sadness_4   ///
	using "$results/All_figures_and_tables/Table2_PanelB(2).tex", replace label keep(post_lockdown_c_year) ///
	b(2) se(2) r(3) booktabs ///
	coeflabel(post_lockdown_c_year "T_{i,c}*Year_i") ///
	mtitles("Irritability" "Loneliness" "Panic" "Sadness") ///
	stats(countryFE timeFE death N, fmt(. . . 0) ///
	label("Country FE" "Year, Week and Day FE" "Death" "Observations"))   ///
	nonotes star(* 0.1 ** 0.05 *** 0.01) nonumbers
		
	esttab DID_Sleep_4 DID_Stress_4 DID_Suicide_4 DID_Wellbeing_4 DID_Worry_4  ///
	using "$results/All_figures_and_tables/Table2_PanelB(3).tex", replace label keep(post_lockdown_c_year) ///
	b(2) se(2) r(3) booktabs ///
	coeflabel(post_lockdown_c_year "T_{i,c}*Year_i") ///
	mtitles("Sleep" "Stress" "Suicide" "Wellbeing" "Worry") ///
	stats(countryFE timeFE death N, fmt(. . . 0) ///
	label("Country FE" "Year, Week and Day FE" "Death" "Observations"))   ///
	nonotes star(* 0.1 ** 0.05 *** 0.01) nonumbers
	
	eststo clear
	
	
	
	**********************************************************
	*****			US									******
	**********************************************************

	
	*Change path below

	global data "/Users/Data/US"
	global results "/Users/Results"


	local varlist "Boredom Contentment Impairment Irritability Loneliness Panic Sadness Sleep Stress Suicide Wellbeing Worry Divorce"
	foreach var of local varlist {
	

	/* Figure A8: Date Announced versus City/County First Enacted*/
		
	** Date of announcement
	use "$data/Google-trends-`var'-US/daily_`var'_18_20_all_full.dta", clear
		drop if dayssincelockdown==0

		replace year=year-2019
		gen post_lockdown_year=post_lockdown*year
		label var post_lockdown_year "Period after lockdown *Year"
		
		sort state year day
		gen L_dailyconfirmeddeathsdeaths=dailyconfirmeddeathsdeaths[_n-1] if state==state[_n-1]

		reghdfe d_`var'_18_20 post_lockdown_year post_lockdown L_dailyconfirmeddeathsdeaths [pw=pop] , ///
		absorb(state year week day_w) vce(cluster day)
		eststo DID_`var'_5
		
	** Date of first city
		gen lockdown_day=day if date==city_enactedfirst
		bysort state: egen m_lockdown_day=mean(lockdown_day)
		replace lockdown_day=m_lockdown_day
		drop m_lockdown_day
		bysort state: gen dayssincelockdown_c=day-lockdown_day
		drop lockdown_day
		label var dayssincelockdown_c "Days elapsed since lockdown first city"
		gen post_lockdown_c=0
		replace post_lockdown_c=1 if dayssincelockdown_c>=0 & dayssincelockdown_c!=.
		label var post_lockdown_c "Period after lockdown first city"
		
		gen post_lockdown_c_year=post_lockdown_c*year
		label var post_lockdown_c_year "Period after lockdown *Year"
		
		sort state year day
		
		reghdfe d_`var'_18_20 post_lockdown_c_year post_lockdown_c L_dailyconfirmeddeathsdeaths [pw=pop] , ///
		absorb(state year week day_w) vce(cluster day)
		eststo DID_`var'_6
		
	coefplot (DID_`var'_5, keep(post_lockdown_year) asequation(Date of announcement) ciopts(recast(rcap))) ///
	(DID_`var'_6, keep(post_lockdown_c_year) asequation(Date city enacted first) ciopts(recast(rcap))), ///
	label asequation swapnames recast(bar) ci(95) legend(off) xtitle("DID Estimates: `var'")  
	graph export "$results/All_figures_and_tables/DID_Estimates_`var'_US.png", replace
	
	}
	
	/*Table A2: The Effects of Stay-at-Home Orders - Implementation Date*/
	
	local varlist "Boredom Contentment Impairment Irritability Loneliness Panic Sadness Sleep Stress Suicide Wellbeing Worry Divorce"
	foreach var of local varlist {
	

	** Date of announcement 
	use "$data/Google-trends-`var'-US/daily_`var'_18_20_all_full.dta", clear
		replace year=year-2019
		drop if dayssincelockdown==0
		gen post_lockdown_year=post_lockdown*year
		label var post_lockdown_year "Period after lockdown *Year"
		
		sort state year day
		gen L_dailyconfirmeddeathsdeaths=dailyconfirmeddeathsdeaths[_n-1] if state==state[_n-1]

		reghdfe d_`var'_18_20 post_lockdown_year post_lockdown L_dailyconfirmeddeathsdeaths [pw=pop] , ///
		absorb(state year week day_w) vce(cluster day)
		eststo DID_`var'_7
		
	** Date of implementation
	use "$data/Google-trends-`var'-US/daily_`var'_18_20_all_full.dta", clear
		replace year=year-2019
		drop if dayssincelockdown==0
		
		gen lockdown_day=day if date==date_lockdown
		bysort state: egen m_lockdown_day=mean(lockdown_day)
		replace lockdown_day=m_lockdown_day
		drop m_lockdown_day
		bysort state: gen dayssincelockdown_c=day-lockdown_day
		drop lockdown_day
		label var dayssincelockdown_c "Days elapsed since lockdown first city"
		gen post_lockdown_c=0
		replace post_lockdown_c=1 if dayssincelockdown_c>=0 & dayssincelockdown_c!=.
		label var post_lockdown_c "Period after lockdown first city"
		
		gen post_lockdown_c_year=post_lockdown_c*year
		label var post_lockdown_c_year "Period after lockdown *Year"
		
		sort state year day
		gen L_dailyconfirmeddeathsdeaths=dailyconfirmeddeathsdeaths[_n-1] if state==state[_n-1]

		reghdfe d_`var'_18_20 post_lockdown_c_year post_lockdown_c L_dailyconfirmeddeathsdeaths [pw=pop] , ///
		absorb(state year week day_w) vce(cluster day)
		eststo DID_`var'_8
		estadd local stateFE "Yes", replace
		estadd local timeFE "Yes", replace
		estadd local death "Yes", replace

		}
		
	esttab DID_Boredom_8 DID_Contentment_8 DID_Divorce_8 DID_Impairment_8  ///
	using "$results/All_figures_and_tables/Table2_PanelB(1)_US.tex", replace label keep(post_lockdown_c_year) ///
	b(2) se(2) r(3) booktabs ///
	coeflabel(post_lockdown_c_year "T_{i,c}*Year_i") ///
	mtitles("Boredom" "Contentment" "Divorce" "Impairment") ///
	stats(stateFE timeFE death N, fmt(. . . 0) ///
	label("State FE" "Year, Week and Day FE" "Death" "Observations"))  compress ///
	nonotes star(* 0.1 ** 0.05 *** 0.01) nonumbers
		
	esttab DID_Irritability_8 DID_Loneliness_8 DID_Panic_8 DID_Sadness_8  ///
	using "$results/All_figures_and_tables/Table2_PanelB(2)_US.tex", replace label keep(post_lockdown_c_year) ///
	b(2) se(2) r(3) booktabs ///
	coeflabel(post_lockdown_c_year "T_{i,c}*Year_i") ///
	mtitles("Irritability" "Loneliness" "Panic" "Sadness" ) ///
	stats(stateFE timeFE death N, fmt(. . . 0) ///
	label("State FE" "Year, Week and Day FE" "Death" "Observations"))  compress ///
	nonotes star(* 0.1 ** 0.05 *** 0.01) nonumbers
		
	esttab DID_Sleep_8 DID_Stress_8 DID_Suicide_8 DID_Wellbeing_8 DID_Worry_8  ///
	using "$results/All_figures_and_tables/Table2_PanelB(3)_US.tex", replace label keep(post_lockdown_c_year) ///
	b(2) se(2) r(3) booktabs ///
	coeflabel(post_lockdown_c_year "T_{i,c}*Year_i") ///
	mtitles("Sleep" "Stress" "Suicide" "Wellbeing" "Worry") ///
	stats(stateFE timeFE death N, fmt(. . . 0) ///
	label("State FE" "Year, Week and Day FE" "Death" "Observations"))  compress ///
	nonotes star(* 0.1 ** 0.05 *** 0.01) nonumbers
	
	eststo clear
	

