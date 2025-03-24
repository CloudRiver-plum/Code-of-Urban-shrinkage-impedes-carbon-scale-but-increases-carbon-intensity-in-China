cd "D:\00博士\小论文\论文1\数据处理\01计算数据\数据处理初步1\stata\数据重新处理"

*前期数据处理
search bootstrap
xls2dta: import excel "data.xlsx", firstrow
use "data.dta", clear
save, replace
//数据增补
xls2dta: import excel "AR.xlsx", firstrow
use "AR.dta", clear
save, replace
reshape long AR, i(city) j(year)
save AR1.dta, replace
use "data.dta", clear
merge 1:1 citycode year using AR1, nogen
replace AR = 0 if missing(AR)
save, replace

//数据增补,建成区人口数量
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


//数据增补

xls2dta: import excel "EC.xlsx", firstrow
use "EC.dta", clear
save, replace
reshape long EC, i(city) j(year)
save EC1.dta, replace
use "data.dta", clear
merge 1:1 citycode year using EC1, nogen
save, replace

//数据增补
xls2dta: import excel "Urbangrade.xlsx", firstrow
use "Urbangrade.dta", clear
save, replace
reshape long Urbangrade, i(city) j(year)
save Urbangrade1.dta, replace
use "data.dta", clear
merge 1:1 citycode year using Urbangrade1, nogen
save, replace

//数据增补
xls2dta: import excel "PMD.xlsx", firstrow
use "PMD.dta", clear
save, replace
reshape long midu, i(city) j(year)
save PMD1.dta, replace
use "data.dta", clear
merge 1:1 citycode year using PMD1, nogen
save, replace


//字符型转化为数值型
destring PGA, replace force
destring BG, replace force
destring NE, replace force
//处理缺失值
replace PGA = 0 if missing(PGA)
replace BG = 0 if missing(BG)

//取对数,数值变换
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
//删除多余空白格
drop if missing(citycode)
save, replace
gen lnAR = ln(AR)
replace lnAR = 0 if missing(lnAR)



*基准回归结果

*检验
//设定全局变量
global xlist0 NL GI NE PI OE HC UR BG ED
xtset city1 year

//共线性检验，结果正常
regress lnSC SR $xlist0 i.city1 i.year
estat vif

//基准回归分析，双固定效应
xtreg lnSC SR $xlist0, fe
est store m1
xtreg lnPC SR $xlist0, fe
est store m2
xtreg lnGC SR $xlist0, fe
est store m3




//结果输出
outreg2 [m1 m2 m3] using tab01, word replace tstat tdec(2) //系数下显示t值，带括号



*内生性检验
//导入文件
* Install ftools (remove program if it existed previously)
cap ado uninstall ftools
net install ftools, from("C:\Program Files\Stata17\ado\plus\11\ftools-master\src")
 
* Install reghdfe
cap ado uninstall reghdfe
net install reghdfe, from("C:\Program Files\Stata17\ado\plus\11\reghdfe-master\src")

 
* Finally, install this package
cap ado uninstall ivreghdfe
net install ivreghdfe, from("C:\Program Files\Stata17\ado\plus\11\ivreghdfe-master\src")


//以老龄化、受教育年限、金融发展度为工具变量解决内生性问题


// 执行内生检验回归
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



*稳健性检验

//替换核心解释变量（改变核心解释变量的计算方式）
xtreg lnSC midu $xlist0, fe
est store m1
xtreg lnGC midu $xlist0, fe
est store m2


//替换被解释变量，强度互相印证，能源碳排放规模，结果可以

xtreg lnEC SR $xlist0, fe
est store m3
xtreg lnPC SR $xlist0, fe
est store m4

//增加控制变量,人均GDP
global xlist1 NL GI PI OE HC BG NE UR lnPG ED
xtreg lnSC SR $xlist1, fe
est store m5
xtreg lnGC SR $xlist1, fe
est store m6


//改变回归方法，下面的因果效应模型也验证了


outreg2 [m1 m2 m3 m4 m5 m6] using tab05, word replace tstat tdec(2) //系数下显示t值，带括号


*交互项分析，因变量lnSC.核心解释变量SR


//变量去中心化
center SR, prefix(c_)
center NE, prefix(c_)
center lnPGA, prefix(c_)
center BG, prefix(c_)
save, replace

//因变量SC,单个交互项影响分析,去中心化
xtreg lnSC SR c.c_SR#c.c_NE $xlist0, fe
est store m1
xtreg lnSC SR c.c_SR#c.c_BG $xlist0, fe
est store m2
xtreg lnSC SR c.c_SR#c.c_lnPGA $xlist0, fe
est store m4
//结果输出

outreg2 [m1 m2 m4] using tab03, word replace tstat tdec(2) //系数下显示t值，带括号


*中介机制检验

//四段式检验法

*中介效应分析，因变量lnSC,lnGC.核心解释变量SR,


//lnSC,能源效率NE的中介效应分析
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
//lnGC,能源效率NE的中介效应分析
xtreg lnGC SR $xlist2, fe
est store m5
xtreg NE SR $xlist2, fe
est store m6
xtreg lnGC NE $xlist2, fe
est store m7
xtreg lnGC NE SR $xlist2, fe
est store m8
//结果输出
outreg2 [m1 m2 m3 m4 m5 m6 m7 m8] using tab04, word replace tstat tdec(2) //系数下显示t值，带括号



//Boostrap检验--检验中介效应是否存在--,lnT_Carbon,能源效率NE的中介效应分析
clear all
use "data.dta", clear
xtset city1 year



program define mediateffect, rclass
    syntax , xvar(string) mvar(string) yvar(string)
    
    * 回归 M 变量在 X 变量上的影响
    xtreg `mvar' `xvar', fe vce(cluster city1)
    matrix b1 = e(b)
    
    * 回归 Y 变量在 X 和 M 变量上的影响
    xtreg `yvar' `xvar' `mvar', fe vce(cluster city1)
    matrix b2 = e(b)
    
    * 计算间接效应
    scalar indirect_effect = b1[1,1] * b2[1,2]
    
    * 返回结果
    return scalar indirect_effect = indirect_effect
end
* 使用 bootstrap 方法估计间接效应
bootstrap r(indirect_effect), reps(1000) seed(123): mediateffect, xvar(SR) mvar(NE) yvar(lnSC)
bootstrap r(indirect_effect), reps(1000) seed(123): mediateffect, xvar(SR) mvar(NE) yvar(lnPC)

* 显示 bootstrap 结果
estat bootstrap

//Sobel-Goodman检验--检验中介效应是否存在--
xtreg NE SR $xlist2 i.year, fe cluster(city1)
matrix list e(b)
matrix list e(V)
xtreg lnGC NE SR $xlist2 i.year, fe cluster(city1)
matrix list e(b)
matrix list e(V)
sgmediation lnGC, mv(NE) iv(SR) cv(city1 $xlist2)
est sto SG_M

//Sobel-Goodman检验--检验中介效应是否存在--
xtreg NE SR $xlist2 i.year, fe cluster(city1)
matrix list e(b)
matrix list e(V)
xtreg lnSC NE SR $xlist2 i.year, fe cluster(city1)
matrix list e(b)
matrix list e(V)
sgmediation lnSC, mv(NE) iv(SR) cv(city1 $xlist2)
est sto SG_M

*空间异质性分析，分区域，分城市规模
 
 //lnSC,分区域交互项影响分析，结果均不显著
xtreg lnSC SR $xlist0 if region3 == 1, fe
est store m1
xtreg lnSC SR $xlist0 if region3 == 2, fe
est store m2
xtreg lnSC SR $xlist0 if region3 == 3, fe
est store m3

//lnGC,分区域交互项影响分析，结果均不显著
xtreg lnGC SR $xlist0 if region3 == 1, fe
est store m4
xtreg lnGC SR $xlist0 if region3 == 2, fe
est store m5
xtreg lnGC SR $xlist0 if region3 == 3, fe
est store m6


//结果输出
outreg2 [m1 m2 m3 m4 m5 m6] using tab11, word replace tstat tdec(2)  //系数下显示t值，带括号

//lnSC,分城市规模交互项影响分析，结果均不显著
xtreg lnSC SR $xlist0 if Urbangrade == 1, fe
xtreg lnSC SR $xlist0 if Urbangrade == 2, fe
est store m1
xtreg lnSC SR $xlist0 if Urbangrade == 3, fe
est store m2
xtreg lnSC SR $xlist0 if Urbangrade == 4, fe
est store m3
xtreg lnSC SR $xlist0 if Urbangrade == 5, fe
est store m4

//lnGC,分城市规模交互项影响分析，结果均不显著
xtreg lnGC SR $xlist0 if Urbangrade == 1, fe
xtreg lnGC SR $xlist0 if Urbangrade == 2, fe
est store m5
xtreg lnGC SR $xlist0 if Urbangrade == 3, fe
est store m6
xtreg lnGC SR $xlist0 if Urbangrade == 4, fe
est store m7
xtreg lnGC SR $xlist0 if Urbangrade == 5, fe
est store m8

//结果输出
outreg2 [m1 m2 m3 m4 m5 m6 m7 m8] using tab13, word replace tstat tdec(2)  //系数下显示t值，带括号




*因果分析结果，因变量lnT_Carbon,lnG_Carbon,lnP_Carbon.核心解释变量ST，SRU
*平行趋势检验

//数据预处理
sort citycode year
bysort citycode ST: gen t0 = _n
order t0, a(ST)
bysort citycode ST: egen max_t0 = max(t0) if ST == 0
replace t0 = t0 - max_t0 - 1 if ST == 0
replace t0 = t0 - 1 if ST == 1
drop max_t0
rename t0 t1
label variable t1 "距离收缩时间"

replace t1 = -3 if t<-3
forvalues i = 3(-1)1{
    gen pre`i' = (t1 == -`i' & SRU == 1)
}


gen current = (t1 == 0 & SRU == 1)

forvalues i = 1(1)3{
    gen post`i' = (t1 == `i' & SRU == 1)
}


//因变量lnSC.核心解释变量ST，SRU
global xlist1 PI GI OE ED BG HC NL NE UR
reghdfe lnSC c.ST#c.SRU $xlist1, a(city1 year) cl(city1)  //固定个体效应，固定时间，添加控制变量
est store m1
//因变量lnPC.核心解释变量ST，SRU
reghdfe lnPC c.ST#c.SRU $xlist1, a(city1 year) cl(city1)  //固定个体效应，固定时间，添加控制变量
est store m2
//因变量lnGC.核心解释变量ST，SRU
reghdfe lnGC c.ST#c.SRU $xlist1, a(city1 year) cl(city1)  //固定个体效应，固定时间，添加控制变量
est store m3
//结果输出
outreg2 [m1 m2 m3] using tab08, word replace tstat tdec(2) //系数下显示t值，带括号





//平行趋势检验：事件分析法

reghdfe lnSC c.SRU#c.pre3 c.SRU#c.pre2 c.SRU#c.pre1 ///
c.SRU#c.current c.SRU#c.post1 c.SRU#c.post2  c.SRU#c.post3 c.SRU $xlist1, a(year  citycode)  cl(citycode)

reghdfe lnPC c.SRU#c.pre3 c.SRU#c.pre2 c.SRU#c.pre1 ///
c.SRU#c.current c.SRU#c.post1 c.SRU#c.post2  c.SRU#c.post3 c.SRU $xlist1, a(year  citycode)  cl(citycode)



*##画图

//简单版
coefplot, vertical keep(*pre* *current *post*) 

//美化版
coefplot, vertical keep(*pre* *current *post*) ///
 yline(0,lwidth(vthin) lpattern(solid) lcolor(black)) ///
 xline(4,lwidth(vthin) lpattern(solid) lcolor(black)) ///
 ytitle("Coefficient", size(medium)) ///Y轴标题
 xtitle("Time", size(medium)) ///X轴标题 
 ylabel(-0.5(0.1)0.1, angle(0)) ///
 xlabel(1 "pre3" 2 "pre2" 3 "pre1" 4 "current" 5 "post1" 6 "post2", angle(0))   ///
 addplot(line @b @at, lcolor(black) lwidth(medium)) ///
 ciopts(lp(dash) recast(rcap) lcolor(blue) lwidth(medium)) ///
 msymbol(Oh) msize(small) mcolor(gs1)
 graph_options(bgcolor(white)) /// 去掉蓝色背景，设置为白色背景
 
 




