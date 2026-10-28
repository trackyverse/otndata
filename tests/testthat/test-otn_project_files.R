test_that("otn_project_files constructs GET @search query when no filters are applied", {
  setup_otn_env()
  mock_otn_bindings()

  mock_req_perform_json(
    validate_req = function(req) {
      expect_equal(req$method, NULL)
      expect_true(grepl(
        "/data-and-metadata/@search",
        utils::URLdecode(req$url)
      ))
      expect_true(grepl("portal_type=File", req$url))
    }
  )

  res <- otn_project_files("PROJ", network = "testthat")

  # Assert data frame transformation
  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 1)
  expect_equal(
    names(res),
    c(
      "name",
      "description",
      "url",
      "created",
      "modified",
      "network",
      "creator",
      "size",
      "type"
    )
  )
  expect_equal(res$name, "detections_2023.parquet")
  expect_equal(res$network, "TESTTHAT")
  expect_s3_class(res$created, "POSIXct")
  expect_s3_class(res$modified, "POSIXct")
})

test_that("otn_project_files constructs POST @querystring-search query when text or since filters are present", {
  setup_otn_env()
  mock_otn_bindings()

  mock_req_perform_json(
    validate_req = function(req) {
      # Verify filtered POST request route
      expect_equal(req$method, "POST")
      expect_true(grepl(
        "/data-and-metadata/@querystring-search",
        utils::URLdecode(req$url)
      ))

      # Verify JSON query structure
      query_list <- req$body$data$query
      expect_equal(query_list[[3]]$i, "Title")
      expect_equal(query_list[[3]]$v, "parquet")
      expect_equal(query_list[[4]]$i, "modified")
      expect_equal(query_list[[4]]$v, "2023-01-01")
    }
  )

  res <- otn_project_files(
    "PROJ",
    text = "parquet",
    since = "2023-01-01",
    network = "testthat"
  )
  expect_equal(nrow(res), 1)
})

test_that("otn_project_files attaches bearer token when authenticated", {
  setup_otn_env(token = "mocked_bearer_token")
  mock_otn_bindings()

  mock_req_perform_json(
    validate_req = function(req) {
      headers <- httr2::req_get_headers(req, redacted = "reveal")
      expect_equal(headers[["Authorization"]], "Bearer mocked_bearer_token")
    }
  )

  res <- otn_project_files("PROJ", network = "testthat")
  expect_equal(nrow(res), 1)
})

test_that("otn_project_files aborts with prompt message on 401/403 status when token is missing", {
  setup_otn_env()
  mock_otn_bindings()

  mock_req_perform_error(status_code = 401)

  expect_error(
    otn_project_files("PROJ", network = "testthat"),
    regexp = "This project requires authentication"
  )
})

test_that("otn_project_files handles empty search results cleanly", {
  setup_otn_env()
  mock_otn_bindings()

  mock_req_perform_json(body_json = sample_plone_json(items = 0))

  res <- otn_project_files("PROJ", network = "testthat")

  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 0)
  expect_equal(
    names(res),
    c(
      "name",
      "description",
      "url",
      "created",
      "modified",
      "network",
      "creator",
      "size",
      "type"
    )
  )
})

test_that(".otn_files falls back to .otn_server_url when server_url is missing from otn_global", {
  setup_otn_env()
  mock_otn_bindings()

  # Remove server_url from global state to trigger fallback
  otn_glob <- asNamespace("otndata")$otn_global
  otn_glob$testthat$server_url <- NULL

  fallback_called <- FALSE

  local_mocked_bindings(
    .otn_server_url = function(network, set = FALSE) {
      fallback_called <<- TRUE
      "https://fallback.otn.org"
    },
    .package = "otndata"
  )

  mock_req_perform_json(
    body_json = '{"items": []}',
    validate_req = function(req) {
      expect_true(grepl("^https://fallback\\.otn\\.org", req$url))
    }
  )

  otn_project_files("PROJ", network = "testthat")

  expect_true(fallback_called)
})
