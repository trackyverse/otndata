test_that("is_logged_in succeeds quietly when bearer token exists in global state", {
  setup_otn_env("testthat", token = "valid_token_123")

  expect_silent(is_logged_in("testthat"))
})

test_that("is_logged_in errors when token is missing from session environment", {
  setup_otn_env("testthat")

  expect_error(
    is_logged_in("testthat"),
    regexp = "Please log into the testthat data portal"
  )
})
