#' Internal function for searching OTN projects.
#'
#' @param type Character. Internal data base to search.
#' @param search_term Character. Search term to use.
#' @inheritParams .otn_server_url network
#' @keywords internal
.otn_search <- function(network, type, search_term) {
  `:=` <- NULL

  network <- fix_null_network(network)
  server <- otn_global[[network]]$server_url

  if (is.null(server) & !is.null(network)) {
    server <- .otn_server_url(network, set = FALSE)
  }
  # is_logged_in(network)

  endpoint <- paste0("projects_by_", type, ".json")
  key <- switch(
    type,
    code = "ccode",
    contact = "contact",
    country = "country",
    species = "species",
    node = "node",
    institutions = "institution"
  )
  base_req <- endpoint |>
    .otn_api(server)

  rlang::inject(httr2::req_url_query(
    base_req,
    !!key := !!search_term
  )) |>
    httr2::req_perform() |>
    httr2::resp_body_json(simplifyVector = TRUE)
}

#' Search OTN database by project code.
#'
#' @param code Character. Project code for which to search. Supports partial matching.
#' @inheritParams .otn_search
#' @export
otn_search_code <- function(code, network = NULL) {
  .otn_search(network, type = "code", search_term = code)
}

#' Search OTN database by project contact.
#'
#' @param contact Character. Project contact for which to search. DOES NOT support partial matching.
#' @inheritParams .otn_search
#' @export
otn_search_contact <- function(contact, network = NULL) {
  .otn_search(network, type = "contact", search_term = contact)
}

#' Search OTN database by project country.
#'
#' @param country Character. Project country for which to search. DOES NOT support partial matching.
#' @inheritParams .otn_search
#' @export
otn_search_country <- function(country, network = NULL) {
  .otn_search(network, type = "country", search_term = country)
}

#' Search OTN database by project species
#'
#' @param species Character. Project species for which to search. DOES NOT
#'   support partial matching and only recognizes scientific names of the
#'   form "Genus species" (note capitalization).
#' @inheritParams .otn_search
#' @export
otn_search_species <- function(species, network = NULL) {
  .otn_search(network, type = "species", search_term = species)
}

#' Search OTN database by local node.
#'
#' @param node Character. OTN node for which to search. DOES NOT support partial matching.
#' @inheritParams .otn_search
#' @export
otn_search_node <- function(node, network = NULL) {
  .otn_search(network, type = "node", search_term = node)
}

#' Search OTN database by institution.
#'
#' @param institution Character. Institution for which to search. DOES NOT
#'   support partial matching.
#' @inheritParams .otn_search
#' @export
otn_search_institution <- function(institution, network = NULL) {
  .otn_search(network, type = "institutions", search_term = institution)
}
