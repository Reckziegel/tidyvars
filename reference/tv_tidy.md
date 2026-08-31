# Tidy VAR model coefficients

Converts coefficient estimates from a supported VAR model into a tidy
tibble. Each row represents one estimated coefficient in one equation of
the VAR.

## Usage

``` r
tv_tidy(x, ...)

# Default S3 method
tv_tidy(x, ...)

# S3 method for class 'varest'
tv_tidy(x, ...)

# S3 method for class 'vec2var'
tv_tidy(x, ...)
```

## Arguments

- x:

  A supported VAR model object.

- ...:

  Additional arguments passed to methods.

## Value

A tibble with one row per coefficient-equation pair and the following
columns:

- equation:

  Character. Equation of the VAR.

- term:

  Character. Model term associated with the coefficient.

- estimate:

  Double. Estimated coefficient.

- std_error:

  Double. Standard error of the estimate.

- statistic:

  Double. t statistic for the coefficient.

- p_value:

  Double. p-value associated with the t statistic.

## Details

\`tv_tidy()\` currently provides inferential coefficient statistics for
\`varest\` objects. The values are extracted from the coefficient tables
exposed by the corresponding `vars` model.

The \`equation\` and \`term\` columns are returned as character vectors.
Their ordering and representation are not modified for plotting
purposes.

## Examples

``` r
model <- vars::VAR(EuStockMarkets)
tv_tidy(model)
#> <tidyvars coefficients>
#> Equations: 4 | Terms: 5
#> # A tibble: 20 × 6
#>    equation term     estimate std_error statistic p_value
#>    <chr>    <chr>       <dbl>     <dbl>     <dbl>   <dbl>
#>  1 DAX      DAX.l1    0.975     0.00687   142.     0     
#>  2 DAX      SMI.l1    0.0119    0.00567     2.10   0.0357
#>  3 DAX      CAC.l1    0.0100    0.00570     1.76   0.0789
#>  4 DAX      FTSE.l1   0.00310   0.00621     0.500  0.617 
#>  5 DAX      const    -9.13     13.3        -0.687  0.492 
#>  6 SMI      DAX.l1   -0.00877   0.00846    -1.04   0.300 
#>  7 SMI      SMI.l1    0.994     0.00698   142.     0     
#>  8 SMI      CAC.l1    0.00665   0.00702     0.948  0.343 
#>  9 SMI      FTSE.l1   0.0184    0.00765     2.41   0.0162
#> 10 SMI      const   -34.8      16.4        -2.12   0.0340
#> 11 CAC      DAX.l1   -0.0102    0.00556    -1.84   0.0662
#> 12 CAC      SMI.l1    0.00962   0.00459     2.10   0.0363
#> 13 CAC      CAC.l1    0.998     0.00461   216.     0     
#> 14 CAC      FTSE.l1  -0.00260   0.00503    -0.517  0.605 
#> 15 CAC      const     9.02     10.8         0.838  0.402 
#> 16 FTSE     DAX.l1   -0.00734   0.00649    -1.13   0.258 
#> 17 FTSE     SMI.l1    0.0132    0.00536     2.47   0.0137
#> 18 FTSE     CAC.l1   -0.00913   0.00538    -1.70   0.0902
#> 19 FTSE     FTSE.l1   0.991     0.00587   169.     0     
#> 20 FTSE     const    28.7      12.6         2.29   0.0224
```
