sample_json <- '{"items": [
    {
      "title": "detections_2023.parquet",
      "description": "Detection file",
      "getURL": "https://testnet.otn.org/data/repository/PROJ/data-and-metadata/detections_2023.parquet",
      "created": "2023-01-15T10:00:00+00:00",
      "modified": "2023-01-16T15:30:00+00:00",
      "Creator": "admin",
      "getObjSize": "1048576",
      "type_title": "File"
    }
  ]}'

test_that("otn_project_files constructs GET @search query when no filters are applied", {
  local_mocked_bindings(
    fix_null_network = function(network) {
      if (is.null(network)) "testthat" else network
    },
    build_namespace = function(project, network) project,
    .otn_server_url = function(network, set = FALSE) "https://testthat.otn.org",
    .otn_api = function(endpoint, server) {
      httr2::request(paste0(server, endpoint))
    },
    .package = "otndata"
  )

  local_mocked_bindings(
    req_perform = function(req) {
      # httr2 defaults to NULL for standard GET requests
      expect_equal(req$method, NULL)
      expect_true(grepl("/data-and-metadata/@search", req$url))
      expect_true(grepl("portal_type=File", req$url))

      httr2::response(
        status_code = 200,
        body = charToRaw(sample_json),
        headers = list("Content-Type" = "application/json")
      )
    },
    .package = "httr2"
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
  local_mocked_bindings(
    fix_null_network = function(network) {
      if (is.null(network)) "testthat" else network
    },
    build_namespace = function(project, network) project,
    .otn_server_url = function(network, set = FALSE) "https://testthat.otn.org",
    .otn_api = function(endpoint, server) {
      httr2::request(paste0(server, endpoint))
    },
    .package = "otndata"
  )

  local_mocked_bindings(
    req_perform = function(req) {
      # Verify filtered POST request route
      expect_equal(req$method, "POST")
      expect_true(grepl("/data-and-metadata/@querystring-search", req$url))

      # Verify JSON query structure
      query_list <- req$body$data$query
      expect_equal(query_list[[3]]$i, "Title")
      expect_equal(query_list[[3]]$v, "parquet")
      expect_equal(query_list[[4]]$i, "modified")
      expect_equal(query_list[[4]]$v, "2023-01-01")

      httr2::response(
        status_code = 200,
        body = charToRaw(sample_json),
        headers = list("Content-Type" = "application/json")
      )
    },
    .package = "httr2"
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
  otn_glob <- asNamespace("otndata")$otn_global
  otn_glob$testthat$token <- "mocked_bearer_token"

  local_mocked_bindings(
    fix_null_network = function(network) {
      if (is.null(network)) "testthat" else network
    },
    build_namespace = function(project, network) project,
    .otn_server_url = function(network, set = FALSE) "https://testthat.otn.org",
    .otn_api = function(endpoint, server) {
      httr2::request(paste0(server, endpoint))
    },
    .package = "otndata"
  )

  local_mocked_bindings(
    req_perform = function(req) {
      # Verify Bearer token authorization header
      headers <- httr2::req_get_headers(req, redacted = "reveal")
      expect_equal(headers[["Authorization"]], "Bearer mocked_bearer_token")

      httr2::response(
        status_code = 200,
        body = charToRaw(sample_json),
        headers = list("Content-Type" = "application/json")
      )
    },
    .package = "httr2"
  )

  res <- otn_project_files("PROJ", network = "testthat")
  expect_equal(nrow(res), 1)
})

test_that("otn_project_files aborts with prompt message on 401/403 status when token is missing", {
  local_mocked_bindings(
    fix_null_network = function(network) {
      if (is.null(network)) "testthat" else network
    },
    build_namespace = function(project, network) project,
    .otn_server_url = function(network, set = FALSE) "https://testthat.otn.org",
    .otn_api = function(endpoint, server) {
      httr2::request(paste0(server, endpoint))
    },
    .package = "otndata"
  )

  local_mocked_bindings(
    req_perform = function(req) {
      httr2::response(
        status_code = 401,
        body = charToRaw('{"message": "Unauthorized"}'),
        headers = list("Content-Type" = "application/json")
      )
    },
    .package = "httr2"
  )

  expect_error(
    otn_project_files("PROJ", network = "testthat"),
    regexp = "This project requires authentication"
  )
})

test_that("otn_project_files handles empty search results cleanly", {
  local_mocked_bindings(
    fix_null_network = function(network) {
      if (is.null(network)) "testthat" else network
    },
    build_namespace = function(project, network) project,
    .otn_server_url = function(network, set = FALSE) "https://testthat.otn.org",
    .otn_api = function(endpoint, server) {
      httr2::request(paste0(server, endpoint))
    },
    .package = "otndata"
  )

  local_mocked_bindings(
    req_perform = function(req) {
      httr2::response(
        status_code = 200,
        body = charToRaw('{"items": []}'),
        headers = list("Content-Type" = "application/json")
      )
    },
    .package = "httr2"
  )

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
