# tidyvars discrete colour scales

Discrete colour and fill scales designed for econometric and financial
graphics produced with tidyvars.

## Usage

``` r
scale_color_tidyvars(..., na.value = "grey70")

scale_fill_tidyvars(..., na.value = "grey70")
```

## Arguments

- ...:

  Additional arguments passed to \[ggplot2::discrete_scale()\].

- na.value:

  Colour used for missing values.

## Value

A discrete ggplot2 scale.

## Details

\`scale_color_tidyvars()\` controls mapped \`colour\` aesthetics, while
\`scale_fill_tidyvars()\` controls mapped \`fill\` aesthetics.

These scales are independent from \[theme_tidyvars()\]. Applying the
theme does not modify data colours.

## Examples

``` r
library(ggplot2)

ggplot(
  mtcars,
  aes(wt, mpg, colour = factor(cyl))
) +
  geom_point(size = 3) +
  scale_color_tidyvars()


ggplot(
  mtcars,
  aes(factor(cyl), fill = factor(gear))
) +
  geom_bar() +
  scale_fill_tidyvars()

```
