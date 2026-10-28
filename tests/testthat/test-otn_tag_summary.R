test_that("otn_tag_summary aborts when both project and matched are NULL", {
  expect_error(
    otn_tag_summary(),
    regexp = "Must provide a project code"
  )
})

test_that("otn_tag_summary aborts when extract files contain no matched detection parquet files", {
  setup_otn_env()
  mock_otn_bindings()

  local_mocked_bindings(
    otn_extract_files = function(...) {
      data.frame(url = c("https://testthat.otn.org/files/unmatched.parquet"))
    },
    .package = "otndata"
  )

  expect_error(
    otn_tag_summary(project = "PROJ", network = "testthat"),
    regexp = "No matched detection parquet files detected"
  )
})

test_that("otn_tag_summary executes directly when local matched file is provided", {
  passed_matched <- NULL

  local_mocked_bindings(
    make_tag_push_summary = function(matched, ...) {
      passed_matched <<- matched
      "tag_summary_report.html"
    },
    .package = "otndo"
  )

  res <- otn_tag_summary(matched = "local/matched_detections.parquet")

  expect_equal(res, "tag_summary_report.html")
  expect_equal(passed_matched, "local/matched_detections.parquet")
})

test_that("otn_tag_summary downloads matched detections and warns on external partner files", {
  setup_otn_env()
  mock_otn_bindings()

  extract_df <- data.frame(
    url = c(
      "https://testthat.otn.org/files/matched_detections.parquet",
      "https://testthat.otn.org/files/matched_external_partners.parquet"
    )
  )

  local_mocked_bindings(
    otn_extract_files = function(project, network) extract_df,
    otn_download = function(files, outdir) {
      urls <- if (is.data.frame(files)) files$url else files
      file.path(outdir, basename(urls))
    },
    .package = "otndata"
  )

  local_mocked_bindings(
    make_tag_push_summary = function(matched, ...) {
      "tag_summary_report.html"
    },
    .package = "otndo"
  )

  expect_message(
    res <- otn_tag_summary(project = "PROJ", network = "testthat"),
    regexp = "external partners"
  )

  expect_equal(res, "tag_summary_report.html")
})
