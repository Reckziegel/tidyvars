# Tidy VAR forecasts

Converts forecasts from a \`varest\` model into a tidy, self-contained
representation containing both the observed history and future
forecasts.

## Usage

``` r
tv_predict(x, n_ahead, level = 0.95, ...)

# Default S3 method
tv_predict(x, n_ahead, level = 0.95, ...)

# S3 method for class 'varest'
tv_predict(x, n_ahead, level = 0.95, ...)
```

## Arguments

- x:

  A \`varest\` object.

- n_ahead:

  A positive whole number giving the number of forecast periods.

- level:

  One or more confidence levels between 0 and 1.

- ...:

  Additional arguments passed to \[stats::predict()\], such as
  \`dumvar\`. The \`ci\` argument should not be supplied directly; use
  \`level\` instead.

## Value

A \`tv_predict\` tibble with columns: \`index\`, \`variable\`, \`type\`,
\`level\`, \`observed\`, \`estimate\`, \`lower\`, and \`upper\`.

## Details

Historical observations are represented once for each variable and
index. Forecast observations are represented once for each variable,
index, and confidence level.

## Examples

``` r
model <- vars::VAR(EuStockMarkets)

tv_predict(model, n_ahead = 12)
#> <tidyvars forecast>
#> Variables: 4 | History: 1860 | Forecast: 12
#> # A tibble: 7,488 × 8
#>    index variable type    level observed estimate lower upper
#>    <dbl> <chr>    <chr>   <dbl>    <dbl>    <dbl> <dbl> <dbl>
#>  1 1991. DAX      history    NA    1629.       NA    NA    NA
#>  2 1991. SMI      history    NA    1678.       NA    NA    NA
#>  3 1991. CAC      history    NA    1773.       NA    NA    NA
#>  4 1991. FTSE     history    NA    2444.       NA    NA    NA
#>  5 1992. DAX      history    NA    1614.       NA    NA    NA
#>  6 1992. SMI      history    NA    1688.       NA    NA    NA
#>  7 1992. CAC      history    NA    1750.       NA    NA    NA
#>  8 1992. FTSE     history    NA    2460.       NA    NA    NA
#>  9 1992. DAX      history    NA    1607.       NA    NA    NA
#> 10 1992. SMI      history    NA    1679.       NA    NA    NA
#> # ℹ 7,478 more rows
tv_predict(model, n_ahead = 12, level = 0.80)
#> <tidyvars forecast>
#> Variables: 4 | History: 1860 | Forecast: 12
#> # A tibble: 7,488 × 8
#>    index variable type    level observed estimate lower upper
#>    <dbl> <chr>    <chr>   <dbl>    <dbl>    <dbl> <dbl> <dbl>
#>  1 1991. DAX      history    NA    1629.       NA    NA    NA
#>  2 1991. SMI      history    NA    1678.       NA    NA    NA
#>  3 1991. CAC      history    NA    1773.       NA    NA    NA
#>  4 1991. FTSE     history    NA    2444.       NA    NA    NA
#>  5 1992. DAX      history    NA    1614.       NA    NA    NA
#>  6 1992. SMI      history    NA    1688.       NA    NA    NA
#>  7 1992. CAC      history    NA    1750.       NA    NA    NA
#>  8 1992. FTSE     history    NA    2460.       NA    NA    NA
#>  9 1992. DAX      history    NA    1607.       NA    NA    NA
#> 10 1992. SMI      history    NA    1679.       NA    NA    NA
#> # ℹ 7,478 more rows
tv_predict(model, n_ahead = 12, level = c(0.50, 0.75, 0.90))
#> <tidyvars forecast>
#> Variables: 4 | History: 1860 | Forecast: 12
#> # A tibble: 7,584 × 8
#>    index variable type    level observed estimate lower upper
#>    <dbl> <chr>    <chr>   <dbl>    <dbl>    <dbl> <dbl> <dbl>
#>  1 1991. DAX      history    NA    1629.       NA    NA    NA
#>  2 1991. SMI      history    NA    1678.       NA    NA    NA
#>  3 1991. CAC      history    NA    1773.       NA    NA    NA
#>  4 1991. FTSE     history    NA    2444.       NA    NA    NA
#>  5 1992. DAX      history    NA    1614.       NA    NA    NA
#>  6 1992. SMI      history    NA    1688.       NA    NA    NA
#>  7 1992. CAC      history    NA    1750.       NA    NA    NA
#>  8 1992. FTSE     history    NA    2460.       NA    NA    NA
#>  9 1992. DAX      history    NA    1607.       NA    NA    NA
#> 10 1992. SMI      history    NA    1679.       NA    NA    NA
#> # ℹ 7,574 more rows
```
