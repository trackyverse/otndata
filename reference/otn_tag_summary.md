# Create summary reports of receiver project data from the OTN data push.

Create summary reports of receiver project data from the OTN data push.

## Usage

``` r
otn_tag_summary(project = NULL, matched = NULL, network = NULL, ...)
```

## Arguments

- project:

  Project name that you wish to have summarized

- matched:

  Default is NULL: OTN matched detections in parquet format will be
  downloaded from the data server. If you do not wish to download your
  files or your node does not use an OTN-style Plone CMS, this argument
  also accepts a character vector of file paths of your matched
  detections. These can be parquet, CSVs, or zipped folders.

- network:

  Character. Lowercase code of the desired telemetry network. One of
  "otn", "act", "atap", "itag", "migramar", "nep", "npact", "pirat", or
  "otn_devel" (the OTN development server). Note that "etn", "fact",
  "glatos", "path" and "raft" are accepted, but only to produce an error
  and redirect you.

- ...:

  Arguments passed to
  [`otndo::make_tag_push_summary`](https://otndo.obrien.page/reference/make_tag_push_summary.html)

## Examples

``` r
if (FALSE) { # \dontrun{
# You can just use your project name
otn_tag_summary("mdwea")

# Or provide an optional date to summarize "What's New".
otn_tag_summary("mdwea", since = "2025-11-01")
} # }
```
