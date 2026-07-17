#' Build project namespace
#'
#' Most project files are saved under `/data/repository/{project}`.
#' Some networks, namely ATAP, MigraMar and NEP, are directly hosted by OTN and
#' so have their files saved under `/data/repository/{network}/{project}`. This
#' function does some light cleaning of the project code and adjusts for these
#' OTN-hosted networks.
#'
#' @inheritParams .otn_files project
#' @keywords utils internal
build_namespace <- function(project) {
  # Project codes need to be lower case as we're essentially just matching the url
  project <- tolower(project)

  # ATAP (formerly SAF), MigraMar, and NEP data are hosted on the OTN instance under
  # /data/repository/{network}/{project}
  if (isTRUE(otn_global$network %in% c("migramar", "nep", "saf"))) {
    project <- paste(otn_global$network, project, sep = "/")
  }

  return(project)
}

#' Check if user is logged in
#'
#' Checks for the presence of a session token in the session environment, erroring
#' if one does not exist.
#'
#' @keywords utils internal
is_logged_in <- function() {
  if (is.null(otn_global$SESSION_TOKEN)) {
    cli::cli_abort("Please log into the data portal.")
  }
}
