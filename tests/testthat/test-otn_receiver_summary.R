test_that("otn_receiver_summary aborts when missing project and required files", {
  expect_error(
    otn_receiver_summary(),
    regexp = "Must provide a project code"
  )

  expect_error(
    otn_receiver_summary(project = NULL, qualified = "q.parquet"),
    regexp = "Must provide a project code"
  )
})

test_that("otn_receiver_summary aborts when no parquet files exist in extracts", {
  setup_otn_env()
  mock_otn_bindings()

  local_mocked_bindings(
    otn_extract_files = function(...) {
      data.frame(url = c("https://testthat.otn.org/files/data.csv"))
    },
    .package = "otndata"
  )

  expect_error(
    otn_receiver_summary(project = "PROJ", network = "testthat"),
    regexp = "No parquet files detected"
  )
})

test_that("otn_receiver_summary executes directly when local files are supplied", {
  called_args <- NULL

  local_mocked_bindings(
    make_receiver_push_summary = function(
      qualified,
      unqualified,
      deployment,
      ...
    ) {
      called_args <<- list(
        qualified = qualified,
        unqualified = unqualified,
        deployment = deployment
      )
      "summary_report.html"
    },
    .package = "otndo"
  )

  res <- otn_receiver_summary(
    qualified = "path/q.parquet",
    unqualified = "path/u.parquet",
    deployment = "path/deploy.xlsx"
  )

  expect_equal(res, "summary_report.html")
  expect_equal(called_args$qualified, "path/q.parquet")
  expect_equal(called_args$unqualified, "path/u.parquet")
  expect_equal(called_args$deployment, "path/deploy.xlsx")
})

test_that("otn_receiver_summary fetches and downloads missing extract and deployment files", {
  setup_otn_env()
  mock_otn_bindings()

  extract_df <- data.frame(
    url = c(
      "https://testthat.otn.org/files/proj_qualified.parquet",
      "https://testthat.otn.org/files/proj_unqualified.parquet"
    )
  )

  project_df <- data.frame(
    url = c(
      "https://testthat.otn.org/files/deployment_metadata.xlsx",
      "https://testthat.otn.org/files/metadata.txt"
    )
  )

  downloaded_files <- list()

  local_mocked_bindings(
    otn_extract_files = function(project, network) extract_df,
    otn_project_files = function(project, network) project_df,
    otn_download = function(files, outdir) {
      urls <- if (is.data.frame(files)) files$url else files
      downloaded_files <<- c(downloaded_files, list(urls))
      file.path(outdir, basename(urls))
    },
    .package = "otndata"
  )

  passed_to_otndo <- NULL
  local_mocked_bindings(
    make_receiver_push_summary = function(
      qualified,
      unqualified,
      deployment,
      ...
    ) {
      passed_to_otndo <<- list(
        qualified = qualified,
        unqualified = unqualified,
        deployment = deployment
      )
      "summary_report.html"
    },
    .package = "otndo"
  )

  res <- otn_receiver_summary(project = "PROJ", network = "testthat")

  expect_equal(res, "summary_report.html")
  expect_equal(length(downloaded_files), 3)
  expect_true(grepl("_qualified\\.parquet$", passed_to_otndo$qualified))
  expect_true(grepl("_unqualified\\.parquet$", passed_to_otndo$unqualified))
  expect_true(grepl("deployment_metadata\\.xlsx$", passed_to_otndo$deployment))
})
