#' Download file(s) from an OTN-style Plone server.
#'
#' Either `files` or `url` must be provided. If `files` is provided, files in
#' the data.frame are downloaded in parallel.
#'
#' @param files a data.frame returned by by `otn_project_files` or
#'   `otn_extract_files`. Can have been filtered or edited, but must have columns
#'   of "url" and "name".
#' @param urls The URL of the file as returned by `otn_project_files` or
#'   `otn_extract_files`
#' @param outdir The output directory (where you want the file to be saved).
#'   Defaults to the current working directory.
#'
#' @returns Silently returns a vector of file locations.
#'
#' #' @seealso
#'  * Plone REST API documentation:
#'    * [Serialization](https://6.docs.plone.org/plone.restapi/docs/source/usage/serialization.html#download-serialization)
#' @export
otn_download <- function(files = NULL, urls = NULL, outdir = '.') {
  if (all(is.null(files), is.null(urls))) {
    cli::cli_abort("Please provide one of `files` or `urls`.")
  }
  if (all(!is.null(files), !is.null(urls))) {
    cli::cli_abort("Please provide only one of `files` or `urls`.")
  }

  build_request <- function(file_url, network) {
    request <- file_url |>
      httr2::request() |>
      httr2::req_url_path_append("@@download/file")

    token <- otn_global[[network]]$token
    if (!is.null(token)) {
      request <- request |>
        httr2::req_cookies_set(auth_token = token)
    }

    request |>
      httr2::req_throttle(capacity = 2, fill_time_s = 1)
  }

  # Helper function to check if HTML is returned (means a login is needed)
  is_html_file <- function(file_path, response = NULL) {
    # 1. Primary check: Plone returns Content-Type "text/html" for login pages
    if (!is.null(response) && inherits(response, "httr2_response")) {
      ct <- httr2::resp_header(response, "content-type", default = "")
      if (grepl("text/html", ct, ignore.case = TRUE)) {
        return(TRUE)
      }
    }

    # 2. Fallback check: Read first 5 lines using latin1 encoding to prevent multibyte errors
    if (file.exists(file_path) && file.info(file_path)$size > 0) {
      first_lines <- suppressWarnings(
        readLines(file_path, n = 5, encoding = "latin1", warn = FALSE)
      )
      if (
        any(grepl(
          "<html|<!doctype",
          first_lines,
          ignore.case = TRUE,
          useBytes = TRUE
        ))
      ) {
        return(TRUE)
      }
    }

    FALSE
  }

  if (!dir.exists(outdir)) {
    dir.create(outdir)

    cli::cli_alert_info("Directory created: {outdir}.")
  }

  if (!is.null(files)) {
    files <- files[, c("url", "network")]
    files$network <- tolower(files$network)
  }

  if (!is.null(urls)) {
    files <- data.frame(
      url = urls,
      network = .otn_network_from_url(urls)
    )
  }

  files$out_path <- file.path(outdir, basename(files$url)) |>
    gsub("-parquet$", ".parquet", x = _) |>
    path.expand()

  requests <- mapply(
    build_request,
    file_url = files$url,
    network = files$network,
    SIMPLIFY = FALSE
  )

  responses <- requests |>
    httr2::req_perform_parallel(
      paths = files$out_path,
      on_error = "continue"
    )

  # Unwrap underlying response object if httr2 returned an error object
  resp_status <- function(resp) {
    if (inherits(resp, "httr2_http")) {
      resp <- resp$resp
    } else if (inherits(resp, "error") && !is.null(resp$resp)) {
      resp <- resp$resp
    }

    if (inherits(resp, "httr2_response")) {
      httr2::resp_status(resp)
    } else {
      NA_integer_
    }
  }

  is_success <- mapply(
    function(resp, out_path, url, network) {
      status <- resp_status(resp)

      # Check if response returned HTML or unauthorized status
      is_html <- is_html_file(out_path, resp)

      if ((!is.na(status) && status %in% c(401, 403)) || is_html) {
        # Delete the local HTML artifact
        if (file.exists(out_path)) {
          file.remove(out_path)
        }

        if (is.null(otn_global[[network]]$token)) {
          cli::cli_warn(
            "'{url}' requires authentication. Please log into {toupper(network)}."
          )
        }
        return(FALSE)
      }

      status == 200
    },
    resp = responses,
    out_path = files$out_path,
    url = files$url,
    network = files$network,
    USE.NAMES = FALSE
  )

  file_locations <- files$out_path[is_success]

  if (length(file_locations) > 0) {
    cli::cli_alert_success(
      "{length(file_locations)} file(s) saved to {.path {file_locations}}."
    )
  } else {
    cli::cli_alert_danger("No files were downloaded.")
  }

  invisible(file_locations)
}
