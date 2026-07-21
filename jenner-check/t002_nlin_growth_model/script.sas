/* Growth-curve modeling core, extracted from growth_curve.sas:
   the logistic PROC NLIN fit (Marquardt) and the PROC SQL R-squared
   calculation, run on the same test-day weight data. This isolates the
   modeling step from the Excel export and SGPLOT plotting so the NLIN
   convergence and per-animal R-squared can be inspected on their own. */

/* Step 1: Import the data */
data growth_data;
    input Animal td weight; /* Animal ID, time point (td), and weight */
    datalines;
425 1 105
425 2 117
425 3 131
425 4 146
425 5 159
425 6 175
425 7 192
425 8 214
425 9 229
425 10 246
425 11 264
425 12 278
429 1 110
429 2 122
429 3 132
429 12 240
431 1 112
431 2 120
431 3 130
431 4 141
431 5 152
431 6 164
431 7 175
431 8 185
431 9 196
431 10 212
431 11 221
431 12 235
568 1 95
568 2 107
568 3 123
568 4 140
568 5 155
568 6 175
568 7 130
568 8 135
568 9 141
;
run;

proc sort data=growth_data;
	by Animal;
Run;

/* Step 2: Fit the growth curve model */
proc nlin data=growth_data method=marquardt outest=param_est;
    by Animal; /* Fit the model separately for each animal */
    parms A=300 B=0.03 K=0.1; /* Initial parameter guesses for A, B, K */
    model weight = A / (1 + exp(-B*(td - K)));   /* Growth curve equation */
    ods output ParameterEstimates=param_table; /* Output the parameter estimates */
    output out=predicted_data p=predicted r=residual; /* Save predicted values and residuals */
run;

/* Step 3: Calculate R-Squared for each animal */
proc sql;
    /* Step 3.1: Calculate the mean weight for each animal */
    create table mean_weight as
    select Animal, mean(weight) as mean_weight /* Mean observed weight */
    from growth_data
    group by Animal; /* Group by each animal to calculate the mean */
quit;

proc sql;
    /* Step 3.2: Calculate R-Squared for each animal */
    create table r_squared as
    select a.Animal,
           /* R2 formula: 1 - (SS_residual / SS_total) */
           1 - (sum(a.residual**2) / sum((a.weight - b.mean_weight)**2)) as R_squared
    from predicted_data as a
    left join mean_weight as b
    on a.Animal = b.Animal /* Join to get the mean weight for each animal */
    group by a.Animal; /* Group by each animal */
quit;

/* Show the fitted parameters and R-squared per animal */
proc print data=param_table noobs;
    title "NLIN parameter estimates (A, B, K) per animal";
run;

proc print data=r_squared noobs;
    title "R-squared per animal";
run;
