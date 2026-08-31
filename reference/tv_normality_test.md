# Tidy VAR normality tests

Computes normality tests for the residuals of a supported VAR model
using \[vars::normality.test()\] and converts the results to a tidy
tibble.

## Usage

``` r
tv_normality_test(x, ...)

# Default S3 method
tv_normality_test(x, ...)

# S3 method for class 'varest'
tv_normality_test(x, ...)

# S3 method for class 'vec2var'
tv_normality_test(x, ...)
```

## Arguments

- x:

  A supported VAR model object. Currently supports objects of class
  \`varest\` and \`vec2var\`.

- ...:

  Additional arguments passed to \[vars::normality.test()\], such as
  \`multivariate.only\`.

## Value

A tibble with one row per normality test and the following columns:

- scope:

  Character. Scope of the test: \`"multivariate"\` or \`"univariate"\`.

- variable:

  Character. Variable associated with a univariate test. \`NA\` for
  multivariate tests.

- test:

  Character. Test identifier: \`"jarque_bera"\`, \`"skewness"\`, or
  \`"kurtosis"\`.

- statistic:

  Double. Test statistic.

- df:

  Double. Degrees of freedom.

- p_value:

  Double. p-value associated with the test statistic.

- method:

  Character. Description of the statistical test.

With the default \`multivariate.only = TRUE\`, only the multivariate
Jarque-Bera, skewness, and kurtosis tests are returned. When
\`multivariate.only = FALSE\`, the result also includes one univariate
Jarque-Bera test for each equation of the model.

## Details

Each row represents one normality test applied either to the residuals
of the VAR jointly or to the residuals of one equation.

## See also

\[vars::normality.test()\]

## Examples

``` r
model <- vars::VAR(EuStockMarkets)

tv_normality_test(model)
#> <tidyvars normality tests>
#> Scopes: 1 | Tests: 3
#> # A tibble: 3 × 7
#>   scope        variable test        statistic    df p_value method              
#>   <chr>        <chr>    <chr>           <dbl> <dbl>   <dbl> <chr>               
#> 1 multivariate NA       jarque_bera    10087.     8       0 JB-Test (multivaria…
#> 2 multivariate NA       skewness         150.     4       0 Skewness only (mult…
#> 3 multivariate NA       kurtosis        9938.     4       0 Kurtosis only (mult…

tv_normality_test(
  model,
  multivariate.only = FALSE
)
#> <tidyvars normality tests>
#> Scopes: 2 | Tests: 3
#> # A tibble: 7 × 7
#>   scope        variable test        statistic    df p_value method              
#>   <chr>        <chr>    <chr>           <dbl> <dbl>   <dbl> <chr>               
#> 1 multivariate NA       jarque_bera    10087.     8       0 JB-Test (multivaria…
#> 2 multivariate NA       skewness         150.     4       0 Skewness only (mult…
#> 3 multivariate NA       kurtosis        9938.     4       0 Kurtosis only (mult…
#> 4 univariate   DAX      jarque_bera     4243.     2       0 JB-Test (univariate)
#> 5 univariate   SMI      jarque_bera     5434.     2       0 JB-Test (univariate)
#> 6 univariate   CAC      jarque_bera      966.     2       0 JB-Test (univariate)
#> 7 univariate   FTSE     jarque_bera     1125.     2       0 JB-Test (univariate)
```
