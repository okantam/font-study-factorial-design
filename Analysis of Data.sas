data comprehension;
	input A B C y;
	datalines;
	-1 -1 -1 9
	-1 -1 -1 5
	-1 -1 -1 10
	1 -1 -1 10
	1 -1 -1 10
	1 -1 -1 6
	-1 1 -1 10
	-1 1 -1 9
	-1 1 -1 8
	1 1 -1 10
	1 1 -1 10
	1 1 -1 10
	-1 -1 1 10
	-1 -1 1 10
	-1 -1 1 10
	1 -1 1 3
	1 -1 1 10
	1 -1 1 10
	-1 1 1 7
	-1 1 1 10
	-1 1 1 5
	1 1 1 9
	1 1 1 10
	1 1 1 10
	;
run;

data inter; 
	set comprehension;
	AB=A*B; 
	AC=A*C; 
	BC=B*C; 
	ABC=AB*C; 
run;


 /* ANOVA model to calculate effect estimates (A and AC specifically) */
ods rtf bodytitle style=daisy file="M:\STA 566\Project\initial_output.rtf";
ods graphic / noborder;

proc glm data=inter;
	class A B C AB AC BC ABC; 
	model y=A B C AB AC BC ABC;
run;


/* Calculate coefficient estimates */ 
proc reg outest=effects data=inter; 
	model y=A B C AB AC BC ABC;
run;

/* Check structure of effects output	*/
proc print data=effects;
run;

/* Remove non-coefficient columns */
data effect2; 
	set effects; 
	drop y Intercept _RMSE_;
run;

/* Get column of parameter estimates	*/
proc transpose data=effect2 out=effect3; 
run;

/* Calculate effect estimates from coefficient estimates */
data effect4; 
	set effect3; 
	effect=col1*2;
run;

/* Sort effect estimates for plotting */
proc sort data=effect4; 
	by effect;
run; 

/* Check regresion estimates and effect estimates	*/
proc print data=effect4;
run;

proc rank data=effect4 out=effect5 
	/* Using Blom equation we create z-scores from effect values */
	normal=blom;
	/* Variable to calculate z-scores on	*/
	var effect;
	/* Assign z-scores to column called neff	*/
	ranks neff;
run;

/* View ranked data with z-scores	*/
proc print data=effect5;
	symbol1 v=circle;
run;

/* Create QQ plot for effects	*/
proc gplot data=effect5; plot effect*neff=_NAME_; 
run;

/* Perform Box-Cox analysis */
proc transreg data=comprehension;
	model boxcox(y/lambda = -10 to 10.0 by 0.1)=qpoint(A B C);
run;

ods rtf close;

/* The analysis suggests lambda = 5 */

/* Transformed the response with lambda = 5 */
data test;
	set comprehension;
	y_n = ((y**5)-1)/5;
run;

proc print data=test;
run;

data inter; 
	set test;
	AB=A*B; 
	AC=A*C; 
	BC=B*C; 
	ABC=AB*C; 
run; 

 /* ANOVA model to calculate effect estimates (A and AC specifically) */
proc glm data=inter;
class A B C AB AC BC ABC; 
model y_n=A B C AB AC BC ABC;
run;


/* Calculate coefficient estimates */ 
proc reg outest=effects data=inter; 
model y_n=A B C AB AC BC ABC;
run;

/* Check structure of effects output	*/
proc print data=effects;
run;

/* Remove non-coefficient columns */
data effect2; 
set effects; 
drop y_n Intercept _RMSE_;
run;

/* Get column of parameter estimates	*/
proc transpose data=effect2 out=effect3; 
run;


/* Calculate effect estimates from coefficient estimates */
data effect4; 
set effect3; 
effect=col1*2;
run;


/* Sort effect estimates for plotting */
proc sort data=effect4; 
by effect;
run; 

/* Check regresion estimates and effect estimates	*/
proc print data=effect4;
run;

proc rank data=effect4 out=effect5 
/* Using Blom equation we create z-scores from effect values */
normal=blom;
/* Variable to calculate z-scores on	*/
var effect;
/* Assign z-scores to column called neff	*/
ranks neff;
run;

/* View ranked data with z-scores	*/
proc print data=effect5;
symbol1 v=circle;
run;

/* Create QQ plot for effects	*/
proc gplot data=effect5; plot effect*neff=_NAME_; 
run;



