# Upload a file to the Plone CMS

Upload a file to the Plone CMS

## Usage

``` r
otn_upload(file_path, project, network = NULL)
```

## Arguments

- file_path:

  Character. Location of the file to be uploaded.

- project:

  Character. The project code.

- network:

  Character. Lowercase code of the desired telemetry network. One of
  "otn", "act", "atap", "itag", "migramar", "nep", "npact", "pirat", or
  "otn_devel" (the OTN development server). Note that "etn", "fact",
  "glatos", "path" and "raft" are accepted, but only to produce an error
  and redirect you.

## Value

Silently returns a vector of file locations.

## See also

- Plone REST API documentation:

  - [Content
    manipulation](https://6.docs.plone.org/plone.restapi/docs/source/usage/content.html)

  - [Deserialization](https://6.docs.plone.org/plone.restapi/docs/source/usage/serialization.html#upload-deserialization)
