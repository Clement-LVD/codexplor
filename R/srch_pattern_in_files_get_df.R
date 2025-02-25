#' Read some files and answer a df, optionnaly try to match a text pattern
#' e.g., detect a file with a func' defined with 'function_name <- function'
#'
#' | A] Read a bunch of files and answer the content readed in a df
#' | B] Then try to extract a pattern and return the extracted text  (no match on commented lines by default)
#' In the 'matched text' part of the result, NA meaning 'no match'
#' | C] Finally answer a df with all the readed content
#' Regarding the returned df : the first col' is the file path of all the matched files (first regex passed to list.files)
#' Last col is the extracted text : this will be the prefix passed by the user, only when there is a complete match
#'
#' @param files_path `character`
#'   A vector of files path path and/or url.
#' @param pattern `character`, default = `"\\b([A-Za-z0-9_]+)(?=\\s*(?:<-|=)\\s*(?:function|$))"`
#'   A regex for matching lines and extract text. Use the regex for finding a line by extracting text
#' @param match_to_exclude `character` A vector of values that will not be returned such as a match.
#' The rows where the `values` match any element in this vector will be removed.
#' @param  ignore_match_less_than_nchar `double`, default = 2 Excluding match depending on char. number of the matched text (strictly inferior)
#' Default exclude match of 1 char such as 'x'.
#' @param ... Additional arguments passed to `readlines_in_df`
#' For example, keep_comments (`logical`, default = `FALSE`) for taking into account the commented lines of the files
#' @param file_path_col_name `character`, default = `"file_path"`
#'   Column name for the file path in the output dataframe (first col' of the returned df)
#' @param content_col_name `character`, default = `"content"`
#'   Column name for the file content in the output dataframe.
#' @param line_number_col_name `character`, default = `"line_number"`
#'   Column name for the line numbers in the output dataframe.
#' @param extracted_txt_col_name `character`, default = `"matches"`
#'   Column name for the extracted text (last col' of the returned df)
#'
#' @return A `data.frame` with 4 col' :
#' \describe{
#'   \item{\code{file_path}}{`character` The local file path or constructed GitHub URL.}
#'   \item{\code{line_number}}{`integer` The line number within the file.}
#'   \item{\code{content}}{`character` The content from a line.}
#'   \item{\code{match}}{`character` The matched text on this line, `NA` if there is no match.}
#' }
#' @examples
#' #Analysing the func of the package, assuming you have installed it :
#' p_path <- list.files("~", pattern = ".R$",  recursive = TRUE , full.names = TRUE  )
#' lines_readed <- srch_pattern_in_files_get_df(p_path, .verbose = FALSE)
#' # Return : a dataframe of links, according to - default - pattern
#' @seealso \code{\link{readlines_in_df}}
#' @export
srch_pattern_in_files_get_df <- function(
    files_path = NULL

       ,pattern = "(^| \\.|\\b)([\\.A-Za-z0-9_]+)(?=\\s*(?:<-)\\s*function)"
# a caveat here is the func' that not start from the 1st char : not easy to catch

   , match_to_exclude = NULL# "error"  e.g., for "error" (?<!error\\s*)

   , ignore_match_less_than_nchar = 3
# ?=look ahead

   , file_path_col_name = "file_path", content_col_name = "content", line_number_col_name = "line_number"
, extracted_txt_col_name = "matches"
, ...
  ){

# get files content
content_df <-  readlines_in_df(files_path = files_path

# the colnames are customizable
,file_path_col_name = file_path_col_name, content_col_name = content_col_name, line_number_col_name = line_number_col_name
, ...
                               )

if(is.null(content_df)) return(NULL)

# add row number
content_df$row_num <- 1:nrow(content_df)

# extract alltext (base R)

first_matches <- regmatches(content_df[[content_col_name]], gregexpr(pattern, content_df[[content_col_name]], perl = TRUE))
# Unnest with base R
flattened_df <- data.frame(row_num = rep( 1:length(first_matches)
                                         , sapply(first_matches, length)),
                           values = unlist(first_matches) )# and unlist give a raw vector.
 # We REP each row number until unnesting the list
# sapply(expanded_df$matches, length) give length of each sublist, used for repeating value (sometimes 0 times when no match)

# Remove lines according to nchar limit and list passed by the user
rows_to_remove <- c(which(nchar(flattened_df$values) < ignore_match_less_than_nchar), which(flattened_df$values %in% match_to_exclude) )

if(length(rows_to_remove) > 0){  flattened_df <- flattened_df[-rows_to_remove, ] }

colnames(flattened_df) <- c("row_num", extracted_txt_col_name )
#  custom colnames provided by the user => we'll merge this col' herafter with the content extracted from the files readed


# check if lines are multiplicated during the merge since we keep all x lines but maybe passing several matches on the same row_num
n_lines_before = nrow(content_df)

content_df <- merge(content_df, all.x = T, flattened_df, by = "row_num") #  ALL lines !

n_lines_after = nrow(content_df)

if(!n_lines_before == n_lines_after){warning(immediate. = T, "\n ==> Have returned duplicated line(s) : you've matched several match on a single line ! :x")
cat("Duplicated row number are : \n");cat(sep = " & ", content_df$row_num[anyDuplicated(content_df$row_num)])
}

content_df$row_num <- NULL # erase row_num col'

#etract fn names (na if no match at all)
# we have a df with fn name IN THE LAST COL and the path to the file they are defined IN THE FIRST COL

return(content_df)
  }

