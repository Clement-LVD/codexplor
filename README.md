
<!-- README.md is generated from README.Rmd. Please edit that file -->

# codexplor

<style>
  p {
    text-align: justify;
  }
</style>

🧰🔧🔨 UNDER CONSTRUCTION 🧰🔧🔨 <!-- badges: start --> [![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/codexplor)](https://CRAN.R-project.org/package=codexplor)
<!-- badges: end -->

**Abstract.** codexplor help you to understand and analysis a
programming project with text & network analysis : from the constitution
of your corpus of documents, to the network analysis themselves (e.g.,
see the most important nodes and look at cool interactive dataviz’ about
them).

**Usecases.** codexplor is dedicated to explore code, providing tools
for *create, analyze and visualize a programming project*. In this
regard, codexplor first goal is to giving you tools for reduce global
complexity (e.g., text-analysis, network-analysis & dataviz’ tools are
offered by codexplor). Thus, codexplor help you to maintain and/or
apprehend a large programming project quickly. In other terms, with
network analysis and dataviz’, you should understand the big picture of
a R programming project easily and get *insights* about the project,
find candidates (functions) for starting a polishing loop in order to
reduce the complexity of the project, etc.

**Functionnality.** codexplor offers tools to create and analyze the
relationships between the functions defined in a programming projet
(e.g., which functions are the most used by others func’ of the proje,
which one used others func’ of the project and thus have local
dependencies, etc.). This network analysis approach is supposed to be a
way to reduce the time lost in understanding a ‘globally complex’
project, and metrics & dataviz’ are supposed to be useful to determine
where you push micro-factorization too far (there is a short vignette
about [measuring complexity of your
codes](/articles/measuring_complexity_of_your_codes.html)).

## Installation

You can install the development version of codexplor with

``` r
devtools::install_github("clement-LVD/codexplor")
```

## Example

⏩ First, you want to constitute your corpus (i.e. creating a list of
files path and/or url to read )

For example by providing a github repo to
`codexplor::get_github_raw_filespath(repo)`

`paths <- get_github_raw_filespath(repo = "tidyverse/readr", pattern = "\\.R")`

⏩ Get a network of func’ from a list of paths and/or url :

`net <- get_text_network_from_files(paths, regex_to_exclude_files_path = "test-", ignore_match_less_than_nchar = 5)`

Here, you want to associate a first text label to each files, since the
content of each files don’t refer to “`path/R/my_file_name.R`” but
instead to `function_name()`.

The user have to indicate a 1st regular expression that lead to extract
the initially-matched text as a new ‘definition’ of the path of the file
: hereabove we 1st extract every text *before* “\<- function” \[the
default regex-pattern used by `get_text_network_from_files()`, crafted
for matching the R programming language func’ definition\]; and then we
remove the matches with less than 5 char (e.g., we don’t match `cli()`
since it’s a 3 letters match). Then a 2nd text extraction is made with
this term, considered now as equivalent as the original file path were
we find the 1st match. This result in a standardized way of constructing
the typical *edgeslist* of a citations network (i.e. from the file path
or url of the func’ that mention the name of another func’ =\> to the
file path or url of the files where this func’ is defined).

There is several useful parameters for craft your [‘cascading
matching’](vignettes/cascading_matching.html) ).

⏩ Turn it into a directed `igraph` network object

`netig <- get_igraph_from_df(net )`

⏩ Turn this igraph object into an interactive `networkD3` JS object  

`get_networkd3_from_igraph(netig)`

⏩ Get metrics and identifying cascading dependancies of func’

\[🔧🔨\]

<!-- *Usecases of a quick programming project understanding*. codexplor goal is to *quickly* analyse your developing project, in order to *gain* time of comprehension, made your documentation, dataviz' of your project, etc. The features offered are crafted for coordinate large programming project, made helper func' for new colleagues and/or future you, formally identifying your higher-level func' and/or the most-frequently used as dependancies... and other handy features for priorizing your work by quickly figure out 'where' you have to pay attention. For example, before to change a parameter name in a func', you want to check what are the func' that used the one you want to modify. Same for changing the returned content or the behavior of a func' : you want to check which ones used this func' that you want to modify. You also want to offer an easy way to understand the chaining of your custom func'. -->
