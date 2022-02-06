
options nocenter nonumber nodate orientation=portrait;

filename in1 'C:\Users\radon\OneDrive\Documents\820\SeasonalEffect.xlsx';
filename res 'C:\Users\radon\OneDrive\Documents\820\SAS_Output_HW2_Rachel_Donahue';

proc format;
    value NoYesf 0='No' 1='Yes';
	value Racef   1='White' 2='Black' 3='Other';
	value Statusf 1='Normal' 2='Mild' 3='Severe' 4='Threat';
	value Seasonf 1='Fall' 2='Winter' 3='Spring' 4='Summer';
run;


proc import OUT= WORK.zero 
            DATAFILE= in1
            DBMS=xlsx;
run; 

data one;
     set zero;
     if ((Season eq 2) or (Season eq 4)); /* Keep Winter and Summer */

     format Female Diabetes Renal Steroids Emergency SSI NoYesf. 
            Race Racef. Status Statusf. Season Seasonf.;
     label Age='Age (years)' 
	     BMI='Body Mass Index (kg/m^2)'
	     Status='Physical Status'
	     Renal='Chronic Renal Failure'
	     Steroids='Preop Steroids'
	     DurationSurgery='Surgery Duration (hours)'
	     VitaminD='Vitamin D Level (ng/mL)'
	     RBC='Blood Transfusion (mL)'
	     SSI='Surgical Site Infection';
run;


/*ods rtf file=res bodytitle style=journal;*/


proc contents data=one;
     title1 'Seasonal Effect Data';
run;
ods rtf file=res bodytitle style=journal;
/*Question 1 how many surgeries performed winter or summer*/


proc freq data=one;
     tables Season*SSI/nocol norow nopercent;
	 title1 'Season';
run;
/*Question 2 */
proc logistic data=one;
	class Season (ref='Summer')/ param=ref;
	model SSI (event='Yes')=Season;
	title1 'Logistic Regression Model';
run;


/*Question 2 Profile Likelihood*/
proc logistic data=one;
	class Season (ref='Summer')/ param=ref;
	model SSI (event='Yes')=Season / clodds=pl;
	title1 'Logistic Regression Model with Season as Predictor';
run;


/*Question 3*/

proc logistic data=one;
	class Season (ref='Summer')/ param=ref;
	model SSI (event='Yes')=Season Duration;
	title1 'Logistic Regression Model with Season as Predictor';
run;

proc logistic data=one;
	class Season (ref='Summer')/ param=ref;
	model SSI (event='Yes')=Season Duration / clodds=pl;
	oddsratio SSI / at(Season='Summer' 'Winter') cl=pl;
	title1 'Logistic Regression Model with Season and Duration Predictors';
run;

/*Question 4*/

proc logistic data=one;
	class Season (ref='Summer')/ param=ref;
	model SSI (event='Yes')=Season Duration Season*Duration;
	output out=probs3 predicted=plogst reschi=DpDResid;
	effectplot slicefit(X=Duration sliceby=Season);
	title1 'Logistic Regression with Interaction Model with Interaction Term';
run;
/*Question 5*/


proc sgplot data=probs3;
 scatter x=Duration y=DpDResid;
 yaxis min=-3 max=3;
 title 'Residuals for Duration';
run;


proc sgplot data=probs3;
 scatter x=Season y=DpDResid;
 yaxis min=-3 max=3;
 title 'Residuals for Season';
run;

proc sgplot data=probs3;
 scatter x=Season*Duration y=DpDResid;
 yaxis min=-3 max=3;
 title 'Residuals for Duration*Season';
run;

ods rtf close;
quit;
