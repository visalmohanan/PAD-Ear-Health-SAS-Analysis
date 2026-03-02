proc import datafile="/home/u64100231/sasuser.v94/Analysis_data.xlsx"
    out=work.miniproject
    dbms=xlsx
    replace;
    sheet="Sheet2";   
    getnames=yes;     
run;
                        *Frequency for demographics;
PROC FREQ data=work.miniproject;
Tables Gender 
Age 
"Education Level"n 
"Residential Area"n 
"Have You ever had frequent ear i"n 
"Any family history of hearing lo"n 
"Are you currently taking, or hav"n
 Occupation /nocum;
run;
proc univariate data=work.miniproject normal;
var age;
run;
proc means data=work.miniproject median q1 q3;
var Age;
run;
proc univariate data=work.miniproject ;
var age;
run;
                             *frequency for PAD use;
proc freq data=work.miniproject ;
Tables "Type of device used"n 
"How many days per week do you us"n 
"Typical daily listening time on"n 
"Typical daily listening time o_1"n 
"Typical listening volume"n 
"Do you often increase volume in"n 
 "Do your device have active noise"n
 "Do your device have transparency"n
 "Do you fall asleep with earphone"n
 "Are you aware of the '60/60 rule"n
 /nocum; 
run;
                             *Frequency of ear symptoms;
proc freq data=work.miniproject;
tables "Ringing or buzzing in ears after"n 
"Difficulty hearing clearly after"n 
"Ear pain/fullness after listenin"n 
"Difficulty hearing conversations"n 
/nocum;
run;
                         *Frequency for Knowledge and Attitudes;
proc freq data=work.miniproject;
tables '“Loud headphone use can perman'n 
'“Using Active Noise Cancellati'n 
"Which safe listening practices d"n

/nocum;
run;

                                   *Analysis;
                                  *Chi square;

proc import datafile="/home/u64100231/sasuser.v94/Analysis_data.xlsx"
    out=work.analysis
    dbms=xlsx
    replace;
    sheet="Coded_data";   /* optional: specify sheet */
    getnames=yes; 
                                 *Demographics;
proc freq data=work.analysis;
tables
Gender * Outcome
"Education Level"n * Outcome
Occupation * Outcome
"Residential Area"n * Outcome
/chisq exact;
run;
                                  *mann whitney u;
proc npar1way data=work.analysis wilcoxon;
var age;
class Outcome;
run;
                                    *PAD usage;
proc freq data=work.analysis;
tables "Type of device used"n * Outcome 
"How many days per week do you us"n * Outcome 
"Typical daily listening time on"n * Outcome 
"Typical daily listening time o_1"n * Outcome 
"Typical listening volume"n * Outcome 
"Do you often increase volume in"n * Outcome 
 "Do your device have active noise"n * Outcome 
 "Do your device have transparency"n * Outcome 
 "Do you fall asleep with earphone"n * Outcome 
 "Are you aware of the '60/60 rule"n * Outcome 
/chisq;
run;
                                *Knowledge and attitude;
proc freq data=work.analysis;
tables '“Loud headphone use can perman'n * Outcome 
'“Using Active Noise Cancellati'n * Outcome
/* "Which safe listening practices d"n * Outcome */
/chisq exact;
run;
                               *Logistic Regression;
proc import datafile="/home/u64100231/sasuser.v94/Analysis_data.xlsx"
out=logistic_data
dbms=xlsx
replace;
sheet="Logistic";
getnames=Yes;
run;

proc freq data=logistic_data;
tables Outcome*("Type of device used"n "Typical daily listening time on"n "Typical daily listening time o_1"n "Typical listening volume"n "Do you often increase volume in"n "Do your device have transparency"n "Do you fall asleep with earphone"n) / chisq;
run;

proc npar1way data=logistic_data wilcoxon;
class outcome;
var  "Typical daily listening time on"n "Typical daily listening time o_1"n "Typical listening volume"n  "Do your device have transparency"n ;
run;
                                 *multicollinearity check;
proc corr data=logistic_data;
var "Type of device used"n "Typical daily listening time on"n "Typical daily listening time o_1"n "Typical listening volume"n "Do you often increase volume in"n "Do your device have transparency"n "Do you fall asleep with earphone"n;
;
proc reg data=logistic_data;
model outcome="Type of device used"n "Typical daily listening time on"n "Typical daily listening time o_1"n "Typical listening volume"n "Do you often increase volume in"n "Do your device have transparency"n "Do you fall asleep with earphone"n
/vif tol;
run;
                                 *regression;
proc logistic data=logistic_data;
class "Type of device used"n(ref='2')
       "Do you often increase volume in"n(ref='0')
       "Do your device have transparency"n(ref="3")
       "Do you fall asleep with earphone"n(ref="0")
       "Typical daily listening time on"n(ref="1")      /*<60 =1/60–119=2/120–179=3/≥180=4*/
       "Typical listening volume"n(ref="1")
/param=ref;
model outcome(event="1")=
       "Type of device used"n                  /*inear=1,overear=2*/
       "Do you often increase volume in"n      /*yes=1,no=0,maybe=2*/
       "Do your device have transparency"n     /*always=1,sometimes=2,no=3*/
       "Do you fall asleep with earphone"n     /*yes=1,no=0*/
       "Typical daily listening time on"n      /*<60 =1/60–119=2/120–179=3/≥180=4*/
       /*"Typical daily listening time o_1"n <60 =1/60–119=2/120–179=3/≥180=4 */
       "Typical listening volume"n ;          /*Very low=1/ Low=2/ Medium=3/ High=4/ Very high=5*/

oddsratio "Type of device used"n;
oddsratio "Do you often increase volume in"n;
oddsratio "Do your device have transparency"n;
oddsratio "Do you fall asleep with earphone"n;
oddsratio "Typical daily listening time on"n;
/*oddsratio "Typical daily listening time o_1"n;*/ 
oddsratio "Typical listening volume"n;
run;


/*proc freq data=logistic_data;
tables "Type of device used"n * outcome /chisq;
run;*/

                                     *pie chart;
proc import datafile="/home/u64100231/sasuser.v94/Analysis_data.xlsx"
    out=work.analysis
    dbms=xlsx
    replace;
    sheet="Coded_data";   /* optional: specify sheet */
    getnames=yes; 
proc gchart data=work.analysis;
pie gender Occupation "Education Level"n "Residential area"n/ percent=inside value=outside slice=outside coutline=black ;
   pattern1 color=bisque;
   pattern2 color= red;
   pattern3 color=yellow;
   pattern4 color=cyan;
   pattern5 color=magenta;
run;
                                     *ROC curve;
proc logistic data=logistic_data;
class "Type of device used"n(ref='2')
       "Do you often increase volume in"n(ref='0')
       "Do your device have transparency"n(ref="3")
       "Do you fall asleep with earphone"n(ref="0")
       "Typical daily listening time on"n(ref="1")      /*<60 =1/60–119=2/120–179=3/≥180=4*/
       "Typical listening volume"n(ref="1")
/param=ref;
model outcome(event="1")=
       "Type of device used"n                  /*inear=1,overear=2*/
       "Do you often increase volume in"n      /*yes=1,no=0,maybe=2*/
       "Do your device have transparency"n     /*always=1,sometimes=2,no=3*/
       "Do you fall asleep with earphone"n     /*yes=1,no=0*/
       "Typical daily listening time on"n      /*<60 =1/60–119=2/120–179=3/≥180=4*/
       /*"Typical daily listening time o_1"n <60 =1/60–119=2/120–179=3/≥180=4 */
       "Typical listening volume"n / outroc=rocdata;
       roc 'Model';
       run;
data x;
set work.analysis;
if "Education level"n="PhD" then "Education level"n="Postgraduate";
run;
proc freq data=x;
tables "Education Level"n*Gender
/chisq;
run;

       


