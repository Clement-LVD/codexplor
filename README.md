
# codexplor

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
![Project Progress](https://img.shields.io/badge/R-black) [![CRAN
status](https://www.r-pkg.org/badges/version/codexplor)](https://CRAN.R-project.org/package=codexplor)
<!-- badges: end -->

🧰🔧🔨 UNDER CONSTRUCTION 🧰🔧🔨

`codexplor` offers R functions for explore and monitor a programming
project with text-mining methods : analyze and visualize the project
with text-mining metrics, network analysis & dataviz’. Get a deep
understanding and get rid of complexity.

## Installation

You can install the development version of codexplor with

``` r
devtools::install_github("clement-LVD/codexplor")
```

## Features

- **Appreciate global complexity of a project with a Citations Network
  of internal dependencies.**
  - Get metrics & dataviz’ about the functions defined in the project
    (e.g. explore global structure or zoom on major internal
    dependancies[^1]).
- **Assess local complexity with text-Mining metrics.**
  - Compute document-level metrics (e.g., files readability)
- …

## Short Example

1.  List the project’ files path and/or urls, eventually from a github
    repo with
    ![.](https://img.shields.io/badge/%7BScraping%7D-bold?style=flat&logoColor=black&logoSize=2&label=get-github-raw-filespath()&labelColor=green&color=black)

2.  Compute a Citations Network by passing files path and/or urls to
    ![.](https://img.shields.io/badge/%7BMethod%7D-bold?style=flat&logoColor=black&logoSize=2&label=get-text-network-from-files()&labelColor=yellow&color=black)

3.  Get a directed network with `igraph` by passing an edgelist to
    ![1.](https://img.shields.io/badge/%7Bigraph%7D-bold?style=flat&logoColor=black&logoSize=2&label=get-igraph-from-df()&labelColor=green&color=black)

4.  Optionnaly zoom on a precise function with
    ![](https://img.shields.io/badge/%7Bigraph%7D-bold?style=flat&logoColor=black&logoSize=2&label=filter-igraph-egonetwork()&labelColor=green&color=black)

5.  Look at a quick dataviz’ with `networkD3` :
    ![](https://img.shields.io/badge/%7BDataviz%7D-bold?style=flat&logoColor=black&logoSize=2&label=get-networkd3-from_igraph()&labelColor=yellow&color=black)

Planned features :
![](https://img.shields.io/badge/%7BMethod%7D-bold?style=flat&logoColor=black&logoSize=2&label=Text-mining&labelColor=orange&color=black)
![](https://img.shields.io/badge/%7BExport%7D-bold?style=flat&logoColor=black&logoSize=2&label=Reporting&labelColor=orange&color=black)

## Complete Example

Hereafter we use the default parameters, dedicated to analyze .R codes
files.

⏩ **1. Create a corpus a list of files path and/or url.**

List .R files, from url and/or on your locale machine :

    paths <- list.files(path = "~/", pattern = ".R$"
    , ignore.case = T, full.names = T, recursive = T) 

And/or from public github repo :

    paths <- codexplor::get_github_raw_filespath(repo = "tidyverse/readr", pattern = "\\.R")
    #  Return characters list of url of .R files from https://raw.githubusercontent.com/

⏩ **2. Read the files and get a citations network of func’.**

    net <- codexplor::get_text_network_from_files(paths, 
    regex_to_exclude_files_path = "test-", ignore_match_less_than_nchar = 5)
    # Return a data.frame, edgelist of the functions citations network

Assuming the user provide a list of files paths and/or url,
`get_text_network_from_files()` will :

- read the files, trying to extract a first pattern (e.g., defaults
  parameters will extract R functions names as soon as they are defined
  within a file).
- search for these patterns (functions names by default) in the contents
  of the files, in order to constitute a Citations Network (a directed
  type of document network).
- return the edgelist of the network (hereabove, we exclude files with
  “test-” in the file path and the matches with less than 5 char’, e.g.,
  `cli()` will not be matched since it’s a 3 letters function name).

⏩ **3. Get a directed `igraph` network object.**

    netig <- codexplor::get_igraph_from_df(net) 
    # return a directed 'igraph' object from our edgelist

⏩ **4. Get an interactive `networkD3` HTML object**

    codexplor::get_networkd3_from_igraph(netig) 

Return a list of 2 objects :

1.  a list named `'net3d'` with 2 data.frames, with the data used by
    `networkD3` (`'nodes'` and `'edges'`)

2.  a networkD3::forceNetwork S3 class object named `'forcenetwork'`, an
    html interactive network dataviz’

You should play with the parameters, e.g., coloring nodes depending on
their outdegrees :

     get_networkd3_from_igraph(netig, color_outdeg_instead_of_indeg = T) 

<figure>
<img src="man/figures/example_net3d_dataviz.png"
alt="The interactive network dataviz’" />
<figcaption aria-hidden="true">The interactive network
dataviz’</figcaption>
</figure>

⏩ **5. Get metrics and identifying cascading dependancies of func’**

Under construction \[🔧🔨\]

------------------------------------------------------------------------

There is several useful parameters to take care with, depending on the
languages you have to manage. Default is for a R programming project.

<!--
> `codexplor` help you to manage and analyze a programming project, giving you tools to figure out the big picture and to find the little wrench in the (net)work. 
&#10;> **Usecases 1.** As a head of a dozens of persons (non-tech) team', I have to dev' actively on the long run. codexplor help me to get the big picture of a large programming project quickly, with instant metrics & insights. Thanks to the network analysis and dataviz', I have deep insights about the project, such as for identifying theoritical vulnerability, for choosing where to start a polishing loop, but also for following a programming project over the long run. 
&#10;> **Usecases 2.** I can show the network or a small part of the network to the dev' and tech' profiles during our meetings or event prez'.
&#10;> **Usecases 3.** codexplor add insights on a particular function, as an help for the dev' when it come back on a project after a while (e.g., list all the local dependancies of a function and the functions that call it as a local dependancy).
&#10;-->
<!-- *Usecases of a quick programming project understanding*. codexplor goal is to *quickly* analyse your developing project, in order to *gain* time of comprehension, made your documentation, dataviz' of your project, etc. The features offered are crafted for coordinate large programming project, made helper func' for new colleagues and/or future you, formally identifying your higher-level func' and/or the most-frequently used as dependancies... and other handy features for priorizing your work by quickly figure out 'where' you have to pay attention. For example, before to change a parameter name in a func', you want to check what are the func' that used the one you want to modify. Same for changing the returned content or the behavior of a func' : you want to check which ones used this func' that you want to modify. You also want to offer an easy way to understand the chaining of your custom func'. -->

[^1]: functions that are called by others functions of the project
