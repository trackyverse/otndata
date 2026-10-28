test_that("fix_null_network returns explicitly provided network", {
  expect_equal(fix_null_network("custom_net"), "custom_net")
})

test_that("fix_null_network auto-detects network when exactly one is active in global state", {
  setup_otn_env("testthat")

  expect_equal(fix_null_network(NULL), "testthat")
})

test_that("fix_null_network errors when network is NULL and active networks != 1", {
  otn_glob <- asNamespace("otndata")$otn_global
  rm(list = ls(otn_glob), envir = otn_glob)

  # Case 1: 0 active networks
  expect_error(
    fix_null_network(NULL),
    regexp = "Please specify a network"
  )

  # Case 2: >1 active networks
  setup_otn_env("net1")
  otn_glob$net2 <- new.env(parent = emptyenv())

  expect_error(
    fix_null_network(NULL),
    regexp = "Please specify a network"
  )
})
