test_that("otn_login succeeds when valid credentials exist in Sys.getenv()", {
  setup_otn_env()
  mock_otn_bindings()

  # Set environment variables manually
  Sys.setenv(OTN_USER.testthat = "testuser", OTN_PASS.testthat = "testpass")
  on.exit({
    Sys.unsetenv("OTN_USER.testthat")
    Sys.unsetenv("OTN_PASS.testthat")
  })

  # Mock external package bindings
  mock_req_perform_error(status_code = 401, throw_condition = TRUE)

  otn_login("testthat")
  otn_glob <- asNamespace("otndata")$otn_global
  expect_equal(otn_glob$testthat$token, "mocked_jwt_token_123")
})

test_that("otn_login prompts for credentials before making the API query", {
  setup_otn_env()
  mock_otn_bindings()

  # Execution order tracking flag
  prompt_occurred <- FALSE

  local_mocked_bindings(
    otn_set_credentials = function(network, temporary) {
      prompt_occurred <<- TRUE # Record that prompt step executed
      otn_glob <- asNamespace("otndata")$otn_global
      otn_glob[[network]]$username <- "prompted_user"
      otn_glob[[network]]$password <- "prompted_pass"
    },
    .package = "otndata"
  )

  mock_req_perform_json(
    body_json = '{"token": "fake_token"}',
    validate_req = function(req) {
      # Assertion 1: Verify prompting happened BEFORE req_perform was reached
      expect_true(prompt_occurred)

      # Assertion 2: Verify the request body contains the prompted credentials
      expect_equal(as.character(req$body$data$login), "prompted_user")
      expect_equal(as.character(req$body$data$password), "prompted_pass")
    }
  )

  otn_login("testthat")

  # Assertion 3: Verify token updated in global state
  otn_glob <- asNamespace("otndata")$otn_global
  expect_equal(otn_glob$testthat$token, "fake_token")
})


test_that("otn_login errors with wrong credentials", {
  setup_otn_env()
  mock_otn_bindings()

  Sys.setenv(OTN_USER.testthat = "wrong_user", OTN_PASS.testthat = "wrong_pass")
  on.exit({
    Sys.unsetenv("OTN_USER.testthat")
    Sys.unsetenv("OTN_PASS.testthat")
  })

  mock_req_perform_error(status_code = 401, throw_condition = TRUE)

  expect_error(
    otn_login("testthat"),
    regexp = "Login failed. Check the supplied credentials"
  )
})
