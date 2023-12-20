library(tidyvars)

x <- vars::VAR(EuStockMarkets, p = 2)

test_that("tv_predict works", {

  td <- tv_predict(x, n.ahead = 10)

  expect_named(td, c("rowid", ".asset", "fcst", "lower", "upper", "CI"))
  expect_type(td, "list")
  expect_s3_class(td, "tv_predict")
  expect_equal(ncol(td), 6)
  expect_equal(nrow(td), 40)

  expect_error(tv_predict(EuStockMarkets))

})
