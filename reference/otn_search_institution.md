# Search OTN database by institution.

Search OTN database by institution.

## Usage

``` r
otn_search_institution(institution, network = NULL)
```

## Arguments

- institution:

  Character. Institution for which to search. DOES NOT support partial
  matching.

- network:

  Character. Lowercase code of the desired telemetry network. One of
  "otn", "act", "atap", "itag", "migramar", "nep", "npact", "pirat", or
  "otn_devel" (the OTN development server). Note that "etn", "fact",
  "glatos", "path" and "raft" are accepted, but only to produce an error
  and redirect you.
