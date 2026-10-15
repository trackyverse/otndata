#' Build project namespace
#'
#' Most project files are saved under `/data/repository/{project}`.
#' Some networks, namely ATAP, MigraMar and NEP, are directly hosted by OTN and
#' so have their files saved under `/data/repository/{network}/{project}`. This
#' function does some light cleaning of the project code and adjusts for these
#' OTN-hosted networks.
#'
#' @inheritParams .otn_files
#' @inheritParams .otn_server_url
#' @keywords utils internal
build_namespace <- function(project, network = NULL) {
  network <- fix_null_network(network)

  # Project codes need to be lower case as we're essentially just matching the url
  project <- tolower(project)

  # ATAP (formerly SAF), MigraMar, and NEP data are hosted on the OTN instance under
  # /data/repository/{network}/{project}
  if (network %in% c("migramar", "nep", "saf")) {
    project <- paste(network, project, sep = "/")
  }

  return(project)
}

#' Autofill network if only logged into one network
#'
#' @inheritParams .otn_server_url network
#' @keywords utils internal
fix_null_network <- function(network) {
  if (is.null(network)) {
    if (length(otn_global) == 1) {
      network <- names(otn_global)
    } else {
      cli::cli_abort("Please specify a network.")
    }
  }

  network
}

#' Check if user is logged in
#'
#' Checks for the presence of a session token in the session environment, erroring
#' if one does not exist.
#'
#' @inheritParams .otn_server_url network
#' @keywords utils internal
is_logged_in <- function(network) {
  if (is.null(otn_global[[network]]$token)) {
    cli::cli_abort("Please log into the {network} data portal.")
  }
}
