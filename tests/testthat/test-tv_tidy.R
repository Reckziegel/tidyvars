library(modeltests)
library(tidyvars)


x <- vars::VAR(EuStockMarkets, p = 2)
# cajo <- urca::ca.jo(EuStockMarkets)
# v2v <- vars::vec2var(cajo, r = 1)

test_that("tv_tidy works", {
  td <- tv_tidy(x)
  modeltests::check_tibble(td, method = "tidy")
  modeltests::check_tidy_output(td)
  modeltests::check_dims(td, 36, 6)

  # td2 <- tv_tidy(v2v)
  # modeltests::check_tibble(td2, method = "tidy")
  # modeltests::check_tidy_output(td2)
  # modeltests::check_dims(td2, 36, 6)

  expect_error(tv_tidy(EuStockMarkets))
})
