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
global B = 500


// -------------------------------------------------------------------------- //
// --- Bootstrap BJS Dynamic Effects                                      --- //
// -------------------------------------------------------------------------- //

use "$organized/us_nocat_dynamic.dta", clear

gen treat_date1 = ann_date
gen treat_date2 = ant_date

set seed 12345

*--- Set up postfile to store bootstrap draws ---*
tempname memhold
tempfile bsfile
postfile `memhold' str20 word treatment period rep double(att) using `bsfile'


foreach word of global words {
	local var = lower("`word'")

	forval j = 1/2 {

		di as text _n "=== `word', treatment `j' ==="

		*--- Original point estimates ---*
		di as text "  Point estimates..."

		did_imputation d_`var' state edate treat_date`j' ///
			[aw=pop] if treat_date`j' != ., ///
			fe(post_treatment`j' state_id year day dow) ///
			cluster(day) wtr(pop) ///
			saveestimates(att_`var')

		forval k = 0/3 {
			quietly mean att_`var' [pw=pop] if ypost`k'_t`j' == 1
			local pe`k' = r(table)[1,1]
			post `memhold' ("`word'") (`j') (`k') (0) (`pe`k'')
		}
		drop att_`var'


		*--- Bootstrap ---*
		forval i = 1/$B {
			if mod(`i', 50) == 0 {
				di as text "  Bootstrap rep `i'/$B"
			}

			preserve
			bsample, cluster(day)

			cap noisily did_imputation d_`var' state edate treat_date`j' ///
				[aw=pop] if treat_date`j' != ., ///
				fe(post_treatment`j' state_id year day dow) ///
				cluster(day) wtr(pop) ///
				saveestimates(att_`var')

			if _rc == 0 {
				forval k = 0/3 {
					cap quietly mean att_`var' [pw=pop] if ypost`k'_t`j' == 1
					if _rc == 0 {
						post `memhold' ("`word'") (`j') (`k') (`i') (r(table)[1,1])
					}
				}
			}

			restore
		}
	}
}

postclose `memhold'


// -------------------------------------------------------------------------- //
// --- Collapse to point estimates + bootstrap SEs                        --- //
// -------------------------------------------------------------------------- //

use `bsfile', clear

*--- Separate original estimates (rep==0) from bootstrap draws ---*
gen byte is_original = (rep == 0)

*--- Compute bootstrap SE = SD of bootstrap draws ---*
preserve
	keep if rep > 0
	collapse (sd) se = att (count) n_reps = att, by(word treatment period)
	tempfile ses
	save `ses'
restore

*--- Keep original point estimates ---*
keep if rep == 0
rename att estimate
drop rep is_original

merge 1:1 word treatment period using `ses', nogen

*--- Confidence intervals (normal approximation) ---*
gen ci_lower = estimate - 1.96 * se
gen ci_upper = estimate + 1.96 * se

*--- Labels ---*
label var word       "Search term"
label var treatment  "Treatment (1=announcement, 2=anticipation)"
label var period     "Weeks post-treatment"
label var estimate   "ATT point estimate (BJS)"
label var se         "Bootstrap SE"
label var ci_lower   "95% CI lower bound"
label var ci_upper   "95% CI upper bound"
label var n_reps     "Number of successful bootstrap reps"

order word treatment period estimate se ci_lower ci_upper n_reps

sort word treatment period

save "$organized/us_bootstrap_dynamic.dta", replace

list, sepby(word) noobs abbreviate(12)
