#' Authenticate to an Ocean Tracking Network server.
#'
#' This function prompts you for the username and password associated with
#' your OTN account. This is necessary so that you may interface with any
#' project-specific files.
#'
#' A pop up will appear asking for your username and password. If everything works
#' out, a token is written to the "SESSION_TOKEN" variable in the `otn_global` environment.
#' Your username/password will not be saved -- this was done intentionally so
#' that you don't accidentally save credentials in a public script.
#'
#' @inheritParams .otn_server_url
#' @seealso
#'  * [otn_set_credentials]
#'  * Plone REST API documentation:
#'    * [Authentication](https://6.docs.plone.org/plone.restapi/docs/source/usage/authentication.html)
#' @export

otn_login <- function(
  network = NULL
) {
  .otn_server_url(network)

  creds <- c(
    login = Sys.getenv(paste("OTN_USER", network, sep = ".")),
    pass = Sys.getenv(paste("OTN_PASS", network, sep = "."))
  )

  if (any(creds == "")) {
    cli::cli_alert_warning("Credentials missing")
    otn_set_credentials(network, temporary = TRUE)

    creds <- c(
      login = otn_global[[paste("OTN_USER", network, sep = ".")]],
      pass = otn_global[[paste("OTN_PASS", network, sep = ".")]]
    )
  }

  login_request <- "@login" |>
    .otn_api() |>
    httr2::req_body_json(
      list(
        login = creds["login"],
        password = creds["pass"]
      )
    )

  withCallingHandlers(
    login_response <- login_request |>
      httr2::req_perform() |>
      httr2::resp_body_json(),
    httr2_http_401 = function(cnd) {
      rlang::abort("Login failed. Check the supplied credentials", parent = cnd)
    }
  )

  cli::cli_alert_success("Login successful!")
  otn_global$SESSION_TOKEN <- login_response$token
}

#' Installs your OTN username and password in your \code{.Renviron} file for repeated use.
#'
#' @description
#'   This code was adapted from \href{https://github.com/walkerke/tidycensus/blob/ddb33b5f72734a4ff14332bd55cbac4850688600/R/helpers.R}{\code{tidycensus::census_api_key}}.
#'   Note that this saves your credentials in your .Renviron, meaning that anyone
#'   who is using your computer can theoretically access your username and password.
#'   So... use this carefully!
#'
#' @param temporary Logical. Scrub credentials after the current session?
#' @param overwrite Logical. Overwrite previously-stored credentials?
#' @inheritParams .otn_server_url
#'
#' @export
#' @examples
#' \dontrun{
#' otn_set_credentials("act")
#' }
#' # Yup, that's it!
otn_set_credentials <- function(network, temporary = FALSE, overwrite = FALSE) {
  username <- askpass::askpass("Username: ")
  password <- askpass::askpass("Password: ")

  if (isTRUE(temporary)) {
    # Write to otn_global environment
    otn_global[[paste("OTN_USER", network, sep = ".")]] <- username
    otn_global[[paste("OTN_PASS", network, sep = ".")]] <- password
  } else {
    home <- Sys.getenv("HOME")
    renv_path <- file.path(home, ".Renviron")

    if (!file.exists(renv_path)) {
      file.create(renv_path)
    }

    renv <- readLines(renv_path)

    if (
      any(
        grepl(paste0("OTN.*", network), renv),
        grepl(paste0("OTN.*", network), Sys.getenv())
      ) &&
        overwrite == F
    ) {
      cli::cli_abort(
        "Some credentials for that server already exist. You can overwrite them
        with the argument `overwrite=TRUE`."
      )
    }

    # Append credentials to .Renviron file
    write(
      paste0("OTN_USER.", network, "='", username, "'"),
      renv_path,
      sep = "\n",
      append = TRUE
    )
    write(
      paste0("OTN_PASS.", network, "='", password, "'"),
      renv_path,
      sep = "\n",
      append = TRUE
    )

    cli::cli_alert_info(
      'Your OTN credentials have been stored in your .Renviron and can be accessed
      by Sys.getenv("OTN_USER.{network}") or Sys.getenv("OTN_PASS.{network}").
      \nTo use now, restart R or run `readRenviron("~/.Renviron")`.'
    )
  }
}
