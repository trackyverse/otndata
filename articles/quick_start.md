# Access for OTN nodes with a Plone CMS

You’ve just received notifications that your tag matches are in,
hooray!! Let’s walk through how to interact with all of your data.

``` r

library(otndata)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(arrow)
#> 
#> Attaching package: 'arrow'
#> The following object is masked from 'package:utils':
#> 
#>     timestamp
```

First, we need to log in. If you have never entered your username and
password before, you’ll need to do so. I’m an ACT member, so I’ll be
logging into my network. If you’re a member of a different network, just
switch in your network’s code. Run the following:

``` r

otn_login("act")
#> ✔ Login successful!
```

This will just set your credentials for the current R session. If you
wish to use the same credentials after closing/reopening R, use
`otn_set_credentials`:

``` r

otn_set_credentials("act")
```

It might be that you just want a high-level summary of what’s new.
`otndata` interfaces seamlessly with the [`otndo`
package](https://otndo.obrien.page) using
[`otn_receiver_summary`](https://otndata.obrien.page/reference/otn_receiver_summary.html)
or
[`otn_tag_summary`](https://otndata.obrien.page/reference/otn_tag_summary.html)
for receiver and tag projects, respectively.

``` r

otn_receiver_summary("tailwinds")
otn_tag_summary("mdbsb")
```

After this, you might want to dig a little further into all of the data
extract files on offer.

``` r

otn_extract_files(project = "tailwinds")
#>                                             name
#> 1  Detections Mapped to other Trackers (Parquet)
#> 2               Unqualified Detections (Parquet)
#> 3    tailwinds_qualified_detections_2023.parquet
#> 4       Detections Mapped to other Trackers 2023
#> 5    tailwinds_qualified_detections_2024.parquet
#> 6       Detections Mapped to other Trackers 2024
#> 7  tailwinds_unqualified_detections_2023.parquet
#> 8                    Unqualified Detections 2023
#> 9  tailwinds_unqualified_detections_2024.parquet
#> 10                   Unqualified Detections 2024
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         description
#> 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                  These detections have been mapped to animals released by other tracker projects.
#> 2  These are detections for which we do not know the owner. There may be several reasons for this. One: It is a test or sentinel tag and we have not been informed. Two: It is an ambiguous tag which means we have more than one set of tag metadata which the detection could belong to. Three: We have not received any release metadata for the tag. Four: It is an old style sensor tag and we have not been able to determine the associated pinger id, or even if there should be one, because we do not have the vendor tag specifications.
#> 3                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
#> 4                                                                                                                                                                                                                                                                                                                                                                                                                                                                   These detections have been mapped to animals released by othertracker projects.
#> 5                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
#> 6                                                                                                                                                                                                                                                                                                                                                                                                                                                                   These detections have been mapped to animals released by othertracker projects.
#> 7                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
#> 8  These are detections for which we do not know the owner. There may be several reasons for this. One: It is a test or sentinel tag and we have not been informed. Two: It is an ambiguous tag which means we have more than one set of tag metadata which the detection could belong to. Three: We have not received any release metadata for the tag. Four: It is an old style sensor tag and we have not been able to determine the associated pinger id, or even if there should be one, because we do not have the vendor tag specifications.
#> 9                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
#> 10 These are detections for which we do not know the owner. There may be several reasons for this. One: It is a test or sentinel tag and we have not been informed. Two: It is an ambiguous tag which means we have more than one set of tag metadata which the detection could belong to. Three: We have not received any release metadata for the tag. Four: It is an old style sensor tag and we have not been able to determine the associated pinger id, or even if there should be one, because we do not have the vendor tag specifications.
#>                                                                                                                          url
#> 1         https://data.theactnetwork.com/data/repository/tailwinds/detection-extracts/tailwinds_qualified_detections-parquet
#> 2       https://data.theactnetwork.com/data/repository/tailwinds/detection-extracts/tailwinds_unqualified_detections-parquet
#> 3    https://data.theactnetwork.com/data/repository/tailwinds/detection-extracts/tailwinds_qualified_detections_2023-parquet
#> 4        https://data.theactnetwork.com/data/repository/tailwinds/detection-extracts/tailwinds_qualified_detections_2023.zip
#> 5    https://data.theactnetwork.com/data/repository/tailwinds/detection-extracts/tailwinds_qualified_detections_2024-parquet
#> 6        https://data.theactnetwork.com/data/repository/tailwinds/detection-extracts/tailwinds_qualified_detections_2024.zip
#> 7  https://data.theactnetwork.com/data/repository/tailwinds/detection-extracts/tailwinds_unqualified_detections_2023-parquet
#> 8      https://data.theactnetwork.com/data/repository/tailwinds/detection-extracts/tailwinds_unqualified_detections_2023.zip
#> 9  https://data.theactnetwork.com/data/repository/tailwinds/detection-extracts/tailwinds_unqualified_detections_2024-parquet
#> 10     https://data.theactnetwork.com/data/repository/tailwinds/detection-extracts/tailwinds_unqualified_detections_2024.zip
#>                created            modified network creator
#> 1  2026-07-28 14:22:44 2026-07-28 14:22:47     ACT  otnbot
#> 2  2026-07-28 14:22:45 2026-07-28 14:22:48     ACT  otnbot
#> 3  2026-06-12 13:25:31 2026-06-12 13:25:31     ACT krichie
#> 4  2026-06-12 13:25:49 2026-07-28 14:22:45     ACT  otnbot
#> 5  2026-06-12 13:26:03 2026-06-12 13:26:03     ACT krichie
#> 6  2026-06-12 13:26:19 2026-07-28 14:22:47     ACT  otnbot
#> 7  2026-06-12 13:26:33 2026-06-12 13:26:33     ACT krichie
#> 8  2026-06-12 13:26:45 2026-07-28 14:22:46     ACT  otnbot
#> 9  2026-06-12 13:26:59 2026-06-12 13:26:59     ACT krichie
#> 10 2026-06-12 13:27:14 2026-07-28 14:22:48     ACT  otnbot
#>        size type
#> 1  347.2 KB File
#> 2  148.4 KB File
#> 3  133.0 KB File
#> 4   96.2 KB File
#> 5  174.2 KB File
#> 6  131.7 KB File
#> 7  602.3 KB File
#> 8   52.2 KB File
#> 9   62.7 KB File
#> 10  34.3 KB File
```

This can be a lot! We can just grab the files that have been modified
after a certain date – usually the date just before the most-recent data
push.

``` r

otn_extract_files(project = "tailwinds", since = "2026-07-28")
#>                                            name
#> 1 Detections Mapped to other Trackers (Parquet)
#> 2              Unqualified Detections (Parquet)
#> 3      Detections Mapped to other Trackers 2023
#> 4      Detections Mapped to other Trackers 2024
#> 5                   Unqualified Detections 2023
#> 6                   Unqualified Detections 2024
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        description
#> 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                 These detections have been mapped to animals released by other tracker projects.
#> 2 These are detections for which we do not know the owner. There may be several reasons for this. One: It is a test or sentinel tag and we have not been informed. Two: It is an ambiguous tag which means we have more than one set of tag metadata which the detection could belong to. Three: We have not received any release metadata for the tag. Four: It is an old style sensor tag and we have not been able to determine the associated pinger id, or even if there should be one, because we do not have the vendor tag specifications.
#> 3                                                                                                                                                                                                                                                                                                                                                                                                                                                                  These detections have been mapped to animals released by othertracker projects.
#> 4                                                                                                                                                                                                                                                                                                                                                                                                                                                                  These detections have been mapped to animals released by othertracker projects.
#> 5 These are detections for which we do not know the owner. There may be several reasons for this. One: It is a test or sentinel tag and we have not been informed. Two: It is an ambiguous tag which means we have more than one set of tag metadata which the detection could belong to. Three: We have not received any release metadata for the tag. Four: It is an old style sensor tag and we have not been able to determine the associated pinger id, or even if there should be one, because we do not have the vendor tag specifications.
#> 6 These are detections for which we do not know the owner. There may be several reasons for this. One: It is a test or sentinel tag and we have not been informed. Two: It is an ambiguous tag which means we have more than one set of tag metadata which the detection could belong to. Three: We have not received any release metadata for the tag. Four: It is an old style sensor tag and we have not been able to determine the associated pinger id, or even if there should be one, because we do not have the vendor tag specifications.
#>                                                                                                                     url
#> 1    https://data.theactnetwork.com/data/repository/tailwinds/detection-extracts/tailwinds_qualified_detections-parquet
#> 2  https://data.theactnetwork.com/data/repository/tailwinds/detection-extracts/tailwinds_unqualified_detections-parquet
#> 3   https://data.theactnetwork.com/data/repository/tailwinds/detection-extracts/tailwinds_qualified_detections_2023.zip
#> 4   https://data.theactnetwork.com/data/repository/tailwinds/detection-extracts/tailwinds_qualified_detections_2024.zip
#> 5 https://data.theactnetwork.com/data/repository/tailwinds/detection-extracts/tailwinds_unqualified_detections_2023.zip
#> 6 https://data.theactnetwork.com/data/repository/tailwinds/detection-extracts/tailwinds_unqualified_detections_2024.zip
#>               created            modified network creator     size
#> 1 2026-07-28 14:22:44 2026-07-28 14:22:47     ACT  otnbot 347.2 KB
#> 2 2026-07-28 14:22:45 2026-07-28 14:22:48     ACT  otnbot 148.4 KB
#> 3 2026-06-12 13:25:49 2026-07-28 14:22:45     ACT  otnbot  96.2 KB
#> 4 2026-06-12 13:26:19 2026-07-28 14:22:47     ACT  otnbot 131.7 KB
#> 5 2026-06-12 13:26:45 2026-07-28 14:22:46     ACT  otnbot  52.2 KB
#> 6 2026-06-12 13:27:14 2026-07-28 14:22:48     ACT  otnbot  34.3 KB
#>   type
#> 1 File
#> 2 File
#> 3 File
#> 4 File
#> 5 File
#> 6 File
```

The most important thing, however, is downloading those files! Let’s
grab the parquet files via `otn_extract_files`, download them with
`otn_download`, and create a mini-database for ourselves.

``` r

otn_extract_files(
  project = "tailwinds",
  text = "mapped parquet",
  since = "2026-07-28"
) |>
  otn_download(outdir = "./my_awesome_detections")
#> ℹ Directory created: ./my_awesome_detections.
#> ✔ 1 file(s) saved to '
```

Create a database on the fly using the [arrow
package](https://arrow.apache.org/docs/r).

``` r

my_db <- arrow::open_dataset("my_awesome_detections/")
my_db
#> FileSystemDataset with 1 Parquet file
#> 22 columns
#> basisOfRecord: string
#> institutionCode: string
#> collectionCode: string
#> dateLastModified: timestamp[ns, tz=UTC]
#> dateCollectedUTC: timestamp[ns, tz=UTC]
#> uncorrectedDateCollectedUTC: timestamp[ns, tz=UTC]
#> trackerCode: string
#> tagName: string
#> catalogNumber: string
#> station: string
#> receiverSerial: string
#> decimalLongitude: double
#> decimalLatitude: double
#> geodeticDatum: string
#> rcvrCatNumber: string
#> sensorType: string
#> sensorName: string
#> sensorRaw: double
#> geometry: binary
#> contactPI: string
#> ...
#> 2 more columns
#> Use `schema()` to see entire schema
#> 
#> See $metadata for additional Schema metadata
```

Now we can do some really quick summaries.

``` r

my_db |>
  dplyr::group_by(trackerCode) |>
  dplyr::tally() |>
  dplyr::arrange(-n) |>
  dplyr::collect()
#> # A tibble: 60 × 2
#>    trackerCode        n
#>    <chr>          <int>
#>  1 FACT.SCDNRGPD   1784
#>  2 ACT.LICABLE     1290
#>  3 ACT.SBUSOMAS01  1048
#>  4 ACT.MUFISH      1031
#>  5 ACT.HMSWEA       757
#>  6 ACT.NCATS2021    569
#>  7 ACT.MSRPWS       507
#>  8 ACT.SBUINGRAM    394
#>  9 ACT.MUEMPIRE     281
#> 10 ACT.MUS4F        246
#> # ℹ 50 more rows
```

Or find out who we should email and say “hi!”.

``` r

my_db |>
  dplyr::distinct(contactPI) |>
  dplyr::mutate(contactPI = sub(" \\(.*", "", contactPI)) |>
  head() |>
  dplyr::collect()
#> # A tibble: 6 × 1
#>   contactPI       
#>   <chr>           
#> 1 Gregory Skomal  
#> 2 Michael Frisk   
#> 3 Matthew Ogburn  
#> 4 Conor McManus   
#> 5 Bradley Peterson
#> 6 Evan Ingram
```
