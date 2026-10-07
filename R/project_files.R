#' Return files associated with an OTN project.
#'
#' @param project Character. The project code.
#' @param text Character. Text to search for in the file name/title. See Details
#'   for more information.
#' @param since Character. Filter for files modified since this date
#'   (YYYY-MM-DD format).
#' @param batch_size Numeric. The number of results to return. Defaults to 25.
#' @param type Character. Portion of the URL representing the data type you wish
#'   to return.
#'
#' @details
#' Filtering by \code{text} uses Plone's full-text search syntax rather than regular
#' expressions or glob patterns:
#' \itemize{
#'   \item \strong{Case Insensitivity:} Searching is case-insensitive.
#'   \item \strong{Word Matching:} Space-separated words (or elements in a character vector)
#'     are treated as an unordered \code{AND} search. For example, \code{"detections parquet"}
#'     or \code{c("detections", "parquet")} matches any title containing both words in any order.
#'   \item \strong{Partial Matching:} Use trailing wildcards (\code{*}) for word prefixes
#'     (e.g., \code{"det* parquet"}). Leading wildcards (e.g., \code{"*data"}) are not supported.
#'   \item \strong{Exact Phrases:} Wrap words in double quotes to require exact word ordering:
#'     \code{'"detections parquet"'} or \code{"\"detections parquet\""}.
#' }
#'
#' @keywords internal
#' @seealso
#'  * Plone REST API documentation:
#'    * [Querystring Search](https://6.docs.plone.org/plone.restapi/docs/source/endpoints/querystringsearch.html),
#'      triggered when using the "`text`" or "`since`" arguments.
#'      [Query operations are listed here.](https://6.docs.plone.org/plone.restapi/docs/source/endpoints/querystring.html).
#'    * [Search](https://6.docs.plone.org/plone.restapi/docs/source/endpoints/searching.html),
#'      a simpler search used when the "`text`" and "`since`" arguments are NULL.
.otn_files <- function(
  project,
  text = NULL,
  since = NULL,
  batch_size = NULL,
  type
) {
  is_logged_in()

  build_query <- function(text = NULL, since = NULL) {
    query <- list(
      list(
        i = "portal_type",
        o = "plone.app.querystring.operation.selection.any",
        v = "File"
      ),
      list(
        i = "path",
        o = "plone.app.querystring.operation.string.relativePath",
        v = "1"
      )
    )

    if (!is.null(text)) {
      query <- c(
        query,
        list(
          list(
            i = "Title",
            o = "plone.app.querystring.operation.string.contains",
            v = text
          )
        )
      )
    }

    if (!is.null(since)) {
      query <- c(
        query,
        list(
          list(
            i = "modified",
            o = "plone.app.querystring.operation.date.largerThan",
            v = since
          )
        )
      )
    }

    query
  }

  has_filters <- any(!is.null(since), !is.null(text))

  project_endpoint <- paste(
    "/data/repository",
    build_namespace(project),
    type,
    ifelse(
      has_filters,
      "@querystring-search",
      "@search"
    ),
    sep = "/"
  )

  plone_query <- function(has_filters, since, text, batch_size) {
    if (!has_filters) {
      project_endpoint |>
        .otn_api() |>
        httr2::req_url_query(
          portal_type = "File",
          b_size = batch_size,
          metadata_fields = c(
            "Creator",
            "created",
            "modified",
            "getURL",
            "id",
            "title"
          ),
          .multi = "explode"
        )
    } else {
      project_endpoint |>
        .otn_api() |>
        httr2::req_method("POST") |>
        httr2::req_body_json(
          list(
            query = build_query(
              text = text,
              since = since
            ),
            b_size = batch_size,
            metadata_fields = c(
              "Creator",
              "created",
              "modified",
              "getURL",
              "id",
              "title"
            )
          )
        )
    }
  }

  the_files <- plone_query(has_filters, since, text, batch_size) |>
    httr2::req_auth_bearer_token(otn_global$SESSION_TOKEN) |>
    httr2::req_perform() |>
    httr2::resp_body_json() |>
    _$items |>
    lapply(
      \(.) {
        t(.) |> as.data.frame()
      }
    ) |>
    do.call(rbind, args = _)

  # Clean up names
  # This was an opinionated selection by M. O'Brien. Query
  #   `metadata_fields = "_all"` above to see all that are available.
  the_files <- the_files[,
    c(
      "title",
      "description",
      "getURL",
      "created",
      "modified",
      "Creator",
      "getObjSize",
      "type_title"
    )
  ]

  the_names <- c(
    "name",
    "description",
    "url",
    "created",
    "modified",
    "creator",
    "size",
    "type"
  )

  if (is.null(the_files)) {
    the_files <- data.frame(matrix("", nrow = 0, ncol = length(the_names))) |>
      setNames(the_names)
  } else {
    the_files <- setNames(the_files, the_names)
  }

  # Up until now, the DF has had list columns
  the_files <- the_files |>
    lapply(unlist) |>
    data.frame()

  # Clean date-times
  convert_timestamps <- function(timestamp) {
    timestamp |>
      gsub("+00:00", "", x = _) |>
      as.POSIXct(tz = "UTC", format = "%FT%T")
  }

  the_files$created <- convert_timestamps(the_files$created)
  the_files$modified <- convert_timestamps(the_files$modified)

  return(the_files)
}

#' List OTN project files.
#'
#' This function lists the file names, types, upload date, and URLs of OTN
#' project files -- basically everything you see in the *Data and Metadata*
#' section of your project page. You will be prompted to log in if it is not a
#' public project.
#'
#' @inheritParams .otn_files
#' @seealso [.otn_files]
#' @export
otn_project_files <- function(
  project,
  text = NULL,
  since = NULL,
  batch_size = 25
) {
  .otn_files(
    project = project,
    text = text,
    since = since,
    batch_size = batch_size,
    type = "data-and-metadata"
  )
}

#' List OTN extract files.
#'
#' This function recursively lists files in the *Detection Extracts* section of
#' your project.
#'
#' @inheritParams .otn_files
#' @seealso [.otn_files]
#' @export
otn_extract_files <- function(
  project,
  text = NULL,
  since = NULL,
  batch_size = 25
) {
  .otn_files(
    project = project,
    text = text,
    since = since,
    batch_size = batch_size,
    type = "detection-extracts"
  )
}
