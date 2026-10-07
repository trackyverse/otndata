# Return files associated with an OTN project.

Return files associated with an OTN project.

## Usage

``` r
.otn_files(project, text = NULL, since = NULL, batch_size = NULL, type)
```

## Arguments

- project:

  Character. The project code.

- text:

  Character. Text to search for in the file name/title. See Details for
  more information.

- since:

  Character. Filter for files modified since this date (YYYY-MM-DD
  format).

- batch_size:

  Numeric. The number of results to return. Defaults to 25.

- type:

  Character. Portion of the URL representing the data type you wish to
  return.

## Details

Filtering by `text` uses Plone's full-text search syntax rather than
regular expressions or glob patterns:

- **Case Insensitivity:** Searching is case-insensitive.

- **Word Matching:** Space-separated words (or elements in a character
  vector) are treated as an unordered `AND` search. For example,
  `"detections parquet"` or `c("detections", "parquet")` matches any
  title containing both words in any order.

- **Partial Matching:** Use trailing wildcards (`*`) for word prefixes
  (e.g., `"det* parquet"`). Leading wildcards (e.g., `"*data"`) are not
  supported.

- **Exact Phrases:** Wrap words in double quotes to require exact word
  ordering: `'"detections parquet"'` or `"\"detections parquet\""`.

## See also

- Plone REST API documentation:

  - [Querystring
    Search](https://6.docs.plone.org/plone.restapi/docs/source/endpoints/querystringsearch.html),
    triggered when using the "`text`" or "`since`" arguments. [Query
    operations are listed
    here.](https://6.docs.plone.org/plone.restapi/docs/source/endpoints/querystring.html).

  - [Search](https://6.docs.plone.org/plone.restapi/docs/source/endpoints/searching.html),
    a simpler search used when the "`text`" and "`since`" arguments are
    NULL.
