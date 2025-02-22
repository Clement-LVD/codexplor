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
#' @param first_match_to_exclude `character` A vector of strings to exclude specific results
#' from the original matches. For example, you can exclude results like `"server"`.
#'
#' @param prefix_for_regex_from_the_text `character` A string representing the prefix to add
#' to each 1st match that will be turned into a new regular expressions. The default is an empty string.
#'
#' @param suffix_for_regex_from_the_text `character` A string representing a regex to add as a suffix
#'  of each match, in order to have a complete regular expression. The default is an empty string.
#'
#' @param filter_2nd_match_unmatched_lines `logical` Default = `TRUE` A logical value indicating whether to keep only lines
#' that match with the second pattern if set to `TRUE`, or keep all lines if set to `FALSE.`
#'
#' @param filter_first_match_results `logical`, default = `TRUE` A logical value indicating whether to apply the filter
#' for the first match. The default is TRUE.
#'
#' @param filter_egolink_within_a_file `logical` Default = `TRUE`. A logical value indicating whether to filter results based on
#' "ego links" (a document referring to itself)
#'
#'
#' @param ... Parameters passed to `construct_corpus()` and `srch_pattern_in_files_get_df()`. These parameters are
#' - characters values, e.g., adjusting yourself the "`pattern`" parameter that will be matched
#' - logical values, e.g., "`keep_comments = T`"
#' - integer values such as `ignore_match_less_than_nchar`, etc.
#'
#' @param file_path_from_colname `character` Default = `'from'` The column name (as a string) representing the "from" file path
#' in the result data frame.
#'
#' @param file_path_to_colname `character` Default = `'to'` The column name (as a string) representing the "to" file path in
#' the result data frame.
#'
#' @param match1_colname `character` Default = `'first_match'` The column name (as a string) for the first match in the result
#' data frame.
#'
#' @param match2_colname `character` Default = `'second_match'` The column name (as a string) for the second match in the result
#' data frame.
#'
#' @param line_number_match2_colname `character` Default = `'line_number'`  The column name (as a string) for the line number
#' of the second match in the result data frame.
#'
#' @param content_match1_col_name `character` Default = `'content_match_1'` The column name (as a string) for the full content of
#' the first match.
#'
#' @param content_match2_col_name `character` Default = `'content_match_2'`  The column name (as a string) for the full content of
#' the second match.

#'
#' @return A data frame wich is the edgelist of the citations network
#' columns 'from' and 'to' indicates the files paths or urls of the matched contents.
# ' There is other infos (line numbers, precise line matched for verification, etc.)
#'
#' @examples
#' # Example with url from github
#' result <- get_text_network_from_project(
#' folder_path =  "~",    ignore_match_less_than_nchar = 3, #'ui()', 'cli()', etc. are removed
#' first_match_to_exclude = c( "server") )
#'
#' # Will return a network of func' from the file path where called => to the file path were defined)
#'
#' @seealso \code{\link{construct_corpus}}, \code{\link{srch_pattern_in_files_get_df}}
#' @seealso [vignette("get_text_network_from_project")]
#' @export
get_text_network_from_project <- function(folder_path = NULL, repos = NULL

    , first_match_to_exclude = NULL

   , prefix_for_regex_from_the_text = "\\b" # text before the 1st match

   ,  suffix_for_regex_from_the_text = "\\("# add text after the 1st match


  # , regex_to_exclude_files_path = "test-|\\.Rcheck"

 , filter_2nd_match_unmatched_lines = TRUE

   , filter_first_match_results = TRUE

   , filter_egolink_within_a_file = TRUE


 , ...

 , file_path_from_colname = 'from'
 , file_path_to_colname = 'to'
 , match1_colname =  "first_match"

 ,  match2_colname ="second_match"
 , line_number_match2_colname = "line_number"
 , content_match1_col_name = "content_match_1" # we want to keep the full content very available

 , content_match2_col_name = "content_match_2" # we want to keep the full content very available


  ){
##### 1) Construct a corpus ####
 # we will rename in the end so var' names are hardcoded hereafter :
fn_network <- construct_corpus(local_folders_paths = folder_path,   repos = repos , file_path_col_name = "file_path"
                                            , content_col_name = "content", match_to_exclude = first_match_to_exclude
 , extracted_txt_col_name =   "first_match",  ...)



fn_network$row_number <- seq_len(nrow(fn_network))
#we will retrieve this object and these var later

# we have 3 informations that we used hereafter :
# full content + path + a first match (default try to match each func' definition)
regexx_complete <-get_regex_from_vector(fn_network$first_match,prefix_for_regex_from_the_text,suffix_for_regex_from_the_text, fix_escaping = T  )

#### 2) EXTRACT #2 ####
#  match every mention of our previous matches and returning a DF
fns_called_df <- str_extract_all_to_tidy_df(string = fn_network$content
                                            , pattern = regexx_complete
 , row_number_colname = "row_number" # we add row_number colname in both !
 , matches_colname = "second_match"
 , filter_unmatched = filter_2nd_match_unmatched_lines)

# but we have our pattern added (suffix or prefix) =>
fns_called_df$second_match <- gsub(x = fns_called_df$second_match
                                   , pattern = paste0("^", prefix_for_regex_from_the_text), replacement = "")

fns_called_df$second_match <- gsub(x = fns_called_df$second_match
     , pattern = paste0(  suffix_for_regex_from_the_text, "$"), replacement = "")
#### 5) take care of the network of func' ####
# reunite matches 1 and matches 2 =>
complete_network <- merge(fns_called_df, fn_network,
                    all.x = T # we preserve each 2nd match
                   , by = "row_number")
# lines will be duplicated if + than 1 match per line

# filter the network
# not empty first_match (func_defined) value indicate that this file mention his own match
# ('internal link', recursivity or func' definition) whereas other link refer to external link
if(filter_first_match_results){complete_network <- complete_network[ which(is.na(complete_network["first_match"])) , ] }

#in the begining we have made fn_network of file_path where we've match func' definition - by default
origines_files <- unique(fn_network[which(!is.na(fn_network$first_match)), c("first_match","file_path", "content")])
colnames( origines_files ) <- c("function", "defined_in", "definition_content") # renaming for hereafter

# take original files - begining of the code - for adding the path where a func' is defined and the name
returned_network <- merge(complete_network, origines_files
                          , by.x = "second_match"
                          , by.y = "function" # it was also 'first_match' so we've renamed
                          , all.x = TRUE)

returned_network <- returned_network[, c("file_path", "defined_in", "first_match", "second_match", "line_number", "content",  "definition_content")]

if(filter_egolink_within_a_file){returned_network <- returned_network[ which( returned_network["file_path"] != returned_network["defined_in"]) , ] }


colnames(returned_network) <- c(file_path_from_colname, file_path_to_colname, match1_colname, match2_colname, line_number_match2_colname, content_match2_col_name,  content_match1_col_name)
# finally givin the colname wanted by the user

return(returned_network)

}
