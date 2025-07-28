#' Try to match a text pattern in a df column by only extract the text
#'
#' Read some files and answer the content readed in a df.
#'  Then try to extract a pattern
#'  and return the extracted text in a column of the returned df (NA meaning 'no match').
#'
#' @param df `data.frame`
#'   A data.frame with a minima a `character` column.
#' @param content_col_name `character`, default = `"content"`
#'   Name of the text column in the input df (will be returned in the output df).
#' @param pattern `character`, default = `"\\b([A-Za-z0-9_]+)(?=\\s*(?:<-|=)\\s*(?:function|$))"`
#'   A regex for matching lines and extract text.
#' @param match_to_exclude `character` A vector of values that will not be returned such as a match.
#' The rows where the `values` match any element in this vector will be removed.
#' @param  ignore_match_less_than_nchar `double`, default = 2 Excluding match depending on char. number of the matched text (strictly inferior)
#' Default exclude match of 1 char such as 'x'.
#' @param extracted_txt_col_name `character`, default = `"matches"`
#'   Column name for the extracted text (last col' of the returned df)
#' @param duplicated_lines_are_normal `logical`, default = `FALSE`. If set to `TRUE`, silent the warning  about duplicated lines
#' @return A `data.frame` similar to the one passed by the user with 1 more column : the match ; *a minima* :
#' \describe{
#'   \item{\code{content}}{`character` The text column designed by the user.}
#'   \item{\code{match}}{`character` The matched text on this line, `NA` if there is no match.}
#' }
#' @seealso \code{\link{readlines_in_df}}
srch_pattern_in_df <- function(df, content_col_name = "content"

       ,pattern = "(^| \\.|\\b)([\\.A-Za-z0-9_]+)(?=\\s*(?:<-)\\s*function)"
# a caveat here is the func' that not start from the 1st char : not easy to catch

   , match_to_exclude = NULL# "error"  e.g., for "error" (?<!error\\s*)

   , ignore_match_less_than_nchar = 3
# ?=look ahead

, extracted_txt_col_name = "matches"

, duplicated_lines_are_normal = F
  ){

content_df <- df

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

flattened_df$values <- trimws(flattened_df$values)
# cleaning out our indesired results as soon as possible :

# default is filtering the custom warning, e.g., a 'warning' condition (trycatch or whatever)
# Remove lines according to nchar limit and list passed by the user
rows_to_remove <- c(which(nchar(flattened_df$values) < ignore_match_less_than_nchar),
                    which(flattened_df$values %in% match_to_exclude) )

if(length(rows_to_remove) > 0){  flattened_df <- flattened_df[-rows_to_remove, ] }

colnames(flattened_df) <- c("row_num", extracted_txt_col_name )
#  custom colnames provided by the user => we'll merge this col' herafter with the content extracted from the files readed


# check if lines are multiplicated during the merge since we keep all x lines but maybe passing several matches on the same row_num
n_lines_before = nrow(content_df)

content_df <- merge(content_df, all.x = T, flattened_df, by = "row_num") #  ALL lines !

n_lines_after = nrow(content_df)

if(!n_lines_before == n_lines_after & !duplicated_lines_are_normal){
  warning(immediate. = T, "==> Have returned duplicated line(s) : you've matched several matches on a single line ! :x")
dupkey <- content_df$row_num[anyDuplicated(content_df$row_num)]
  cat("Duplicated row number are : \n"); cat(sep = "  ", dupkey )
cat("\n")
}

content_df$row_num <- NULL # erase row_num col'

#etract fn names (na if no match at all)
# we have a df with fn name IN THE LAST COL and the path to the file they are defined IN THE FIRST COL

content_df[[extracted_txt_col_name]] <- trimws(content_df[[extracted_txt_col_name]] )

return(content_df)
  }

