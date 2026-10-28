#' Create a fake network and temporary otn_global environment
setup_otn_env <- function(network = "testthat", token = NULL) {
  otn_glob <- asNamespace("otndata")$otn_global
  otn_glob[[network]] <- new.env(parent = emptyenv())
  otn_glob[[network]]$server_url <- paste0("https://", network, ".otn.org")
  otn_glob[[network]]$token <- token
  invisible(otn_glob[[network]])
}

#' Mocks for network & API routing
mock_otn_bindings <- function(
  network_name = "testthat",
  .frame = parent.frame()
) {
  testthat::local_mocked_bindings(
    fix_null_network = function(network) {
      if (is.null(network)) network_name else network
    },
    build_namespace = function(project, network) project,
    .otn_server_url = function(network, set = FALSE) {
      paste0("https://", network_name, ".otn.org")
    },
    .otn_api = function(endpoint, server) {
      server_base <- gsub("/$", "", server)
      endpoint_path <- gsub("^/", "", endpoint)
      httr2::request(paste0(server_base, "/", endpoint_path))
    },
    .package = "otndata",
    .env = .frame
  )
}

#' Mock httr2::req_perform to return a JSON response
mock_req_perform_json <- function(
  body_json = sample_plone_json(),
  status_code = 200,
  headers = list("Content-Type" = "application/json"),
  validate_req = NULL,
  .frame = parent.frame()
) {
  force(body_json)
  force(status_code)
  force(headers)
  force(validate_req)

  testthat::local_mocked_bindings(
    req_perform = function(req) {
      if (is.function(validate_req)) {
        validate_req(req)
      }
      httr2::response(
        status_code = status_code,
        body = charToRaw(body_json),
        headers = headers
      )
    },
    .package = "httr2",
    .env = .frame
  )
}

#' Mock httr2::req_perform to simulate an HTTP error condition or status
mock_req_perform_error <- function(
  status_code = 401,
  body_json = '{"message": "Unauthorized"}',
  throw_condition = FALSE,
  .frame = parent.frame()
) {
  testthat::local_mocked_bindings(
    req_perform = function(req) {
      resp <- httr2::response(
        status_code = status_code,
        body = charToRaw(body_json),
        headers = list("Content-Type" = "application/json")
      )

      if (throw_condition) {
        cnd <- structure(
          list(message = paste("HTTP", status_code), response = resp),
          class = c(
            paste0("httr2_http_", status_code),
            "httr2_http",
            "error",
            "condition"
          )
        )
        stop(cnd)
      }

      resp
    },
    .package = "httr2",
    .env = .frame
  )
}

#' Mock req_perform_parallel to simulate file downloads
mock_parallel_download <- function(
  status_code = 200,
  body_content = "dummy data",
  content_type = "application/octet-stream",
  validate_req = NULL,
  .frame = parent.frame()
) {
  testthat::local_mocked_bindings(
    req_perform_parallel = function(
      requests,
      paths,
      on_error = "continue",
      ...
    ) {
      if (is.function(validate_req)) {
        validate_req(requests)
      }
      lapply(paths, function(p) {
        writeLines(body_content, p)
        httr2::response(
          status_code = status_code,
          headers = list("Content-Type" = content_type)
        )
      })
    },
    .package = "httr2",
    .env = .frame
  )
}

#' Sample Plone API search response JSON string
sample_plone_json <- function(items = 1) {
  if (items == 0) {
    return('{"items": []}')
  }

  '{"items": [
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
}
