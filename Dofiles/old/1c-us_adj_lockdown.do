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
// --- (1) State adjacency pairs										  --- //
// -------------------------------------------------------------------------- //

preserve

clear
input str2 state str80 neighbors
"AL" "FL GA MS TN"
"AK" ""
"AZ" "CA CO NM NV UT"
"AR" "LA MO MS OK TN TX"
"CA" "AZ NV OR"
"CO" "AZ KS NE NM OK UT WY"
"CT" "MA NY RI"
"DE" "MD NJ PA"
"FL" "AL GA"
"GA" "AL FL NC SC TN"
"HI" ""
"ID" "MT NV OR UT WA WY"
"IL" "IA IN KY MO WI"
"IN" "IL KY MI OH"
"IA" "IL MN MO NE SD WI"
"KS" "CO MO NE OK"
"KY" "IL IN MO OH TN VA WV"
"LA" "AR MS TX"
"ME" "NH"
"MD" "DE PA VA WV"
"MA" "CT NH NY RI VT"
"MI" "IN OH WI"
"MN" "IA ND SD WI"
"MS" "AL AR LA TN"
"MO" "AR IA IL KS KY NE OK TN"
"MT" "ID ND SD WY"
"NE" "CO IA KS MO SD WY"
"NV" "AZ CA ID OR UT"
"NH" "MA ME VT"
"NJ" "DE NY PA"
"NM" "AZ CO OK TX UT"
"NY" "CT MA NJ PA VT"
"NC" "GA SC TN VA"
"ND" "MN MT SD"
"OH" "IN KY MI PA WV"
"OK" "AR CO KS MO NM TX"
"OR" "CA ID NV WA"
"PA" "DE MD NJ NY OH WV"
"RI" "CT MA"
"SC" "GA NC"
"SD" "IA MN MT ND NE WY"
"TN" "AL AR GA KY MO MS NC VA"
"TX" "AR LA NM OK"
"UT" "AZ CO ID NM NV WY"
"VT" "MA NH NY"
"VA" "KY MD NC TN WV"
"WA" "ID OR"
"WV" "KY MD OH PA VA"
"WI" "IA IL MI MN"
"WY" "CO ID MT NE SD UT"
end

*--- Reshape to long (state, neighbor) pairs ---*
split neighbors, parse(" ") gen(n)
drop neighbors
reshape long n, i(state) j(k)
drop if n == ""
rename n neighbor
drop k

tempfile adjacency
save `adjacency'

restore


// -------------------------------------------------------------------------- //
// --- (2) Extract state-level lockdown dates							  --- //
// -------------------------------------------------------------------------- //

use "$organized/us_nocat_twfe.dta", clear

*--- One lockdown date per state ---*
preserve

keep state ann_date
duplicates drop

rename state neighbor
rename ann_date neighbor_lockdown

tempfile neighbor_dates
save `neighbor_dates'

restore


// -------------------------------------------------------------------------- //
// --- (3) Compute earliest adjacent lockdown date per state			  --- //
// -------------------------------------------------------------------------- //

preserve

use `adjacency', clear

*--- Merge in each neighbor's lockdown date ---*
merge m:1 neighbor using `neighbor_dates', keep(match) nogen

*--- Earliest adjacent lockdown date per state ---*
collapse (min) min_adj_lockdown = neighbor_lockdown, by(state)

tempfile adj_dates
save `adj_dates'

restore

// -------------------------------------------------------------------------- //
// --- (4) Create adjacency spillover dummy								  --- //
// -------------------------------------------------------------------------- //

use "$organized/us_nocat_twfe.dta", clear

merge m:1 state using `adj_dates', nogen

*--- Dummy: 1 once any adjacent state has entered lockdown ---*
* Uses noyear_edate (maps 2019 dates to paired 2020 dates), consistent
* with post_treatment1 construction in 1b-us_did_setup.do.
*
* Three cases:
*   (1) Always 0: state has no adjacent states with lockdowns (AK, HI)
*   (2) 0 → 1:    switches on at min adjacent lockdown date
*   (3) Always 1:  state starts during an adjacent lockdown (does not occur)

*--- adj_date: analog of ann_date for adjacent states ---*
gen adj_date = min_adj_lockdown
format adj_date %d
label var adj_date "Earliest adjacent-state lockdown date (analog of ann_date)"

gen adj_lockdown = (noyear_edate >= min_adj_lockdown) if min_adj_lockdown != .
replace adj_lockdown = 0 if min_adj_lockdown == .

*--- Interaction with year dummy for DiD ---*
gen year_adj_lockdown = dyear * adj_lockdown

label var adj_lockdown       "Post adjacent-state lockdown"
label var year_adj_lockdown  "Year x Post adjacent-state lockdown"
label var min_adj_lockdown   "Earliest adjacent-state lockdown date"

// -------------------------------------------------------------------------- //
// --- (5) Party classification (2016 presidential election)				  --- //
// -------------------------------------------------------------------------- //

*--- Republican = states won by Trump in the 2016 presidential election ---*
*--- Democrat  = states won by Clinton in the 2016 presidential election ---*
*
* Classification is by statewide popular vote winner, the standard unit
* for Electoral College purposes. Maine voted Clinton overall (though ME-02
* went Trump); Nebraska voted Trump overall (though NE-02 went Clinton).
*
* Republican (30): AL AK AZ AR FL GA ID IN IA KS KY LA MI MS MO MT NE
*                  NC ND OH OK PA SC SD TN TX UT WV WI WY
* Democrat   (20): CA CO CT DE HI IL ME MD MA MN NV NH NJ NM NY OR RI VT VA WA

gen republican = 0
foreach st in AL AK AZ AR FL GA ID IN IA KS KY LA MI MS MO MT NE NC ND OH OK PA SC SD TN TX UT WV WI WY {
	replace republican = 1 if state == "`st'"
}

label var republican "=1 if state voted Republican (Trump) in 2016 presidential election"

*stop

save "$organized/us_nocat_twfe_adj.dta", replace
