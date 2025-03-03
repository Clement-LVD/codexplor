#' Turn a programing project into a Documents Network
#'
#' This function craft a corpus, according to the default settings. It will
#' return the corpus with a citations network of internal dependancies
#'
#' @param folders  `character` A string or list representing the path(s) of local folders path to read.
#' @param repos  `character` A string or list representing the name(s) of github repos (e.g., 'tidyverse/stringr').
#' @param languages `character`. Default = `"R"`. A character vector specifying the programming language(s) to include in the corpus.
#' @param ... Parameters passed to `add_doc_network_to_corpus()`. These parameters are
#' - characters values, in order to add a prefix and a suffix to the pattern searched (e.g., `suffix_for_2nd_matches`)
#' or changing the colnames (e.g., `file_path_from_colname`).
#' - logical values, e.g., "`filter_egolink_within_a_file`" (default = `TRUE`)
#' @return A `list` of 4 `dataframe` : 2 of class `corpus.lines`, 1 `corpus.nodelist` and 1 `citations.network`
#'   (symbolizing the edgelist of a document-to-document citations network within a programming project)
#' \describe{
#'   \item{\code{from}}{`character` citations.network - The local file path or GitHub URL that call a function.}
#'   \item{\code{to}}{`character` citations.network - The local file path or constructed GitHub URL where the function called is defined.}
#'   \item{\code{function}}{`character` citations.network - The name of the function matched on a line.}
#'   \item{\code{content_matched}}{`character` citations.network - The full content matched with the 2nd matches, in order to verify and craft a new regex.}
#'   \item{\code{line_number}}{`character` citations.network & corpus.lines - The line number of the 2nd match (citation.network) or associated with a line (corpus.lines).}
#'   \item{\code{file_path}}{`character` corpus.lines & corpus.nodelist - The local file path or constructed GitHub URL, same values as the `from` & `to` columns of the citations.network df.}
#'   \item{\code{content}}{`character` corpus.lines - The content from a line.}
#'   \item{\code{matches}}{`character` corpus.lines (specifically the `codes` data.frame)
#'   - The matched text during the 1st matches (full of `NA` if there is no match or if they are filtered out, the default).}
#' }
#' @examples
#' # Example with url from github
#' result <- get_doc_network_from_project(folder =  "~" )
#' # Return a list of df
#' # (from the file where a function is call => to the file were defined)
#' @seealso \code{\link{construct_corpus}}, \code{\link{srch_pattern_in_df}}, \code{\link{get_citations_network_from_df}}
#' @seealso
#'   \url{https://clement-lvd.github.io/codexplor/articles/vignette_analyse_citations_network_from_project.html}
#'   \url{https://clement-lvd.github.io/codexplor/articles/vignette_construct_corpus.html}
#'   \url{https://clement-lvd.github.io/codexplor/articles/vignette_citations.network_df_of_internal.dependencies.html}
#' @export
get_doc_network_from_project <- function(folders = NULL, repos = NULL, languages = "R", ...){

##### 1) Construct a lines corpus ####
 # We will rename in the end
corpus <- construct_corpus(folders = folders,   repos = repos, languages = languages)

corpus <- add_doc_network_to_corpus(corpus = corpus, ...)

# compute stats
corpus <- add.stats.corpus.list(corpus)

#get report (todo)

return(corpus)}

