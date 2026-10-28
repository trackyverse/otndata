test_that("otn_list wrapper functions query correct endpoints and handle default network", {
  setup_otn_env()
  mock_otn_bindings()

  endpoints_called <- character(0)

  mock_req_perform_json(
    body_json = '[{"id": 1}]',
    validate_req = function(req) {
      endpoints_called <<- c(endpoints_called, req$url)
    }
  )

  # Invoke all standard list wrappers
  res_contacts <- otn_list_contacts()
  res_countries <- otn_list_countries()
  res_species <- otn_list_species()
  res_institutions <- otn_list_institutions()
  res_stats <- otn_list_stats()
  res_projects_all <- otn_list_projects(what = "all")

  # Verify endpoint routing
  expect_true(any(grepl("all_contacts.json$", endpoints_called)))
  expect_true(any(grepl("active_countries.json$", endpoints_called)))
  expect_true(any(grepl("all_species.json$", endpoints_called)))
  expect_true(any(grepl("all_institutions.json$", endpoints_called)))
  expect_true(any(grepl("header_stats.json$", endpoints_called)))
  expect_true(any(grepl("projects.json$", endpoints_called)))

  # Verify parsing return structure
  expect_equal(res_contacts, data.frame(id = 1))
})

test_that("otn_list_projects(what = 'mine') attaches bearer token and parses nested response into data frame", {
  setup_otn_env(token = "mock_bearer_token")
  mock_otn_bindings()

  local_mocked_bindings(
    is_logged_in = function(network) TRUE,
    .package = "otndata"
  )

  # Nested list matching the structure expected by _[[1]][["projects"]][[1]]
  my_projects_list <- list(
    list(
      projects = list(
        list(
          id = "proj1",
          text = "OTN - TEST - Project",
          a_attr = list(
            title = "Test Project Long Name",
            href = "/projects/proj1"
          )
        )
      )
    )
  )

  mock_req_perform_json(
    body_json = "{}",
    validate_req = function(req) {
      headers <- httr2::req_get_headers(req, redacted = "reveal")
      expect_equal(headers[["Authorization"]], "Bearer mock_bearer_token")
      expect_true(grepl("project_root.json$", req$url))
    }
  )

  local_mocked_bindings(
    resp_body_json = function(resp, simplifyVector = TRUE, ...) {
      my_projects_list
    },
    .package = "httr2"
  )

  res <- otn_list_projects(what = "mine", network = "testthat")

  # Assert output data frame structure and string parsing
  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 1)
  expect_equal(res$node, "TESTTHAT")
  expect_equal(res$collectioncode, "PROJ1")
  expect_equal(res$shortname, "TEST")
  expect_equal(res$longname, "Test Project Long Name")
  expect_equal(res$url, "https://testthat.otn.org/projects/proj1")
})

test_that("otn_list_projects throws error for invalid 'what' argument", {
  expect_error(
    otn_list_projects(what = "invalid_option"),
    regexp = "must\\s+be\\s+one\\s+of"
  )
})
