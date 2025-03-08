
# codexplor

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/codexplor)](https://CRAN.R-project.org/package=codexplor)
<!-- badges: end -->

🧰🔧🔨 `codexplor` is a WIP 🧰🔧🔨

`codexplor` offers **R** functions dedicated to explore, analyze and
monitor a programming project.

Given a programming project, `codexplor` compute standardized text
mining metrics and dataviz’ about the project : get rid of global
complexity with a network of local dependancies, and assess local
complexity with document-level metrics.

> `codexplor` help me to figure out the big picture of a programming
> project faster, and to manage it more efficiently.

### Installation

You can install the development version of codexplor with

``` r
devtools::install_github("clement-LVD/codexplor")
```

The default settings of `codexplor` are optimized for analyzing a
project in ![R](https://img.shields.io/badge/R-black) language.
Supported languages are : R, Python, JavaScript

------------------------------------------------------------------------

### Example : dataviz’ of internal dependancies

Return an interactive dataviz’ of the internal dependancies within
`codexplor` :

``` r
library(codexplor)

 # 1) Construct a corpus and a Citations network
  corpus <- get_doc_network_from_project(folders = getwd(), languages = "R" )
   # return a corpus.list object with 4 data.frames :
  # => 2 corpus.lines
  # => 1 corpus.nodelist 
  # => 1 citations.network
```

``` r
# 2) Produce an interactive dataviz'
dataviz <- get_networkd3_from_igraph(corpus$internal.dependencies
, title_h1 = "codexplor"
, subtitle_h2 = "graph of internal dependancies" ) 
```

<img src="man/figures/force_network.png" width="100%" />

> These dataviz are useful for pinpointing where to start a polishing
> loop, identifying all the functions impacted by upcoming changes,
> \[…\] or assessing the impact of a new dev loop on the project’s
> complexity.

------------------------------------------------------------------------

### Features

`codexplor` will compute several metrics, in order to gain global and
local insights on a programming project.

| Computed Methods | Global insights | Local insights on files |
|:---|:---|:---|
| ![.](https://img.shields.io/badge/✔️-bold?style=flat&logoColor=black&logoSize=2&label=Network%20of%20internal%20dependencies&labelColor=black&color=green) | Appreciate global complexity and figure out the pig picture | Reveal critical files, e.g., major internal dependancies |
| ![.](https://img.shields.io/badge/%7B🚧%7D-bold?style=flat&logoColor=black&logoSize=2&label=Document-level%20metrics&labelColor=grey&color=orange) | Reveal clusters of ‘difficult-to-read’ files | Assess each file with text-mining metrics, e.g., length and files readability |
| ![.](https://img.shields.io/badge/%7B🚧%7D-bold?style=flat&logoColor=black&logoSize=2&label=Line-level%20metrics&labelColor=grey&color=green) | ↑ (used by global level metric) | Identify problematic lines, e.g., the longest ones |

<!-- FEATURES are on 3 flex-columns : -->

<div style="display: flex;font-size: 12px;">

<div style="flex: 35%; padding: 10px; border: 2px solid #000; border-radius: 10px; margin-right: 8px;">

**Availables features :**

![ ](https://img.shields.io/badge/%7BConstruct--corpus%7D-bold?style=flat&logoColor=black&logoSize=2&label=Read%20files%20from%20github%20and/or%20locally&labelColor=black&color=green)
![.](https://img.shields.io/badge/%7BAnalyze%7D-bold?style=flat&logoColor=black&logoSize=2&label=Line-level%20metrics&labelColor=grey&color=green)
![ ](https://img.shields.io/badge/%7BAnalyze%7D-bold?style=flat&logoColor=black&logoSize=2&label=Compute%20a%20network%20of%20internal%20dependencies&labelColor=black&color=green)
![ ](https://img.shields.io/badge/%7BnetworkD3%7D-bold?style=flat&logoColor=black&logoSize=2&label=Dataviz%20from%20a%20network&labelColor=black&color=green)

</div>

<div style="flex: 40%; padding: 10px; border: 2px solid #000; border-radius: 10px; margin-right: 8px;">

**Planned features :**

![.](https://img.shields.io/badge/%7BAnalyze%7D-bold?style=flat&logoColor=black&logoSize=2&label=Document-level%20metrics&labelColor=grey&color=yellow)
![.](https://img.shields.io/badge/%7BAnalyze%7D-bold?style=flat&logoColor=black&logoSize=2&label=Global%20text-mining%20metrics&labelColor=grey&color=orange)
![.](https://img.shields.io/badge/%7BExport%7D-bold?style=flat&logoColor=black&logoSize=2&label=Reporting&labelColor=grey&color=orange)
![.](https://img.shields.io/badge/%7BAnalyze%7D-bold?style=flat&logoColor=black&logoSize=2&label=Advanced%20network%20metrics&labelColor=grey&color=orange)

</div>

<div style="flex: 20%; padding: 10px; border: 2px solid #000; border-radius: 20px">

**Supported language(s) :**

![ ](https://img.shields.io/badge/R-green)
![ ](https://img.shields.io/badge/Python-yellow)
![ ](https://img.shields.io/badge/Javascript-orange)

Other languages are planned.

</div>

</div>

### Vignettes

*WIP* \[🔧🔨\]

`codexplor` offers functions that are dedicated to analyze a programming
project, accordingly to subanalysis tools.

| Complete reporting | Underlying functions |
|:---|:---|
| Construct a network of internal dependancies from a programming project folder path(s) and/or github repo(s) : [vignette of `get_doc_network_from_project()`](https://clement-lvd.github.io/codexplor/articles/vignette_analyse_citations_network_from_project.html) | Construct a corpus : [vignette of `construct_corpus()`](https://clement-lvd.github.io/codexplor/articles/vignette_construct_corpus.html) |
|  | Understand the citations.network of internal dependancies : [vignette of `citations.network` `dataframe`](https://clement-lvd.github.io/codexplor/articles/vignette_citations.network_df_of_internal.dependencies.html) |

`codexplor` also offers helper functions, e.g., for create and filter a
network with the `igraph` package, see the [vignette of helper functions
for igraph object and
dataviz](https://clement-lvd.github.io/codexplor/articles/manage_igraph_object.html)
