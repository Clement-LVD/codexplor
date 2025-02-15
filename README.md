
<!-- README.md is generated from README.Rmd. Please edit that file -->

# codexplor

🧰🔧🔨 UNDER CONSTRUCTION 🧰🔧🔨 <!-- badges: start --> [![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/codexplor)](https://CRAN.R-project.org/package=codexplor)
<!-- badges: end -->

codexplor turn your files into a ‘document network’ and give you several
utility functions to analyze and visualize your codes files. This help
you to understand *quickly* a programming project, since a quick network
analysis give a lot of insights for priorize your programming activity
(e.g., get a network of dependencies of the func’ in the “R” folder of
this repo for see the funcs’ used by each other func’).

> Document network analysis is well suited for get quick understanding
> of a large programming project, since *it is already* a document
> network. Get a network of the func’ dependancies is always interesting
> : even without fine understanding of the content you should benefit a
> lot from these analysis.

codexplor offer some network-analysis func’ (answering `igraph` objet)
and dataviz’ func’ (answering `networkD3` object).

The network is constructed with a semi-supervized approach since the
user indicate a 1st regular expression that lead to extract the
initially-matched text. These texts are then used as a pattern for a 2nd
search, resulting in a standardized way of constructing a *edgeslist*.
In the network-analysis language, this recursively operated
text-matching is a Citations Network.

## Installation

You can’t install the development version of codexplor yet

``` r
cat("...")
```

## Example

Assuming you have a R folder full of custom R func’ :

⏩ Get a network of func’ from a path (here “~”)

`net <- get_text_network_from_files("~",   regex_to_exclude_files_path = "test-")`

⏩ Turn it into a filtered `igraph` network object

`netig <- get_igraph_from_df(net)`

⏩ Turn this igraph object into an interactive `networkD3` JS object  

`get_networkd3_from_igraph(netig)`

⏩ Get metrics and identifying cascading dependancies of func’

\[🔧🔨\]

For example the default will try to catch every R func’ definition that
occur in the .R files - by default files are recursively listed from the
folder indicated by the user, and extract some text during this 1st
matches iteration : we have the names of the func’ defined in the readed
files. Then, we’ll match all these function names in the content, in
order to construct a directed network, with links

- **from** the path of the files which mention the name of a func’,
- *to* the path of the files that let us find this precise name, during
  the 1st matches iteration (the file where the func’ is defined).

``` r
# library(codexplor)
## basic example code
dog <- c("
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣠⣤⣤⣤⣤⣤⣤⣄⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⡾⠛⠉⠉⠉⠁⠀⠀⠀⠀⠉⠉⠉⠛⠷⣦⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡀⠀⠈⠙⢿⣄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡾⠛⠛⢷⡆⠀⠀⠉⠉⠛⠶⣦⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⡇⠀⠀⠀⠀⠀⠀⠀⢀⣴⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣆⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⡇⠀⠀⠀⠀⠀⣠⣴⠟⣅⣠⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢻⣧⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⠇⠀⠀⢀⣠⣾⠟⠁⢸⣿⣿⡿⢿⡆⠀⠀⠀⠀⠀⢀⣤⠀⠀⠀⠀⠀⠀⠀⠀⢿⣆⡀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⠟⠀⢀⣴⠟⣿⠃⠀⠀⠸⣿⣿⣷⡾⠃⠀⠀⢀⣠⣶⡟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠿⣦⡄⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⠏⣠⡾⠛⠁⣸⡇⠀⠀⠀⠀⠈⠉⠉⢀⣠⡴⠚⠋⣡⡟⠀⠀⠀⠀⠀⠀⠀⠀⢠⣄⠀⠀⠘⣿⡀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⡿⠛⠋⠀⠀⢀⡿⠀⠀⣀⣠⣤⠖⠛⠛⠉⠁⠀⠀⠀⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⠀⠀⠀⠸⣷⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠉⠀⠀⠀⠀⢀⣾⢁⣴⠟⠋⠉⠀⠀⠀⠀⠀⠀⠀⠀⣸⠇⠀⣠⣶⣶⣦⡀⠀⠀⠀⢀⣿⠀⠀⠀⠀⢻⣧⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⣿⠋⠀⠀⠀⢀⡀⠀⠀⠀⠀⠀⠀⢰⠏⠀⠀⣿⣿⣿⠟⡇⠀⠀⠀⣼⡏⠀⠀⠀⠀⠀⢿⡆⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⠋⢸⣧⠀⠀⠀⠸⢿⣿⣿⣦⡀⠀⠀⠀⡟⠀⠀⠀⠙⠿⠿⠚⠁⠀⢀⣼⠏⠀⠀⠀⠀⠀⠀⠸⣿⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⡟⠁⠀⠘⣿⣤⣀⠀⠈⣿⣿⢿⣿⡇⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⣠⣴⣿⠋⠀⠀⠀⠀⠀⠀⠀⢠⣿⠁
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⠏⠀⠀⠀⠀⢹⡍⠛⢷⣄⠉⠉⠁⠉⠀⠀⠀⣼⠃⠀⠀⠀⣀⣤⣶⠿⢻⣿⠁⠀⠀⠀⠀⠀⢀⣠⣴⠟⠁⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⡏⠀⠀⠀⠀⠀⠀⠻⣆⡀⢻⣆⠀⠀⠀⠀⢀⣼⣁⣀⣤⡶⠿⠛⣿⡤⠀⣼⠇⠀⠀⠀⢀⣤⡶⠟⠋⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠁⠀⠀⠀⠀⠀⠀⠀⠈⠉⠛⠛⠻⠶⠶⠾⠟⠛⠉⠉⠁⠀⠀⠀⠛⣷⠀⣿⠀⠀⠀⣴⡟⠋⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⡇⣿⠀⠀⣼⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣷⢹⣇⢠⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⠈⢿⣾⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⠏⠸⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⠀⠸⠿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
")
```

I don’t need to render `README.Rmd` regularly, since keep `README.md`
up-to-date is near to useless. `devtools::build_readme()` is handy for
this.

*Usecases of a quick programming project understanding*. codexplor goal
is to *quickly* analyse your developing project, in order to *gain* time
of comprehension, made your documentation, dataviz’ of your project,
etc. The features offered are crafted for coordinate large programming
project, made helper func’ for new colleagues and/or future you,
formally identifying your higher-level func’ and/or the most-frequently
used as dependancies… and other handy features for priorizing your work
by quickly figure out ‘where’ you have to pay attention. For example,
before to change a parameter name in a func’, you want to check what are
the func’ that used the one you want to modify. Same for changing the
returned content or the behavior of a func’ : you want to check which
ones used this func’ that you want to modify. You also want to offer an
easy way to understand the chaining of your custom func’.
