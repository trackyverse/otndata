#' Upload a file to the Plone CMS
#'
#' @param file_path Character. Location of the file to be uploaded.
#' @inheritParams .otn_files project
#' @returns Silently returns a vector of file locations.
#' @importFrom stats runif
#'
#' @seealso
#'  * Plone REST API documentation:
#'    * [Content manipulation](https://6.docs.plone.org/plone.restapi/docs/source/usage/content.html)
#'    * [Deserialization](https://6.docs.plone.org/plone.restapi/docs/source/usage/serialization.html#upload-deserialization)
otn_upload <- function(file_path, project) {
  is_logged_in()

  # Fail quickly if file is too large
  file_size <- file.info(file_path)$size
  size_check <- file_size > 5e8
  if (any(size_check)) {
    if (all(size_check)) {
      cli::cli_abort(
        c(
          "File{?s} larger than 500MB: {.val {file_path[size_check]}}.",
          "i" = "Contact your node manager or {.href 
      [group your data into multiple, smaller, zipped folders and upload these](https://members.oceantrack.org/faq#can-i-upload-big-files-to-the-otn-data-portal)}."
        )
      )
    } else {
      cli::cli_inform(
        c(
          "x" = "File{?s} larger than 500MB: {.val {file_path[size_check]}}.",
          "i" = "Contact your node manager or {.href 
      [group your data into multiple, smaller, zipped folders and upload these](https://members.oceantrack.org/faq#can-i-upload-big-files-to-the-otn-data-portal)}.",
          "i" = "Upload of the following file{?s} will continue: {.val {file_path[!size_check]}}"
        )
      )

      file_path <- file_path[!size_check]
      file_size <- file_size[!size_check]
    }
  }

  project_endpoint <- paste(
    "/data/repository",
    build_namespace(project),
    "to-be-filed",
    sep = "/"
  )

  mime_type <- mime::guess_type(file_path)
  file_name <- basename(file_path)

  requests <- Map(
    function(file_path, file_name, mime_type, file_size) {
      is_image <- grepl("image", mime_type)

      payload <- list(
        `@type` = ifelse(is_image, "Image", "File"),
        title = file_name
      )
      file_payload <- list(
        data = readBin(file_path, "raw", file_size),
        encoding = "base64",
        filename = file_name,
        `content-type` = mime_type
      )
      if (is_image) {
        payload$image <- file_payload
      } else {
        payload$file <- file_payload
      }

      project_endpoint |>
        .otn_api() |>
        httr2::req_headers(Accept = "application/json") |>
        httr2::req_auth_bearer_token(otn_global$SESSION_TOKEN) |>
        httr2::req_body_json(payload) |>
        httr2::req_throttle(capacity = 2, fill_time_s = 1) |>
        # Plone can return 500 (Plone "ConflictError") if two files are received
        # at the same time. This allows us to back off and retry the failed file.
        httr2::req_retry(
          # Let httr2 know that 500 should trigger a re-try.
          max_tries = 2,
          is_transient = \(resp) httr2::resp_status(resp) == 500,
          backoff = \(iter) 2^iter * 0.1 + runif(1, 0, 0.1)
        )
    },
    file_path,
    file_name,
    mime_type,
    file_size
  )

  if (length(requests) == 1) {
    responses <- httr2::req_perform(requests[[1]])
  } else {
    responses <- httr2::req_perform_parallel(
      requests,
      on_error = "return",
      max_active = 3
    )
  }

  location <- sapply(responses, httr2::resp_header, 'Location')

  if (all(sapply(responses, httr2::resp_status) == 201)) {
    cli::cli_alert_success(
      "File{?s} successfully uploaded to {.href {location}}"
    )

    invisible(location)
  }
}
