# Autoplot forecast results

Autoplot forecast results

## Usage

``` r
# S3 method for class 'tv_predict'
autoplot(
  object,
  .variable = NULL,
  n_history = NULL,
  levels = NULL,
  scales = c("free_y", "fixed"),
  ci = TRUE,
  ...
)
```

## Arguments

- object:

  A \`tv_predict\` object.

- .variable:

  Optional variables to display.

- n_history:

  Number of historical observations to display. If \`NULL\`, all
  available history is shown. Forecast observations are never removed.

- levels:

  Optional confidence levels to display. If \`NULL\`, all confidence
  levels available in \`object\` are shown.

- scales:

  Scale behaviour across facets. One of \`"free_y"\` or \`"fixed"\`.

- ci:

  Whether to display forecast intervals when available.

- ...:

  Additional arguments reserved for future use.

## Value

A \`ggplot\` object.
