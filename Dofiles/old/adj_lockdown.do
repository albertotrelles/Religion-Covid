global root "C:/Users/ALBERTO TRELLES/Dropbox/Religion-Covid"
global output "$root/Output"
global input "$root/Input"
global data "$root/Data"
global organized "$data/Organized"
global raw "$data/Data_collection/raw"
global demographic "$data/Demographic"
global temporal "$root/Temporal"
cd "$root"

global words "Faith God Meditation Prayer Religion Spirituality"


// -------------------------------------------------------------------------- //
// --- (1) Sample construction											  --- //
// -------------------------------------------------------------------------- //

use "$organized/us_nocat_twfe_adj.dta", clear

// Research design: identify the effect of an ADJACENT state's lockdown on
// religiosity, using the staggered timing of adj_date (earliest adjacent-state
// lockdown) as the treatment. To isolate this effect from the focal state's own
// lockdown, we restrict the sample to observations BEFORE the focal state itself
// begins lockdown.
//
// Note on the sample restriction:
// The previous version used:
//   replace sample_adj = 0 if post_treatment1==1 & adj_lockdown==1
// This is incorrect because it only drops observations where BOTH the focal state
// AND an adjacent state have locked down. It keeps observations where
// post_treatment1==1 but adj_lockdown==0 — i.e., the focal state is already in
// lockdown but no adjacent state has locked down yet. Those observations are
// contaminated by the own-state lockdown effect and must be excluded too.
//
// The correct restriction is simply: drop all observations on or after the
// focal state's OWN lockdown date, regardless of adj_lockdown status.

bys state: egen et = max(adj_lockdown)	// 1 if state ever has an adjacent lockdown
gen sample_adj = (et == 1)				// only keep states with at least one adj. lockdown
replace sample_adj = 0 if post_treatment1 == 1	// drop on/after focal state's own lockdown

label var sample_adj "=1 if adj. state ever locked down & before own lockdown"


// -------------------------------------------------------------------------- //
// --- (2) WHY did_imputation (BJS) FAILS FOR THIS SPECIFICATION			  --- //
//																			  //
// The Borusyak-Jaravel-Spiess (BJS) imputation estimator works in two steps:  //
//   (a) It estimates a fixed-effects model on "clean" observations (Omega_0): //
//       pre-treatment obs for eventually-treated units, plus all obs for      //
//       never-treated units. From this it learns each unit's counterfactual.  //
//   (b) It computes ATT(g,t) = Y_it - Y_it(0) for every (cohort g, period t) //
//       cell in the treated set (Omega_1), then averages over cells.          //
//                                                                             //
// Step (b) REQUIRES actual post-treatment observations (Omega_1). Here the   //
// treatment date is adj_date. But the sample restriction drops every          //
// observation on or after the FOCAL state's own lockdown (ann_date). So:     //
//                                                                             //
//   Case 1 — adj_date >= ann_date (adjacent lockdown arrives at or after the //
//   focal state's own lockdown): after applying sample_adj==1, there are      //
//   ZERO post-adj_date observations for these units. BJS has nothing to       //
//   compute ATT on for this cohort.                                           //
//                                                                             //
//   Case 2 — adj_date < ann_date (adjacent lockdown came first): the valid   //
//   post-treatment window is [adj_date, ann_date). This gap is typically a   //
//   matter of days, not weeks. BJS therefore has very few observations in    //
//   Omega_1 per cohort and warns: "suppressing tau because of insufficient   //
//   effective sample size." The reported tau is forced to 0 (omitted).       //
//                                                                             //
// TWFE (reghdfe) does NOT have this problem because it is pooled OLS with    //
// fixed-effect projections. It uses ALL variation in year_adj_lockdown        //
// across the unbalanced panel in a single pass and produces a coefficient    //
// without needing each cohort's post-treatment window to satisfy a minimum   //
// cell-size requirement. The estimand is a variance-weighted ATT, which is   //
// less clean than BJS but feasible here.                                     //
//                                                                             //
// CONCLUSION: For this adjacency spillover specification, TWFE is the right  //
// estimator. BJS is inappropriate because the sample restriction that is     //
// essential to the research design (no observations after own lockdown)      //
// structurally eliminates the post-treatment cells that BJS needs.           //
//                                                                             //
// If a robustness check with BJS is ever desired, it would require limiting  //
// to states where adj_date < ann_date by a substantial margin (e.g., >= 14   //
// days) so that a meaningful post-treatment pre-own-lockdown window exists.  //
// Even then, ATT would only reflect the very short-run spillover effect.     //
// -------------------------------------------------------------------------- //


// -------------------------------------------------------------------------- //
// --- (3) Estimation: TWFE only (BJS omitted — see explanation above)	  --- //
// -------------------------------------------------------------------------- //

local var prayer
reghdfe d_`var' year_adj_lockdown adj_lockdown [pw=pop] if sample_adj==1, ///
	absorb(state_id year day dow) vce(cluster day)

// BJS is commented out because it returns tau=0 (omitted) for the reasons
// explained in section (2) above. TWFE is the appropriate estimator here.
*did_imputation d_`var' state edate adj_date [aw=pop] if sample_adj==1, ///
*	fe(adj_lockdown state_id year day dow) cluster(day) wtr(pop)


local var prayer
did_imputation d_`var' state edate adj_date [aw=pop] if sample_adj==1, ///
	fe(adj_lockdown state_id year day dow) cluster(day) wtr(pop) minn(1)


// -------------------------------------------------------------------------- //
// --- (4) Heterogeneous treatment effects by party (2016 presidential)	  --- //
// -------------------------------------------------------------------------- //

// The treatment is year_adj_lockdown = dyear × adj_lockdown. To study
// heterogeneity by party we need a triple-DiD, interacting the treatment
// with the Republican dummy.
//
// A proper triple-DiD requires all lower-order interactions to be included
// alongside the key triple interaction, so that the triple term is not
// confounded by differential level effects or differential year trends across
// party groups. The full set of terms is:
//
//   (a) adj_lockdown            level effect of any adjacent lockdown
//   (b) year_adj_lockdown       DiD treatment (baseline: Democrat states, R=0)
//   (c) adj_lockdown_rep        differential level of adj_lockdown in R states
//   (d) year_rep                differential 2020 trend in R states, independent
//                               of the adjacent lockdown — e.g. any R-state
//                               religiosity shock in 2020 unrelated to spillovers
//   (e) year_adj_lockdown_rep   KEY TERM: (ATT Republican) - (ATT Democrat)
//
// Note: republican is time-invariant, so it is absorbed by state_id FE and
// does not appear as a standalone regressor.
//
// Interpretation:
//   b[year_adj_lockdown]        ATT for Democrat states
//   b[year_adj_lockdown_rep]    difference: ATT(Republican) - ATT(Democrat)
//   b[year_adj_lockdown]
//    + b[year_adj_lockdown_rep] ATT for Republican states (use lincom)

gen adj_lockdown_rep      = adj_lockdown * republican
gen year_rep              = dyear * republican
gen year_adj_lockdown_rep = year_adj_lockdown * republican

label var adj_lockdown_rep      "Post adj. lockdown x Republican"
label var year_rep              "Year 2020 x Republican"
label var year_adj_lockdown_rep "Year x Post adj. lockdown x Republican"

foreach word of global words {
	local var = lower("`word'")
	reghdfe d_`var' year_adj_lockdown year_adj_lockdown_rep ///
		adj_lockdown adj_lockdown_rep year_rep ///
		[pw=pop] if sample_adj==1, ///
		absorb(state_id year day dow) vce(cluster day)
}



















