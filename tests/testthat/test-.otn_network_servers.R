test_that(".otn_network_servers returns named character vector of base URLs", {
  servers <- .otn_network_servers()

  expect_type(servers, "character")
  expect_named(servers)
  expect_equal(servers[["act"]], "https://data.theactnetwork.com")
  expect_equal(servers[["otn"]], "https://members.oceantrack.org")
})
