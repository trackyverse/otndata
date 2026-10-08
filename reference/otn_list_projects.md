# Retrieve OTN project list.

Retrieve OTN project list.

## Usage

``` r
otn_list_projects(network = "otn", what = c("all", "mine"))
```

## Arguments

- network:

  Character. Lowercase code of the desired telemetry network. One of
  "otn", "act", "atap", "itag", "migramar", "nep", "npact", "pirat", or
  "otn_devel" (the OTN development server). Note that "etn", "fact",
  "glatos", "path" and "raft" are accepted, but only to produce an error
  and redirect you.

- what:

  Which projects do you wish to see: `all` or `mine`? `all` can be
  viewed without logging in, but you must log in before viewing yours
  (well, `mine`).
