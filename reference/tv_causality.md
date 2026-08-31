# Tidy causality tests

Computes Granger and instantaneous causality tests using
\[vars::causality()\] and converts the results to a tidy tibble.

## Usage

``` r
tv_causality(x, ...)

# Default S3 method
tv_causality(x, ...)

# S3 method for class 'varest'
tv_causality(x, ...)
```

## Arguments

- x:

  A \`varest\` model object.

- ...:

  Additional arguments passed to \[vars::causality()\], such as
  \`vcov.\`, \`boot\`, and \`boot.runs\`. The \`cause\` argument is
  managed internally by \`tv_causality()\`.

## Value

A tibble with one row per cause-test combination and the following
columns:

- cause:

  Character. Variable considered as the cause.

- test:

  Character. Type of causality test.

- statistic:

  Double. Test statistic.

- df:

  Double. Degrees of freedom when represented by one parameter.

- df1:

  Double. Numerator degrees of freedom for an F test.

- df2:

  Double. Denominator degrees of freedom for an F test.

- boot_runs:

  Double. Number of bootstrap replications when the Granger test is
  bootstrapped.

- p_value:

  Double. p-value associated with the test statistic.

- method:

  Character. Description of the statistical test.

Parameter columns that do not apply to a given test are returned as
\`NA\`. For a non-bootstrapped Granger test, \`df1\` and \`df2\` are
populated. For a bootstrapped Granger test, \`boot_runs\` is populated
instead. Instantaneous causality uses \`df\`.

## Details

Each row represents one causality test for one variable considered as
the cause.

## See also

\[vars::causality()\]

## Examples

``` r
model <- vars::VAR(EuStockMarkets)

tv_causality(model)
#> <tidyvars causality tests>
#> Causes: 4 | Tests: 2
#> # A tibble: 8 × 9
#>   cause test          statistic    df   df1   df2 boot_runs  p_value method     
#>   <chr> <chr>             <dbl> <dbl> <dbl> <dbl>     <dbl>    <dbl> <chr>      
#> 1 DAX   granger            1.14    NA     3  7416        NA 0.332    Granger ca…
#> 2 DAX   instantaneous    762.       3    NA    NA        NA 0        H0: No ins…
#> 3 SMI   granger            2.18    NA     3  7416        NA 0.0882   Granger ca…
#> 4 SMI   instantaneous    689.       3    NA    NA        NA 0        H0: No ins…
#> 5 CAC   granger            6.24    NA     3  7416        NA 0.000314 Granger ca…
#> 6 CAC   instantaneous    705.       3    NA    NA        NA 0        H0: No ins…
#> 7 FTSE  granger            4.48    NA     3  7416        NA 0.00377  Granger ca…
#> 8 FTSE  instantaneous    650.       3    NA    NA        NA 0        H0: No ins…
```
