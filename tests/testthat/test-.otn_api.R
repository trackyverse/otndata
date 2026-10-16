test_that(".otn_api constructs the expected URL endpoint", {
  server <- "https://api.otn.org"
  endpoint <- "@login"

  req <- .otn_api(endpoint = endpoint, server = server)

  expect_s3_class(req, "httr2_request")
  expect_equal(req$url, "https://api.otn.org/++api++/@login")
})

test_that(".otn_api handles server URLs with trailing slashes", {
  server <- "https://api.otn.org/"
  endpoint <- "projects.json"

  req <- .otn_api(endpoint = endpoint, server = server)

  expect_equal(req$url, "https://api.otn.org/++api++/projects.json")
})

test_that(".otn_api sets the custom User-Agent header", {
  server <- "https://api.otn.org"
  endpoint <- "header_stats.json"

  req <- .otn_api(endpoint = endpoint, server = server)

  expect_equal(req$options$useragent, "otndata R Package")
})

test_that(".otn_api handles multi-part path endpoints", {
  server <- "https://api.otn.org"
  endpoint <- "@search"

  req <- .otn_api(endpoint = endpoint, server = server)

  expect_equal(req$url, "https://api.otn.org/++api++/@search")
})
