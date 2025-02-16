#' Get Text Network from Files
#'
#' This function read files in a specified folder (default to only .R files)
#' extracting and filtering text based on a set of criteria.
#' It is designed to generate a network of text by cascading (regex) research :
#' 1st the func' try to match a pattern within the files, optionnaly filter the initial results.
#' Then, a regex-pattern is constructed by appending all the 1st match
#' and a 2nd research extract this text and construct a network
#' (1st match finded => exact same text matched elsewhere).
#'
#' @param files_path A string representing the path and/or url of the files
#' to read.
#'
#' @param ignore_match_less_than_nchar Integer that specifies the number of
#' characters for the 1st match to be considered valid. The default is 3.
#'
#' @param first_match_to_exclude A vector of strings to exclude specific results
#' from the original matches. For example, you can exclude results like `"server"`.
#'
#' @param suffix_for_regex_from_the_text A string representing the suffix (a non-letter or
#' non-digit character) to match in the text using regular expressions. The default is an
#' empty string.
#'
#' @param prefix_for_regex_from_the_text A string representing the prefix to match in the
#' text using regular expressions. The default is an empty string.
#'
#' @param regex_to_exclude_files_path A regular expression pattern to exclude certain
#' files based on their paths. For example, `"test-"` can be used to exclude files whose
#' path includes the word "test". The default is NULL, meaning no files are excluded by path.
#'
#' @param filter_2nd_match_unmatched_lines A logical value indicating whether to filter
#' lines that do not match the second pattern. The default is TRUE.
#'
#' @param filter_first_match_results A logical value indicating whether to apply the filter
#' for the first match. The default is TRUE.
#'
#' @param filter_ego_link A logical value indicating whether to filter results based on
#' "ego links". The default is TRUE.
#'
#' @param file_path_from_colname The column name (as a string) representing the "from" file path
#' in the result data frame. The default is 'from'.
#'
#' @param file_path_to_colname The column name (as a string) representing the "to" file path in
#' the result data frame. The default is 'to'.
#'
#' @param match1_colname The column name (as a string) for the first match in the result
#' data frame. The default is 'first_match'.
#'
#' @param match2_colname The column name (as a string) for the second match in the result
#' data frame. The default is 'second_match'.
#'
#' @param line_number_match2_colname The column name (as a string) for the line number
#' of the second match in the result data frame. The default is 'line_number'.
#'
#' @param content_match1_col_name The column name (as a string) for the full content of
#' the first match. The default is 'content_match_1'.
#'
#' @param content_match2_col_name The column name (as a string) for the full content of
#' the second match. The default is 'content_match_2'.
#'
#' @param ... Parameters passed to srch_pattern_in_files_get_df(). You typically want to adjust the "pattern" parameter, or keep_comments = T
#'
#' @return A data frame wich is the edgelist of the citations network
#' columns 'from' and 'to' indicates the files paths or urls of the matched contents.
# ' There is other infos (line numbers, precise line matched for verification, etc.)
#'
#' @examples
#' # Example with url from github
#' result <- get_text_network_from_files(
#' files_path = paste0("https://github.com/Clement-LVD/codexplor/blob/main/R/",
#'  c("get_text_network_from_files","srch_pattern_in_files_get_df" ) , ".R"),
#'                                       ignore_match_less_than_nchar = 1,
#'                                       first_match_to_exclude = c("server"),
#'                                       regex_to_exclude_files_path = "test-")
#'
#' # Will return a network of func' from the file path where called => to the file path were defined)
#'
#' @seealso \code{\link{srch_pattern_in_files_get_df}}, \code{\link{str_extract_all_to_tidy_df}}, \code{\link{fix_escaping}}
#' @export
get_text_network_from_files <- function(files_path = "~"

    , ignore_match_less_than_nchar = 3

    , first_match_to_exclude = NULL

   , prefix_for_regex_from_the_text = ""

   ,  suffix_for_regex_from_the_text = ""# pas une lettre ou un chiffre !


  , regex_to_exclude_files_path = NULL #"test-"

 , filter_2nd_match_unmatched_lines = T

   , filter_first_match_results = T

   , filter_ego_link = T

 , file_path_from_colname = 'from'
 , file_path_to_colname = 'to'
 , match1_colname =  "first_match"

 ,  match2_colname ="second_match"
 , line_number_match2_colname = "line_number"
 , content_match1_col_name = "content_match_1" # we want to keep the full content very available

 , content_match2_col_name = "content_match_2" # we want to keep the full content very available

 , ...
  ){

 # we will rename in the end so var' names are hardcoded hereafter :

  ####1) Get content from R files ####
# With the default regex of srch_pattern_in_files_get_df, fn_network indicate where the func' are defined
fn_network <-  srch_pattern_in_files_get_df(files_path = files_path, match_to_exclude = first_match_to_exclude
                                            , file_path_col_name = "file_path"
                                            , content_col_name = "content"
 , extracted_txt_col_name =   "first_match", ignore_match_less_than_nchar = ignore_match_less_than_nchar, ...) #file with a func' defined by default
#we will retrieve this object and these var later

# we have 3 informations that we used hereafter :
# full content + path + a first match (default try to match each func' definition)

#### 2) List the result ####
fn_defined <- unique(fn_network$first_match) # it's the func' defined by default

fn_defined <- fn_defined[which(!is.na(fn_defined))]

# clean undesired char that will bug stringi.r
# regexx <-  escape_unescaped_chars(fn_defined)

#### 3) Construct a regex ####
# optionnally add a suffix (such as a filter from the user, capture-group, etc.)
regexx <- paste0(prefix_for_regex_from_the_text, fn_defined, suffix_for_regex_from_the_text)

# made a single regex and clean it from unescaped chars
regexx_complete <- paste0(regexx, collapse = "|")

regexx_complete <-  fix_escaping(regexx_complete,num_escapes = 2, special_chars = c("(", ")"))

#### 4) EXTRACT #2 ####
#  match every mention of our previous matches and returning a DF
fns_called_df <- str_extract_all_to_tidy_df(string = fn_network$content
                                            , pattern = regexx_complete
 , row_number_colname = "row_number", matches_colname = "second_match"
 , filter_unmatched = filter_2nd_match_unmatched_lines)

fn_network$row_number <- seq_len(nrow(fn_network))
# we have add row_number colname in both !

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

# take original files - begining of the code - for adding the path where a func' is defined
returned_network <- merge(complete_network, origines_files
                          , by.x = "second_match"
                          , by.y = "function" # it was also 'first_match' so we've renamed
                          , all.x = TRUE)

returned_network <- returned_network[, c("file_path", "defined_in", "first_match", "second_match", "line_number", "content",  "definition_content")]

if(filter_ego_link){returned_network <- returned_network[ which( returned_network["file_path"] != returned_network["defined_in"]) , ] }

# filter if user want to filter
lines_to_exclude <- NULL
if(!is.null(regex_to_exclude_files_path)){ lines_to_exclude <- grep(x = returned_network$file_path, pattern =  regex_to_exclude_files_path) }

if(length(lines_to_exclude) > 0){returned_network <-  returned_network[-lines_to_exclude, ] }


colnames(returned_network) <- c(file_path_from_colname, file_path_to_colname, match1_colname, match2_colname, line_number_match2_colname, content_match2_col_name,  content_match1_col_name)
# finally givin the colname wanted by the user

return(returned_network)

}
