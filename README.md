
# codexplor

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
![R](https://img.shields.io/badge/R-black) [![CRAN
status](https://www.r-pkg.org/badges/version/codexplor)](https://CRAN.R-project.org/package=codexplor)
<!-- badges: end -->

🧰🔧🔨 `codexplor` is a WIP 🧰🔧🔨

`codexplor` offers R functions for explore, analyze and monitor a
programming project. These tools are aimed to manage a programming
project as a network of documents, with text-mining and network metrics
& dataviz’.

> Thanks to the immediate insights, dataviz’ and deep reports offered by
> `codexplor`, I understand the big picture of a programming project
> more efficiently.

### Installation

You can install the development version of codexplor with

``` r
devtools::install_github("clement-LVD/codexplor")
```

### Features

**Available feature :**
![.](https://img.shields.io/badge/%7BMethod%7D-bold?style=flat&logoColor=black&logoSize=2&label=Citations%20Network%20of%20internal%20dependencies&labelColor=black&color=green)

| Feature | ↓ Given a programming project : | ↓ Given a precise file : |
|:---|:---|:---|
| Network of internal dependencies | ⏩ Get rid of global complexity with **network metrics & dataviz’** (e.g., network of internal dependencies[^1]). | ⏩ Identify local complexity with **text-mining** and document-level metrics (e.g., length and files readability). |

**Planned features :**
![.](https://img.shields.io/badge/%7BMethod%7D-bold?style=flat&logoColor=black&logoSize=2&label=Text-mining%20metrics&labelColor=grey&color=orange)
![.](https://img.shields.io/badge/%7BExport%7D-bold?style=flat&logoColor=black&logoSize=2&label=Reporting&labelColor=grey&color=orange)
![.](https://img.shields.io/badge/%7BExport%7D-bold?style=flat&logoColor=black&logoSize=2&label=Network-advanced&labelColor=grey&color=orange)

**Supported programming languages :**
![.](https://img.shields.io/badge/R-green)

Other languages are planned[^2].

### Example : Explore a network of internal dependancies

1.  Given folders path(s) and/or github repo(s), compute a *citations
    network* of the functions with
    ![.](https://img.shields.io/badge/%7BMethod%7D-bold?style=flat&logoColor=black&logoSize=2&label=get_text_network_from_project()&labelColor=yellow&color=black)

         net <-  get_text_network_from_project(repos = c("tidyverse/stringr", "clement-LVD/codexplor") )
         # Return a data.frame, edgelist of a citations network

- See the vignette of
  [get_text_network_from_project()](https://clement-lvd.github.io/codexplor/articles/vignette_get_text_network_from_project.html)

2.  Look an *interactive dataviz’* with `networkD3` :
    ![.](https://img.shields.io/badge/%7BDataviz%7D-bold?style=flat&logoColor=black&logoSize=2&label=get_networkd3_from_igraph()&labelColor=yellow&color=black)

        codexplor::get_networkd3_from_igraph(net)
        # Return an interactive dataviz' from networkD3

By default, nodes are colorized accordingly to their indegrees, in order
to reveal the local dependancies of the programming project
(i.e. functions used by others files of the project).

<figure>
<img src="man/figures/example_net3d_dataviz.png" alt="." />
<figcaption aria-hidden="true">.</figcaption>
</figure>

*(codexplor functions network are truncated)*

Hereabove, we see that the most-common local dependancy inside the
tidyverse/stringr repo is `compat-types-check.R`. One of the `codexplor`
file actually rely on a `stringr`method, but the opposite is not true
(i.e. `codexplor::str_extract_all_to_tidy_df.R` rely on
`stringr/extract.R`, but no file of stringr rely on codexplor).

Play with the parameters reveal others insights, e.g., you should try to
color nodes accordingly to their outdegrees, in order to reveal the
high-level files of the project.

> Get rid of complexity with a broader perspective on the project !

## Vignettes

`codexplor` offers text-mining protocols, but also tools for managing
your own analysis. See the vignettes about :

⏩ Turning a programming project into a corpus with
[construct_corpus()](https://clement-lvd.github.io/codexplor/articles/construct_a_corpus.html)

⏩ Turning an edgelist into an igraph object and filter it with [helper
functions for manage igraph
objects](https://clement-lvd.github.io/codexplor/articles/manage_igraph_object.html)

⏩ *Get metrics and identifying problematic patterns (e.g., cascading
dependancies of func’)*

*WIP* \[🔧🔨\]

### Crafting your own corpus with codexplor

Depending on the languages you have to manage, you’ll want to tweak the
‘pattern’ used for match a function definition, since for now
`codexplor` support only the R programming language (other languages are
planned).

<!--
⏩ **4. Get an interactive `networkD3` HTML object**
&#10; 
`get_networkd3_from_igraph()` Return a list of 2 objects : 
&#10;1. a list named `'net3d'` with 2 data.frames, with the data used by `networkD3` (`'nodes'` and `'edges'`)
&#10;2. a networkD3::forceNetwork S3 class object named `'forcenetwork'`, an html interactive network dataviz'
&#10;-->
<!--
> `codexplor` help you to manage and analyze a programming project, giving you tools to figure out the big picture and to find the little wrench in the (net)work. 
&#10;> **Usecases 1.** As a head of a dozens of persons (non-tech) team', I have to dev' actively on the long run. codexplor help me to get the big picture of a large programming project quickly, with instant metrics & insights. Thanks to the network analysis and dataviz', I have deep insights about the project, such as for identifying theoritical vulnerability, for choosing where to start a polishing loop, but also for following a programming project over the long run. 
&#10;> **Usecases 2.** I can show the network or a small part of the network to the dev' and tech' profiles during our meetings or event prez'.
&#10;> **Usecases 3.** codexplor add insights on a particular function, as an help for the dev' when it come back on a project after a while (e.g., list all the local dependancies of a function and the functions that call it as a local dependancy).
&#10;-->
<!-- *Usecases of a quick programming project understanding*. codexplor goal is to *quickly* analyse your developing project, in order to *gain* time of comprehension, made your documentation, dataviz' of your project, etc. The features offered are crafted for coordinate large programming project, made helper func' for new colleagues and/or future you, formally identifying your higher-level func' and/or the most-frequently used as dependancies... and other handy features for priorizing your work by quickly figure out 'where' you have to pay attention. For example, before to change a parameter name in a func', you want to check what are the func' that used the one you want to modify. Same for changing the returned content or the behavior of a func' : you want to check which ones used this func' that you want to modify. You also want to offer an easy way to understand the chaining of your custom func'. -->

[^1]: Local dependencies are functions that are called by others
    functions of the project

[^2]: Current list of planned supported languages is : R, Python,
    JavaScript, Java, C, Cpp, Go
