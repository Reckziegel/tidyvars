# tidyvars ggplot2 theme

A clean and professional ggplot2 theme designed for econometric and
financial graphics.

## Usage

``` r
theme_tidyvars(base_size = 11, base_family = "")
```

## Arguments

- base_size:

  Base font size in points. Must be a positive numeric scalar.

- base_family:

  Base font family. The default, \`""\`, uses the default graphics
  device font.

## Value

A complete ggplot2 theme.

## Details

\`theme_tidyvars()\` controls the structural appearance of a plot,
including typography, grid lines, facet strips, legends, spacing, and
margins.

The theme does not modify data colours or discrete colour palettes.
Colour styling is handled separately by the tidyvars colour and fill
scales.

## Examples

``` r
library(ggplot2)

ggplot(
  mtcars,
  aes(wt, mpg)
) +
  geom_point() +
  labs(
    title = "Fuel economy and vehicle weight",
    subtitle = "Motor Trend road tests",
    x = "Weight",
    y = "Miles per gallon"
  ) +
  theme_tidyvars()

```
