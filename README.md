
# codexplor

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
![R](https://img.shields.io/badge/R-black) [![CRAN
status](https://www.r-pkg.org/badges/version/codexplor)](https://CRAN.R-project.org/package=codexplor)
<!-- badges: end -->

🧰🔧🔨 UNDER CONSTRUCTION 🧰🔧🔨

`codexplor` offers R functions for explore and monitor a programming
project : get immediate insights on a programming project with
text-mining metrics, network analysis & dataviz’.

**Installation.** You can install the development version of codexplor
with

``` r
devtools::install_github("clement-LVD/codexplor")
```

### Features

<figure>
<img
src="https://img.shields.io/badge/%7BMethod%7D-bold?style=flat&amp;logoColor=black&amp;logoSize=2&amp;label=Citations%20Network%20of%20internal%20dependencies&amp;labelColor=black&amp;color=green"
alt="↓ Given a programming project :" />
<figcaption aria-hidden="true">↓ Given a programming project
:</figcaption>
</figure>

⏩ Get rid of global complexity with **network metrics & dataviz’**,
such as a network of internal dependencies[^1].

⏩ Assess local complexity with **Text-mining** and document-level
metrics, e.g., length and files readability.

**Supported programming languages :**
![.](https://img.shields.io/badge/R-green)

Other languages are planned[^2].

**Planned features.**
![.](https://img.shields.io/badge/%7BMethod%7D-bold?style=flat&logoColor=black&logoSize=2&label=Text-mining%20metrics&labelColor=grey&color=orange)
![.](https://img.shields.io/badge/%7BExport%7D-bold?style=flat&logoColor=black&logoSize=2&label=Reporting&labelColor=grey&color=orange)
![.](https://img.shields.io/badge/%7BExport%7D-bold?style=flat&logoColor=black&logoSize=2&label=Network-advanced&labelColor=grey&color=orange)

### Example : Explore a network of internal dependancies

1.  Given folders path(s) and/or github repo(s), get a Citations Network
    of the functions with
    ![.](https://img.shields.io/badge/%7BMethod%7D-bold?style=flat&logoColor=black&logoSize=2&label=get_text_network_from_project()&labelColor=yellow&color=black)

         net <-  get_text_network_from_project(repos = c("tidyverse/stringr", "clement-LVD/codexplor") )
         # Return a data.frame, edgelist of a citations network

2.  Look an interactive dataviz’ with `networkD3` :
    ![.](https://img.shields.io/badge/%7BDataviz%7D-bold?style=flat&logoColor=black&logoSize=2&label=get_networkd3_from_igraph()&labelColor=yellow&color=black)

        codexplor::get_networkd3_from_igraph(net) 

<figure>
<img src="man/figures/example_net3d_dataviz.png" alt="." />
<figcaption aria-hidden="true">.</figcaption>
</figure>

By default, ingoing links are colorized on this dataviz, in order to
reveal the local dependancies of the project (i.e. functions used by
others files of the project). Hereabove, we see that the most-common
local dependancy inside the tidyverse/stringr repo is
`compat-types-check.R`. One of the codexplor functions actually rely on
a stringr/extract.R function - codexplor functions network is truncated
on the herabove picture, but the opposite is not true.

Play with the parameters reveal others insights, e.g., you should try to
color nodes accordingly to their outdegrees - the number of functions
they call, in order to reveal the high-level files of the project.

> Get rid of complexity with a broader perspective on the project !

## Vignettes

`codexplor` offers several protocols & parameters to take care with. See
the vignettes about the text-analysis protocols offered by `codexplor`,
such as :

- [Turning a programming project into a
  text-network](https://clement-lvd.github.io/codexplor/articles/vignette_get_text_network_from_project.html)

Or familiarize yourself with the specialized tools offered by
`codexplor`, such as :

- [Turn a programming project into a corpus with
  construct_corpus()](https://clement-lvd.github.io/codexplor/articles/construct_a_corpus.html)
- [Turn it into an igraph object, filter and manage it with helper
  functions](https://clement-lvd.github.io/codexplor/articles/manage_igraph_object.html)

Depending on the languages you have to manage, you’ll want to tweak the
‘pattern’ used for match a function definition. The user must be
familiar with text-mining & network methods since - for now -
`codexplor` only support the R programming language (other languages are
planned).

<!--
⏩ **4. Get an interactive `networkD3` HTML object**
&#10; 
`get_networkd3_from_igraph()` Return a list of 2 objects : 
&#10;1. a list named `'net3d'` with 2 data.frames, with the data used by `networkD3` (`'nodes'` and `'edges'`)
&#10;2. a networkD3::forceNetwork S3 class object named `'forcenetwork'`, an html interactive network dataviz'
&#10;-->

⏩ *Get metrics and identifying problematic patterns (e.g., cascading
dependancies of func’)*

Under construction \[🔧🔨\]

<!--
> `codexplor` help you to manage and analyze a programming project, giving you tools to figure out the big picture and to find the little wrench in the (net)work. 
&#10;> **Usecases 1.** As a head of a dozens of persons (non-tech) team', I have to dev' actively on the long run. codexplor help me to get the big picture of a large programming project quickly, with instant metrics & insights. Thanks to the network analysis and dataviz', I have deep insights about the project, such as for identifying theoritical vulnerability, for choosing where to start a polishing loop, but also for following a programming project over the long run. 
&#10;> **Usecases 2.** I can show the network or a small part of the network to the dev' and tech' profiles during our meetings or event prez'.
&#10;> **Usecases 3.** codexplor add insights on a particular function, as an help for the dev' when it come back on a project after a while (e.g., list all the local dependancies of a function and the functions that call it as a local dependancy).
&#10;-->
<!-- *Usecases of a quick programming project understanding*. codexplor goal is to *quickly* analyse your developing project, in order to *gain* time of comprehension, made your documentation, dataviz' of your project, etc. The features offered are crafted for coordinate large programming project, made helper func' for new colleagues and/or future you, formally identifying your higher-level func' and/or the most-frequently used as dependancies... and other handy features for priorizing your work by quickly figure out 'where' you have to pay attention. For example, before to change a parameter name in a func', you want to check what are the func' that used the one you want to modify. Same for changing the returned content or the behavior of a func' : you want to check which ones used this func' that you want to modify. You also want to offer an easy way to understand the chaining of your custom func'. -->

[^1]: functions that are called by others functions of the project

[^2]: Current list of planned supported languages is : R, Python,
    JavaScript, Java, C, Cpp, Go
