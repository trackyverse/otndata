# Internal function to list small OTN databases.

Provides access to the data that is on the main OTN members page. Login
is only required for "my projects".

## Usage

``` r
.otn_list(network, type)
```

## Arguments

- network:

  Character. Lowercase code of the desired telemetry network. One of
  "otn", "act", "atap", "itag", "migramar", "nep", "npact", "pirat", or
  "otn_devel" (the OTN development server). Note that "etn", "fact",
  "glatos", "path" and "raft" are accepted, but only to produce an error
  and redirect you.

- type:

  Character. Internal data base to retrieve.
