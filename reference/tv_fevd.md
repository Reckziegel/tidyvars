# Tidy forecast error variance decomposition

Computes the forecast error variance decomposition using
\[vars::fevd()\] and converts the result to a tidy tibble.

## Usage

``` r
tv_fevd(x, ...)

# Default S3 method
tv_fevd(x, ...)

# S3 method for class 'varest'
tv_fevd(x, ...)

# S3 method for class 'vec2var'
tv_fevd(x, ...)
```

## Arguments

- x:

  A supported VAR model object. Currently supports objects of class
  \`varest\` and \`vec2var\`.

- ...:

  Additional arguments passed to \[vars::fevd()\], such as \`n.ahead\`.

## Value

A tibble with one row per response-shock-horizon combination and the
following columns:

- horizon:

  Integer. Forecast horizon, starting at one.

- response:

  Character. Variable whose forecast error variance is decomposed.

- shock:

  Character. Shock contributing to the forecast error variance.

- contribution:

  Double. Proportion of the forecast error variance attributable to the
  shock.

For \`n.ahead = n\`, the result contains horizons from \`1\` through
\`n\`, inclusive. For each combination of \`horizon\` and \`response\`,
the contributions across shocks sum to one, up to numerical precision.

## Details

Each row represents the contribution of one shock to the forecast error
variance of one response variable at one forecast horizon.

## See also

\[vars::fevd()\]

## Examples

``` r
model <- vars::VAR(EuStockMarkets)

tv_fevd(model, n.ahead = 5)
#> <tidyvars FEVD>
#> Responses: 4 | Shocks: 4 | Horizons: 1-5
#> # A tibble: 80 × 4
#>    horizon response shock contribution
#>      <int> <chr>    <chr>        <dbl>
#>  1       1 DAX      DAX     1         
#>  2       1 DAX      SMI     0         
#>  3       1 DAX      CAC     0         
#>  4       1 DAX      FTSE    0         
#>  5       2 DAX      DAX     1.000     
#>  6       2 DAX      SMI     0.0000642 
#>  7       2 DAX      CAC     0.0000178 
#>  8       2 DAX      FTSE    0.00000200
#>  9       3 DAX      DAX     1.000     
#> 10       3 DAX      SMI     0.000212  
#> # ℹ 70 more rows
```
