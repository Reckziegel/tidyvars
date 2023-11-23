library(modeltests)
library(tidyvars)


x <- vars::VAR(EuStockMarkets, p = 2)
cajo <- urca::ca.jo(EuStockMarkets)
v2v <- vars::vec2var(cajo, r = 1)

test_that("tv_augment works", {
  td <- tv_augment(x)
  modeltests::check_dims(td, 7440, 5)

  td2 <- tv_augment(v2v)
  modeltests::check_dims(td, 7440, 5)

  expect_error(tv_augment(EuStockMarkets))


})
