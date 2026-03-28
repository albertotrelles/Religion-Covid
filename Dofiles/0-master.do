// ============================================================ //
// Master dofile: Religious Coping and COVID-19 Lockdowns       //
// Author: Alberto Trelles                                      //
// Last updated: March 2026                                     //
// Description: Runs all cleaning and analysis dofiles in order //
// ============================================================ //

global root "C:/Users/ALBERTO TRELLES/Dropbox/Religion-Covid"
global data "$root/Data"
global organized "$data/Organized"
global raw "$data/Data_collection/raw"
global demographic "$data/Demographic"
global temporal "$root/Temporal"
global tables "$root/Tables"
global figures "$root/Figures"
global dofiles "$root/Dofiles"
cd "$root"


*--- Cleaning ----*
do "$dofiles/1a-us_clean.do"
do "$dofiles/1b-us_did_setup.do"

*--- Analysis ---*
do "$dofiles/2-us_descriptive.do"
do "$dofiles/3a-us_twfe.do"
do "$dofiles/3b-us_dynamic.do"
do "$dofiles/4a-us_het_religion_twfe.do"
do "$dofiles/4b-us_het_religion_eventstudy.do"

