# Search OTN database by project species

Search OTN database by project species

## Usage

``` r
otn_search_species(species, network = NULL)
```

## Arguments

- species:

  Character. Project species for which to search. DOES NOT support
  partial matching and only recognizes scientific names of the form
  "Genus species" (note capitalization).

- network:

  Character. Lowercase code of the desired telemetry network. One of
  "otn", "act", "atap", "itag", "migramar", "nep", "npact", "pirat", or
  "otn_devel" (the OTN development server). Note that "etn", "fact",
  "glatos", "path" and "raft" are accepted, but only to produce an error
  and redirect you.
