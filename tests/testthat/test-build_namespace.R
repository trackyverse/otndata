test_that("build_namespace normalizes project code to lowercase", {
  setup_otn_env()

  res <- build_namespace("PROJECT_123", network = "testthat")
  expect_equal(res, "project_123")
})

test_that("build_namespace prepends hosted OTN networks to project path", {
  setup_otn_env("nep")

  expect_equal(build_namespace("FISH", network = "nep"), "nep/fish")
  expect_equal(build_namespace("TAGS", network = "migramar"), "migramar/tags")
  expect_equal(build_namespace("DATA", network = "saf"), "saf/data")
})
