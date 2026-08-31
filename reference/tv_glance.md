# Glance at the equations of a VAR model

Summarises each equation of a VAR model using the corresponding linear
model stored in the \`varest\` object.

## Usage

``` r
tv_glance(x, ...)

# Default S3 method
tv_glance(x, ...)

# S3 method for class 'varest'
tv_glance(x, ...)
```

## Arguments

- x:

  A \`varest\` object.

- ...:

  Additional arguments passed to \[broom::glance()\] for each equation.

## Value

A tibble with one row per equation and columns: \`equation\`,
\`r_squared\`, \`adj_r_squared\`, \`sigma\`, \`statistic\`, \`p_value\`,
\`df\`, \`log_lik\`, \`aic\`, \`bic\`, \`deviance\`, \`df_residual\`,
and \`n_obs\`.

## Details

Each row represents one equation of the VAR. Model fit statistics such
as \`log_lik\`, \`aic\`, and \`bic\` refer to the individual equation,
not to the multivariate VAR system as a whole.

## Examples

``` r
model <- vars::VAR(EuStockMarkets)

tv_glance(model)
#> <tidyvars equation summaries>
#> Equations: 4
#> # A tibble: 4 × 13
#>   equation r_squared adj_r_squared sigma statistic p_value    df log_lik    aic
#>   <chr>        <dbl>         <dbl> <dbl>     <dbl>   <dbl> <dbl>   <dbl>  <dbl>
#> 1 DAX          0.999         0.999  32.4   521599.       0     4  -9099. 18210.
#> 2 SMI          0.999         0.999  39.9   807886.       0     4  -9487. 18985.
#> 3 CAC          0.998         0.998  26.2   227499.       0     4  -8706. 17424.
#> 4 FTSE         0.999         0.999  30.6   473347.       0     4  -8994. 17999.
#> # ℹ 4 more variables: bic <dbl>, deviance <dbl>, df_residual <int>, n_obs <int>
```
