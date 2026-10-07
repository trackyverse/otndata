
<!-- README.md is generated from README.Rmd. Please edit that file -->

# otndata

<!-- badges: start -->

<!-- badges: end -->

`otndata` is a wrapper around the Ocean Tracking Network’s Plone content
management system. The following data portals are nominally supported,
though some things might not work depending on the optional add-ons used
by the various networks. Because of this, [bug reports are really,
really, *really*
appreciated](https://github.com/trackyverse/otndata/issues)!!

- [Atlantic Cooperative Telemetry Network
  (ACT)](https://data.theactnetwork.com)
- [Integrated Tracking of Aquatic Animals in the Gulf
  (iTAG)](https://data.itagscience.com)
- [Northeast Pacific Acoustic Telemetry Network
  (N-PAcT)](https://plone.npact.aoos.org)
- [Ocean Tracking Network (OTN)](https://members.oceantrack.org), which
  also includes:
  - Acoustic Tracking Array Platform (ATAP)
  - MigraMar
  - Northeast Pacific (NEP)
- [Ocean Tracking Network’s development
  server](https://members.devel.oceantrack.org)
- [Pacific Islands Region Acoustic Telemetry Network
  (PIRAT)](https://piratnetwork.org)

The following networks are not supported for various reasons:

- [Pacific Aquatic Telemetry Hub
  (PATH)](https://fishdb.wfcb.ucdavis.edu): PATH will be supported
  following an update to their version of Plone in the next few months.
- [European Tracking Network (ETN)](https://www.lifewatch.be/etn): ETN
  does not use a Plone CMS; see the [etn R
  package](https://inbo.github.io/etn) for programmatic access.
- [Great Lakes Acoustic Telemetry Observing System
  (GLATOS)](https://glatos.org/portal): GLATOS does not use a Plone CMS
  or have a tool for programmatic access to their data portal; see the
  [glatos R package](https://github.com/ocean-tracking-network/glatos)
  for data import, visualization, and analysis tools.
- [FACT](https://secoora.org/fact) and the [Riverine Acoustic Fish
  Telemetry Network (RAFT)](https://umesc-gisdb03.er.usgs.gov/raft) do
  not use a Plone CMS or have a tool for programmatic access to their
  data portal.

## Installation

You can install the development version of otndata from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("trackyverse/otndata")
```

## Search project metadata

There are a few things that can be accessed without logging in. Most
nodes come pre-baked with a statistics widget and a project map:

![](man/figures/README-widget.png)

If this widget is enabled, you can access the information shown without
needing to log in.

``` r
library(otndata)

# OTN's server (default)
otn_list_species() |>
  head()
#>           scientificname           commonname
#> 1          Abramis brama                bream
#> 2 Acanthocybium solandri                wahoo
#> 3             Acanthurus       Chirurgien sp.
#> 4    Acanthurus bahianus       cirujano pardo
#> 5     Acanthurus blochii ringtail surgeonfish
#> 6   Acanthurus chirurgus           doctorfish

# Try a different server
otn_list_projects(network = "act") |>
  head()
#>   node collectioncode country longitude latitude
#> 1  ACT        NJWPEFH     USA -75.46144 39.60147
#> 2  ACT     SBUSOMASCO     USA -73.67922 40.47010
#> 3  ACT        NJDEPSB     USA -74.26016 39.60989
#> 4  ACT          WTAPS     USA -76.21810 37.34658
#> 5  ACT     ASIPORBEAG     USA -73.81850 38.07050
#> 6  ACT         SBURAA     USA -73.81850 38.07050
#>                               shortname
#> 1        AKRF Sand-Wave Habitat Phase 1
#> 2 Dusky Shark Habitat Use and Migration
#> 3                   NJ DEP striped bass
#> 4                      WTAPS Blue Crabs
#> 5           ASI - Porbeagle Shark Study
#> 6                  SBU HRF Sturgeon RAA
#>                                                                                                                                                       longname
#> 1 Compensatory Mitigation for the Loss of Sand-Wave Habitat due to Dredging at the New Jersey Wind Port – Phase 1 - at Artificial Island on the Delaware River
#> 2                                                                                                                        Dusky Shark Habitat Use and Migration
#> 3                                                                     Spatial and temporal movements of Atlantic striped bass (Morone saxatilis) in New Jersey
#> 4                                                          Blue Crab Overwintering and placement of dredge material in the Wolf Trap Alternate Placement Site.
#> 5                                                                                  This study involves the porbeagle shark in New England and adjacent waters.
#> 6                                                 Defining the ecological and conservation importance of the Rockaway Atlantic Sturgeon aggregation area (RAA)
#>         ocean                               website datacenter_infourl
#> 1 NW ATLANTIC                                  <NA>                 NA
#> 2 NW ATLANTIC                                  <NA>                 NA
#> 3 NW ATLANTIC                                  <NA>                 NA
#> 4 NW ATLANTIC                                  <NA>                 NA
#> 5 NW ATLANTIC http://www.atlanticsharkinstitute.org                 NA
#> 6 NW ATLANTIC                                  <NA>                 NA
#>                                           institutionname
#> 1                                               AKRF Inc.
#> 2                                  Stony Brook University
#> 3       New Jersey Department of Environmental Protection
#> 4 University of Maryland Center for Environmental Science
#> 5                                Atlantic Shark Institute
#> 6                                  Stony Brook University

otn_list_stats(network = "otn_devel")
#> $project_count
#> [1] 1718
#> 
#> $contributor_count
#> [1] 2583
#> 
#> $inst_count
#> [1] 491
#> 
#> $species_count
#> [1] 476
#> 
#> $rcvr_count
#> [1] 3529
```

You can also query projects according to code, country of origin,
species, institution, node, or point of contact.

``` r
otn_search_node("ACT") |>
  head()
#>   node collectioncode country longitude latitude
#> 1  ACT        CTR0204     USA -72.64802 42.20387
#> 2  ACT          CBASR     USA -76.51859 38.88313
#> 3  ACT          CBCRP     USA -76.54500 38.88000
#> 4  ACT       MDWEAMAM     USA -73.81850 38.07050
#> 5  ACT        DEARRAY     USA -73.81500 38.07000
#> 6  ACT       SBUEPSRW     USA -73.81850 38.07050
#>                                shortname
#> 1          CT River Sturgeon (2002-2004)
#> 2           SERC Atlantic Stingray Study
#> 3                 SERC Common Carp Study
#> 4    UMCES BOEM Marine Mammal Monitoring
#> 5 Delaware Division of Fish and Wildlife
#> 6                            SBU Eco-Pod
#>                                                                                                                               longname
#> 1                                                                    Seasonal Movements of Shortnose Sturgeon in the Connecticut River
#> 2                                                                                          Atlantic Stingray Habitat Use and Migration
#> 3                                                                                           Common Carp Habitat Use in Chesapeake Bay.
#> 4 Add-on to: Determining Habitat Use by Marine Mammals and Ambient Noise Levels Using Passive Acoustic Monitoring Offshore of Maryland
#> 5                                               Delaware Division of Fish and Wildlife, Delaware Estuary Acoustic Telemetry Monitoring
#> 6                                                Monitoring copepod prey abundances using bottom-mounted, upward-looking echosounders.
#>         ocean                                                  website
#> 1 NW ATLANTIC                                                     <NA>
#> 2 NW ATLANTIC                                                     <NA>
#> 3 NW ATLANTIC                                                     <NA>
#> 4 NW ATLANTIC https://espis.boem.gov/final%20reports/BOEM_2019-018.pdf
#> 5 NW ATLANTIC                                                     <NA>
#> 6 NW ATLANTIC                                                     <NA>
#>              datacenter_infourl
#> 1 https://matos.asascience.com/
#> 2 https://matos.asascience.com/
#> 3 https://matos.asascience.com/
#> 4 https://matos.asascience.com/
#> 5 https://matos.asascience.com/
#> 6 https://matos.asascience.com/

# This accepts partial matches
otn_search_code("tail")
#>   node collectioncode country longitude latitude       shortname
#> 1  ACT      TAILWINDS     USA  -73.8185  38.0705 UMCES TailWinds
#>                                                                                longname
#> 1 TailWinds: Team for Assessing Impacts to Living resources from offshore WIND turbineS
#>         ocean                      website            datacenter_infourl
#> 1 NW ATLANTIC https://tailwinds.umces.edu/ https://matos.asascience.com/

# This does not accept partial matches
otn_search_contact("Mike O'Brien")
#>   node collectioncode country longitude latitude
#> 1  ACT         CBBBMB     USA  -73.8150  38.0700
#> 2  ACT      TAILWINDS     USA  -73.8185  38.0705
#> 3  ACT         MAMBON     USA  -73.8185  38.0705
#> 4  ACT       NAVYKENN     USA  -69.7800  43.7750
#>                            shortname
#> 1 UMCES Chesapeake Backbone, Mid-Bay
#> 2                    UMCES TailWinds
#> 3                  Mid-Atlantic MBON
#> 4   Navy Kennebec ME Telemetry Array
#>                                                                                         longname
#> 1                            Building a Mainstem Chesapeake Bay Telemetry Array: Mid-Bay Segment
#> 2          TailWinds: Team for Assessing Impacts to Living resources from offshore WIND turbineS
#> 3                Mid-Atlantic MBON: Dynamic Biodiversity and Telemetry Data for a Changing Coast
#> 4 Naval Undersea Warfare Center (NUWC) Kennebec River and Offshore Acoustic Telemetry Monitoring
#>         ocean                                          website
#> 1 NW ATLANTIC                                             <NA>
#> 2 NW ATLANTIC                     https://tailwinds.umces.edu/
#> 3 NW ATLANTIC https://marinebon.org/us-mbon/mid-atlantic-mbon/
#> 4 NW ATLANTIC                                             <NA>
#>              datacenter_infourl
#> 1 https://matos.asascience.com/
#> 2 https://matos.asascience.com/
#> 3 https://matos.asascience.com/
#> 4 https://matos.asascience.com/
```

## Logging in

You’ll need to log in to access other parts of the CMS using
`otn_login`. This package is meant to interface with any node’s Plone
instance. You can switch between them using the `network` argument.

``` r
otn_login(network = 'act')
#> ✔ Login successful!
```

If you don’t wish to enter your username and password every time, you
can set the credentials for your system using the `otn_set_credentials`
helper function.

``` r
otn_set_credentials("act")
otn_login("act")
```

## Listing project files

List your project’s files:

``` r
otn_project_files(project = 'tailwinds', batch_size = 5)
#>                                            name description
#> 1        tailwinds_master_metadata_20240812.csv            
#> 2     tailwinds_metadata_deployment_202411.xlsx            
#> 3        tailwinds_otn_metadata_deployment.xlsx            
#> 4 tailwinds_otn_metadata_deployment_202404.xlsx            
#> 5                   VR2AR_546307_20240425_1.vrl            
#>                                                                                                                                          url
#> 1        https://data.theactnetwork.com/data/repository/tailwinds/data-and-metadata/receiver-metadata/tailwinds_master_metadata_20240812.csv
#> 2     https://data.theactnetwork.com/data/repository/tailwinds/data-and-metadata/receiver-metadata/tailwinds_metadata_deployment_202411.xlsx
#> 3        https://data.theactnetwork.com/data/repository/tailwinds/data-and-metadata/receiver-metadata/tailwinds_otn_metadata_deployment.xlsx
#> 4 https://data.theactnetwork.com/data/repository/tailwinds/data-and-metadata/receiver-metadata/tailwinds_otn_metadata_deployment_202404.xlsx
#> 5                     https://data.theactnetwork.com/data/repository/tailwinds/data-and-metadata/detection-files/vr2ar_546307_20240425_1.vrl
#>               created            modified creator     size type
#> 1 2026-06-10 03:51:32 2026-06-10 03:51:32 krichie   2.5 KB File
#> 2 2026-06-10 03:51:58 2026-06-10 03:51:58 krichie  41.9 KB File
#> 3 2026-06-10 03:52:17 2026-06-10 03:52:17 krichie  37.0 KB File
#> 4 2026-06-10 03:52:30 2026-06-10 03:52:30 krichie  36.7 KB File
#> 5 2026-06-10 03:55:34 2026-06-10 03:55:34 krichie 751.0 KB File

otn_extract_files(project = 'tailwinds', batch_size = 5)
#>                                            name
#> 1 Detections Mapped to other Trackers (Parquet)
#> 2              Unqualified Detections (Parquet)
#> 3   tailwinds_qualified_detections_2023.parquet
#> 4      Detections Mapped to other Trackers 2023
#> 5   tailwinds_qualified_detections_2024.parquet
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        description
#> 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                 These detections have been mapped to animals released by other tracker projects.
#> 2 These are detections for which we do not know the owner. There may be several reasons for this. One: It is a test or sentinel tag and we have not been informed. Two: It is an ambiguous tag which means we have more than one set of tag metadata which the detection could belong to. Three: We have not received any release metadata for the tag. Four: It is an old style sensor tag and we have not been able to determine the associated pinger id, or even if there should be one, because we do not have the vendor tag specifications.
#> 3                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
#> 4                                                                                                                                                                                                                                                                                                                                                                                                                                                                  These detections have been mapped to animals released by othertracker projects.
#> 5                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
#>                                                                                                                       url
#> 1      https://data.theactnetwork.com/data/repository/tailwinds/detection-extracts/tailwinds_qualified_detections-parquet
#> 2    https://data.theactnetwork.com/data/repository/tailwinds/detection-extracts/tailwinds_unqualified_detections-parquet
#> 3 https://data.theactnetwork.com/data/repository/tailwinds/detection-extracts/tailwinds_qualified_detections_2023-parquet
#> 4     https://data.theactnetwork.com/data/repository/tailwinds/detection-extracts/tailwinds_qualified_detections_2023.zip
#> 5 https://data.theactnetwork.com/data/repository/tailwinds/detection-extracts/tailwinds_qualified_detections_2024-parquet
#>               created            modified creator     size type
#> 1 2026-07-28 14:22:44 2026-07-28 14:22:47  otnbot 347.2 KB File
#> 2 2026-07-28 14:22:45 2026-07-28 14:22:48  otnbot 148.4 KB File
#> 3 2026-06-12 13:25:31 2026-06-12 13:25:31 krichie 133.0 KB File
#> 4 2026-06-12 13:25:49 2026-07-28 14:22:45  otnbot  96.2 KB File
#> 5 2026-06-12 13:26:03 2026-06-12 13:26:03 krichie 174.2 KB File
```

Or, just grab the ones modified more recently using the `since`
argument:

``` r
otn_project_files(
  project = 'tailwinds',
  since = "2026-06-01",
  batch_size = 5
)
#>                                            name description
#> 1        tailwinds_master_metadata_20240812.csv            
#> 2     tailwinds_metadata_deployment_202411.xlsx            
#> 3        tailwinds_otn_metadata_deployment.xlsx            
#> 4 tailwinds_otn_metadata_deployment_202404.xlsx            
#> 5                   VR2AR_546307_20240425_1.vrl            
#>                                                                                                                                          url
#> 1        https://data.theactnetwork.com/data/repository/tailwinds/data-and-metadata/receiver-metadata/tailwinds_master_metadata_20240812.csv
#> 2     https://data.theactnetwork.com/data/repository/tailwinds/data-and-metadata/receiver-metadata/tailwinds_metadata_deployment_202411.xlsx
#> 3        https://data.theactnetwork.com/data/repository/tailwinds/data-and-metadata/receiver-metadata/tailwinds_otn_metadata_deployment.xlsx
#> 4 https://data.theactnetwork.com/data/repository/tailwinds/data-and-metadata/receiver-metadata/tailwinds_otn_metadata_deployment_202404.xlsx
#> 5                     https://data.theactnetwork.com/data/repository/tailwinds/data-and-metadata/detection-files/vr2ar_546307_20240425_1.vrl
#>               created            modified creator     size type
#> 1 2026-06-10 03:51:32 2026-06-10 03:51:32 krichie   2.5 KB File
#> 2 2026-06-10 03:51:58 2026-06-10 03:51:58 krichie  41.9 KB File
#> 3 2026-06-10 03:52:17 2026-06-10 03:52:17 krichie  37.0 KB File
#> 4 2026-06-10 03:52:30 2026-06-10 03:52:30 krichie  36.7 KB File
#> 5 2026-06-10 03:55:34 2026-06-10 03:55:34 krichie 751.0 KB File

otn_extract_files(
  project = 'tailwinds',
  since = "2026-07-01",
  batch_size = 5
)
#>                                            name
#> 1 Detections Mapped to other Trackers (Parquet)
#> 2              Unqualified Detections (Parquet)
#> 3      Detections Mapped to other Trackers 2023
#> 4      Detections Mapped to other Trackers 2024
#> 5                   Unqualified Detections 2023
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        description
#> 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                 These detections have been mapped to animals released by other tracker projects.
#> 2 These are detections for which we do not know the owner. There may be several reasons for this. One: It is a test or sentinel tag and we have not been informed. Two: It is an ambiguous tag which means we have more than one set of tag metadata which the detection could belong to. Three: We have not received any release metadata for the tag. Four: It is an old style sensor tag and we have not been able to determine the associated pinger id, or even if there should be one, because we do not have the vendor tag specifications.
#> 3                                                                                                                                                                                                                                                                                                                                                                                                                                                                  These detections have been mapped to animals released by othertracker projects.
#> 4                                                                                                                                                                                                                                                                                                                                                                                                                                                                  These detections have been mapped to animals released by othertracker projects.
#> 5 These are detections for which we do not know the owner. There may be several reasons for this. One: It is a test or sentinel tag and we have not been informed. Two: It is an ambiguous tag which means we have more than one set of tag metadata which the detection could belong to. Three: We have not received any release metadata for the tag. Four: It is an old style sensor tag and we have not been able to determine the associated pinger id, or even if there should be one, because we do not have the vendor tag specifications.
#>                                                                                                                     url
#> 1    https://data.theactnetwork.com/data/repository/tailwinds/detection-extracts/tailwinds_qualified_detections-parquet
#> 2  https://data.theactnetwork.com/data/repository/tailwinds/detection-extracts/tailwinds_unqualified_detections-parquet
#> 3   https://data.theactnetwork.com/data/repository/tailwinds/detection-extracts/tailwinds_qualified_detections_2023.zip
#> 4   https://data.theactnetwork.com/data/repository/tailwinds/detection-extracts/tailwinds_qualified_detections_2024.zip
#> 5 https://data.theactnetwork.com/data/repository/tailwinds/detection-extracts/tailwinds_unqualified_detections_2023.zip
#>               created            modified creator     size type
#> 1 2026-07-28 14:22:44 2026-07-28 14:22:47  otnbot 347.2 KB File
#> 2 2026-07-28 14:22:45 2026-07-28 14:22:48  otnbot 148.4 KB File
#> 3 2026-06-12 13:25:49 2026-07-28 14:22:45  otnbot  96.2 KB File
#> 4 2026-06-12 13:26:19 2026-07-28 14:22:47  otnbot 131.7 KB File
#> 5 2026-06-12 13:26:45 2026-07-28 14:22:46  otnbot  52.2 KB File
```

Your can also text search for only certain files with the `text`
argument:

``` r
otn_extract_files(
  project = 'tailwinds',
  text = "parquet",
  batch_size = 5
)
#>                                            name
#> 1 tailwinds_unqualified_detections_2024.parquet
#> 2 tailwinds_unqualified_detections_2023.parquet
#> 3   tailwinds_qualified_detections_2024.parquet
#> 4   tailwinds_qualified_detections_2023.parquet
#> 5              Unqualified Detections (Parquet)
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        description
#> 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
#> 2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
#> 3                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
#> 4                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
#> 5 These are detections for which we do not know the owner. There may be several reasons for this. One: It is a test or sentinel tag and we have not been informed. Two: It is an ambiguous tag which means we have more than one set of tag metadata which the detection could belong to. Three: We have not received any release metadata for the tag. Four: It is an old style sensor tag and we have not been able to determine the associated pinger id, or even if there should be one, because we do not have the vendor tag specifications.
#>                                                                                                                         url
#> 1 https://data.theactnetwork.com/data/repository/tailwinds/detection-extracts/tailwinds_unqualified_detections_2024-parquet
#> 2 https://data.theactnetwork.com/data/repository/tailwinds/detection-extracts/tailwinds_unqualified_detections_2023-parquet
#> 3   https://data.theactnetwork.com/data/repository/tailwinds/detection-extracts/tailwinds_qualified_detections_2024-parquet
#> 4   https://data.theactnetwork.com/data/repository/tailwinds/detection-extracts/tailwinds_qualified_detections_2023-parquet
#> 5      https://data.theactnetwork.com/data/repository/tailwinds/detection-extracts/tailwinds_unqualified_detections-parquet
#>               created            modified creator     size type
#> 1 2026-06-12 13:26:59 2026-06-12 13:26:59 krichie  62.7 KB File
#> 2 2026-06-12 13:26:33 2026-06-12 13:26:33 krichie 602.3 KB File
#> 3 2026-06-12 13:26:03 2026-06-12 13:26:03 krichie 174.2 KB File
#> 4 2026-06-12 13:25:31 2026-06-12 13:25:31 krichie 133.0 KB File
#> 5 2026-07-28 14:22:45 2026-07-28 14:22:48  otnbot 148.4 KB File
```

## Download files

You can pipe this list into `otn_download` to save the files to your
computer:

``` r
otn_extract_files(
  project = 'tailwinds',
  since = "2026-06-01",
  batch_size = 1
) |>
  otn_download()
#> ℹ Files saved to ./tailwinds_qualified_detections.parquet.
```

Or download directly via its URL:

``` r
otn_download(
  url = "https://members.devel.oceantrack.org/data/repository/nsbs/detection-extracts/nsbs_matched_detections_2017.zip"
)
```

## Upload files

Upload files to the staging area in preparation for the next data push:

``` r
"VR2AR_XYZ_123.vrl" |>
  otn_upload("my_project")
```

## Summarize your detection extracts

You can create [otndo reports](https://otndo.obrien.page) using the
`otn_receiver_summary` and `otn_tag_summary` helper functions.

``` r
otn_receiver_summary("tailwinds")
otn_tag_summary("mdwea")
```
