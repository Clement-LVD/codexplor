
<!-- README.md is generated from README.Rmd. Please edit that file -->

# codexplor

🧰🔧🔨 UNDER CONSTRUNCTION 🧰🔧🔨 <!-- badges: start --> [![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/codexplor)](https://CRAN.R-project.org/package=codexplor)
<!-- badges: end -->

The goal of codexplor is to Explore Your Codes Files, with a bunch of
dedicated func’. Soon, you should try to :

⏩ Get a network of func’ iby passing a folder path to
get_text_network_from_files()

⏩ Get metrics and identifying cascading dependancies of func’ \[🔧🔨\]

⏩ Identifying your higher-level func’ and visualize the ones they
launch \[🔧🔨\]

⏩ Made some cool dataviz’ about your func’ network \[🔧🔨\]

And other features, more or less useful for coordinate large programming
project, made helper func’ for new colleagues and/or future you, and
chill in front of cool megalomaniac dataviz about your programming
world.

## Installation

You can’t install the development version of codexplor yet

``` r
cat("...")
```

## Example

Assuming you have a R folder full of custom R func’ :

`fn_net <- get_text_network_from_files()`

Will read all files in the folder, and extract all text from the 1st
regex you provided, then construct a regex from the result (i.e. pasted
together with the “\|” separator and optionnally adding a suffix and
prefix defined by the user) Then, a 2nd search is made in the content to
extract, and this lead to a network (from file path with 2nd match =\>
to file path with first match) For example the default will try to catch
a basic func’ definition, extracting the text before this definition.
Then, givin’ the previous matches (supposed as ‘function names’) you’ll
extract all matches of these text in the original files.

``` r
library(codexplor)
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

I can also embed plots but it’s cool to forget to replace the default
url :
