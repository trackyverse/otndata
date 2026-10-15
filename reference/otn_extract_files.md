# List OTN extract files.

This function recursively lists files in the *Detection Extracts*
section of your project.

## Usage

``` r
otn_extract_files(
  project,
  text = NULL,
  since = NULL,
  batch_size = 25,
  network = NULL
)
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

- network:

  Character. Lowercase code of the desired telemetry network. One of
  "otn", "act", "atap", "itag", "migramar", "nep", "npact", "pirat", or
  "otn_devel" (the OTN development server). Note that "etn", "fact",
  "glatos", "path" and "raft" are accepted, but only to produce an error
  and redirect you.

## See also

[.otn_files](https://otndata.obrien.page/reference/dot-otn_files.md)
