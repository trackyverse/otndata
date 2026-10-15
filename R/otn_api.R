#' Call OTN API endpoints.
#'
#' @param endpoint Character. API endpoint to call.
#' @param server URL of the network's Plone CMS
#'
#' @keywords internal
#' @seealso [Plone REST API endpoints](https://6.docs.plone.org/plone.restapi/docs/source/endpoints)
.otn_api <- function(endpoint, server) {
  server |>
    httr2::request() |>
    httr2::req_url_path_append("++api++") |>
    httr2::req_url_path_append(endpoint) |>
    httr2::req_user_agent("otndata R Package")
}
