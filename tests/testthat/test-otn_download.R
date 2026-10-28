test_that("otn_download throws errors on invalid input combinations", {
  # Neither files nor urls provided
  expect_error(
    otn_download(),
    regexp = "Please provide one of `files` or `urls`"
  )

  # Both files and urls provided
  expect_error(
    otn_download(
      files = "abcdf",
      urls = "https://testthat.otn.org/data/file1.csv"
    ),
    regexp = "Please provide only one of `files` or `urls`"
  )
})

test_that("otn_download creates output directory if it does not exist", {
  setup_otn_env()
  mock_otn_bindings()
  mock_parallel_download()

  outdir <- file.path(tempdir(), "new_downloads")
  on.exit(unlink(outdir, recursive = TRUE), add = TRUE)

  local_mocked_bindings(
    .otn_network_from_url = function(urls) "testthat",
    .package = "otndata"
  )

  res <- otn_download(
    urls = "https://testthat.otn.org/data/test.csv",
    outdir = outdir
  )

  expect_true(dir.exists(outdir))
  expect_equal(res, file.path(outdir, "test.csv"))
})

test_that("otn_download theoretically works with `urls` input", {
  setup_otn_env()
  mock_otn_bindings()
  mock_parallel_download()

  tmp_dir <- tempfile()
  dir.create(tmp_dir)
  on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)

  test_url <- "https://testthat.otn.org/data/repository/PROJ/data.csv"

  local_mocked_bindings(
    .otn_network_from_url = function(urls) "testthat",
    .package = "otndata"
  )

  res <- otn_download(urls = test_url, outdir = tmp_dir)

  expect_equal(length(res), 1)
  expect_equal(basename(res), "data.csv")
  expect_true(file.exists(res))
})

test_that("otn_download adjusts '-parquet' extension to '.parquet'", {
  setup_otn_env()
  mock_otn_bindings()
  mock_parallel_download()

  tmp_dir <- tempfile()
  dir.create(tmp_dir)
  on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)

  files_df <- data.frame(
    url = "https://testthat.otn.org/data/detections-parquet",
    network = "TESTTHAT"
  )

  res <- otn_download(files = files_df, outdir = tmp_dir)

  expect_equal(basename(res), "detections.parquet")
  expect_true(file.exists(file.path(tmp_dir, "detections.parquet")))
})

test_that("otn_download sets auth_token cookie when token is present", {
  setup_otn_env(token = "mock_jwt_cookie_token")
  mock_otn_bindings()

  tmp_dir <- tempfile()
  dir.create(tmp_dir)
  on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)

  files_df <- data.frame(
    url = "https://testthat.otn.org/data/private_file.csv",
    network = "TESTTHAT"
  )

  mock_parallel_download(
    body_content = "secure data",
    content_type = "text/csv",
    validate_req = function(requests) {
      expect_true(any(grepl(
        "auth_token=mock_jwt_cookie_token",
        requests[[1]]$options$cookie
      )))
    }
  )

  res <- otn_download(files = files_df, outdir = tmp_dir)

  expect_equal(length(res), 1)
  expect_true(file.exists(res))
})

test_that("otn_download cleans up local file artifact and warns when HTML login page or 401/403 status is returned", {
  setup_otn_env()
  mock_otn_bindings()

  tmp_dir <- tempfile()
  dir.create(tmp_dir)
  on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)

  files_df <- data.frame(
    url = "https://testthat.otn.org/data/protected_file.csv",
    network = "TESTTHAT"
  )

  mock_parallel_download(
    body_content = "<!DOCTYPE html><html><body>Login required</body></html>",
    content_type = "text/html; charset=utf-8"
  )

  # Expect warning regarding authentication requirement
  expect_warning(
    res <- otn_download(files = files_df, outdir = tmp_dir),
    regexp = "requires\\s+authentication"
  )

  # Assert download returned empty vector and local HTML file was deleted
  expect_equal(res, character(0))
  expect_false(file.exists(file.path(tmp_dir, "protected_file.csv")))
})

test_that("otn_download detects HTML login pages via fallback readLines inspection (line 66)", {
  setup_otn_env()
  mock_otn_bindings()

  tmp_dir <- tempfile(pattern = "mock_out_")
  dir.create(tmp_dir)
  on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)

  # Create an extract file entry
  files_df <- data.frame(
    url = "https://testthat.otn.org/files/data.parquet",
    network = "testthat"
  )

  # Mock req_perform_parallel to write HTML content into destination file
  # but supply a non-HTML response header to force line 66 evaluation
  local_mocked_bindings(
    req_perform_parallel = function(requests, paths, on_error = "continue") {
      writeLines(
        c("<!DOCTYPE html>", "<html><body>Login</body></html>"),
        paths[[1]]
      )
      list(
        httr2::response(
          status_code = 200,
          headers = list(`content-type` = "application/octet-stream")
        )
      )
    },
    .package = "httr2"
  )

  expect_warning(
    res <- otn_download(files = files_df, outdir = tmp_dir),
    regexp = "requires authentication"
  )

  expect_equal(length(res), 0)
})

test_that("otn_download unwraps httr2_http error conditions (line 111)", {
  setup_otn_env()
  mock_otn_bindings()

  tmp_dir <- tempfile(pattern = "mock_out_")
  dir.create(tmp_dir)
  on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)

  files_df <- data.frame(
    url = "https://testthat.otn.org/files/data.parquet",
    network = "testthat"
  )

  # Construct an httr2_http error object containing $resp with status 401
  mock_http_err <- structure(
    list(
      message = "HTTP 401 Unauthorized",
      resp = httr2::response(
        status_code = 401,
        headers = list(`content-type` = "application/json")
      )
    ),
    class = c("httr2_http_401", "httr2_http", "error", "condition")
  )

  local_mocked_bindings(
    req_perform_parallel = function(requests, paths, on_error = "continue") {
      list(mock_http_err)
    },
    .package = "httr2"
  )

  expect_warning(
    res <- otn_download(files = files_df, outdir = tmp_dir),
    regexp = "requires authentication"
  )

  expect_equal(length(res), 0)
})

test_that("otn_download unwraps generic error objects with $resp (line 113)", {
  setup_otn_env()
  mock_otn_bindings()

  tmp_dir <- tempfile(pattern = "mock_out_")
  dir.create(tmp_dir)
  on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)

  files_df <- data.frame(
    url = "https://testthat.otn.org/files/data.parquet",
    network = "testthat"
  )

  # Construct a generic error object (without httr2_http class) containing $resp
  mock_generic_err <- structure(
    list(
      message = "Custom network error",
      resp = httr2::response(
        status_code = 403,
        headers = list(`content-type` = "application/json")
      )
    ),
    class = c("error", "condition")
  )

  local_mocked_bindings(
    req_perform_parallel = function(requests, paths, on_error = "continue") {
      list(mock_generic_err)
    },
    .package = "httr2"
  )

  expect_warning(
    res <- otn_download(files = files_df, outdir = tmp_dir),
    regexp = "requires authentication"
  )

  expect_equal(length(res), 0)
})
