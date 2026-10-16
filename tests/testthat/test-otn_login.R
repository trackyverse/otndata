test_that("otn_login succeeds when valid credentials exist in Sys.getenv()", {
  # Set environment variables manually
  Sys.setenv(OTN_USER.testthat = "testuser", OTN_PASS.testthat = "testpass")
  on.exit({
    Sys.unsetenv("OTN_USER.testthat")
    Sys.unsetenv("OTN_PASS.testthat")
  })

  # Mock internal package bindings
  local_mocked_bindings(
    .otn_server_url = function(network) TRUE,
    .otn_api = function(path, server) httr2::request(paste0(server, "/", path)),
    .package = "otndata"
  )

  # Mock external package bindings
  local_mocked_bindings(
    req_perform = function(req) {
      httr2::response(
        status_code = 200,
        body = charToRaw('{"token": "mocked_jwt_token_123"}'),
        headers = list("Content-Type" = "application/json")
      )
    },
    .package = "httr2"
  )

  otn_login("testthat")
  otn_glob <- asNamespace("otndata")$otn_global
  expect_equal(otn_glob$testthat$token, "mocked_jwt_token_123")
})

test_that("otn_login prompts for credentials before making the API query", {
  # Execution order tracking flag
  prompt_occurred <- FALSE

  local_mocked_bindings(
    .otn_server_url = function(network) TRUE,
    .otn_api = function(path, server) httr2::request("https://test.api/@login"),
    otn_set_credentials = function(network, temporary) {
      prompt_occurred <<- TRUE # Record that prompt step executed
      otn_glob <- asNamespace("otndata")$otn_global
      otn_glob[[network]]$username <- "prompted_user"
      otn_glob[[network]]$password <- "prompted_pass"
    },
    .package = "otndata"
  )

  local_mocked_bindings(
    req_perform = function(req) {
      # Assertion 1: Verify prompting happened BEFORE req_perform was reached
      expect_true(prompt_occurred)

      # Assertion 2: Verify the request body contains the prompted credentials
      expect_equal(as.character(req$body$data$login), "prompted_user")
      expect_equal(as.character(req$body$data$password), "prompted_pass")

      httr2::response(
        status_code = 200,
        body = charToRaw('{"token": "fake_token"}'),
        headers = list("Content-Type" = "application/json")
      )
    },
    .package = "httr2"
  )

  otn_login("testthat")

  # Assertion 3: Verify token updated in global state
  otn_glob <- asNamespace("otndata")$otn_global
  expect_equal(otn_glob$testthat$token, "fake_token")
})


test_that("otn_login errors with wrong credentials", {
  Sys.setenv(OTN_USER.testthat = "wrong_user", OTN_PASS.testthat = "wrong_pass")
  on.exit({
    Sys.unsetenv("OTN_USER.testthat")
    Sys.unsetenv("OTN_PASS.testthat")
  })

  local_mocked_bindings(
    .otn_server_url = function(network) TRUE,
    .otn_api = function(path, server) httr2::request("https://test.api/@login"),
    .package = "otndata"
  )

  local_mocked_bindings(
    req_perform = function(req) {
      resp <- httr2::response(status_code = 401)
      cnd <- structure(
        list(message = "HTTP 401 Unauthorized", response = resp),
        class = c("httr2_http_401", "httr2_http", "error", "condition")
      )
      stop(cnd)
    },
    .package = "httr2"
  )

  expect_error(
    otn_login("testthat"),
    regexp = "Login failed. Check the supplied credentials"
  )
})
