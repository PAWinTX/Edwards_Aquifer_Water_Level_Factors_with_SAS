/* Set path and library name */
%let path=/folders/myfolders/Edwards;
libname Edwards "&path";

/* DATA PREPERATION START */

/* Read raw data file EckCombJ17Pop.csv and create SAS file */
DATA Edwards.EckCombJ17Pop;
	INFILE "&path/EckCombJ17Pop.csv" dlm=',' FIRSTOBS=2;
	INPUT Year TtlRecharge TtlDischarge SprgDischarge WellDischarge SAPrecip 
		Muni_Mil Ind Dom_Livestk Irrig Springs AvgJ17Year PopTtl;
RUN;

/* Examine EckCombJ17Pop */
PROC CONTENTS data=Edwards.EckCombJ17Pop;
RUN;

/* Print first five rows */
PROC PRINT data=Edwards.EckCombJ17Pop (obs=5);
	TITLE "Example Contents of EckCombJ17Pop";
RUN;
TITLE;

/* Compare sum of detail variables to aggregate variables */
DATA VariableVar;
	SET Edwards.EckCombJ17Pop;
	Var_Dsch=round((Muni_Mil+Ind+Dom_Livestk+Irrig+Springs)-TtlDischarge, .01);
	Var_Sprg=round(Springs-SprgDischarge, .01);
	Var_Well=round((Muni_Mil+Ind+Dom_Livestk+Irrig)-WellDischarge, .01);
	PerVar_Dsch=round((((Muni_Mil+Ind+Dom_Livestk+Irrig+Springs)/TtlDischarge)-1), 
		.0001)*100;
	PerVar_Sprg=round((Springs/SprgDischarge)-1, .0001)*100;
	PerVar_Well=round((((Muni_Mil+Ind+Dom_Livestk+Irrig)/WellDischarge)-1), 
		.0001)*100;
	OUTPUT;
RUN;

/* Print observations with more than .1% percent variance */ 
PROC PRINT data=VariableVar;
	WHERE ABS(PerVar_Dsch) >.1 OR ABS(PerVar_Sprg) >.1 OR ABS(PerVar_Well) >.1;
	ID Year;
	VAR TtlDischarge SprgDischarge WellDischarge Muni_Mil Ind Dom_Livestk Irrig 
		Springs Var_Dsch Var_Sprg Var_Well PerVar_Dsch PerVar_Sprg PerVar_Well;
	TITLE "Observations Where Sum of Detail Variables varies more than 0.1% from 
	Aggregate Variables";
RUN;
TITLE;

/* 1954 has more than 10% variance */

/* Create a second data set with erroneous observation 1954 and three redundant 
	aggregate variables removed */
DATA Edwards.EckCombJ17Pop2 (drop=TtlDischarge SprgDischarge WellDischarge);
	SET Edwards.EckCombJ17Pop;
	WHERE Year <> 1954;
	OUTPUT;
RUN;

/* Compare descriptive statistics of original and new data */
PROC MEANS data=Edwards.EckCombJ17Pop 
			n nmiss min max range mean clm std stderr cv skew maxdec=2;
	TITLE "Descriptive Statistics for EckCombJ17Pop";
RUN;
PROC MEANS data=Edwards.EckCombJ17Pop2 
			n nmiss min max range mean clm std stderr cv skew maxdec=2;
	TITLE "Descriptive Statistics for EckCombJ17Pop2";
RUN;
TITLE;

/* ANALYSIS START */

/* Create macro variable vars for all eight regressor variables */
%let vars=TtlRecharge SAPrecip Muni_Mil Ind Dom_Livestk Irrig Springs PopTtl;

/* Explore correlations between all potential regressors and AvgJ17Year */
ODS GRAPHICS / reset=all imagemap;
PROC SGSCATTER data=Edwards.EckCombJ17Pop2;
	PLOT AvgJ17Year*(&vars) / reg rows=4 spacing=0;
	TITLE "Correlations between Potential Regressor Variables and AvgJ17Year";
RUN;
TITLE;

* Expand details of correlations between selected regressors and AvgJ17Year */
ODS GRAPHICS / reset=all;
PROC SGSCATTER data=Edwards.EckCombJ17Pop2;
	PLOT AvgJ17Year*Dom_Livestk / reg grid datalabel=Year;
	TITLE "Correlation between Regressor Variable Dom_Livestk and AvgJ17Year";
RUN;
PROC SGSCATTER data=Edwards.EckCombJ17Pop2;
	PLOT AvgJ17Year*Ind / reg grid datalabel=Year;
	TITLE "Correlation between Regressor Variable Ind and AvgJ17Year";
RUN;
TITLE;

/* Explore correlations between all potential regressors and AvgJ17Year */
ODS GRAPHICS / reset=all imagemap;
PROC REG data=Edwards.EckCombJ17Pop2 plots(label)=(all);
	MODEL AvgJ17Year=&vars / vif;
	ID Year;
	TITLE "Regression Model with Collinearity Check for all Potential 
	Regressors";
RUN;
TITLE;

/* VIF < 10 for all variables. RStudent and CooksD indicate 1992 is 
	influential. So, it is deleted after verifying the data. */
/* Create a third data set with observation 1992 removed */
DATA Edwards.EckCombJ17Pop3;
	SET Edwards.EckCombJ17Pop2;
	WHERE Year <> 1992;
	OUTPUT;
RUN;

/* Explore regression again with all potential regressors without 1992 */
ODS GRAPHICS / reset=all imagemap;
PROC REG data=Edwards.EckCombJ17Pop3 plots(label)=(all);
	MODEL AvgJ17Year=&vars / vif;
	ID Year;
	TITLE "Regression Model with Collinearity Check for all Potential 
	Regressors without 1992";
RUN;
TITLE;

/* Model selection using leave-one-out k-fold cross-validation */
ODS GRAPHICS / reset=all imagemap;
PROC GLMSELECT data=Edwards.EckCombJ17Pop3 plots=all;
	MODEL AvgJ17Year=&vars / 
		selection=stepwise(select=CV) cvmethod=split(60) stats=all;
	TITLE "Model Selection using Leave-one-out k-fold Cross-validation";
RUN;
TITLE;

/* Create macro variable vars3 with five selected regressor variables: 
	Springs Ind TtlRecharge PopTtl Muni_Mil */
%let vars3=Springs Ind TtlRecharge PopTtl Muni_Mil;

/* Explore regression again with five selected regressors */
ODS GRAPHICS / reset=all imagemap;
PROC REG data=Edwards.EckCombJ17Pop3 plots(label)=(all);
	MODEL AvgJ17Year=&vars3 / vif clb;
	ID Year;
	TITLE "Regression Model with Diagnostics for Five Selected Regressors";
RUN;
TITLE;

/* Create macro variable vars4 with four selected regressor variables: 
	Springs Ind TtlRecharge PopTtl */
%let vars4=Springs Ind TtlRecharge PopTtl;

/* p-value for Muni_Mil are not significant */
/* Explore model without Muni_Mil */
ODS GRAPHICS / reset=all imagemap;
PROC REG data=Edwards.EckCombJ17Pop3 plots(label)=(all);
	MODEL AvgJ17Year=&vars4 / vif clb;
	ID Year;
	TITLE "Regression Model with Diagnostics for Four Selected Regressors";
RUN;
TITLE;

/* Create macro variable vars5 with three selected regressor variables: 
	Springs TtlRecharge PopTtl */
%let vars5=Springs TtlRecharge PopTtl;

/* The model's Adj R-Sq is lower but more observations are influential */
/* Explore model without Ind */
ODS GRAPHICS / reset=all imagemap;
PROC REG data=Edwards.EckCombJ17Pop3 plots(label)=(all);
	MODEL AvgJ17Year=&vars5 / vif clb;
	ID Year;
	TITLE "Regression Model with Diagnostics for Three Selected Regressors";
RUN;
TITLE;

