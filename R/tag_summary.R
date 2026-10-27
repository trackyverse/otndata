#' Create summary reports of receiver project data from the OTN data push.
#'
#' @param project Project name that you wish to have summarized
#' @param matched Default is NULL: OTN matched detections in parquet format will
#'   be downloaded from the data server. If you do not wish to download your files
#'   or your node does not use an OTN-style Plone CMS, this argument also accepts
#'   a character vector of file paths of your matched detections. These can be
#'   parquet, CSVs, or zipped folders.
#' @param ... Arguments passed to \code{otndo::make_tag_push_summary}
#' @inheritParams .otn_server_url
#'
#' @export
#' @examples
#' \dontrun{
#' # You can just use your project name
#' otn_tag_summary("mdwea")
#'
#' # Or provide an optional date to summarize "What's New".
#' otn_tag_summary("mdwea", since = "2025-11-01")
#' }
otn_tag_summary <- function(
  project = NULL,
  matched = NULL,
  network = NULL,
  ...
) {
  if (all(is.null(project), is.null(matched))) {
    cli::cli_abort(
      "Must provide a project code or at least one set of OTN-matched data."
    )
  }

  # Project ----
  if (is.null(matched)) {
    network <- fix_null_network(network)
    server <- otn_global[[network]]$server_url

    if (is.null(server) & !is.null(network)) {
      server <- .otn_server_url(network, set = FALSE)
    }

    cli::cli_alert_info("Finding data extract files...")
    extract_files <- otn_extract_files(project = project)
    if (any(grepl(".*matched_detections.*parquet$", extract_files$url))) {
      cli::cli_alert_success("   Files found.")
    } else {
      cli::cli_abort("No matched detection parquet files detected.")
    }

    # Create a temporary directory to store intermediate files
    td <- file.path(tempdir(), "otn_files")
    dir.create(td)

    on.exit(unlink(td, recursive = TRUE), add = TRUE)

    matched <- otn_download(
      files = extract_files[
        grepl("matched_detections.*parquet$", extract_files$url),
      ],
      outdir = td
    )

    if (any(grepl("matched_external_partners", extract_files$url))) {
      cli::cli_alert_warning(
        "Files containing detections matched to external partners have been detected, but otndo does not currently support these files."
      )
    }
  }

  otndo::make_tag_push_summary(matched = matched, ...)
}
