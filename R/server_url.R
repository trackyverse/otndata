#' Get mapping of network codes to server URLs
#' @keywords utils internal
.otn_network_servers <- function() {
  c(
    otn = "https://members.oceantrack.org",
    atap = "https://members.oceantrack.org",
    migramar = "https://members.oceantrack.org",
    nep = "https://members.oceantrack.org",
    otn_devel = "https://members.devel.oceantrack.org",
    act = "https://data.theactnetwork.com",
    itag = "https://data.itagscience.com",
    npact = "https://plone.npact.aoos.org",
    pirat = "https://piratnetwork.org"
  )
}

#' Set the OTN Plone instance with which you wish to interact.
#'
#' @param network Character. Lowercase code of the desired telemetry network. One of
#'   "otn", "act", "atap", "itag", "migramar", "nep", "npact", "pirat", or
#'   "otn_devel" (the OTN development server). Note that "etn", "fact", "glatos",
#'   "path" and "raft" are accepted, but only to produce an error and redirect you.
#' @param set Set the network in the current session?
.otn_server_url <- function(
  network = c(
    "otn",
    "act",
    "atap",
    "itag",
    "migramar",
    "nep",
    "npact",
    "pirat",
    "otn_devel",
    "etn",
    "fact",
    "glatos",
    "path",
    "raft"
  ),
  set = TRUE
) {
  network <- rlang::arg_match(network)

  # Servers that don't exist and should error:
  switch(
    network,
    etn = cli::cli_abort(
      c(
        "ETN does not use an OTN-style Plone CMS.",
        "Check out the {.href [ETN R package](https://www.europeantrackingnetwork.org/en/etn-package)} instead."
      ),
    ),
    fact = cli::cli_abort("FACT does not use an OTN-style Plone CMS."),
    glatos = cli::cli_abort(
      c(
        "GLATOS does not use an OTN-style Plone CMS.",
        "Check out the {.href [glatos R package](https://ocean-tracking-network.r-universe.dev/glatos)} instead."
      )
    ),
    path = cli::cli_abort(
      c(
        "PATH does not have the Plone REST API activated.",
        "Work on this front is ongoing, so try again in a few months!"
      )
    ),
    raft = cli::cli_abort("RAFT does not use an OTN-style Plone CMS.")
  )

  server_url <- .otn_network_servers()[[network]]

  if (isTRUE(set)) {
    network_fixed <- ifelse(network == "atap", "saf", network)
    otn_global[[network_fixed]] <- list(
      server_url = server_url
    )
  }
  invisible(server_url)
}

#' Extract an OTN node code from a file's URL
#'
#' @param url The URL of a file on the Plone CMS
#' @keywords utils internal
.otn_network_from_url <- function(url) {
  servers <- .otn_network_servers()

  # Find matching network key by checking if URL starts with the base server URL
  network <- sapply(
    url,
    function(x) {
      matched <- names(servers)[sapply(servers, function(base) {
        grepl(paste0("^", base), x)
      })]

      if (length(matched) == 0) {
        cli::cli_abort("Could not determine telemetry network for URL: {x}")
      }

      matched
    },
    USE.NAMES = FALSE
  )

  # Standardize ATAP -> SAF if your otn_global key convention uses SAF
  network[network == "atap"] <- "saf"

  return(network)
}
