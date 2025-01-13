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
proc nlin data=growth_data method=marquardt outest=param_est maxiter=700;
    by Animal; /* Fit the model separately for each animal */
    parms A=300 B=0.03 K=0.1; /* Initial parameter guesses for A, B, K */
    model weight = A / (1 + exp(-B*(td - K)));   /* Growth curve equation */
    ods output ParameterEstimates=param_table; /* Output the parameter estimates */
    output out=predicted_data p=predicted r=residual; /* Save predicted values and residuals */
run;

/* Step 3: Calculate R-Squared for each animal */
/*
Explanation for R-Squared (R²):
--------------------------------
- R² (coefficient of determination) measures the proportion of variance in the observed data (weight) explained by the model (predicted).
- R² ranges from 0 to 1:
  - R² = 1: Perfect fit (all variance explained by the model).
  - R² = 0: The model explains none of the variance.
- Formula:
  R² = 1 - (SS_residual / SS_total)
    - SS_residual = Sum of squared residuals (errors): sum(residual**2).
    - SS_total = Total variance in observed weights: sum((weight - mean_weight)**2).
- Steps:
  1. Calculate the mean observed weight (mean_weight) for each animal.
  2. Compute SS_residual and SS_total for each animal.
  3. Use the formula to calculate R² for each animal.
*/

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
           /* R² formula: 1 - (SS_residual / SS_total) */
           1 - (sum(a.residual**2) / sum((a.weight - b.mean_weight)**2)) as R_squared
    from predicted_data as a
    left join mean_weight as b
    on a.Animal = b.Animal /* Join to get the mean weight for each animal */
    group by a.Animal; /* Group by each animal */
quit;


/* Step 4: Reshape the param_table to include one row per animal with columns A, B, K */
proc transpose data=param_table out=transposed_param_table(drop=_NAME_);
    by Animal; /* Group the data by Animal */
    id Parameter; /* Make the parameter names (A, B, K) the column names */
    var Estimate; /* Transpose the Estimate values into columns */
run;

/* Step 5: Merge R-Squared values with parameter estimates */
data parameters;
    merge transposed_param_table r_squared; /* Combine reshaped parameters and R² */
    by Animal;
run;

/* Step 6: Export the combined parameters and R-Squared to Excel */
proc export data=parameters
    outfile="F:\00_coding\amin_extractInfo_SASoutput_growthCurve\growth_parameters.xlsx"
    dbms=xlsx
    replace; /* Overwrite if the file already exists */
    sheet="parameters"; /* Export data to the "parameters" sheet */
run;

/* Step 7: Create and export the standard errors table */
proc transpose data=param_table out=transposed_se_table(drop=_NAME_ _LABEL_); /* Drop the _LABEL_ column */
    by Animal; /* Group the data by Animal */
    id Parameter; /* Make the parameter names (A, B, K) the column names */
    var StdErr; /* Transpose the standard errors into columns */
run;

data se_parameters;
    set transposed_se_table; /* Use the transposed standard errors data */
    rename A = SE_A B = SE_B K = SE_K; /* Rename columns for standard errors */
run;

proc export data=se_parameters
    outfile="F:\00_coding\amin_extractInfo_SASoutput_growthCurve\growth_parameters.xlsx"
    dbms=xlsx
    replace; /* Overwrite if the file already exists */
    sheet="se_parameters"; /* Export data to the "se_parameters" sheet */
run;

/* Step 8: Prepare data for plotting */
data final_data;
    merge growth_data predicted_data; /* Combine original and predicted data */
    by Animal td; /* Merge by Animal and time point (td) */
run;

/* Step 9: Plot the growth curve for each animal */
ods graphics on; /* Enable ODS graphics for plots */
proc sgplot data=final_data;
    by Animal; /* Create separate plots for each animal */
    series x=td y=weight / lineattrs=(color=blue thickness=2) legendlabel="Observed"; /* Observed weight */
    series x=td y=predicted / lineattrs=(color=red pattern=2 thickness=2) legendlabel="Predicted"; /* Predicted weight */
    xaxis label="Test Day (td)";
    yaxis label="Weight (kg)";
    title "Growth Curve for Animal #";
run;
ods graphics off; /* Disable ODS graphics after plotting */
