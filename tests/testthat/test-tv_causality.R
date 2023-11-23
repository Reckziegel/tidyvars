library(tidyvars)

x <- vars::VAR(EuStockMarkets, p = 2)

test_that("tv_causality works", {

  td <- tv_causality(x)

  expect_named(td, c(".asset", ".test", ".statistic", ".parameter", ".p.value", ".method"))
  expect_type(td, "list")
  expect_s3_class(td, "tv_causality")
  expect_equal(ncol(td), 6)
  expect_equal(nrow(td), 8)

  expect_error(tv_causality(EuStockMarkets))

})
