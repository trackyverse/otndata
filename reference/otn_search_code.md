# Search OTN database by project code.

Search OTN database by project code.

## Usage

``` r
otn_search_code(code, network = NULL)
```

## Arguments

- code:

  Character. Project code for which to search. Supports partial
  matching.

- network:

  Character. Lowercase code of the desired telemetry network. One of
  "otn", "act", "atap", "itag", "migramar", "nep", "npact", "pirat", or
  "otn_devel" (the OTN development server). Note that "etn", "fact",
  "glatos", "path" and "raft" are accepted, but only to produce an error
  and redirect you.
