test_that("otn_extract_files targets detection-extracts section", {
  setup_otn_env("testnet")

  local_mocked_bindings(
    fix_null_network = function(network) {
      if (is.null(network)) "testnet" else network
    },
    build_namespace = function(project, network) project,
    .otn_server_url = function(network, set = FALSE) "https://testnet.otn.org",
    .otn_api = function(endpoint, server) {
      httr2::request(paste0(server, endpoint))
    },
    .package = "otndata"
  )

  local_mocked_bindings(
    req_perform = function(req) {
      expect_true(grepl("/detection-extracts/@search", req$url))

      httr2::response(
        status_code = 200,
        body = charToRaw(sample_item_json()),
        headers = list("Content-Type" = "application/json")
      )
    },
    .package = "httr2"
  )

  res <- otn_extract_files("PROJ", network = "testnet")
  expect_equal(nrow(res), 1)
})
