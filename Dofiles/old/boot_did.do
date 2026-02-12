*------------------------------*
* boot_did.do
*------------------------------*

args repid outfile

use "$organized/us_nocat_dynamic.dta", clear

gen treat_date1 = ann_date

* Cluster bootstrap by day
bsample, cluster(day)

local var prayer
local j   1

did_imputation d_`var' state edate treat_date`j' ///
    [aw=pop] if treat_date`j'!=., ///
    fe(post_treatment`j' state_id year day dow) ///
    cluster(day) wtr(pop) ///
    saveestimates(att_`var')

mean att_`var' [pw=pop] if ypost0_t1
local m0 = r(table)[1,1]

mean att_`var' [pw=pop] if ypost1_t1
local m1 = r(table)[1,1]

mean att_`var' [pw=pop] if ypost2_t1
local m2 = r(table)[1,1]

clear
set obs 1

gen rep  = `repid'
gen att0 = `m0'
gen att1 = `m1'
gen att2 = `m2'

save "`outfile'", replace