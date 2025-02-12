#' srch_pattern_in_files_get_df associate a text to a file
#' e.g., detect a file with a func' defined with 'function_name <- function'
#'
#' | A] Read files in a folder and answer the content readed in a df
#' Default parameters : search into the wd() path recursively, read .R files
#' | B] Then try to extract a pattern and return the extracted text  (no match on commented lines by default)
#' In the 'matched text' part of the result, NA meaning 'no match'
#' | C] Finally answer a df with all the readed content
#' Regarding the regex : regex prefix_to_add_to_pattern and pattern are pasted in order to match
#'  but only the prefix is extracted as a result
#' Regarding the returned df : the first col' is the file path of all the matched files (first regex passed to list.files)
#' Last col is the extracted text : this will be the prefix passed by the user, only when there is a complete match
#'
#' @param path_main_folder `character`
#'   Folder where to read all files that match a pattern. Default to current working directory. The files must match the pattern_regex_list_files parameter which is passed to list.files(pattern = )
#' @param pattern `character`, default = `"\\b([A-Za-z0-9_]+)(?=\\s*(?:<-|=)\\s*(?:function|$))"`
#'   A regex for matching lines and extract text. Use the regex for finding a line by extracting text
#' @param match_to_exclude `character` A vector of values that will not be returned such as a match.
#' The rows where the `values` match any element in this vector will be removed.
#' @param  ignore_match_less_than_nchar `double`, default = 2 Excluding match depending on char. number of the matched text (strictly inferior)
#' Default exclude match of 1 char such as 'x'.
#' @param recursive_search_for_files `logical`, default = `TRUE`
#' If `TRUE` - the default, the files will be searched recursively in the path (including subdirectories)
#' @param pattern_regex_list_files `character`, default = `"\\.r$"`
#'  Files to read : passed to list.files(pattern = pattern_regex_list_files). Note that it's not case sensitive
#' @param  ignore_case `logical`, default = `TRUE`
#' If `TRUE`, the pattern search (lines matched) will ignore case. If `FALSE`, the search will be case-sensitive.
#' @param comments `logical`, default = `FALSE`
#' If `FALSE` - the default, the lines whith a leading # will be removed from the returned df
#'
#' @param file_path_col_name `character`, default = `"file_path"`
#'   Column name for the file path in the output dataframe (first col' of the returned df)
#' @param content_col_name `character`, default = `"content"`
#'   Column name for the file content in the output dataframe.
#' @param line_number_col_name `character`, default = `"line_number"`
#'   Column name for the line numbers in the output dataframe.
#' @param extracted_txt_col_name `character`, default = `"matches"`
#'   Column name for the extracted text (last col' of the returned df)
#'
#' @return A `data.frame` with 4 col' : first (`file_path` by default) contain the file_path, then `line_number` (by default) contain line_number, third column (`content` by default) containing the readed lines from the file and the LAST ONE contain the matched text, according to the regex provided by the user
#' @examples
#' #Analysing the func of the package, assuming you have installed it :
#' pkg_path <- system.file("R")
#' #lines_readed <- srch_pattern_in_files_get_df(pkg_path)
#' # Return : XXX A FAIRE XXX
#' @seealso \code{\link{readlines_in_df}}
#' @export
srch_pattern_in_files_get_df <- function(
    path_main_folder = getwd()

       ,pattern = "\\b([A-Za-z0-9_\\.]+)(?=\\s*(?:<-)\\s*function)"


   , match_to_exclude = NULL# "error"  e.g., for "error" (?<!error\\s*)

   , ignore_match_less_than_nchar = 2
# ?=look ahead
    , recursive_search_for_files = T

    ,     pattern_regex_list_files  = "\\.r$" #fichiers à lire identifiés avec list.files : not case sensitive

    ,    ignore_case   = T

    ,  comments = FALSE # on dégage les lignes commentées

   , file_path_col_name = "file_path", content_col_name = "content", line_number_col_name = "line_number"
, extracted_txt_col_name = "matches"
  ){

  ####1) import content ####
fls <- list.files(path = path_main_folder, ignore.case = T
                  , all.files = T, full.names = T, recursive = recursive_search_for_files, pattern = pattern_regex_list_files)

# get files content
content_df <-  readlines_in_df(files_to_read_path = fls,
                               return_lowered_text = F, comments = comments # skip comment by default
                               ,file_path_col_name = file_path_col_name, content_col_name = content_col_name
                               , line_number_col_name = line_number_col_name
                              ,    .verbose = T

                               )

if(is.null(content_df)) return(NULL)

# add row number
content_df$row_num <- 1:nrow(content_df)

# extract alltext (base R)
les_matches <- regmatches(content_df[[content_col_name]], gregexpr(pattern, content_df[[content_col_name]], perl = TRUE))
# Unnest with base R
flattened_df <- data.frame(row_num = rep( 1:length(les_matches)
                                         , sapply(les_matches, length)),
                           values = unlist(les_matches) )# and unlist give a raw vector.
 # We REP each row number until unnesting the list
# sapply(expanded_df$matches, length) give length of each sublist, used for repeating value (sometimes 0 times when no match)

# Remove lines according to nchar limit and list passed by the user
rows_to_remove <- c(which(nchar(flattened_df$values) < ignore_match_less_than_nchar), which(flattened_df$values %in% match_to_exclude) )

if(length(rows_to_remove) > 0){  flattened_df <- flattened_df[-rows_to_remove, ] }

colnames(flattened_df) <- c("row_num", extracted_txt_col_name )
#  custom colnames provided by the user => we'll merge this col' herafter with the content extracted from the files readed


# check if lines are multiplicated during the merge since we keep all x lines but maybe passing several matches on the same row_num
n_lines_before = nrow(content_df)

content_df <- merge(content_df, flattened_df, by = "row_num", all.x = T) # here we get ALL lines !

n_lines_after = nrow(content_df)

if(!n_lines_before == n_lines_after){warning(immediate. = T, "\n ==> Have returned duplicated line(s) : you've matched several match on a single line ! :x")
cat("Duplicated row number are : \n");cat(sep = " & ", content_df$row_num[anyDuplicated(content_df$row_num)])
}
# content_df[68451,]
content_df$row_num <- NULL # erase row_num col'

#etract fn names (na if no match at all)
# we have a df with fn name IN THE LAST COL and the path to the file they are defined IN THE FIRST COL

return(content_df)
  }

