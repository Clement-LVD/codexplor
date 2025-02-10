#' Extract regex matches from a string and return a tidy dataframe
#'
#' This function applies `stringr::str_extract_all()` to a string, extracts regex matches,
#' and returns an unested dataframe with customizable column names.
#' Option offered : filtering of unmatched result (default)
#'
#' @param string A character vector containing the input text.
#' @param pattern A regex pattern to extract matches.
#' @param filter_unmatched Logical (default `TRUE`); if `TRUE`, removes unmatched values from the output.
#' @param matches_colname A string specifying the column name for extracted matches (default: `"matches"`).
#' @param row_number_colname A string specifying the column name for row numbers (default: `"row_number"`).
#' @return A dataframe with the extracted matches and their corresponding row numbers.
#' @examples
#' text_data <- c("Here is funcA and funcB", "Nothing here", "funcC is present")
#' pattern <- "func[A-C]"
#' result_df <- str_extract_all_to_tidy_df(text_data, pattern)
#' print(result_df)
#' @export
str_extract_all_to_tidy_df <- function(string, pattern
                                       , filter_unmatched = T
                                       , matches_colname = "matches"
                                       , row_number_colname = "row_number"){

matches <- stringr::str_extract_all(string = string, pattern = pattern)

# Unnest the result without keeping empty result, using unlist
matches_df <-  data.frame(called_name = unlist(matches),
                             row_number = rep(seq_along(matches), sapply(matches, length)))
# filter :
if(filter_unmatched) {matches_df <- matches_df[!is.na(matches_df$called_name), ]}
# rename :
colnames(matches_df) <- c(matches_colname, row_number_colname)

return(matches_df)
}
