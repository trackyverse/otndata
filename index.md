# otndata

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

![](reference/figures/README-widget.png)

If this widget is enabled, you can access the information shown without
needing to log in.

``` r

library(otndata)

# What species are tagged?
otn_list_species("otn") |>
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
#> 1  ACT        SOFLONC     USA -76.67000 34.72500
#> 2  ACT     SBUSOMASCO     USA -75.10195 37.65009
#> 3  ACT     UNESACOBAY     USA -70.38000 43.46500
#> 4  ACT          WTAPS     USA -76.17964 37.29108
#> 5  ACT     ASIPORBEAG     USA -70.87500 42.03000
#> 6  ACT      VIMS4AMIA     USA -76.61441 37.60105
#>                                  shortname
#> 1     ECU Southern Flounder Spawning Study
#> 2 SBUSOMASCO - SBU Dusky Shark Habitat Use
#> 3                   UNE Saco River Estuary
#> 4                 WTAPS - UMCES Blue Crabs
#> 5              ASI - Porbeagle Shark Study
#> 6                VIMS Bowfin and Snakehead
#>                                                                                                                       longname
#> 1 Identification of the Spawning Grounds and Offshore Migration Corridor Used by the North Carolina Stock of Southern Flounder
#> 2                                                                                        Dusky Shark Habitat Use and Migration
#> 3                           Tracking seasonal movements of anadromous fishes in the Saco River system using acoustic telemetry
#> 4                          Blue Crab Overwintering and placement of dredge material in the Wolf Trap Alternate Placement Site.
#> 5                                                  This study involves the porbeagle shark in New England and adjacent waters.
#> 6                                                 Habitat utilization and seasonal movements of Bowfin and Northern Snakehead.
#>         ocean                               website datacenter_infourl
#> 1 NW ATLANTIC                                  <NA>                 NA
#> 2 NW ATLANTIC                                  <NA>                 NA
#> 3 NW ATLANTIC                                  <NA>                 NA
#> 4 NW ATLANTIC                                  <NA>                 NA
#> 5 NW ATLANTIC http://www.atlanticsharkinstitute.org                 NA
#> 6 NW ATLANTIC                                  <NA>                 NA
#>                                           institutionname
#> 1                                East Carolina University
#> 2                                  Stony Brook University
#> 3                               University of New England
#> 4 University of Maryland Center for Environmental Science
#> 5                                Atlantic Shark Institute
#> 6                    Virginia Institute of Marine Science

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
#> [1] 3522
```

You can also query projects according to code, country of origin,
species, institution, node, or point of contact.

``` r

otn_search_node("act", network = "otn") |>
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
otn_search_code("tail", network = "act")
#>   node collectioncode country longitude latitude       shortname
#> 1  ACT      TAILWINDS     USA   -74.685   38.325 UMCES TailWinds
#>                                                                                longname
#> 1 TailWinds: Team for Assessing Impacts to Living resources from offshore WIND turbineS
#>         ocean                      website datacenter_infourl
#> 1 NW ATLANTIC https://tailwinds.umces.edu/                 NA
#>                                           institutionname
#> 1 University of Maryland Center for Environmental Science

# This does not accept partial matches
otn_search_contact("Mike O'Brien", "act")
#>    node collectioncode country longitude latitude
#> 1   ACT          MDBSB     USA -74.41074 37.98817
#> 2   ACT          PASBT     USA -76.43000 38.77727
#> 3   ACT        PAXSB08     USA -76.55903 38.41000
#> 4   ACT         HRSB04     USA -73.75500 42.45000
#> 5   ACT         MAMBON     USA -74.64000 38.35000
#> 6   ACT         HUDRSB     USA -73.91500 41.66000
#> 7   ACT        USWTRBM     USA -74.75000 38.35500
#> 8   ACT       NAVYKENN     USA -69.74000 43.90500
#> 9   ACT          MDWEA     USA -73.45500 40.37500
#> 10  ACT         CBBBMB     USA -76.32500 38.31500
#> 11  ACT      TAILWINDS     USA -74.68500 38.32500
#> 12  ACT         HRSB09     USA -73.99000 41.19500
#> 13  ACT       MDWEAMAM     USA -74.63500 38.34500
#>                                       shortname
#> 1  UMCES Black Sea Bass & Offshore Construction
#> 2    UMCES Potomac River Striped Bass Migration
#> 3            UMCES Striped Bass Thermal Squeeze
#> 4  UMCES Resident Hudson Striped Bass Migration
#> 5                             Mid-Atlantic MBON
#> 6     UMCES-NYSDEC Hudson Striped Bass Spawning
#> 7                           US Wind MarWin TRBM
#> 8              Navy Kennebec ME Telemetry Array
#> 9               UMCES BOEM Offshore Wind Energy
#> 10           UMCES Chesapeake Backbone, Mid-Bay
#> 11                              UMCES TailWinds
#> 12  UMCES Lower Hudson Striped Bass Contingents
#> 13          UMCES BOEM Marine Mammal Monitoring
#>                                                                                                                                longname
#> 1         Influence of Turbine Construction Noise on Black Sea Bass Displacement and Physiological Condition in the MD Wind Energy Area
#> 2                                                                           PAST: The Potomac and Atlantic Striped Bass Telemetry Study
#> 3                                                   Test of The Thermal Niche-Oxygen Squeeze Hypothesis for Chesapeake Bay Striped Bass
#> 4                                                                              Migration Patterns of Resident Hudson River Striped Bass
#> 5                                                       Mid-Atlantic MBON: Dynamic Biodiversity and Telemetry Data for a Changing Coast
#> 6                                                                   Spawning Behavior and Ocean Migrations by Hudson River Striped Bass
#> 7                                                                         US Wind MarWin MetOcean Buoy and Trawl-Resistant Bottom Mount
#> 8                                        Naval Undersea Warfare Center (NUWC) Kennebec River and Offshore Acoustic Telemetry Monitoring
#> 9           Movement and Habitat Selection by Migratory Marine Fishes within the Maryland Wind Energy Area and Adjacent Reference Sites
#> 10                                                                  Building a Mainstem Chesapeake Bay Telemetry Array: Mid-Bay Segment
#> 11                                                TailWinds: Team for Assessing Impacts to Living resources from offshore WIND turbineS
#> 12                                                            Striped Bass Habitat Use and Migrations in the Lower Hudson River Estuary
#> 13 Add-on to: Determining Habitat Use by Marine Mammals and Ambient Noise Levels Using Passive Acoustic Monitoring Offshore of Maryland
#>          ocean
#> 1  NW ATLANTIC
#> 2  NW ATLANTIC
#> 3  NW ATLANTIC
#> 4  NW ATLANTIC
#> 5  NW ATLANTIC
#> 6  NW ATLANTIC
#> 7  NW ATLANTIC
#> 8  NW ATLANTIC
#> 9  NW ATLANTIC
#> 10 NW ATLANTIC
#> 11 NW ATLANTIC
#> 12 NW ATLANTIC
#> 13 NW ATLANTIC
#>                                                                          website
#> 1                                                                           <NA>
#> 2                                     http://fishconnectivity.cbl.umces.edu/PAST
#> 3                                                                           <NA>
#> 4                                                                           <NA>
#> 5                               https://marinebon.org/us-mbon/mid-atlantic-mbon/
#> 6                                                                           <NA>
#> 7                                  https://remote.normandeau.com/uswind_home.php
#> 8                                                                           <NA>
#> 9  https://www.govinfo.gov/app/details/GOVPUB-I-e41f0ebd0487ba48b521a21a7ae45ec5
#> 10                                                                          <NA>
#> 11                                                  https://tailwinds.umces.edu/
#> 12                                                                          <NA>
#> 13                      https://espis.boem.gov/final%20reports/BOEM_2019-018.pdf
#>    datacenter_infourl                                         institutionname
#> 1                  NA University of Maryland Center for Environmental Science
#> 2                  NA University of Maryland Center for Environmental Science
#> 3                  NA University of Maryland Center for Environmental Science
#> 4                  NA University of Maryland Center for Environmental Science
#> 5                  NA               Smithsonian Environmental Research Center
#> 6                  NA University of Maryland Center for Environmental Science
#> 7                  NA      Mid-Atlantic Acoustic Telemetry Observation System
#> 8                  NA                   Naval Undersea Warfare Center Newport
#> 9                  NA University of Maryland Center for Environmental Science
#> 10                 NA University of Maryland Center for Environmental Science
#> 11                 NA University of Maryland Center for Environmental Science
#> 12                 NA University of Maryland Center for Environmental Science
#> 13                 NA University of Maryland Center for Environmental Science
```

## Logging in

You’ll need to log in to access other parts of the CMS using
`otn_login`. This package is meant to interface with any node’s Plone
instance. You can switch between them using the `network` argument. If
you are a member of multiple networks, you can log into all of them and
toggle between using the `network` argument of other functions, such as
`otn_extract_files("nsbs", network = "otn")`.

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

## Listing your projects

List the projects to which you have access:

``` r

otn_list_projects("act", what = "mine")
#>    node collectioncode                                    shortname
#> 1   ACT         CBBBMB           UMCES Chesapeake Backbone, Mid-Bay
#> 2   ACT         HRSB04 UMCES Resident Hudson Striped Bass Migration
#> 3   ACT         HRSB09  UMCES Lower Hudson Striped Bass Contingents
#> 4   ACT         HUDRSB    UMCES-NYSDEC Hudson Striped Bass Spawning
#> 5   ACT         MAMBON                            Mid-Atlantic MBON
#> 6   ACT          MDBSB UMCES Black Sea Bass & Offshore Construction
#> 7   ACT          MDWEA              UMCES BOEM Offshore Wind Energy
#> 8   ACT       MDWEAMAM          UMCES BOEM Marine Mammal Monitoring
#> 9   ACT          PASBT   UMCES Potomac River Striped Bass Migration
#> 10  ACT        PAXSB08           UMCES Striped Bass Thermal Squeeze
#> 11  ACT      TAILWINDS                              UMCES TailWinds
#> 12  ACT        USWTRBM                          US Wind MarWin TRBM
#>                                                                                                                                longname
#> 1                                                                   Building a Mainstem Chesapeake Bay Telemetry Array: Mid-Bay Segment
#> 2                                                                              Migration Patterns of Resident Hudson River Striped Bass
#> 3                                                             Striped Bass Habitat Use and Migrations in the Lower Hudson River Estuary
#> 4                                                                   Spawning Behavior and Ocean Migrations by Hudson River Striped Bass
#> 5                                                       Mid-Atlantic MBON: Dynamic Biodiversity and Telemetry Data for a Changing Coast
#> 6         Influence of Turbine Construction Noise on Black Sea Bass Displacement and Physiological Condition in the MD Wind Energy Area
#> 7           Movement and Habitat Selection by Migratory Marine Fishes within the Maryland Wind Energy Area and Adjacent Reference Sites
#> 8  Add-on to: Determining Habitat Use by Marine Mammals and Ambient Noise Levels Using Passive Acoustic Monitoring Offshore of Maryland
#> 9                                                                           PAST: The Potomac and Atlantic Striped Bass Telemetry Study
#> 10                                                  Test of The Thermal Niche-Oxygen Squeeze Hypothesis for Chesapeake Bay Striped Bass
#> 11                                                TailWinds: Team for Assessing Impacts to Living resources from offshore WIND turbineS
#> 12                                                                        US Wind MarWin MetOcean Buoy and Trawl-Resistant Bottom Mount
#>                                                         url
#> 1     https://data.theactnetwork.com/data/repository/cbbbmb
#> 2     https://data.theactnetwork.com/data/repository/hrsb04
#> 3     https://data.theactnetwork.com/data/repository/hrsb09
#> 4     https://data.theactnetwork.com/data/repository/hudrsb
#> 5     https://data.theactnetwork.com/data/repository/mambon
#> 6      https://data.theactnetwork.com/data/repository/mdbsb
#> 7      https://data.theactnetwork.com/data/repository/mdwea
#> 8   https://data.theactnetwork.com/data/repository/mdweamam
#> 9      https://data.theactnetwork.com/data/repository/pasbt
#> 10   https://data.theactnetwork.com/data/repository/paxsb08
#> 11 https://data.theactnetwork.com/data/repository/tailwinds
#> 12   https://data.theactnetwork.com/data/repository/uswtrbm
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
#>               created            modified network creator     size type
#> 1 2026-06-10 03:51:32 2026-06-10 03:51:32     ACT krichie   2.5 KB File
#> 2 2026-06-10 03:51:58 2026-06-10 03:51:58     ACT krichie  41.9 KB File
#> 3 2026-06-10 03:52:17 2026-06-10 03:52:17     ACT krichie  37.0 KB File
#> 4 2026-06-10 03:52:30 2026-06-10 03:52:30     ACT krichie  36.7 KB File
#> 5 2026-06-10 03:55:34 2026-06-10 03:55:34     ACT krichie 751.0 KB File

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
#>               created            modified network creator     size type
#> 1 2026-07-28 14:22:44 2026-07-28 14:22:47     ACT  otnbot 347.2 KB File
#> 2 2026-07-28 14:22:45 2026-07-28 14:22:48     ACT  otnbot 148.4 KB File
#> 3 2026-06-12 13:25:31 2026-06-12 13:25:31     ACT krichie 133.0 KB File
#> 4 2026-06-12 13:25:49 2026-07-28 14:22:45     ACT  otnbot  96.2 KB File
#> 5 2026-06-12 13:26:03 2026-06-12 13:26:03     ACT krichie 174.2 KB File
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
#>               created            modified network creator     size type
#> 1 2026-06-10 03:51:32 2026-06-10 03:51:32     ACT krichie   2.5 KB File
#> 2 2026-06-10 03:51:58 2026-06-10 03:51:58     ACT krichie  41.9 KB File
#> 3 2026-06-10 03:52:17 2026-06-10 03:52:17     ACT krichie  37.0 KB File
#> 4 2026-06-10 03:52:30 2026-06-10 03:52:30     ACT krichie  36.7 KB File
#> 5 2026-06-10 03:55:34 2026-06-10 03:55:34     ACT krichie 751.0 KB File

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
#>               created            modified network creator     size type
#> 1 2026-07-28 14:22:44 2026-07-28 14:22:47     ACT  otnbot 347.2 KB File
#> 2 2026-07-28 14:22:45 2026-07-28 14:22:48     ACT  otnbot 148.4 KB File
#> 3 2026-06-12 13:25:49 2026-07-28 14:22:45     ACT  otnbot  96.2 KB File
#> 4 2026-06-12 13:26:19 2026-07-28 14:22:47     ACT  otnbot 131.7 KB File
#> 5 2026-06-12 13:26:45 2026-07-28 14:22:46     ACT  otnbot  52.2 KB File
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
#>               created            modified network creator     size type
#> 1 2026-06-12 13:26:59 2026-06-12 13:26:59     ACT krichie  62.7 KB File
#> 2 2026-06-12 13:26:33 2026-06-12 13:26:33     ACT krichie 602.3 KB File
#> 3 2026-06-12 13:26:03 2026-06-12 13:26:03     ACT krichie 174.2 KB File
#> 4 2026-06-12 13:25:31 2026-06-12 13:25:31     ACT krichie 133.0 KB File
#> 5 2026-07-28 14:22:45 2026-07-28 14:22:48     ACT  otnbot 148.4 KB File
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
#> ✔ 1 file(s) saved to './tailwinds_qualified_detections.parquet'.
```

Or download directly via its URL:

``` r

otn_download(
  urls = "https://members.devel.oceantrack.org/data/repository/nsbs/detection-extracts/nsbs_matched_detections_2017.zip"
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
