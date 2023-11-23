library(tidyvars)

x <- vars::VAR(EuStockMarkets, p = 2)
cajo <- urca::ca.jo(EuStockMarkets)
v2v <- vars::vec2var(cajo, r = 1)
bq <- vars::BQ(x)

test_that("tv_irf works", {

  td <- tv_irf(x)

  expect_named(td, c("rowid", ".impulse", ".asset", ".irf", ".lower", ".upper"))
  expect_type(td, "list")
  expect_s3_class(td, "tv_irf")
  expect_equal(ncol(td), 6)
  expect_equal(nrow(td), 176)

  td2 <- tv_irf(v2v)

  expect_named(td2, c("rowid", ".impulse", ".asset", ".irf", ".lower", ".upper"))
  expect_type(td2, "list")
  expect_s3_class(td2, "tv_irf")
  expect_equal(ncol(td2), 6)
  expect_equal(nrow(td2), 176)

  td3 <- tv_irf(bq)

  expect_named(td3, c("rowid", ".impulse", ".asset", ".irf", ".lower", ".upper"))
  expect_type(td3, "list")
  expect_s3_class(td3, "tv_irf")
  expect_equal(ncol(td3), 6)
  expect_equal(nrow(td3), 176)

  expect_error(tv_irf(EuStockMarkets))

})
