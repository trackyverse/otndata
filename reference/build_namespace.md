# Build project namespace

Most project files are saved under `/data/repository/{project}`. Some
networks, namely ATAP, MigraMar and NEP, are directly hosted by OTN and
so have their files saved under `/data/repository/{network}/{project}`.
This function does some light cleaning of the project code and adjusts
for these OTN-hosted networks.

## Usage

``` r
build_namespace(project, network = NULL)
```

## Arguments

- project:

  Character. The project code.

- network:

  Character. Lowercase code of the desired telemetry network. One of
  "otn", "act", "atap", "itag", "migramar", "nep", "npact", "pirat", or
  "otn_devel" (the OTN development server). Note that "etn", "fact",
  "glatos", "path" and "raft" are accepted, but only to produce an error
  and redirect you.
