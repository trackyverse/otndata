#' Internal function to list small OTN databases.
#'
#' Provides access to the data that is on the main OTN members page. Login is
#'   only required for "my projects".
#'
#' @param type Character. Internal data base to retrieve.
#' @inheritParams .otn_server_url network
#'
#' @keywords internal
.otn_list <- function(network, type) {
  endpoint <- switch(
    type,
    all_projects = "projects.json",
    my_projects = "project_root.json",
    contacts = "all_contacts.json",
    countries = "active_countries.json",
    species = "all_species.json",
    institutions = "all_institutions.json",
    stats = "header_stats.json"
  )

  if (type == "my_projects") {
    is_logged_in()

    query <- endpoint |>
      .otn_api(server = .otn_server_url(network, set = FALSE)) |>
      httr2::req_auth_bearer_token(otn_global$SESSION_TOKEN)
  } else {
    query <- endpoint |>
      .otn_api(server = .otn_server_url(network, set = FALSE))
  }

  query |>
    httr2::req_perform() |>
    httr2::resp_body_json(simplifyVector = TRUE)
}

#' Retrieve OTN contact list.
#'
#' @inheritParams .otn_list
#' @export
otn_list_contacts <- function(network = "otn") {
  .otn_list(network, "contacts")
}

#' Retrieve OTN country list.
#'
#' @inheritParams .otn_list
#' @export
otn_list_countries <- function(network = "otn") {
  .otn_list(network, "countries")
}

#' Retrieve OTN species list.
#'
#' @inheritParams .otn_list
#' @export
otn_list_species <- function(network = "otn") {
  .otn_list(network, "species")
}

#' Retrieve OTN institution list.
#'
#' @inheritParams .otn_list
#' @export
otn_list_institutions <- function(network = "otn") {
  .otn_list(network, "institutions")
}

#' Retrieve OTN project list.
#'
#' @param what Which projects do you wish to see: `all` or `mine`? `all` can be
#'   viewed without logging in, but you must log in before viewing yours (well, `mine`).
#' @inheritParams .otn_list
#' @export
otn_list_projects <- function(network = "otn", what = c("all", "mine")) {
  what <- rlang::arg_match(what)

  if (what == "mine") {
    resp <- .otn_list(network, "my_projects") |>
      _[[1]][["projects"]][[1]]

    data.frame(
      node = toupper(network),
      collectioncode = toupper(resp$id),
      shortname = gsub(".*- (.*) -.*", "\\1", resp$text),
      longname = resp$a_attr$title,
      url = paste0(
        .otn_server_url(network, set = FALSE),
        resp$a_attr$href
      )
    )
  } else {
    .otn_list(network, "all_projects")
  }
}

#' Retrieve OTN network statistics.
#'
#' @inheritParams .otn_list
#' @export
otn_list_stats <- function(network = "otn") {
  .otn_list(network, "stats")
}
