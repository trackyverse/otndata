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

test_that("otn_extract_files targets detection-extracts section", {
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
      expect_true(grepl(
        "/detection-extracts/@search",
        utils::URLdecode(req$url)
      ))

      httr2::response(
        status_code = 200,
        body = charToRaw(sample_json),
        headers = list("Content-Type" = "application/json")
      )
    },
    .package = "httr2"
  )

  res <- otn_extract_files("PROJ", network = "testthat")
  expect_equal(nrow(res), 1)
})
