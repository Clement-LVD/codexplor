#' Extracts specified patterns from a dataframe column and returns the corresponding lines of the dataframe
#' In case of several pattern gived by the user, line will be multiplied if there is several matches on a line
#' This function allows the extraction of a specified pattern from selected columns of a dataframe.
#' The pattern extraction is applied to each row, and the results are returned as a new dataframe with
#' the extracted patterns as a list in a new column. The function handles multiple patterns and
#' will expand the dataframe by adding rows if necessary.
#' Only matching lines are returned (the default) or every line gived + eventually some new lines refleting several matches on a line

#'
#' @param df DataFrame. The input dataframe from which the patterns will be extracted.
#' @param regex_extract_txt Character string. The regular expression pattern to extract from the text.
#' @param cols_for_searching_text Character or numeric vector. Specifies which columns to search for the patterns.
#' @param keep_empty_results `logical`, default = `T` Logical: Whether to keep rows with no matches (default is TRUE).
#' @param returned_col_name `character`, default = `"to"`: The name of the new column that will contain the matches (default is "to").
#'
#' @return A dataframe with an additional column containing the extracted patterns for each row.
#' @examples
#' # Example usage
#' df <- data.frame(A = c("Hello World", "Pattern matching here", "Test123"),
#'                  B = c("This is a test", "Hello World again", "Pattern not found"))
#' extract_txt_from_df_vars(df, "World", 1:2)
#'
#' @importFrom stringr str_extract_all regex
#' @importFrom tidyr unnest
#' @export
extract_txt_from_df_vars <- function(df = NULL , regex_extract_txt = NULL , cols_for_searching_text = NULL, keep_empty_results = T, returned_col_name = "to"
                                     ){

  if (is.null(df)) {cat("You should pass a dataframe to extract_txt_from_df_vars\n"); return(NULL)}

  if (is.null(regex_extract_txt)) { cat("You should provide a regular expression pattern to extract_txt_from_df_vars\n"); return(NULL)}

  # Manage cols given by the user
  if (is.numeric(cols_for_searching_text)) {cols_for_searching_text <- colnames(df)[cols_for_searching_text]}

  # Combine selected columns into a single string per row
complete_content<- apply(df[cols_for_searching_text], 1, paste, collapse = " ")

# extract these pattern in a list of same length than original df vector !
complete_result <- stringr::str_extract_all(string = complete_content,  pattern = stringr::regex(regex_extract_txt))

complete_result <- lapply(complete_result, FUN = function(x) {x <- x[!is.na(x) & x != ""]; return(x)})  # Replace empty listes by character(0L)
# here we will multiply lines depending on the number of result
# max_var_to_create <- max(unlist(lapply(complete_result , length )))

#Adding some col (and multiply lines) to df passed by the user
# expanded_df <- dplyr::mutate(df, to = complete_result) #to
expanded_df <- df
expanded_df[[returned_col_name]] <- complete_result
# become a dataframe (table): lost blanc lines
expanded_df <- tidyr::unnest(data = expanded_df, cols = !!returned_col_name, keep_empty = keep_empty_results) # to

# or we have to reduce the number of lines and join to the user dataframe
# expanded_df <- unique(expanded_df)

return(expanded_df)
}


