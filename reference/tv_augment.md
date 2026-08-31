# Augment a VAR model

Converts observed values, fitted values, and residuals from a supported
VAR model into a tidy tibble.

## Usage

``` r
tv_augment(x, ...)

# Default S3 method
tv_augment(x, ...)

# S3 method for class 'varest'
tv_augment(x, ...)

# S3 method for class 'vec2var'
tv_augment(x, ...)
```

## Arguments

- x:

  A supported VAR model object.

- ...:

  Additional arguments passed to methods. Currently unused.

## Value

A tibble with one row per variable-observation pair and the following
columns:

- index:

  Observation index from the original series.

- variable:

  Character. Variable of the VAR.

- observed:

  Double. Observed value.

- fitted:

  Double. Fitted value.

- residual:

  Double. Model residual.

Observations unavailable for model fitting because of the VAR lag
structure have \`NA\` in \`fitted\` and \`residual\`.

## Details

Each row represents one variable at one observation of the original time
series.

## Examples

``` r
model <- vars::VAR(EuStockMarkets)
tv_augment(model)
#> <tidyvars augmented data>
#> Variables: 4 | Observations: 1860
#> # A tibble: 7,440 × 5
#>    index variable observed fitted residual
#>    <dbl> <chr>       <dbl>  <dbl>    <dbl>
#>  1 1991. DAX         1629.    NA     NA   
#>  2 1991. SMI         1678.    NA     NA   
#>  3 1991. CAC         1773.    NA     NA   
#>  4 1991. FTSE        2444.    NA     NA   
#>  5 1992. DAX         1614.  1625.   -11.2 
#>  6 1992. SMI         1688.  1676.    12.8 
#>  7 1992. CAC         1750.  1771.   -20.4 
#>  8 1992. FTSE        2460.  2444.    16.3 
#>  9 1992. DAX         1607.  1610.    -3.48
#> 10 1992. SMI         1679.  1686.    -7.78
#> # ℹ 7,430 more rows
```
