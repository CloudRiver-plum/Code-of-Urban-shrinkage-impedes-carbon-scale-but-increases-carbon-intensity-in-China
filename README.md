**This code package implements econometric analysis and mapping techniques to examine the differentiated impact of urban shrinkage on carbon emissions scale and intensity through econometric models.**

The file "The econometric model code is applicable to stata16 and above.do" contains econometric model code compatible with Stata version 16 and higher. The relevant datasets are included in the data file for verification purposes by reviewers. For any other usage, please acquire the data from the URL specified in the article and include appropriate citation.

To enhance code conciseness and facilitate variable usage, we have employed abbreviations. Below, we provide comprehensive descriptions of these variable abbreviations：
ST: Urban shrinkage status, 1 means shrinkage, 0 means no shrinkage；
SR: Urban shrinkage rate, calculation method see Appendix 1；
TC: Carbon scale/CEs, calculation method see Appendix 1；
GC: Carbon intensity/CEs per unit of GDP,  calculation method see Appendix 1;
PC: Carbon emissions per capita, calculation method see Appendix 1;
BPD:  Population density change rate in built-up areas, calculation method see Appendix 1;
HC: Human capital level, calculation method see Appendix 1;
UR: Urbanization rate, calculation method see Appendix 1;
PG: GDP per capita, calculation method see Appendix 1;
PI: Per capita disposable income, calculation method see Appendix 1;
FD: Financial Development level, calculation method see Appendix 1;
OE: Openness to external markets, calculation method see Appendix 1;
ED: Educational development level, calculation method see Appendix 1;
NL: Innovation development level,  calculation method see Appendix 1;
GI: Government intervention,  calculation method see Appendix 1;
NE: Energy efficiency,  calculation method see Appendix 1;
PGA: Park green space per capita, calculation method see Appendix 1;
BG: Green coverage rate of built-up areas, calculation method see Appendix 1;
SRU: Consecutive years of urban shrinkage, calculated;
ISU: Industrial structure upgrade, only as an alternative variable;
PT: The level of public transportation development, it is only used as an alternative variable；
AR：Aging rate；
EC:Energy CEs;
PMD:Population density change rate in built-up areas；
UrbanGrade:Cities classified according to official standards.
Please refer to Table 1 of the supporting materials for the calculation method and data source of the indicators.

The Figure-2.py file contains Python code for generating Figure 2 in the manuscript. This code is executable in "PyCharm Community Edition 2024.1.4" with a configured Python 3 environment. The data utilized by this code is available in the data table within the data file package.

Figure-3.R is the R language code for generating Figure 3 in the manuscript. It is compatible with RStudio when an R 4.4.2 environment is configured on your computer. The data required for this code can be found in the data table within the data file package.
