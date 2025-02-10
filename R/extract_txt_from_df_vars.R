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
#' @export
extract_txt_from_df_vars <- function(df = NULL , regex_extract_txt = NULL , cols_for_searching_text = NULL
                                     , keep_empty_results = T
                                     , returned_col_name = "to"
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

# adding matches to the df passed by the user
expanded_df <- df # df with same n_row than the original one

expanded_df$row_num <- 1:nrow(expanded_df) # a valid line_number

expanded_df$list_of_matched_txt <- complete_result  # by default initialize the col' "to" (here we write a list in this col')

# xxx verifier ici xxx
flattened_df <- data.frame(row_num = rep(expanded_df$row_num # We REP each row until unnesting the list =>
            , sapply(expanded_df$matches, length)),
            # sapply(expanded_df$matches, length) give length of each sublist, used for repeating value.
           values = unlist(expanded_df$matches)) # and finally unlist(expanded_df$matches) give a raw vector.

colnames(flattened_df) <- c("row_num",   returned_col_name ) # add custom colnames
# the df will have eventually a lines addition. Equivalent of :
# expanded_df <- tidyr::unnest(data = expanded_df, cols = !!returned_col_name, keep_empty = keep_empty_results) # to

expanded_df <- merge(expanded_df, flattened_df, by = "row_num", all = T ) # adding these lines to expanded_df

# eject lines with no match (optionnal)
if(!keep_empty_results){expanded_df <- expanded_df[which(!is.na(expanded_df[[returned_col_name]]) ) , ]}

# df_new <- do.call(rbind, Map(cbind, id = df$id, df$valeurs))
# rownames(df_new) <- NULL  # Nettoyage des noms de lignes

# or we have to reduce the number of lines and join to the user dataframe
# expanded_df <- unique(expanded_df)

return(expanded_df)
}


