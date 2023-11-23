library(tidyvars)

x <- vars::VAR(EuStockMarkets, p = 2)
cajo <- urca::ca.jo(EuStockMarkets)
v2v <- vars::vec2var(cajo, r = 1)

test_that("tv_normality_test works", {

  td <- tv_normality_test(x)

  expect_named(td, c(".test", ".statistic", ".parameter", ".p.value", ".method"))
  expect_type(td, "list")
  expect_s3_class(td, "tv_normality_test")
  expect_equal(ncol(td), 5)
  expect_equal(nrow(td), 3)

  td2 <- tv_normality_test(v2v)

  expect_named(td2, c(".test", ".statistic", ".parameter", ".p.value", ".method"))
  expect_type(td2, "list")
  expect_s3_class(td2, "tbl_df")
  expect_equal(ncol(td2), 5)
  expect_equal(nrow(td2), 3)

  expect_error(tv_normality_test(EuStockMarkets))

})
