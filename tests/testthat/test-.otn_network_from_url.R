test_that(".otn_network_from_url identifies telemetry network from file URL", {
  url_act <- "https://data.theactnetwork.com/data/repository/proj/file.csv"
  url_itag <- "https://data.itagscience.com/data/repository/proj/file.csv"

  expect_equal(.otn_network_from_url(url_act), "act")
  expect_equal(.otn_network_from_url(url_itag), "itag")
})

test_that(".otn_network_from_url throws error when URL match is not found", {
  unknown_url <- "https://unknown-network-domain.org/data/file.csv"

  expect_error(
    .otn_network_from_url(unknown_url),
    regexp = "Could not determine telemetry network for URL"
  )
})
