# Growth Curve Modeling and Visualization in SAS

### Author: Hamdy Abdel-Shafy
### Date: January 2025
### Affiliation: Department of Animal Production, Cairo University, Faculty of Agriculture


## Overview
This project demonstrates the use of SAS to model and analyze growth curves for animals based on test day weight measurements. The provided script is an example with data from a few animals to illustrate the process.

The script includes the following steps:
1. Importing and organizing data.
2. Fitting a nonlinear growth curve model.
3. Calculating the coefficient of determination (R²) for each animal.
4. Reshaping and exporting parameter estimates and their standard errors.
5. Plotting observed and predicted growth curves.

The output includes:
- An Excel file containing parameter estimates, standard errors, and R² values.
- Growth curve plots for each animal.

---

## Files

### 1. `growth_curve.sas`
The SAS script implementing the growth curve analysis.

### 2. `growth_parameters.xlsx`
The Excel file with the following sheets:
- **`parameters`**: Contains parameter estimates (A, B, K) and R² for each animal.
- **`se_parameters`**: Contains the standard errors (SE_A, SE_B, SE_K) for each parameter.

---

## Step-by-Step Explanation

### Step 1: Import the Data
The `growth_data` dataset includes test day (td) weight measurements for each animal.

```sas
data growth_data;
    input Animal td weight;
    datalines;
    ... (data values) ...
;
run;
```

### Step 2: Fit the Growth Curve Model
A nonlinear logistic growth curve model is fitted separately for each animal:

**Model Equation:**
\[
Weight = \frac{A}{1 + \exp(-B \times (td - K))}
\]

Where:
- **A**: Asymptotic weight (maximum possible weight).
- **B**: Growth rate.
- **K**: Time point of inflection.

The estimates for A, B, and K are saved in the `param_table`, along with predicted weights and residuals.

### Step 3: Calculate R² for Each Animal
**R² (Coefficient of Determination):**
Measures how well the model explains the variance in observed weights. The calculation involves:
- **SS_residual**: Sum of squared residuals (errors).
- **SS_total**: Total variance in observed weights.

Formula:
\[
R^2 = 1 - \frac{SS_{residual}}{SS_{total}}
\]

### Step 4: Reshape Parameter Table
The parameter estimates (A, B, K) are reshaped to include one row per animal.

### Step 5: Merge R² with Parameters
The R² values are added to the reshaped parameter estimates.

### Step 6: Export Results to Excel
The following datasets are exported:
1. `parameters`: Includes A, B, K, and R² for each animal.
2. `se_parameters`: Includes standard errors (SE_A, SE_B, SE_K) for each parameter.

### Step 7: Prepare Data for Plotting
The original data is combined with predicted weights for visualization.

### Step 8: Plot Growth Curves
Plots for observed and predicted weights are generated for each animal using `PROC SGPLOT`.

---

## Instructions for Use

### Prerequisites
- SAS software installed.
- Update file paths in the script to match your local environment.

### Running the Script
1. Copy the `growth_curve.sas` script to your SAS workspace.
2. Execute the script to:
   - Fit growth curves.
   - Calculate R².
   - Export results to `growth_parameters.xlsx`.
   - Generate growth curve plots.

3. Check the output Excel file for parameter estimates and standard errors.
4. Review the plots in the SAS output window.

---

## Notes
- This example uses a small dataset to illustrate the process. For larger datasets, ensure data quality and adjust model parameters if necessary.
- The growth curve model used is logistic; other models may be explored depending on data characteristics.

---

## Contact
For questions or support, please reach out to the author or refer to the SAS documentation.

---
## License

This project is licensed under the [MIT License](LICENSE).
