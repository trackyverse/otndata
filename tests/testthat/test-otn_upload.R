test_that("otn_upload aborts when all files exceed 500MB limit", {
  setup_otn_env(token = "mock_token")
  mock_otn_bindings()

  local_mocked_bindings(
    is_logged_in = function(network) TRUE,
    .package = "otndata"
  )

  tmp_file <- tempfile(fileext = ".csv")
  writeLines("test data", tmp_file)
  on.exit(unlink(tmp_file), add = TRUE)

  local_mocked_bindings(
    file.info = function(...) data.frame(size = 6e8),
    .package = "base"
  )

  expect_error(
    otn_upload(tmp_file, project = "PROJ", network = "testthat"),
    regexp = "larger than 500MB"
  )
})

test_that("otn_upload informs user and filters out files exceeding 500MB while uploading valid files", {
  setup_otn_env(token = "mock_token")
  mock_otn_bindings()

  local_mocked_bindings(
    is_logged_in = function(network) TRUE,
    .package = "otndata"
  )

  tmp1 <- tempfile(fileext = ".csv")
  tmp2 <- tempfile(fileext = ".csv")
  writeLines("big file data", tmp1)
  writeLines("small file data", tmp2)
  on.exit(unlink(c(tmp1, tmp2)), add = TRUE)

  local_mocked_bindings(
    file.info = function(files, ...) {
      sizes <- ifelse(files == tmp1, 6e8, 100)
      data.frame(size = sizes)
    },
    .package = "base"
  )

  target_url <- "https://testthat.otn.org/data/repository/PROJ/to-be-filed/small.csv"
  mock_req_perform_json(
    status_code = 201,
    headers = list(Location = target_url)
  )

  expect_message(
    res <- otn_upload(c(tmp1, tmp2), project = "PROJ", network = "testthat"),
    regexp = "larger than 500MB"
  )

  expect_equal(res, target_url)
})

test_that("otn_upload successfully uploads a single non-image file", {
  setup_otn_env(token = "mock_token")
  mock_otn_bindings()

  local_mocked_bindings(
    is_logged_in = function(network) TRUE,
    .package = "otndata"
  )

  tmp_file <- tempfile(pattern = "sample_", fileext = ".csv")
  writeLines("col1,col2\n1,2", tmp_file)
  on.exit(unlink(tmp_file), add = TRUE)

  file_name <- basename(tmp_file)
  target_url <- paste0(
    "https://testthat.otn.org/data/repository/PROJ/to-be-filed/",
    file_name
  )

  mock_req_perform_json(
    status_code = 201,
    headers = list(Location = target_url),
    validate_req = function(req) {
      expect_true(grepl("/data/repository/PROJ/to-be-filed$", req$url))
      expect_equal(req$body$data$`@type`, "File")
      expect_equal(req$body$data$title, file_name)
      expect_equal(req$body$data$file$filename, file_name)

      headers <- httr2::req_get_headers(req, redacted = "reveal")
      expect_equal(headers[["Authorization"]], "Bearer mock_token")
    }
  )

  res <- otn_upload(tmp_file, project = "PROJ", network = "testthat")
  expect_equal(res, target_url)
})

test_that("otn_upload formats payload correctly for image files", {
  setup_otn_env(token = "mock_token")
  mock_otn_bindings()

  local_mocked_bindings(
    is_logged_in = function(network) TRUE,
    .package = "otndata"
  )

  tmp_img <- tempfile(pattern = "photo_", fileext = ".png")
  writeLines("dummy image content", tmp_img)
  on.exit(unlink(tmp_img), add = TRUE)

  file_name <- basename(tmp_img)
  target_url <- paste0(
    "https://testthat.otn.org/data/repository/PROJ/to-be-filed/",
    file_name
  )

  local_mocked_bindings(
    guess_type = function(...) "image/png",
    .package = "mime"
  )

  mock_req_perform_json(
    status_code = 201,
    headers = list(Location = target_url),
    validate_req = function(req) {
      expect_equal(req$body$data$`@type`, "Image")
      expect_equal(req$body$data$title, file_name)
      expect_equal(req$body$data$image$filename, file_name)
      expect_equal(req$body$data$image$`content-type`, "image/png")
    }
  )

  res <- otn_upload(tmp_img, project = "PROJ", network = "testthat")
  expect_equal(res, target_url)
})

test_that("otn_upload routes multiple files through req_perform_parallel", {
  setup_otn_env(token = "mock_token")
  mock_otn_bindings()

  local_mocked_bindings(
    is_logged_in = function(network) TRUE,
    .package = "otndata"
  )

  tmp1 <- tempfile(pattern = "file1_", fileext = ".csv")
  tmp2 <- tempfile(pattern = "file2_", fileext = ".csv")
  writeLines("data1", tmp1)
  writeLines("data2", tmp2)
  on.exit(unlink(c(tmp1, tmp2)), add = TRUE)

  loc1 <- paste0(
    "https://testthat.otn.org/data/repository/PROJ/to-be-filed/",
    basename(tmp1)
  )
  loc2 <- paste0(
    "https://testthat.otn.org/data/repository/PROJ/to-be-filed/",
    basename(tmp2)
  )

  local_mocked_bindings(
    req_perform_parallel = function(
      requests,
      on_error = "return",
      max_active = 3
    ) {
      expect_equal(length(requests), 2)
      list(
        httr2::response(status_code = 201, headers = list(Location = loc1)),
        httr2::response(status_code = 201, headers = list(Location = loc2))
      )
    },
    .package = "httr2"
  )

  res <- otn_upload(c(tmp1, tmp2), project = "PROJ", network = "testthat")
  expect_equal(res, c(loc1, loc2))
})
