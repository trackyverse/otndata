test_that("otn_extract_files targets detection-extracts section", {
  setup_otn_env()
  mock_otn_bindings()

  mock_req_perform_json(
    validate_req = function(req) {
      expect_true(grepl(
        "/detection-extracts/@search",
        utils::URLdecode(req$url)
      ))
    }
  )

  res <- otn_extract_files("PROJ", network = "testthat")
  expect_equal(nrow(res), 1)
})
