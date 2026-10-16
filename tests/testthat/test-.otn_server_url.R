test_that(".otn_server_url returns server URL without setting otn_global when set = FALSE", {
  url <- .otn_server_url("act", set = FALSE)

  expect_equal(url, "https://data.theactnetwork.com")

  otn_glob <- asNamespace("otndata")$otn_global
  expect_null(otn_glob$act)
})

test_that(".otn_server_url populates otn_global when set = TRUE", {
  url <- .otn_server_url("act", set = TRUE)

  expect_equal(url, "https://data.theactnetwork.com")

  otn_glob <- asNamespace("otndata")$otn_global
  expect_equal(otn_glob$act$server_url, "https://data.theactnetwork.com")
})

test_that(".otn_server_url maps 'atap' network code to 'saf' in otn_global", {
  url <- .otn_server_url("atap", set = TRUE)

  expect_equal(url, "https://members.oceantrack.org")

  otn_glob <- asNamespace("otndata")$otn_global
  expect_null(otn_glob$atap)
  expect_equal(otn_glob$saf$server_url, "https://members.oceantrack.org")
})

test_that(".otn_server_url throws descriptive errors for non-Plone redirect networks", {
  expect_error(
    .otn_server_url("etn"),
    regexp = "ETN does not use an OTN-style Plone CMS"
  )
  expect_error(
    .otn_server_url("fact"),
    regexp = "FACT does not use an OTN-style Plone CMS"
  )
  expect_error(
    .otn_server_url("glatos"),
    regexp = "GLATOS does not use an OTN-style Plone CMS"
  )
  expect_error(
    .otn_server_url("path"),
    regexp = "PATH does not have the Plone REST API activated"
  )
  expect_error(
    .otn_server_url("raft"),
    regexp = "RAFT does not use an OTN-style Plone CMS"
  )
})

test_that(".otn_server_url throws error for invalid network argument", {
  expect_error(.otn_server_url("invalid_network"))
})
