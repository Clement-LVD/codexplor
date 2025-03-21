#' Compute a Citations Network of functions form a corpus_list `dataframe`
#'
#' This function read a standard `list` of `data.frame` (class `corpus.list`)
#' select the `functions` `data.frame` and append a Citations Network to the corpus
#' (see hereafter). The classes of this new entry are `data.frame` `citations.network`
#'
#' It is designed to generate a network of text by cascading text research,
#' assuming the 1st matches are already realized by `construct_corpus` :
#'
#' The function will craft a pattern by appending all the 1st matches (`matches` column elements)
#' , adding a prefix to these elements and maybe a suffix (depending on the number of characters).
#'
#' Then it will perform a direct extraction with this pattern,
#'  and return the corpus with a new `data.frame` of class `citations.network`
#' (document with the 2nd match => document with the 1st match).
#' By default, egolinks are removed since `filter_egolink_within_a_file` default is `TRUE`
#'
#' @param corpus `character` A `corpus.list` object from the construct_corpus function
#' @param matches_colname `character`, default = `'name'` The name of the column of the `functions` df that will be used for construct a regex.
#' @param content_colname `character`, default = `'code'` The name of the column of the `functions` df that will be used for search a match and extract text.
#' @param prefix_for_2nd_matches `character` A string representing the prefix to add
#' to each 1st match that will be turned into a new regular expressions. The default is an empty string.
#' @param suffix_for_2nd_matches `character` A string representing a regex to add as a suffix
#'  of each match, in order to have a complete regular expression. The default is an empty string.
#' @param filter_egolink_within_a_file `logical`, default = `TRUE`. A logical value indicating whether to filter results based on
#' "ego links" (a document referring to itself)
#'
#' @param exclude_quoted_content `logical`, default = `FALSE`. A logical value indicating if the quoted content should be take into consideration.
#'  If set to `TRUE`, text within " or ' over the same line will be suppressed, before to realize the matches
#' @return A `list` of `data.frame`, with a supplementary df that is the edgelist of a document-to-document citations network
#' \describe{
#'   \item{\code{from}}{`character` Citations Network - The local file path or GitHub URL that call a function.}
#'   \item{\code{to}}{`character` Citations Network - The local file path or constructed GitHub URL where the function called is defined.}
#'   \item{\code{file_path}}{`character` Corpus - The local file path or constructed GitHub URL.}
#'   \item{\code{file_path_from}}{`character` The file_path of the 'from' function.}
#'   \item{\code{function_order}}{`character` The order of citation within a text entry.}
#'   \item{\code{n_fn_call}}{`integer` The number of call of a function defined in another file.}
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
                                      , matches_colname = "name"
                                      , content_colname = "code"

                                      , prefix_for_2nd_matches = "(?<!\\w)" # text before the 1st match

                                      ,  suffix_for_2nd_matches = "(\\b|\\()"# add text after the 1st match

                                      , filter_egolink_within_a_file = TRUE

                                      , exclude_quoted_content = F

){


  # Check if it's a corpus.lines from construct_corpus
  if (!"functions" %in% names(corpus)) {
    stop("You have to pass a corpus.list list of data.frame with a functions entry (df).")
  }
if(nrow(corpus$functions ) == 0) { return(corpus)  }
  # Check if it's a corpus.lines from construct_corpus
  if ("citations.network" %in% attr(corpus, "class")) {
    warning("The corpus already have a citations.network data.frame (will be updated by a new one).")
  }

  ##### 1) Construct a lines corpus ####
  # we want a doc-to-doc network and chapter network (i.e. functions network)
  # We will rename column in the end
  fn_network <- corpus$functions # we have our standard class for ensuring boring test about column if necessary
  fn_network <- unique(fn_network[which(!is.na(fn_network[[matches_colname]])), ])

  if(exclude_quoted_content) fn_network[[content_colname]] <- censor_quoted_text(text =   fn_network[[content_colname]])

  # 2.1) Get an HYBRID nodelist of the 1st matches and files path (default names from the corpus func')
  # by default we're supposed to catch lines where functions are defined, but there is maybe several functions in a file

  #c("name","file_path") # we ask for a precise variable : doc-to-doc is file.path / func-to-func is name

  #2.2) we'll just add a column of "function" here with the matched results : the func' will transform our 1st col' into a regex
  fn_2nd_match <- get_citations_network_from_df(df = fn_network[, unique(c(content_colname, matches_colname, "file_path"))] #, "file_path"
                                                , content_varname =content_colname
                                                , pattern_varname = matches_colname # all names will be concatenated
                                                ,varname_for_matches = "function" # and return a "function" variable : the matched text
                                                , prefix_for_regex_from_string = prefix_for_2nd_matches
                                                , suffix_for_regex_from_string = suffix_for_2nd_matches
                                                ,  keep_only_row_without_a_pattern = FALSE
  )

  colnames(fn_2nd_match)[colnames(fn_2nd_match) == matches_colname] <- "from" # construct colnames : 2nd matches are "from"
  colnames(fn_2nd_match)[colnames(fn_2nd_match) == "file_path"] <- "file_path_from" # since they call a func
  colnames(fn_2nd_match)[colnames(fn_2nd_match) ==  "function"] <- "to" # and our matched names are the "to" called func

     # if there is a key within the original files - begining of the code - we add the path where a func' is defined and the name
 returned_network <- merge(fn_2nd_match
              ,  corpus$functions[, c(matches_colname,"file_path")]
               , by.x = "to"
               , by.y = matches_colname #"name"we just add a single column here, e.g., defined_in
                , all.x = TRUE)
 colnames(returned_network)[colnames(returned_network) == "file_path"] <- "file_path_to" # they call this func


  if(filter_egolink_within_a_file){ # (optionnal) REMOVE egolinks means no recursivity in the results !
    returned_network <- returned_network[ which( returned_network["from"] != returned_network["to"]) , ] }

  # give the colname wanted by the user in order to ensure stability of the code about this network

  # Compute the order after removing autolinks : this will be our last col
  returned_network[["function_order"]] <- stats::ave(
    seq_along(returned_network[["to"]]),
    returned_network[['from']],
    FUN = seq_along
  )

  returned_network <- returned_network[, c("from", "to", "function_order", "file_path_from", "file_path_to" )] #, "row_number" if we work on lines !

  # set a valid class (in order to pass tests from .construct.corpus.list)
  returned_network <- structure(returned_network, class = c( "citations.network", 'internal.dependancies', "data.frame") )

  #### And compute a files network with file_path_from & file_path_to
  files.network <- as.data.frame(table(returned_network$file_path_from, returned_network$file_path_to))
  files.network <- files.network[files.network$Freq > 0, ]
  # table : answer a 'Freq' column
colnames(files.network) <- c("from", "to", "freq")
files.network <- structure(files.network, class = c( "citations.network", 'internal.dependancies', "data.frame") )

# construct a list entry
returned_entry <- list(functions.network = returned_network, files.network= files.network)

    #### Update the attributes and return an augmented corpus ####
  corpus <- .construct.corpus.list(corpus = corpus, df_to_add = returned_entry )


  return(corpus)

}
