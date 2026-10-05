#' Download file(s) from an OTN-style Plone server.
#'
#' Either `files` or `url` must be provided. If `files` is provided, files in
#' the data.frame are downloaded in parallel.
#'
#' @param files a data.frame returned by by `otn_project_files` or
#'   `otn_extract_files`. Can have been filtered or edited, but must have columns
#'   of "url" and "name".
#' @param url The URL of the file as returned by `otn_project_files` or
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
otn_download <- function(files = NULL, url = NULL, outdir = '.') {
  is_logged_in()
  if (all(is.null(files), is.null(url))) {
    cli::cli_abort("Please provide one of `files` or `url`.")
  }

  build_request <- function(file_url) {
    file_url |>
      httr2::request() |>
      httr2::req_url_path_append("@@download/file") |>
      httr2::req_cookies_set(auth_token = otn_global$SESSION_TOKEN)
  }

  if (!dir.exists(outdir)) {
    dir.create(outdir)

    cli::cli_alert_info("Directory created: {outdir}.")
  }

  if (!is.null(files)) {
    out_path <- file.path(outdir, basename(files$url)) |>
      gsub("-parquet$", ".parquet", x = _) |>
      path.expand()

    responses <- lapply(
      files$url,
      function(x) {
        build_request(x) |>
          httr2::req_throttle(capacity = 2, fill_time_s = 1)
      }
    ) |>
      httr2::req_perform_parallel(
        paths = out_path,
        on_error = "continue"
      )

    cli::cli_alert_info("Files saved to {out_path}.")
  } else {
    # Download file to memory
    file_in_memory <- url |>
      build_request() |>
      httr2::req_perform()

    # Parse header to find file name
    cd_header <- file_in_memory |>
      httr2::resp_header("Content-Disposition")

    file_name <- gsub("attachment; filename\\*=UTF-8''", '', cd_header)

    out_path <- file.path(outdir, file_name)

    # Write file in memory to disk
    file_in_memory |>
      httr2::resp_body_raw() |>
      writeBin(con = out_path)

    cli::cli_alert_info("File saved to {out_path}.")
  }

  invisible(out_path)
}
