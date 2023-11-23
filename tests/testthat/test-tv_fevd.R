library(tidyvars)

x <- vars::VAR(EuStockMarkets, p = 2)
cajo <- urca::ca.jo(EuStockMarkets)
v2v <- vars::vec2var(cajo, r = 1)

test_that("tv_fevd works", {

  td <- tv_fevd(x)

  expect_named(td, c("rowid", ".asset", ".impact", ".fevd"))
  expect_type(td, "list")
  expect_s3_class(td, "tv_fevd")
  expect_equal(ncol(td), 4)
  expect_equal(nrow(td), 160)


  td2 <- tv_fevd(v2v)

  expect_named(td2, c("rowid", ".asset", ".impact", ".fevd"))
  expect_type(td2, "list")
  expect_s3_class(td2, "tv_fevd")
  expect_equal(ncol(td2), 4)
  expect_equal(nrow(td2), 160)


  expect_error(tv_fevd(EuStockMarkets))

})
