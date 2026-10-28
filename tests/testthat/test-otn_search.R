test_that("otn_search wrappers construct correct endpoints and query parameters", {
  setup_otn_env()
  mock_otn_bindings()

  last_url <- NULL

  mock_req_perform_json(
    body_json = '[{"project_id": "PROJ1"}]',
    validate_req = function(req) {
      last_url <<- utils::URLdecode(req$url)
    }
  )

  # 1. Search code -> projects_by_code.json?ccode=PROJ
  res_code <- otn_search_code("PROJ")
  expect_true(grepl("projects_by_code\\.json/?\\?ccode=PROJ$", last_url))
  expect_equal(res_code, data.frame(project_id = "PROJ1"))

  # 2. Search contact -> projects_by_contact.json?contact=Smith
  otn_search_contact("Smith")
  expect_true(grepl("projects_by_contact\\.json/?\\?contact=Smith$", last_url))

  # 3. Search country -> projects_by_country.json?country=Canada
  otn_search_country("Canada")
  expect_true(grepl("projects_by_country\\.json/?\\?country=Canada$", last_url))

  # 4. Search species -> projects_by_species.json?species=Gadus morhua
  otn_search_species("Gadus morhua")
  expect_true(grepl(
    "projects_by_species\\.json/?\\?species=Gadus morhua$",
    last_url
  ))

  # 5. Search node -> projects_by_node.json?node=OTN
  otn_search_node("OTN")
  expect_true(grepl("projects_by_node\\.json/?\\?node=OTN$", last_url))

  # 6. Search institution -> projects_by_institutions.json?institution=Dalhousie
  otn_search_institution("Dalhousie")
  expect_true(grepl(
    "projects_by_institutions\\.json/?\\?institution=Dalhousie$",
    last_url
  ))
})

test_that(".otn_search falls back to .otn_server_url when server_url is missing from otn_global", {
  otn_glob <- asNamespace("otndata")$otn_global
  otn_glob[["testthat"]] <- new.env(parent = emptyenv())

  mock_otn_bindings("testthat")

  mock_req_perform_json(
    body_json = '[]',
    validate_req = function(req) {
      expect_true(grepl("https://testthat\\.otn\\.org", req$url))
    }
  )

  res <- otn_search_code("PROJ", network = "testthat")

  expect_type(res, "list")
  expect_length(res, 0)
})

test_that(".otn_search propagates HTTP server errors", {
  setup_otn_env()
  mock_otn_bindings()

  mock_req_perform_error(status_code = 500, throw_condition = TRUE)

  expect_error(
    otn_search_code("PROJ"),
    regexp = "HTTP 500"
  )
})
