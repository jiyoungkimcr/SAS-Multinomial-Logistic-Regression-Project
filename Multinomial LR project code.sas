/*Load dataset*/
libname ess "/home/u50052338/ess";

data ess_1;
	set ess.ess9e03_1;
run;

/*Data Preprocessing*/
PROC FORMAT;
   value $CNTRY
   'GB' = 'United Kingdom'  
     'BE' = 'Belgium'  
     'DE' = 'Germany'  
     'EE' = 'Estonia'  
     'IE' = 'Ireland'  
     'ME' = 'Montenegro'  
     'SE' = 'Sweden'  
     'BG' = 'Bulgaria'  
     'CH' = 'Switzerland'  
     'FI' = 'Finland'  
     'SI' = 'Slovenia'  
     'DK' = 'Denmark'  
     'SK' = 'Slovakia'  
     'NL' = 'Netherlands'  
     'PL' = 'Poland'  
     'NO' = 'Norway'  
     'FR' = 'France'  
     'HR' = 'Croatia'  
     'ES' = 'Spain'  
     'IS' = 'Iceland'  
     'RS' = 'Serbia'  
     'AT' = 'Austria'  
     'IT' = 'Italy'  
     'LT' = 'Lithuania'  
     'PT' = 'Portugal'  
     'HU' = 'Hungary'  
     'LV' = 'Latvia'  
     'CY' = 'Cyprus'  
     'CZ' = 'Czechia' ;
   value HINCSRCA
      1 = 'Wages or salaries'  
      2 = 'Income from self-employment (excluding farming)'  
      3 = 'Income from farming'  
      4 = 'Pensions'  
      5 = 'Unemployment/redundancy benefit'  
      6 = 'Any other social benefits or grants'  
      7 = 'Income from investments, savings etc.'  
      8 = 'Income from other sources'  
      77 = 'Refusal' .b = 'Refusal'  
      88 = 'Don''t know' .c = 'Don''t know'  
      99 = 'No answer' .d = 'No answer' ;
   value source_income
      1 = 'Labour Income'
      2 = 'Capital Income'
      3 = 'Social Grants/Benefit Income'
      4 = 'Other Income (inclu farming)';   
   value STFECO
      0 = 'Extremely dissatisfied'  
      1 = '1'  
      2 = '2'  
      3 = '3'  
      4 = '4'  
      5 = '5'  
      6 = '6'  
      7 = '7'  
      8 = '8'  
      9 = '9'  
      10 = 'Extremely satisfied'  
      77 = 'Refusal' .b = 'Refusal'  
      88 = 'Don''t know' .c = 'Don''t know'  
      99 = 'No answer' .d = 'No answer' ;
   value STFGOV
      0 = 'Extremely dissatisfied'  
      1 = '1'  
      2 = '2'  
      3 = '3'  
      4 = '4'  
      5 = '5'  
      6 = '6'  
      7 = '7'  
      8 = '8'  
      9 = '9'  
      10 = 'Extremely satisfied'  
      77 = 'Refusal' .b = 'Refusal'  
      88 = 'Don''t know' .c = 'Don''t know'  
      99 = 'No answer' .d = 'No answer' ;
   value EVMAR
      1 = 'Yes'  
      2 = 'No'  
      7 = 'Refusal' .b = 'Refusal'  
      9 = 'No answer' .d = 'No answer' ;
   value NBTHCLD
      66 = 'Not applicable' .a = 'Not applicable'  
      77 = 'Refusal' .b = 'Refusal'  
      88 = 'Don''t know' .c = 'Don''t know'  
      99 = 'No answer' .d = 'No answer' ;      
   value HINCTNTA
      1 = 'J - 1st decile'  
      2 = 'R - 2nd decile'  
      3 = 'C - 3rd decile'  
      4 = 'M - 4th decile'  
      5 = 'F - 5th decile'  
      6 = 'S - 6th decile'  
      7 = 'K - 7th decile'  
      8 = 'P - 8th decile'  
      9 = 'D - 9th decile'  
      10 = 'H - 10th decile'  
      77 = 'Refusal' .b = 'Refusal'  
      88 = 'Don''t know' .c = 'Don''t know'  
      99 = 'No answer' .d = 'No answer' ;
   value total_netincome
      1 = "Low income"
      2 = "Medium income"
      3 = "High income";
   value AGEA
      999 = 'Not available' .d = 'Not available' ;      
run;      
      

*Check the distribution of the target variable;
*we have 1.56% of 77,88,99 category(level) within this variable
Since they are var with no info at all, we will all drop them later;
proc freq data=ess_1;
 tables hincsrca / out=freq_y;
run;
proc sgplot data=ess_1;
 vbar hincsrca;
run;


/*Data preprocessing*/
/*1)Select only variables we will use for analysis*/
data ess_2;
set ess.ess9e03_1;
format cntry hincsrca stfeco stfgov evmar nbthcld hinctnta agea;
keep cntry hincsrca stfeco stfgov evmar nbthcld hinctnta agea;
run;


*Check the distribution of explanatory variables which require grouping levels;
proc freq data=ess_2;
 tables stfeco / out=freq_stfeco;
run;
proc sgplot data=ess_2;
 vbar stfeco;
run;

proc freq data=ess_2;
 tables stfgov / out=freq_stfgov;
run;
proc sgplot data=ess_2;
 vbar stfgov;
run;

/*After checking the distribution of those two variables,  
we decided to group the levels inside those variables into 3 group.
Low satisfaction(1) / Mid satisfaction(2) / High satisfaction(3)
we will transform it after checking missing data pattern*/


*preprocessing required to check the missing data pattern;
data ess_22;
set ess_2;
format Y source_income. inc total_netincome.;
if ^missing(hincsrca) then do;
	if hincsrca=1 then Y=1;
	else if hincsrca in (2, 7) then Y=2;
	else if hincsrca in (4, 5, 6) then Y=3;
	else if hincsrca in (3, 8) then Y=4;
end;
else if missing(hincsrca) or hincsrca>8 then Y='';
if ^missing(hinctnta) then do;
    if 1<=hinctnta<=3 then inc=1;
    else if 4<=hinctnta<=7 then inc=2;
    else if 8<=hinctnta<=10 then inc=3;
end;
else if missing(hinctnta) or hinctnta>10 then inc='';
if ^missing(stfeco) then do;
	if 0<=stfeco<=3 then _stfeco=1;
	else if 4<=stfeco<=6 then _stfeco=2;
	else if 7<=stfeco<=10 then _stfeco=3;
end;
else if missing(stfeco) or stfeco>11 then _stfeco=.;
if ^missing(stfgov) then do;
	if 0<=stfgov<=3 then _stfgov=1;
	else if 4<=stfgov<=6 then _stfgov=2;
	else if 7<=stfgov<=10 then _stfgov=3;
end;
else if missing(stfgov) or stfgov>11 then _stfgov=.;
if ^missing(evmar) then do;
    if 1<=evmar<=2 then mar=evmar;
end;
else if missing(evmar) or evmar>2 then mar=.;
if ^missing(nbthcld) then do;
	if 0<=nbthcld<=66 then _nbthcld=nbthcld; /*we still keep the category 66(not applicable)*/
end;
else if missing(nbthcld) or nbthcld>66 then _nbthcld='';
age = agea;
run;


/*2)Drop not useful, not meaningful category of the variables 
(Refusal, Don't know, No answer, Not available, Not applicable)
Most of them only accounts less than 5% for each variable (except for HINCTNTA)*/

*Before drop those missing values, Inspect the missing data pattern;
proc mi data=ess_22 nimpute=0;
 var Y age inc mar _nbthcld _stfeco _stfgov;
run;
*=> THERE IS NO SPECIAL PATTERN FOUND;


data ess_3;
set ess_2;
if HINCSRCA in (77,88,99) then delete; 
if STFECO in (77,88,99) then delete; *2.5% NA (these values are from very first original freq table);
if STFGOV in (77,88,99) then delete; *3.53% NA;
if EVMAR in (7,9) then delete; *0.24% NA;
if NBTHCLD in (77,88,99) then delete; *30.12% NA, but if we imputate, only 0.21% 
<- 'not applicable' means they don't have any children -> should be '0' (let's imputate, let's leave 66);
if HINCTNTA in (77,88,99) then delete; *19.49% NA;
if AGEA = 999 then delete; *0.45% NA;
run;

/*2-1) Transform 'NBTHCLD' variable by moving Not applicable into '0' category 
(if u check the distribution of this variable, u can see '0' category is outlier since
it shows only 2 obs. This seems maybe because people checked 'Not applicable(66)' when they don't have any child.
So, it is okay to group them as same category)*/

data ess_3;
set ess_3;
if NBTHCLD=66 then NBTHCLD=0; 
run; 

proc freq data=ess_3;
 tables NBTHCLD / out=freq_nbthcld;
run;
proc sgplot data=ess_3;
 vbar NBTHCLD;
run;

/*3) Final Missing Value Check (Count)*/
proc means data=ess_3 n nmiss;
var hincsrca stfeco stfgov evmar nbthcld hinctnta agea;
run;

/*4) Check some variable's distribution again 
(since we dropped some levels, categories of some variables)*/
proc freq data=ess_3;
    table hincsrca;
run;
proc sgplot data=ess_3;
 vbar hincsrca;
run;

proc freq data=ess_3;
 tables hinctnta / out=freq_hinctnta;
run;
proc sgplot data=ess_3;
 vbar hinctnta;
run;

proc freq data=ess_3;
 tables stfgov / out=freq_stfgov;
run;
proc sgplot data=ess_3;
 vbar stfgov;
run;


/*5)Grouping levels(categories) of target variable and some explanatory variables which are required*/

/*Grouped categories in the target variable HINCSRCA:
1 = Labour Income
2 = Capital Income
3 = Social Grants/Benefit Income
4 = Other Income (including farming)*/

/*Grouped categories in the HINCTNTA
1 = Low total net income
2 = Medium total net income
3 = High total net income*/

/*Grouped categories in the STFECO, STFGOV
1 = Low satisfaction
2 = Medium satisfaction
3 = High satisfaction*/

data ess_4 (drop=hincsrca);
set ess_3;
format Y source_income. hinctnta total_netincome.;
if hincsrca=1 then Y=1;
else if hincsrca in (2, 7) then Y=2;
else if hincsrca in (4, 5, 6) then Y=3;
else if hincsrca in (3, 8) then Y=4;
else hincsrca=.;
if 1<=hinctnta<=3 then hinctnta=1;
else if 4<=hinctnta<=7 then hinctnta=2;
else if 8<=hinctnta<=10 then hinctnta=3;
else hinctnta=.;
if 0<=stfeco<=3 then stfeco=1;
else if 4<=stfeco<=6 then stfeco=2;
else if 7<=stfeco<=10 then stfeco=3;
else stfeco=.;
if 0<=stfgov<=3 then stfgov=1;
else if 4<=stfgov<=6 then stfgov=2;
else if 7<=stfgov<=10 then stfgov=3;
else stfgov=.;
run;


/*6)EDA*/
/*6-1) Check the distribution all variables using freq sgplot (Univariate EDA)*/
/*used this same code for each variables*/
/*check the distribution after previous grouping preprocess*/
proc freq data=ess_4;
    table Y;
run;
proc sgplot data=ess_4;
 vbar Y;
run;

proc freq data=ess_4;
    table hinctnta;
run;
proc sgplot data=ess_4;
 vbar hinctnta;
run;

proc freq data=ess_4;
    table agea;
run;
proc sgplot data=ess_4;
 vbar agea;
run;

proc freq data=ess_4;
    table evmar;
run;
proc sgplot data=ess_4;
 vbar evmar;
run;

proc freq data=ess_4;
    table nbthcld;
run;
proc sgplot data=ess_4;
 vbar nbthcld;
run;

proc freq data=ess_4;
    table stfeco;
run;
proc sgplot data=ess_4;
 vbar stfeco;
run;

proc freq data=ess_4;
    table stfgov;
run;
proc sgplot data=ess_4;
 vbar stfgov;
run;

/*6-2) Discriminatory Performance Analysis*/ 
/*6-2.1) Categorical variables*/
%macro Frequency(Var);
	proc freq data=ess_4;
		tables &Var.*Y;
		ods output CrossTabFreqs=pct01;
	run;
	proc sgplot data=pct01(where=(^missing(RowPercent)));
		vbar &Var. / group=Y groupdisplay=cluster response=RowPercent datalabel;
	run;
%mend;
%Frequency(evmar);
%Frequency(hinctnta);
%Frequency(stfeco);
%Frequency(stfgov);
%Frequency(nbthcld);
%Frequency(cntry);

/*6-2.2) Continuous(numeric) variables*/
*Continuous predictors;
%macro Continuous(Var);
	proc sgplot data=ess_4; 
	vbar &Var. / group=Y;
	run;
%mend;
%Continuous(nbthcld);
%Continuous(agea);

/*6-2.3) EDA by our main X variable satisfaction of current economy (stfeco, JUST TO CHECK)*/
%macro Frequency(Var);
	proc freq data=ess_4;
		tables &Var.*stfeco;
		ods output CrossTabFreqs=pct01;
	run;
	proc sgplot data=pct01(where=(^missing(RowPercent)));
		vbar &Var. / group=stfeco groupdisplay=cluster response=RowPercent datalabel;
	run;
%mend;
%Frequency(evmar);
%Frequency(hinctnta);
%Frequency(stfgov);
%Frequency(cntry);
%Frequency(nbthcld);


%macro Continuous(Var);
	proc sgplot data=ess_4; 
	vbar &Var. / group=stfeco;
	run;
%mend;
%Continuous(nbthcld);
%Continuous(agea);


/*7) Multicollinearity Check*/
/*tried to do it in SAS code as below, but we did in Python (please refer to Appendix in our report)*/
*correlation matrix numerical variables;
proc corr data=ess_4;
 var agea nbthcld;
run;
*chi-square test categorical variables (not sure);
proc freq data=ess_4;
tables evmar*hinctnta/ chisq;
run;


/* Export our final dataset into csv to use it in Python*/
proc export data=ess_4
            outfile=_dataout
            dbms=csv replace;
run;

%let _DATAOUT_MIME_TYPE=text/csv;
%let _DATAOUT_NAME=ess_final.csv;


/*8) Logistic Regression - Multinomial model*/
*Variable selection procedure for our second multinomial LR model (STEPWISE);
proc logistic data=ess_4;
	class evmar (param=ref ref='1') hinctnta (param=ref ref='Medium income') 
	stfeco (param=ref ref='2') stfgov (param=ref ref='2');
	model Y (ref='Labour Income') = evmar hinctnta stfeco stfgov nbthcld agea /
	link=glogit selection=stepwise expb clodds=pl lackfit rsq ctable aggregate scale=none;
	output out=out2 predicted=p;
	ods output Classification=c02;
run;

/*Logistic Regression - Multinomial model with Full Variables based on Stepwise result*/
/*Since we didn't need to drop any variables, the result is same as the first one*/
proc logistic data=ess_4 plots(only)=(effect oddsratio roc);
class  evmar (param=ref ref='1') hinctnta (param=ref ref='Medium income') 
stfeco (param=ref ref='2') stfgov (param=ref ref='2');
model Y (ref='Labour Income') = evmar hinctnta stfeco stfgov nbthcld agea / 
link=glogit corrb expb lackfit rsq ctable aggregate scale=none;
output out=out predicted=p;
ods output Classification=c01;
run;

/*just to check what if we only input our main X variable(directly related to our hypothesis)*/
proc logistic data=ess_4;
class  stfeco (param=ref ref='2');
model Y (ref="Labour Income") = stfeco / link=glogit;
output out=out1 predicted=p;
run;

proc sgplot data=out1;
scatter x=stfeco y=p / group=_LEVEL_;
run;


/*9) Extended analysis(innovative) - LR Multinomial model*/
*In our first LR analysis, we focused on subjective view toward 'Economy' of their own country. 
So, we are curious that if our hypothesis (TRUE) result also applies to any country regardless of their objective economic status.
In here, we chose 2 groups of some countries with relatively higher GDP per capita VS. lower GDP per capita 
while they have a similar amount of obs to have balance in our dataset for analysis.;

proc freq data=ess_4;
    table cntry;
run;
proc sgplot data=ess_4;
 vbar cntry;
run;

*Bring-in data for selected country;
data ess_TOP;
	set ess_4;
	where cntry='AT' or cntry='CH' or cntry='DK' or cntry='NO';
run;

data ess_LOW;
	set ess_4;
	where cntry='IT' or cntry='CZ' or cntry='ES' or cntry='EE';
run;

*Top Countries Group - LR model;
proc logistic data=ess_TOP;
	class stfeco (param=ref ref='2') stfgov (param=ref ref='2') 
	evmar (param=ref ref='1') hinctnta (param=ref ref='Medium income');
	model Y (ref='Labour Income') = stfeco stfgov evmar hinctnta nbthcld agea /
	link=glogit selection=stepwise expb clodds=pl lackfit rsq ctable aggregate scale=none;
	output out=out3 predicted=p;
	ods output Classification=c03;
run;

*Low Countries Group - LR model;
proc logistic data=ess_LOW;
	class stfeco (param=ref ref='2') stfgov (param=ref ref='2') 
	evmar (param=ref ref='1') hinctnta (param=ref ref='Medium income');
	model Y (ref='Labour Income') = stfeco stfgov evmar hinctnta nbthcld agea /
	link=glogit selection=stepwise expb clodds=pl lackfit rsq ctable aggregate scale=none;
	output out=out4 predicted=p;
	ods output Classification=c04;
run;
