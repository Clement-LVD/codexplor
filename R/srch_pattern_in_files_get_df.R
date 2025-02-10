#' srch_pattern_in_files_get_df associate a text to a file
#' e.g., detect a file with a func' defined with 'function_name <- function'
#'
#' | A] Read files in a folder and answer the content readed in a df
#' Default parameters : search into the wd() path recursively, read .R files
#' | B] Then try to extract a pattern and return the extracted text  (no match on commented lines by default)
#' In the 'matched text' part of the result, NA meaning 'no match'
#' | C] Finally answer a df with all the readed content
#' Regarding the regex : regex prefix_to_add_to_pattern and pattern_regex_to_match_and_remove are pasted in order to match
#'  but only the prefix is extracted as a result
#' Regarding the returned df : the first col' is the file path of all the matched files (first regex passed to list.files)
#' Last col is the extracted text : this will be the prefix passed by the user, only when there is a complete match
#'
#' @param path_main_folder `character`
#'   Folder where to read all files that match a pattern. Default to current working directory. The files must match the pattern_regex_list_files parameter which is passed to list.files(pattern = )
#' @param pattern_regex_to_match_and_remove `character`, default = `"(<-|\\=) +?function"`
#'   A regex for matching lines and extract text : this pattern will be removed from the extracted text. Typically use for finding a line where a R function is defined
#' @param prefix_to_add_to_pattern `character`, default = `".*(?<!FUN)"`
#'   A regex added BEFORE the pattern_regex_to_match_and_remove : used for matching lines, not removed. This is the text you want to have in a new col'
#' @param recursive_search_for_files `logical`, default = `TRUE`
#' If `TRUE` - the default, the files will be searched recursively in the path (including subdirectories)
#' @param pattern_regex_list_files `character`, default = `"\\.r$"`
#'  Files to read before to searching for the pattern : passed to list.files(pattern = pattern_regex_list_files). Note that it's not case sensitive
#' @param  ignore_case `logical`, default = `TRUE`
#' If `TRUE`, the pattern search (lines matched) will ignore case. If `FALSE`, the search will be case-sensitive.
#'
#' @param clean_match_from_pattern `logical`, default = `TRUE`
#' If `TRUE`, the matched pattern is removed from the returned results. If `FALSE`, the pattern will remain in the result.

#' @param comments `logical`, default = `FALSE`
#' If `FALSE` - the default, the lines whith a leading # will be removed from the returned df
#'
#' @param file_path_col_name `character`, default = `"file_path"`
#'   Column name for the file path in the output dataframe (first col' of the returned df)
#' @param content_col_name `character`, default = `"content"`
#'   Column name for the file content in the output dataframe.
#' @param line_number_col_name `character`, default = `"line_number"`
#'   Column name for the line numbers in the output dataframe.
#' @param extracted_prefix_col_name `character`, default = `"matches"`
#'   Column name for the extracted text (last col' of the returned df)
#'
#' @return A `data.frame` with 4 col' : first (`file_path` by default) contain the file_path, then `line_number` (by default) contain line_number, third column (`content` by default) containing the readed lines from the file and the LAST ONE contain the matched text, according to the regex provided by the user
#' @examples
#' #Analysing the func of the package, assuming you have installed it :
#' pkg_path <- system.file("R", package = "tidyverse")
#' #lines_readed <- srch_pattern_in_files_get_df(pkg_path)
#' # Return : XXX A FAIRE XXX
#' @export
srch_pattern_in_files_get_df <- function(
    path_main_folder = getwd()


   , pattern_regex_to_match_and_remove = "<- +?function"


    , prefix_to_add_to_pattern = ".*" #(?<!FUN) # useless if "=" is not a valid way to define func'

    , recursive_search_for_files = T


    ,     pattern_regex_list_files  = "\\.r$" #fichiers à lire identifiés avec list.files : not case sensitive


    ,    ignore_case   = T

    , clean_match_from_pattern = T #on clean notre pattern et le suffixe (mais pas le préfixe) des résultats
    ,  comments = FALSE # on dégage les lignes commentées

   , file_path_col_name = "file_path", content_col_name = "content", line_number_col_name = "line_number"
, extracted_prefix_col_name = "matches"
  ){

  ####1) import content ####
fls <- list.files(path = path_main_folder, pattern = pattern_regex_list_files, ignore.case = T
                  , all.files = T, full.names = T, recursive = recursive_search_for_files)

# get files content
content_df <-  readlines_in_df(files_to_read_path = fls,
                               return_lowered_text = F, comments = comments # skip comment by default
                               ,file_path_col_name = file_path_col_name, content_col_name = content_col_name
                               , line_number_col_name = line_number_col_name
                              ,    .verbose = T

                               )

#etract fn names (na if no match at all)
content_df[[extracted_prefix_col_name]] <- extract_txt_before_regex(
  txt_vector = content_df[[content_col_name]]
, clean_match_from_pattern = clean_match_from_pattern
,  filter_only_match = F
  ,ignore_case =  ignore_case
                         , pattern_regex_to_search = pattern_regex_to_match_and_remove
                         , prefix_to_add_to_pattern = prefix_to_add_to_pattern )

# we have a df with fn name IN THE LAST COL and the path to the file they are defined IN THE FIRST COL

return(content_df)
  }

