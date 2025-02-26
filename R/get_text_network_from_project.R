#' Get Text Network from folder path(s) and/or github repos
#'
#' This function read files in a specified folder (default to only .R files)
#' extracting and filtering text based on a set of criteria.
#'
#' It is designed to generate a network of text by cascading text research :
#'
#' 1st the func' try to match a pattern within the files, optionnaly filter the initial results.
#'
#' Then, a regex-pattern is constructed by appending all the 1st match
#'
#' and a 2nd research extract this pattern, and construct a network
#' (document with the 2nd match => document with the 1st match)
#'
#' @param folder_path  `character` A string or list representing the path(s) and/or url of local folders path to read.
#' @param repos  `character` A string or list representing the name(s) of github repos (e.g., 'tidyverse/stringr').
#'
#' @param prefix_for_regex_from_the_text `character` A string representing the prefix to add
#' to each 1st match that will be turned into a new regular expressions. The default is an empty string.
#'
#' @param suffix_for_regex_from_the_text `character` A string representing a regex to add as a suffix
#'  of each match, in order to have a complete regular expression. The default is an empty string.
#'
#' @param filter_egolink_within_a_file `logical`, default = `TRUE`. A logical value indicating whether to filter results based on
#' "ego links" (a document referring to itself)
#'
#' @param ... Parameters passed to `construct_corpus()` and `srch_pattern_in_files_get_df()`. These parameters are
#' - characters values, e.g., filter results with `match_to_exclude`, adjust the "`pattern`" parameter for matching functions names, etc.
#' - logical values, e.g., "`keep_comments = T`"
#' - integer values such as `ignore_match_less_than_nchar`, etc.
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
#' for the full line where a match have occured.
#' @param return_corpus `logical`, default = `FALSE` If set to `TRUE`, a list with the edgelist *and* the corpus be returned
#'
#' @return A `dataframe` symbolizing the edgelist of a document-to-document citations network
#' \describe{
#'   \item{\code{file_path}}{`character` The local file path or constructed GitHub URL.}
#'   \item{\code{line_number}}{`integer` The line number within the file.}
#'   \item{\code{content}}{`character` The content from a line.}
#'   \item{\code{match}}{`character` The matched text on this line, `NA` if there is no match.}
#' }
#' Note that a list with 2 entries is returned if the user indicates `return_corpus` = `TRUE`
#' 1st entry is the `dataframe` described hereabove. The 2nd entry is the corpus, see \code{\link{construct_corpus}}
#' Columns 'from' and 'to' indicates the files paths or urls of the matched contents.
#' There is other infos (line numbers, line matched and content for verification)
#' @examples
#' # Example with url from github
#' result <- get_text_network_from_project(folder_path =  "~" )
#' # Return a `df` (default is supposed to be a network of functions)
#' # (from the file where a function is call => to the file were defined)
#' result_list <- get_text_network_from_project(folder_path =  "~" , return_corpus = TRUE)
#' #Will return a list of 2 elements : the `df` of matches, and the complete corpus
#' @seealso \code{\link{construct_corpus}}, \code{\link{srch_pattern_in_df}}, \code{\link{get_citations_network_from_df}}
#' @seealso
#'   \url{https://clement-lvd.github.io/codexplor/articles/vignette_get_text_network_from_project.html}
#' @export
get_text_network_from_project <- function(folder_path = NULL, repos = NULL

   , prefix_for_regex_from_the_text = "\\b" # text before the 1st match

   ,  suffix_for_regex_from_the_text = "\\("# add text after the 1st match

   , filter_egolink_within_a_file = TRUE

 , ...

 , file_path_from_colname = 'from'
 , file_path_to_colname = 'to'
 , function_matched_colname =  "function"

 , line_number_matched_colname = "line_number"
 , content_matched_colname = "content_matched" # we want to keep the full content available

 , return_corpus = F
  ){


##### 1) Construct a lines corpus ####
 # We will rename in the end
fn_network <- construct_corpus(local_folders_paths = folder_path,   repos = repos ,  ...)


# 2.1) Get an HYBRID nodelist of the 1st matches and files path
# by default we're supposed to catch lines where functions are defined, but there is maybe several functions in a file
origines_files <- unique(fn_network[which(!is.na(fn_network$matches)), c("matches","file_path")])
names(origines_files)[names(origines_files) == "file_path"] <- "to"


# 2.2) add a proper "text" column (full content) = problems when several func' are defined in the same line
# files_content <- gather_df_lines(fn_network, "file_path", "content")
# files_content <- unique(files_content)
#
# test<- extract_nested_blocks_from_text(files_content$text[1])
#
# origines_files <- merge(all.x = T, origines_files, files_content, by.x = "to", by.y = "file_path")

#2.2) we'll just add a column of "function" here with the matched results : the func' will transform our 1st col' into a regex
fn_2nd_match <- get_citations_network_from_df(df = fn_network[, c("content", "matches", "file_path")]
                              , content_varname = "content"
                              , pattern_varname = "matches"
                            ,varname_for_matches = "function"
                            , prefix_for_regex_from_string = prefix_for_regex_from_the_text
                          , suffix_for_regex_from_string = suffix_for_regex_from_the_text
                                )

fn_2nd_match$matches <- NULL #lines with value are already suppressed
names(fn_2nd_match)[names(fn_2nd_match) == "file_path"] <- "from"

# take original files - begining of the code - for adding the path where a func' is defined and the name
returned_network <- merge(fn_2nd_match, origines_files #we just add a single column here : defined_in !
                          , by.x = c("function")
                          , by.y = c("matches" )# here we've renamed
                          , all.x = TRUE)

returned_network <- returned_network[, c("from", "to",  "function", "content", "row_number")]

if(filter_egolink_within_a_file){returned_network <- returned_network[ which( returned_network["from"] != returned_network["to"]) , ] }


colnames(returned_network) <- c(file_path_from_colname, file_path_to_colname, function_matched_colname, content_matched_colname,  line_number_matched_colname)
# finally givin the colname wanted by the user

if(return_corpus) return(list(edgelist = returned_network, corpus = fn_network))

return(returned_network)

}

