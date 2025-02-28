#' Turn a programing project into a Documents Network
#'
#' This function craft a corpus, according to the default settings. It will
#' return the corpus with a citations network of internal dependancies
#'
#' @param folders  `character` A string or list representing the path(s) of local folders path to read.
#' @param repos  `character` A string or list representing the name(s) of github repos (e.g., 'tidyverse/stringr').
#' @param languages `character`. Default = `"R"`. A character vector specifying the programming language(s) to include in the corpus.
#' @param ... Parameters passed to `compute_doc_network_from_corpus()`. These parameters are
#' - characters values, in order to add a prefix and a suffix to the pattern searched (e.g., `suffix_for_2nd_matches`)
#' or changing the colnames (e.g., `file_path_from_colname`).
#' - logical values, e.g., "`filter_egolink_within_a_file`" (default = `TRUE`)
#' @return A `list` of 4 `dataframe` : 2 of class `corpus.lines`, 1 `corpus.nodelist` and 1 `citations.network`
#'   (symbolizing the edgelist of a document-to-document citations network within a programming project)
#' \describe{
#'   \item{\code{from}}{`character` Citations Network - The local file path or GitHub URL that call a function.}
#'   \item{\code{to}}{`character` Citations Network - The local file path or constructed GitHub URL where the function called is defined.}
#'   \item{\code{file_path}}{`character` Corpus - The local file path or constructed GitHub URL.}
#'   \item{\code{line_number}}{`integer` Corpus - The line number within the file.}
#'   \item{\code{content}}{`character` Corpus - The content from a line.}
#'   \item{\code{match}}{`character` Corpus - The matched text on this line, `NA` if there is no match.}
#' }
#' @examples
#' # Example with url from github
#' result <- get_doc_network_from_project(folder =  "~" )
#' # Return a list of df
#' # (from the file where a function is call => to the file were defined)
#' @seealso \code{\link{construct_corpus}}, \code{\link{srch_pattern_in_df}}, \code{\link{get_citations_network_from_df}}
#' @seealso
#'   \url{https://clement-lvd.github.io/codexplor/articles/vignette_construct_a_corpus.html}
#'   \url{https://clement-lvd.github.io/codexplor/articles/vignette_construct_a_corpus.html}
#' @export
get_doc_network_from_project <- function(folders = NULL, repos = NULL, languages = "R", ...){

##### 1) Construct a lines corpus ####
 # We will rename in the end
corpus <- construct_corpus(folders = folders,   repos = repos, languages = languages)

corpus <- compute_doc_network_from_corpus(corpus = corpus, ...)

return(corpus)}

