# Tidy impulse-response functions

Computes impulse-response functions using \[vars::irf()\] and converts
the result to a tidy tibble.

## Usage

``` r
tv_irf(x, ...)

# Default S3 method
tv_irf(x, ...)

# S3 method for class 'varest'
tv_irf(x, ...)

# S3 method for class 'vec2var'
tv_irf(x, ...)

# S3 method for class 'svarest'
tv_irf(x, ...)
```

## Arguments

- x:

  A supported VAR model object. Currently supports objects of class
  \`varest\`, \`vec2var\`, and \`svarest\`.

- ...:

  Additional arguments passed to \[vars::irf()\], such as \`impulse\`,
  \`response\`, \`n.ahead\`, \`ortho\`, \`cumulative\`, \`boot\`,
  \`ci\`, \`runs\`, and \`seed\`.

## Value

A tibble with one row per impulse-response-horizon combination and the
following columns:

- horizon:

  Integer. Horizon of the impulse response, starting at zero.

- impulse:

  Character. Variable receiving the shock.

- response:

  Character. Variable responding to the shock.

- estimate:

  Double. Estimated impulse-response coefficient.

- lower:

  Double. Lower bootstrap confidence bound.

- upper:

  Double. Upper bootstrap confidence bound.

When \`boot = FALSE\`, \`lower\` and \`upper\` are returned as \`NA\`.

For \`n.ahead = n\`, the result contains horizons from \`0\` through
\`n\`, inclusive.

## Details

Each row represents the response of one variable to one impulse at one
horizon.

## See also

\[vars::irf()\]

## Examples

``` r
model <- vars::VAR(EuStockMarkets)

tv_irf(
  model,
  impulse = "DAX",
  response = "SMI",
  n.ahead = 5,
  boot = FALSE
)
#> <tidyvars IRF>
#> Impulses: 1 | Responses: 1 | Horizons: 0-5
#> # A tibble: 6 × 6
#>   horizon impulse response estimate lower upper
#>     <int> <chr>   <chr>       <dbl> <dbl> <dbl>
#> 1       0 DAX     SMI          29.8    NA    NA
#> 2       1 DAX     SMI          29.8    NA    NA
#> 3       2 DAX     SMI          29.9    NA    NA
#> 4       3 DAX     SMI          29.9    NA    NA
#> 5       4 DAX     SMI          30.0    NA    NA
#> 6       5 DAX     SMI          30.0    NA    NA
```
