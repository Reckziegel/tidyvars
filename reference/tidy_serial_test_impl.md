# Extract a tidy serial correlation test

Extract a tidy serial correlation test

## Usage

``` r
tidy_serial_test_impl(x, lags_pt, lags_bg, type, ...)
```

## Arguments

- x:

  A supported VAR model object.

- lags_pt:

  Number of lags for Portmanteau tests.

- lags_bg:

  Number of lags for BG and ES tests.

- type:

  Serial correlation test type.

- ...:

  Reserved for extensions.

## Value

A \`tv_serial_test\` tibble.
