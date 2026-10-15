#' Create summary reports of receiver project data from the OTN data push.
#'
#' @param qualified,unqualified Default is NULL: OTN qualified or unqualified
#'   detections in parquet format will be downloaded from the data server. This
#'   argument also accepts a character vector of file paths of your
#'   qualified/unqualified detections if you do not wish to download your files
#'   or your node does not use an OTN-style Plone CMS.
#' @param deployment File path of user-supplied master OTN receiver deployment metadata.
#' @param ... Arguments passed to \code{otndo::make_receiver_push_summary}
#' @inheritParams otn_extract_files project
#'
#' @section No files provided:
#'
#'  If you only provide your project code and leave all of the arguments as their
#'  defaults, this function will ask you to log in then proceed to download all
#'  of the necessary files. You can speed up this process substantially by
#'  providing already-downloaded files.
#'
#' @section Output:
#'
#'  This function creates an HTML report that can be viewed in your web browser.
#'
#' @export
#' @examples
#' \dontrun{
#' # Using only the project code:
#' otn_receiver_summary("tailwinds")
#'
#' # Providing a local file:
#' otn_receiver_summary("tailwinds", deployment = "my_master_deployment_metadata.xlsx")
#'
#' # Get a summary fo what has changed since a particular date:
#' otn_receiver_summary("tailwinds", since = "2022-05-01")
#' }
otn_receiver_summary <- function(
  project = NULL,
  qualified = NULL,
  unqualified = NULL,
  deployment = NULL,
  network = NULL,
  ...
) {
  if (
    is.null(project) &
      any(is.null(qualified), is.null(unqualified), is.null(deployment))
  ) {
    cli::cli_abort(
      "Must provide a project code or at least one each of qualified detections,
      unqualified detections, and deployment."
    )
  }

  # Create a temporary directory to store intermediate files
  td <- file.path(tempdir(), "otn_files")
  dir.create(td)

  on.exit(unlink(td, recursive = TRUE), add = TRUE)

  # Project ----
  if (any(is.null(qualified), is.null(unqualified))) {
    network <- fix_null_network(network)
    is_logged_in(network)

    cli::cli_alert_info("Finding data extract files...")
    extract_files <- otn_extract_files(project = project, network = network)
    if (any(grepl(".*parquet$", extract_files$url))) {
      cli::cli_alert_success("   Files found.")
    } else {
      cli::cli_abort("No parquet files detected.")
    }

    # Qualified detections ----
    ##  Download qualified detections in parquet format if not provided
    if (is.null(qualified)) {
      qualified <- otn_download(
        files = extract_files[
          grepl("_qualified.*parquet$", extract_files$url),
        ],
        outdir = td
      )
    }

    # Unqualified detections ----
    ##  Download unqualified detections in parquet format if not provided
    if (is.null(unqualified)) {
      unqualified <- otn_download(
        files = extract_files[
          grepl("_unqualified.*parquet$", extract_files$url),
        ],
        outdir = td
      )
    }
  }

  # Deployment log ----
  ##  Download deployment metadata if not provided
  if (is.null(deployment)) {
    project_files <- otn_project_files(project = project, network = network)

    deployment <- otn_download(
      files = project_files[
        grepl(
          # find files that contain "deployment" but ARE NOT .txt files (i.e.
          #   the project metadata)
          "^(?=.*(?:deployment|instrument|receiver))(?!.*\\.txt$).+$",
          project_files$name,
          ignore.case = TRUE,
          perl = TRUE
        ),
      ],
      outdir = td
    )
  }

  otndo::make_receiver_push_summary(
    qualified = qualified,
    unqualified = unqualified,
    deployment = deployment,
    ...
  )
}
