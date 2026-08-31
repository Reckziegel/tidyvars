# Autoplot tidyvars objects

Autoplot tidyvars objects

## Usage

``` r
# S3 method for class 'tv_irf'
autoplot(
  object,
  .impulse = NULL,
  .response = NULL,
  layout = c("auto", "grid", "wrap"),
  scales = c("free_y", "fixed"),
  ci = TRUE,
  ...
)
```

## Arguments

- object:

  A tidyvars object.

- .impulse:

  Optional impulse variables to display.

- .response:

  Optional response variables to display.

- layout:

  Facet layout. One of \`"auto"\`, \`"grid"\`, or \`"wrap"\`.

- scales:

  Scale behaviour across facets. One of \`"free_y"\` or \`"fixed"\`.

- ci:

  Whether to display confidence intervals when available.

- ...:

  Additional arguments reserved for future use.

## Value

A \`ggplot\` object.
