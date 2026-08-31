# Tidy VAR serial correlation test

Computes a multivariate serial correlation test for the residuals of a
supported VAR model using \[vars::serial.test()\] and converts the
result to a tidy tibble.

## Usage

``` r
tv_serial_test(
  x,
  lags_pt = 16,
  lags_bg = 5,
  type = c("PT.asymptotic", "PT.adjusted", "BG", "ES"),
  ...
)

# Default S3 method
tv_serial_test(
  x,
  lags_pt = 16,
  lags_bg = 5,
  type = c("PT.asymptotic", "PT.adjusted", "BG", "ES"),
  ...
)

# S3 method for class 'varest'
tv_serial_test(
  x,
  lags_pt = 16,
  lags_bg = 5,
  type = c("PT.asymptotic", "PT.adjusted", "BG", "ES"),
  ...
)

# S3 method for class 'vec2var'
tv_serial_test(
  x,
  lags_pt = 16,
  lags_bg = 5,
  type = c("PT.asymptotic", "PT.adjusted", "BG", "ES"),
  ...
)
```

## Arguments

- x:

  A supported VAR model object. Currently supports objects of class
  \`varest\` and \`vec2var\`.

- lags_pt:

  Integer. Number of lags used by the Portmanteau tests.

- lags_bg:

  Integer. Number of lags used by the Breusch-Godfrey and
  Edgerton-Shukur tests.

- type:

  Character. Serial correlation test to compute. One of
  \`"PT.asymptotic"\`, \`"PT.adjusted"\`, \`"BG"\`, or \`"ES"\`.

- ...:

  Reserved for extensions. Currently must be empty.

## Value

A one-row tibble with the following columns:

- test:

  Character. Identifier of the serial correlation test.

- lags:

  Integer. Number of lags used by the test.

- statistic:

  Double. Test statistic.

- df:

  Double. Degrees of freedom for chi-squared tests.

- df1:

  Double. Numerator degrees of freedom for the Edgerton-Shukur F test.

- df2:

  Double. Denominator degrees of freedom for the Edgerton-Shukur F test.

- p_value:

  Double. p-value associated with the test statistic.

- method:

  Character. Description of the statistical test.

Parameter columns that do not apply to a given test are returned as
\`NA\`. The Portmanteau and Breusch-Godfrey tests use \`df\`. The
Edgerton-Shukur test uses \`df1\` and \`df2\`.

## Details

Each row represents one serial correlation test for the VAR residuals
with a given lag specification.

## See also

\[vars::serial.test()\]

## Examples

``` r
model <- vars::VAR(EuStockMarkets, p = 2)

tv_serial_test(
  model,
  lags_pt = 8,
  type = "PT.adjusted"
)
#> <tidyvars serial tests>
#> Tests: 1
#> # A tibble: 1 × 8
#>   test                  lags statistic    df   df1   df2  p_value method        
#>   <chr>                <int>     <dbl> <dbl> <dbl> <dbl>    <dbl> <chr>         
#> 1 portmanteau_adjusted     8      246.    96    NA    NA 3.66e-15 Portmanteau T…

tv_serial_test(
  model,
  lags_bg = 2,
  type = "BG"
)
#> <tidyvars serial tests>
#> Tests: 1
#> # A tibble: 1 × 8
#>   test             lags statistic    df   df1   df2 p_value method              
#>   <chr>           <int>     <dbl> <dbl> <dbl> <dbl>   <dbl> <chr>               
#> 1 breusch_godfrey     2      59.4    32    NA    NA 0.00226 Breusch-Godfrey LM …
```
