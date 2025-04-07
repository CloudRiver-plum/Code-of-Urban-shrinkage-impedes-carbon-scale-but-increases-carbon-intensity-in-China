cd "C:\paper"

*Preliminary data processing
search bootstrap
xls2dta: import excel "data.xlsx", firstrow
use "data.dta", clear
save, replace
//Data Supplement
xls2dta: import excel "AR.xlsx", firstrow
use "AR.dta", clear
save, replace
reshape long AR, i(city) j(year)
save AR1.dta, replace
use "data.dta", clear
merge 1:1 citycode year using AR1, nogen
replace AR = 0 if missing(AR)
save, replace

//Data supplement, population of built-up areas
drop BP
clear all
xls2dta: import excel "BP.xlsx", firstrow
use "BP.dta", clear
save, replace
reshape long BP, i(city) j(year)
save BP1.dta, replace
use "data.dta", clear
merge 1:1 citycode year using BP1, nogen
replace BP = 0 if missing(BP)
save, replace


//Data Supplement

xls2dta: import excel "EC.xlsx", firstrow
use "EC.dta", clear
save, replace
reshape long EC, i(city) j(year)
save EC1.dta, replace
use "data.dta", clear
merge 1:1 citycode year using EC1, nogen
save, replace

//Data Supplement
xls2dta: import excel "Urbangrade.xlsx", firstrow
use "Urbangrade.dta", clear
save, replace
reshape long Urbangrade, i(city) j(year)
save Urbangrade1.dta, replace
use "data.dta", clear
merge 1:1 citycode year using Urbangrade1, nogen
save, replace

//Data Supplement
xls2dta: import excel "PMD.xlsx", firstrow
use "PMD.dta", clear
save, replace
reshape long midu, i(city) j(year)
save PMD1.dta, replace
use "data.dta", clear
merge 1:1 citycode year using PMD1, nogen
save, replace


//Convert character type to numeric type
destring PGA, replace force
destring BG, replace force
destring NE, replace force

//Handling missing values
replace PGA = 0 if missing(PGA)
replace BG = 0 if missing(BG)

//Take logarithm, numerical transformation
gen lnSC = ln(SC)
replace HC = 100*HC
replace OE = 1000*OE
encode city, gen(city1)
gen lnGC = ln(GC*10)
gen lnPC = ln(PC)
gen lnPGA = ln(PGA)
replace lnPGA = 0 if missing(lnPGA)
replace NE = 1 if missing(NE)
gen lnFD = ln(FD)
gen lnEC = ln(EC)
gen lnPG = ln(PG)
save, replace

//Delete extra spaces
drop if missing(citycode)
save, replace
gen lnAR = ln(AR)
replace lnAR = 0 if missing(lnAR)



*Benchmark regression results

*Test
//Setting global variables
global xlist0 NL GI NE PI OE HC UR BG ED
xtset city1 year

//Collinearity test
regress lnSC SR $xlist0 i.city1 i.year
estat vif

//Benchmark regression analysis, double fixed effects
xtreg lnSC SR $xlist0, fe
est store m1
xtreg lnPC SR $xlist0, fe
est store m2
xtreg lnGC SR $xlist0, fe
est store m3




//Result Output
outreg2 [m1 m2 m3] using tab01, word replace tstat tdec(2)



*Endogeneity test
//Import files
* Install ftools (remove program if it existed previously)
cap ado uninstall ftools
net install ftools, from("C:\Program Files\Stata17\ado\plus\11\ftools-master\src")
 
* Install reghdfe
cap ado uninstall reghdfe
net install reghdfe, from("C:\Program Files\Stata17\ado\plus\11\reghdfe-master\src")

 
* Finally, install this package
cap ado uninstall ivreghdfe
net install ivreghdfe, from("C:\Program Files\Stata17\ado\plus\11\ivreghdfe-master\src")


//Using aging and financial development as instrumental variables to solve the endogeneity problem


// Performing Endogenous Test Regression
clear all
use "data.dta", clear
xtset city1 year
ivreghdfe lnSC $xlist0 (SR = AR), first savefirst savefprefix(f) absorb(city1 year) cluster(city1)
est store iv

display "Adjusted R-squared: " e(r2_a)


outreg2 iv using Table1.doc,replace se dec(3) addtext(City FE,Yes, Year FE, Yes) e(rkf) drop($xlist0) nocons tex(fragment) ctitle(No lags) label(insert)



ivreghdfe lnGC $xlist0 (SR = lnFD), first savefirst savefprefix(f) absorb(city1 year) cluster(city1)
est store iv
display "Adjusted R-squared: " e(r2_a)

outreg2 iv using Table2.doc,replace se dec(3) addtext(City FE,Yes, Year FE, Yes) e(rkf) drop($xlist0) nocons tex(fragment) ctitle(No lags) label(insert)



*Robustness test

//Replace the core explanatory variables (change the way the core explanatory variables are calculated)
xtreg lnSC midu $xlist0, fe
est store m1
xtreg lnGC midu $xlist0, fe
est store m2


//Replace the explained variable, the intensity confirms each other, and the scale of energy carbon emissions

xtreg lnEC SR $xlist0, fe
est store m3
xtreg lnPC SR $xlist0, fe
est store m4

//Add control variables, GDP per capita
global xlist1 NL GI PI OE HC BG NE UR lnPG ED
xtreg lnSC SR $xlist1, fe
est store m5
xtreg lnGC SR $xlist1, fe
est store m6


//Changing the regression method, the following causal effect model also verifies


outreg2 [m1 m2 m3 m4 m5 m6] using tab05, word replace tstat tdec(2) 


*Interaction analysis


//Variable decentralization
center SR, prefix(c_)
center NE, prefix(c_)
center lnPGA, prefix(c_)
center BG, prefix(c_)
save, replace

//Dependent variable SC, single interaction term impact analysis, decentralization
xtreg lnSC SR c.c_SR#c.c_NE $xlist0, fe
est store m1
xtreg lnSC SR c.c_SR#c.c_BG $xlist0, fe
est store m2
xtreg lnSC SR c.c_SR#c.c_lnPGA $xlist0, fe
est store m4

//Result Output
outreg2 [m1 m2 m4] using tab03, word replace tstat tdec(2) 

*Testing of mediating mechanisms

//Four-stage test method

*Mediation effect analysis, dependent variables lnSC, lnGC. Core explanatory variables SR


//Analysis of the mediating effect of lnSC and energy efficiency NE
global xlist2 PI GI OE BG HC NL UR ED
xtset city1 year
xtreg lnSC SR $xlist2, fe
est store m1
xtreg NE SR $xlist2, fe
est store m2
xtreg lnSC NE $xlist2, fe
est store m3
xtreg lnSC NE SR $xlist2, fe
est store m4

//Analysis of the mediating effect of lnGC and energy efficiency NE
xtreg lnGC SR $xlist2, fe
est store m5
xtreg NE SR $xlist2, fe
est store m6
xtreg lnGC NE $xlist2, fe
est store m7
xtreg lnGC NE SR $xlist2, fe
est store m8

//Result Output
outreg2 [m1 m2 m3 m4 m5 m6 m7 m8] using tab04, word replace tstat tdec(2) 



//Bootstrap test--test whether the mediation effect exists--, lnT Carbon, mediation effect analysis of energy efficiency NE
clear all
use "data.dta", clear
xtset city1 year



program define mediateffect, rclass
    syntax , xvar(string) mvar(string) yvar(string)
    
    // Regressing the effect of the M variable on the X variable
    xtreg `mvar' `xvar', fe vce(cluster city1)
    matrix b1 = e(b)
    
    //Regressing the Effect of the Y Variable on the X and M Variables
    xtreg `yvar' `xvar' `mvar', fe vce(cluster city1)
    matrix b2 = e(b)
    
    //Calculating indirect effects
    scalar indirect_effect = b1[1,1] * b2[1,2]
    
    //Return results
    return scalar indirect_effect = indirect_effect
end

//Use bootstrap method to estimate indirect effect
bootstrap r(indirect_effect), reps(1000) seed(123): mediateffect, xvar(SR) mvar(NE) yvar(lnSC)
bootstrap r(indirect_effect), reps(1000) seed(123): mediateffect, xvar(SR) mvar(NE) yvar(lnPC)

//Display bootstrap results
estat bootstrap

//Sobel-Goodman test - to test whether there is a mediation effect -
xtreg NE SR $xlist2 i.year, fe cluster(city1)
matrix list e(b)
matrix list e(V)
xtreg lnGC NE SR $xlist2 i.year, fe cluster(city1)
matrix list e(b)
matrix list e(V)
sgmediation lnGC, mv(NE) iv(SR) cv(city1 $xlist2)
est sto SG_M

//Sobel-Goodman test - to test whether there is a mediation effect -
xtreg NE SR $xlist2 i.year, fe cluster(city1)
matrix list e(b)
matrix list e(V)
xtreg lnSC NE SR $xlist2 i.year, fe cluster(city1)
matrix list e(b)
matrix list e(V)
sgmediation lnSC, mv(NE) iv(SR) cv(city1 $xlist2)
est sto SG_M

*Spatial heterogeneity analysis, by region and city size
 
 //lnSC, regional interaction analysis
xtreg lnSC SR $xlist0 if region3 == 1, fe
est store m1
xtreg lnSC SR $xlist0 if region3 == 2, fe
est store m2
xtreg lnSC SR $xlist0 if region3 == 3, fe
est store m3

//lnGC, regional interaction analysis
xtreg lnGC SR $xlist0 if region3 == 1, fe
est store m4
xtreg lnGC SR $xlist0 if region3 == 2, fe
est store m5
xtreg lnGC SR $xlist0 if region3 == 3, fe
est store m6


//Result output
outreg2 [m1 m2 m3 m4 m5 m6] using tab11, word replace tstat tdec(2)  

//lnSC, city size interaction analysis
xtreg lnSC SR $xlist0 if Urbangrade == 1, fe
xtreg lnSC SR $xlist0 if Urbangrade == 2, fe
est store m1
xtreg lnSC SR $xlist0 if Urbangrade == 3, fe
est store m2
xtreg lnSC SR $xlist0 if Urbangrade == 4, fe
est store m3
xtreg lnSC SR $xlist0 if Urbangrade == 5, fe
est store m4

//lnGC, city size interaction effect analysis
xtreg lnGC SR $xlist0 if Urbangrade == 1, fe
xtreg lnGC SR $xlist0 if Urbangrade == 2, fe
est store m5
xtreg lnGC SR $xlist0 if Urbangrade == 3, fe
est store m6
xtreg lnGC SR $xlist0 if Urbangrade == 4, fe
est store m7
xtreg lnGC SR $xlist0 if Urbangrade == 5, fe
est store m8

//Result output
outreg2 [m1 m2 m3 m4 m5 m6 m7 m8] using tab13, word replace tstat tdec(2)  //系数下显示t值，带括号




*Causal analysis results, dependent variables lnT_Carbon, lnG_Carbon, lnP_Carbon. Core explanatory variables ST, SRU
*Parallel trend test

//Data preprocessing
sort citycode year
bysort citycode ST: gen t0 = _n
order t0, a(ST)
bysort citycode ST: egen max_t0 = max(t0) if ST == 0
replace t0 = t0 - max_t0 - 1 if ST == 0
replace t0 = t0 - 1 if ST == 1
drop max_t0
rename t0 t1
label variable t1 "Distance shrinkage time"

replace t1 = -3 if t<-3
forvalues i = 3(-1)1{
    gen pre`i' = (t1 == -`i' & SRU == 1)
}


gen current = (t1 == 0 & SRU == 1)

forvalues i = 1(1)3{
    gen post`i' = (t1 == `i' & SRU == 1)
}


//Dependent variable lnSC. Core explanatory variables ST, SRU
global xlist1 PI GI OE ED BG HC NL NE UR
reghdfe lnSC c.ST#c.SRU $xlist1, a(city1 year) cl(city1) 
est store m1
//Dependent variable lnPC. Core explanatory variables ST, SRU
reghdfe lnPC c.ST#c.SRU $xlist1, a(city1 year) cl(city1)  
est store m2
//Dependent variable lnGC. Core explanatory variables ST, SRU
reghdfe lnGC c.ST#c.SRU $xlist1, a(city1 year) cl(city1) 
est store m3
//Result output
outreg2 [m1 m2 m3] using tab08, word replace tstat tdec(2) 





//Parallel Trend Test

reghdfe lnSC c.SRU#c.pre3 c.SRU#c.pre2 c.SRU#c.pre1 ///
c.SRU#c.current c.SRU#c.post1 c.SRU#c.post2  c.SRU#c.post3 c.SRU $xlist1, a(year  citycode)  cl(citycode)

reghdfe lnPC c.SRU#c.pre3 c.SRU#c.pre2 c.SRU#c.pre1 ///
c.SRU#c.current c.SRU#c.post1 c.SRU#c.post2  c.SRU#c.post3 c.SRU $xlist1, a(year  citycode)  cl(citycode)



*##Plot

//Simple
coefplot, vertical keep(*pre* *current *post*) 

//Beautified version
coefplot, vertical keep(*pre* *current *post*) ///
 yline(0,lwidth(vthin) lpattern(solid) lcolor(black)) ///
 xline(4,lwidth(vthin) lpattern(solid) lcolor(black)) ///
 ytitle("Coefficient", size(medium)) ///Y
 xtitle("Time", size(medium)) ///X 
 ylabel(-0.5(0.1)0.1, angle(0)) ///
 xlabel(1 "pre3" 2 "pre2" 3 "pre1" 4 "current" 5 "post1" 6 "post2", angle(0))   ///
 addplot(line @b @at, lcolor(black) lwidth(medium)) ///
 ciopts(lp(dash) recast(rcap) lcolor(blue) lwidth(medium)) ///
 msymbol(Oh) msize(small) mcolor(gs1)
 graph_options(bgcolor(white)) /// Background Color
 




