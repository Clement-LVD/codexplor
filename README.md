
# codexplor

🧰🔧🔨 DOC. UNDER CONSTRUCTION 🧰🔧🔨 <!-- badges: start -->
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
![Project
Progress](https://img.shields.io/badge/Progress-1%2F4%20%7C%20Active_coding-orange)
[![CRAN
status](https://www.r-pkg.org/badges/version/codexplor)](https://CRAN.R-project.org/package=codexplor)
<!-- badges: end -->

codexplor is a R package that offers functions for explore and
understand a programming project, with specialized tools for *understand
quickly, analyze and visualize a programming project* (e.g., see which
functions are the most used by others func’ of the project, which one
used others func’ of the project and thus have local dependencies).

codexplor offer functions for realize a complete network analysis
protocol of your R programming project, from the constitution of your
corpus of documents \[…\] to the realization of your network analysis.
It’s a game changer to get rid of the global complexity of the
project[^1].

## Installation

You can install the development version of codexplor with

``` r
devtools::install_github("clement-LVD/codexplor")
```

## Example

Hereafter we use the default parameters, dedicated to analyze .R codes
files.

⏩ *1. Create a corpus as a list of files path and/or url.*

If the project is on your local machine, you should use :

    paths <- list.files(path = "~/", ignore.case = T, all.files = T, full.names = T, recursive = T, pattern = ".R$") 

If the project is a R public github repo :

    paths <- get_github_raw_filespath(repo = "tidyverse/readr", pattern = "\\.R")
    #  Return characters list with ≃ 75 url of .R files 

⏩ *2. Read the files and get a citations network of func’.*

    # [assuming `paths` is a list of files path and/or url]
    net <- get_text_network_from_files(paths, regex_to_exclude_files_path = "test-", ignore_match_less_than_nchar = 5)
    # Return a data.frame, an edgelist of the functions network (≃  572 obs. and 7 variables with readr repo)

Here we read the files with the default parameters of
[get_text_network_from_files()](vignettes/get_text_network_from_files).

Next, the function have constructed a Citations Network with these
functions names, thanks to a [‘cascading
matching’](vignettes/cascading_matching.html). Finally, this example
have excluded some results from the network : every url that contain
“test-” and the matches with less than 5 char, e.g., `cli()` is not
matched since it’s a 3 letters match).

⏩ *3. Turn it into a directed `igraph` network object.*

    netig <- get_igraph_from_df(net) 
    # return an 'igraph' object from our edgelist with 18 links and 19 nodes (files path are in relationship)

⏩ *4. Get an interactive `networkD3` JS object.*

    get_networkd3_from_igraph(netig) 
    #return a networkD3 object, an interactive network dataviz'

⏩ *5. Get metrics and identifying cascading dependancies of func’*

Under construction \[🔧🔨\]

------------------------------------------------------------------------

In order to use codexplor on various programming project, there is
several useful parameters to take care with, depending on the languages
you have to manage. Default are tunned for a R programming project.

> **Usecases.** codexplor help me to priorize my time and apprehend the
> big picture of a large programming project quickly, with precious
> network analysis and dataviz’. I’ve really good insights about the
> project, when I want to find where to start a polishing loop, follow a
> programming project or show it to other (e.g., animate dev’ network).

<!-- *Usecases of a quick programming project understanding*. codexplor goal is to *quickly* analyse your developing project, in order to *gain* time of comprehension, made your documentation, dataviz' of your project, etc. The features offered are crafted for coordinate large programming project, made helper func' for new colleagues and/or future you, formally identifying your higher-level func' and/or the most-frequently used as dependancies... and other handy features for priorizing your work by quickly figure out 'where' you have to pay attention. For example, before to change a parameter name in a func', you want to check what are the func' that used the one you want to modify. Same for changing the returned content or the behavior of a func' : you want to check which ones used this func' that you want to modify. You also want to offer an easy way to understand the chaining of your custom func'. -->

[^1]: **Local complexity** is the complexity of an individual file (how
    long and difficult to read is each of your files ?). **Global
    complexity** is the difficulty to understand the big picture : how
    many functions are used and what are the relationship between the
    various functions in this project ?
