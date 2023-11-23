library(modeltests)
library(tidyvars)


x <- vars::VAR(EuStockMarkets, p = 2)

test_that("tv_glance works", {
  td <- tv_glance(x)
  modeltests::check_tibble(td, method = "glance")
  modeltests::check_glance_outputs(td)
  modeltests::check_dims(td, 1, 4)
})
