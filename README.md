
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
mining metrics and dataviz’ about the project. Get rid of global
complexity with a network of internal dependancies, and assess local
complexity with document-level and function-level metrics (e.g.,
identify files with many functions, the longest functions, and those
with numerous internal dependencies within the project).

> `codexplor` help me to figure out the big picture of a programming
> project faster, and to manage it more efficiently.

### Installation

You can install the development version of codexplor with

``` r
devtools::install_github("clement-LVD/codexplor")
```

The default settings of `codexplor` are optimized for analyzing a
project in ![R](https://img.shields.io/badge/R-black) language.
Supported languages are : R, Python

------------------------------------------------------------------------

### Features

Given a programming project `codexplor` will compute several
standardized metrics, in order to gain global and local insights on the
project.

| Computed Methods | Level of insights |
|:---|:---|
| ![.](https://img.shields.io/badge/✔️-bold?style=flat&logoColor=black&logoSize=2&label=Network%20of%20internal%20dependencies&labelColor=black&color=green) | Appreciate **global** complexity and reveal critical files, e.g., major internal dependancies, clusters of ‘difficult-to-read’ files |
| ![.](https://img.shields.io/badge/%7B🚧%7D-bold?style=flat&logoColor=black&logoSize=2&label=Document-level%20metrics&labelColor=grey&color=yellow) | Assess each **file**, e.g., length and files readability, number of functions within a file |
| ![.](https://img.shields.io/badge/%7B🚧%7D-bold?style=flat&logoColor=black&logoSize=2&label=Function-level%20metrics&labelColor=grey&color=orange) | Assess each **function**, e.g., those with a lot of internal dependencies |
| ![.](https://img.shields.io/badge/%7B🚧%7D-bold?style=flat&logoColor=black&logoSize=2&label=Line-level%20metrics&labelColor=grey&color=green) | Assess each **line**, e.g., find the longest |

<!-- FEATURES are on 3 flex-columns : -->

<div style="display: flex;font-size: 12px;">

<div style="flex: 35%; padding: 10px; border: 2px solid #000; border-radius: 10px; margin-right: 8px;">

**Availables features :**

![ ](https://img.shields.io/badge/%7BConstruct--corpus%7D-bold?style=flat&logoColor=black&logoSize=2&label=Read%20files%20from%20github%20and/or%20locally&labelColor=black&color=green)
![ ](https://img.shields.io/badge/%7BAnalyze%7D-bold?style=flat&logoColor=black&logoSize=2&label=Compute%20a%20network%20of%20internal%20dependencies&labelColor=black&color=green)
![ ](https://img.shields.io/badge/%7BnetworkD3%7D-bold?style=flat&logoColor=black&logoSize=2&label=Dataviz%20from%20a%20network&labelColor=black&color=green)
![.](https://img.shields.io/badge/%7BAnalyze%7D-bold?style=flat&logoColor=black&logoSize=2&label=Global%20text-mining%20metrics&labelColor=grey&color=orange)
![.](https://img.shields.io/badge/%7BAnalyze%7D-bold?style=flat&logoColor=black&logoSize=2&label=Document-level%20metrics&labelColor=grey&color=yellow)
![.](https://img.shields.io/badge/%7BAnalyze%7D-bold?style=flat&logoColor=black&logoSize=2&label=Networks%20metrics&labelColor=grey&color=yellow)

</div>

<div style="flex: 40%; padding: 10px; border: 2px solid #000; border-radius: 10px; margin-right: 8px;">

**Planned features :**

![.](https://img.shields.io/badge/%7BExport%7D-bold?style=flat&logoColor=black&logoSize=2&label=Reporting&labelColor=grey&color=orange)
![.](https://img.shields.io/badge/%7BAnalyze%7D-bold?style=flat&logoColor=black&logoSize=2&label=Function-level%20metrics&labelColor=grey&color=orange)

</div>

<div style="flex: 20%; padding: 10px; border: 2px solid #000; border-radius: 20px">

**Supported language(s) :**

![ ](https://img.shields.io/badge/R-green)
![ ](https://img.shields.io/badge/Python-yellow)
<!-- ![ ](https://img.shields.io/badge/Javascript-orange) -->

Other languages are planned.

</div>

</div>

### Example

**1. Turn a programming project into a corpus.** Given folder(s) and/or
github repo(s) and programming language(s),
`codexplor::construct_corpus` will return a `list` of dataframes : the
programming project is turned into a corpus.

``` r
library(codexplor)

 # Construct a corpus and a Citations network
corpus <- construct_corpus(
  folders = getwd()
  , languages = "R" )
  
```

This corpus of dataframes is a standardized way to analyze a programming
project as a collection of documents, see the [vignette of
`construct_corpus()`](https://clement-lvd.github.io/codexplor/articles/vignette_construct_corpus.html).
Some of these df have classes `citations.network` of
`internal.dependencies`, a network of functions or files. See the
[vignette of these `citations.network`
`dataframes`](https://clement-lvd.github.io/codexplor/articles/vignette_citations.network_df_of_internal.dependencies.html).

**2. See a dataviz’ from a corpus.list.** Given a `corpus.list`, look at
the dataviz’ of a `citations.network` `data.frame` with
`codexplor::get_networkd3_from_igraph` :

``` r
# Produce an interactive dataviz' with the network of internal.dependencies
dataviz <- get_networkd3_from_igraph(corpus$functions.network
, title_h1 = "codexplor. Graph of internal dependancies : functions network"
, subtitle_h2 = "Color and links = indegrees") 

# herafter an image (non-interactive) of the interactive dataviz ↓
```

<img src="man/figures/force_network.png" width="100%" />

> These dataviz are useful for pinpointing where to start a polishing
> loop, identifying all the functions impacted by upcoming changes,
> \[…\] or assessing the impact of a new dev loop on the project’s
> complexity.

Similarly, you have the possibility to look for a dataviz of the *files*
with the following :

      get_networkd3_from_igraph(corpus$files.network)
      

See an [example of a files
network](https://clement-lvd.github.io/codexplor/articles/vignette_analyse_citations_network_from_project.html).

------------------------------------------------------------------------

### Vignettes

- See the [vignette of
  `construct_corpus()`](https://clement-lvd.github.io/codexplor/articles/vignette_construct_corpus.html).

- `codexplor` also offers helper functions, e.g., for create and filter
  a network with the `igraph` package, see the [vignette of helper
  functions for igraph object and
  dataviz](https://clement-lvd.github.io/codexplor/articles/manage_igraph_object.html)
