
# codexplor

🧰🔧🔨 UNDER CONSTRUCTION 🧰🔧🔨 <!-- badges: start --> [![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
![Project
Progress](https://img.shields.io/badge/Progress-1%2F4%20%7C%20Active_coding-orange)
[![CRAN
status](https://www.r-pkg.org/badges/version/codexplor)](https://CRAN.R-project.org/package=codexplor)
<!-- badges: end -->

`codexplor` is a R package that offers functions for explore and
understand a programming project : these tools are aimed to helping you
to understand quickly the project, by analyze and visualize it.

> `codexplor` help you to analyze a programming project, from the early
> stage \[…\] to the last step (e.g., text-mining metrics, network
> analysis & dataviz’). Get rid of complexity wit `codexplor` !

|  | Features |
|:---|:---|
| Network of internal dependencies (Citations Network) | Constitute a network of functions and get immediate network theory metrics. For example, given a programming project, you will identify the functions that are used by many others functions (‘internal dependancies’) and the ones that are build on top of several others functions (high-level functions). |

## Installation

You can install the development version of codexplor with

``` r
devtools::install_github("clement-LVD/codexplor")
```

## Example

Hereafter we use the default parameters, dedicated to analyze .R codes
files.

⏩ **1. Create a corpus as a list of files path and/or url.**

If the project is on your local machine, you should use :

    paths <- list.files(path = "~/", ignore.case = T, all.files = T, full.names = T, recursive = T, pattern = ".R$") 

If the project is a R public github repo :

    paths <- get_github_raw_filespath(repo = "tidyverse/readr", pattern = "\\.R")
    #  Return characters list with ≃ 75 url of .R files 

⏩ **2. Read the files and get a citations network of func’.**

    # [assuming `paths` is a list of files path and/or url]
    net <- get_text_network_from_files(paths, regex_to_exclude_files_path = "test-", ignore_match_less_than_nchar = 5)
    # Return a data.frame, an edgelist of the functions network (≃  573 obs. and 7 variables with readr repo)

Here we read the .R files with the default parameters of
[get_text_network_from_files()](vignettes/get_text_network_from_files).
This function have returned an edgelist that represent a Citations
Network, thanks to a [‘cascading
matching’](vignettes/cascading_matching.html). In this example we have
excluded some results from the returned edgelist (every url that contain
“test-” and the matches with less than 5 char, e.g., `cli()` is not
matched since it’s a 3 letters func’ name).

⏩ **3. Turn it into a directed `igraph` network object.**

    netig <- get_igraph_from_df(net) 
    # return an 'igraph' object from our edgelist with 18 links and 19 nodes (files path are in relationship)

⏩ **4. Get an interactive `networkD3` HTML object**

    get_networkd3_from_igraph(netig) 

Return a list of 2 objects :

1.  a list named `'net3d'` with 2 data.frames, with the data used by
    `networkD3` (`'nodes'` and `'edges'`)

2.  a networkD3::forceNetwork S3 class object named `'forcenetwork'`, an
    html interactive network dataviz’

You should play with the parameters, e.g., coloring nodes depending on
their outdegrees :

     get_networkd3_from_igraph(netig, color_outdeg_instead_of_indeg = T) 

![The interactive network
dataviz’](man/figures/example_net3d_dataviz.png) For example, we quickly
see that, in the readr repo, read_fwf.R use several others functions,
and is even used by another one (i.e. melt_table.R)

⏩ **5. Get metrics and identifying cascading dependancies of func’**

Under construction \[🔧🔨\]

------------------------------------------------------------------------

In order to use codexplor on various programming project, there is
several useful parameters to take care with, depending on the languages
you have to manage. Default are tunned for a R programming project.

> **Usecases 1.** codexplor help me to priorize my time and get the big
> picture of a large programming project quickly, with precious network
> analysis and dataviz’. I have really good insights about the project,
> it’s simpler to find where to start a polishing loop, follow a
> programming project or show it to the dev’ and tech’ profiles.

> **Usecases 2.** I used the function for add insights on a particular
> function (e.g., list all the local dependancies of this function and
> the functions that use it as a local dependancy).

<!-- *Usecases of a quick programming project understanding*. codexplor goal is to *quickly* analyse your developing project, in order to *gain* time of comprehension, made your documentation, dataviz' of your project, etc. The features offered are crafted for coordinate large programming project, made helper func' for new colleagues and/or future you, formally identifying your higher-level func' and/or the most-frequently used as dependancies... and other handy features for priorizing your work by quickly figure out 'where' you have to pay attention. For example, before to change a parameter name in a func', you want to check what are the func' that used the one you want to modify. Same for changing the returned content or the behavior of a func' : you want to check which ones used this func' that you want to modify. You also want to offer an easy way to understand the chaining of your custom func'. -->
