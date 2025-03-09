#' Compute a Citations Network of functions form a corpus_list `dataframe`
#'
#' This function read a standard `list` of `data.frame` (class `corpus.list`)
#' select the `codes` `data.frame` and append a Citations Network to the corpus
#' (see hereafter). The classes of this new entry are `data.frame` `citations.network`
#'
#' It is designed to generate a network of text by cascading text research,
#' assuming the 1st matches are already realized by `construct_corpus` :
#'
#' The function will craft a pattern by appending all the 1st matches (`matches` column elements)
#' , eventually adding a suffix and a prefix to these elements.
#'
#' Then it will perform a direct extraction with this pattern,
#'  and return the corpus with a new `data.frame` of class `citations.network`
#' (document with the 2nd match => document with the 1st match).
#' By default, egolinks are removed since `filter_egolink_within_a_file` default is `TRUE`
#'
#' @param corpus `character` A `corpus.list` object from the construct_corpus function
#' @param prefix_for_2nd_matches `character` A string representing the prefix to add
#' to each 1st match that will be turned into a new regular expressions. The default is an empty string.
#'
#' @param suffix_for_2nd_matches `character` A string representing a regex to add as a suffix
#'  of each match, in order to have a complete regular expression. The default is an empty string.
#' @param n_char_to_add_suffix `double`, default = `3` Minimum number of characters to add the suffix.
#' @param filter_egolink_within_a_file `logical`, default = `TRUE`. A logical value indicating whether to filter results based on
#' "ego links" (a document referring to itself)
#'
#' @param exclude_quoted_content `logical`, default = `FALSE`. A logical value indicating if the quoted content should be take into consideration.
#'  If set to `TRUE`, text within " or ' over the same line will be suppressed, before to realize the matches
#'
#' @param file_path_from_colname `character`, default = `'from'` The column name (as a string) representing the "from" file path
#' in the result data frame.
#'
#' @param file_path_to_colname `character`, default = `'to'` The column name (as a string) representing the "to" file path in
#' the result data frame.
#'
#' @param function_matched_colname `character`, default = `'function'` The column name for the matched text
#' (default is a function name) in the result data frame.
#'
#' @param line_number_matched_colname `character`, default = `'line_number'`  The column name (as a string) for the line number
#' of the second match in the result data frame.
#'
#' @param content_matched_colname `character`, default = `'content_matched'` The column name (as a string)
#' for the full line where a match have occurred.
#' @param order_fn_called_colname `character`, default = `'order_call'` The order of the functions called in a file, based on line number.
#'
#' @return A `list` of `dataframe` symbolizing the edgelist of a document-to-document citations network
#' \describe{
#'   \item{\code{from}}{`character` Citations Network - The local file path or GitHub URL that call a function.}
#'   \item{\code{to}}{`character` Citations Network - The local file path or constructed GitHub URL where the function called is defined.}
#'   \item{\code{file_path}}{`character` Corpus - The local file path or constructed GitHub URL.}
#'   \item{\code{line_number}}{`integer` Corpus - The line number within the file.}
#'   \item{\code{content}}{`character` The content where a match could occur (`citations.network`), within a file (`corpus.nodelist`) or a line (`corpus.lines`).}
#'   \item{\code{match}}{`character` Corpus - The matched text on this line, `NA` if there is no match.}
#' }
#' @examples {
#' # Example with local folder path
#' corpus <- construct_corpus(folders =  "~", languages = "R")
#' corpus <- add_doc_network_to_corpus(corpus)
#' # Return a list of df (1st one is supposed to be an edgelist)
#' # (from the file where a function is call => to the file were defined)
#' }
#' @seealso \code{\link{construct_corpus}}, \code{\link{srch_pattern_in_df}}, \code{\link{get_citations_network_from_df}}
#' @seealso
#'   \url{https://clement-lvd.github.io/codexplor/articles/vignette_construct_corpus.html}
#' @importFrom stats ave
#' @export
add_doc_network_to_corpus <- function(corpus

   , prefix_for_2nd_matches = "\\b" # text before the 1st match

   ,  suffix_for_2nd_matches = "\\("# add text after the 1st match

   , n_char_to_add_suffix = 3

   , filter_egolink_within_a_file = TRUE

 , exclude_quoted_content = F

 , file_path_from_colname = 'from'
 , file_path_to_colname = 'to'
 , function_matched_colname =  "function"

 , line_number_matched_colname = "line_number"
 , content_matched_colname = "content" # we want to keep the full content available

 , order_fn_called_colname = "order"

  ){

  # Check if it's a corpus.lines from construct_corpus
  if (!"corpus.list" %in% attr(corpus, "class")) {
    stop("You have to pass a corpus.list list of data.frame, constructed with construct_corpus.")
  }

  # Check if it's a corpus.lines from construct_corpus
  if ("citations.network" %in% attr(corpus, "class")) {
    warning("The corpus already have a citations.network data.frame (will be updated by a new one).")
  }

##### 1) Construct a lines corpus ####
 # We will rename column in the end
fn_network <- corpus$functions # we have our standard class for ensuring boring test about column if necessary

if(exclude_quoted_content) fn_network$content <-  censor_quoted_text(text = fn_network$content)

# 2.1) Get an HYBRID nodelist of the 1st matches and files path (default names from the corpus func')
# by default we're supposed to catch lines where functions are defined, but there is maybe several functions in a file
origines_files <- unique(fn_network[which(!is.na(fn_network$name)), c("name","file_path")])

names(origines_files)[names(origines_files) == "file_path"] <- "to"

#2.2) we'll just add a column of "function" here with the matched results : the func' will transform our 1st col' into a regex
fn_2nd_match <- get_citations_network_from_df(df = fn_network[, c("content", "name", "file_path")]
                              , content_varname = "content"
                , pattern_varname = "name" # all names will be concatenated
                            ,varname_for_matches = "function" # and return a "function" variable
                            , prefix_for_regex_from_string = prefix_for_2nd_matches
                          , suffix_for_regex_from_string = suffix_for_2nd_matches
                          ,  keep_only_row_without_a_pattern = FALSE
                ,  n_char_to_add_suffix = n_char_to_add_suffix
                )

names(fn_2nd_match)[names(fn_2nd_match) == "file_path"] <- "from"

fn_2nd_match <- fn_2nd_match[!duplicated(fn_2nd_match), ]

# take original files - begining of the code - for adding the path where a func' is defined and the name
returned_network <- merge(fn_2nd_match, origines_files #we just add a single column here : defined_in !
                          , by.x = "function"# here we've renamed "matches (!)
                          , all.x = TRUE)

returned_network <- returned_network[, c("from", "to", "function", "content", "row_number")]

if(filter_egolink_within_a_file){ # (optionnal) REMOVE egolinks means no recursivity in the results !
returned_network <- returned_network[ which( returned_network["from"] != returned_network["to"]) , ] }

# give the colname wanted by the user in order to ensure stability of the code about this network
colnames(returned_network) <- c(file_path_from_colname, file_path_to_colname, function_matched_colname, content_matched_colname,  line_number_matched_colname)

# Compute the order after removing autolinks : this will be our last col
returned_network[[order_fn_called_colname]] <- ave(
  seq_along(returned_network[[line_number_matched_colname]]),
  returned_network[[file_path_from_colname]],
  FUN = seq_along
)

# set a valid class (in order to pass tests from .construct.corpus.list)
returned_network <- structure(returned_network, class = c( "citations.network", 'internal.dependancies', "data.frame") )

#### Update the attributes and return an augmented corpus ####
corpus <- .construct.corpus.list(corpus = corpus, df_to_add = list(internal.dependencies = returned_network ) )

return(corpus)

}

