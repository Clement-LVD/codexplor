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
#' extract_txt_from_df_vars(df, "World|Hello", cols_for_searching_text = 1:2)
#' #If using 2 regex separated by "|"
#' # It will return 5 lines : line #1 is duplicated on 2 lines (since there is 2 matches on line 1)
#' # (i.e. from one single line with "Hello Word" to one line for matching 'hello' and one for 'world')
#' # same for line #2, with 2 matches for 2 returned lines
#' #Third line is returned despite no match, since keep_empty_results is T (default)
#' @importFrom stringr str_extract_all regex
#' @export
extract_txt_from_df_vars <- function(df = NULL , regex_extract_txt = NULL , cols_for_searching_text = NULL
                                     , keep_empty_results = T
                                     , returned_col_name = "to"
                                     ){

  if (is.null(df)) {cat("You should pass a dataframe to extract_txt_from_df_vars\n"); return(NULL)}

  if (is.null(regex_extract_txt)) { cat("You should provide a regular expression pattern to extract_txt_from_df_vars\n"); return(NULL)}

  if(is.null(cols_for_searching_text)){
    warning("You should provide a or several col' names to extract_txt_from_df_vars\n")

col_char <-  apply(df, MARGIN = 2, FUN = function(col) mean(na.rm = T, nchar(col)))

cols_for_searching_text <- which(col_char == max(col_char, na.rm = T))[[1]]

warning("extract_txt_from_df_vars() HAVE SELECTED THE COLUMN WITH THE GREATEST NUMBER OF CHAR (mean of n_char) FOR SEARCHING PATTERN IN !")

if(!length(cols_for_searching_text) < 0){warning("NO varname(s) or position have been passed to extract_txt_from_df_vars with the 'cols_for_searching_text' parameter") ;return(NULL)}

}
  # Manage cols given by the user
  if (is.numeric(cols_for_searching_text)) {cols_for_searching_text <- colnames(df)[cols_for_searching_text]}

  # Combine selected columns into a single string per row
complete_content<- apply(df[cols_for_searching_text], 1, paste, collapse = " ")

# extract these pattern in a list of same length than original df vector !
complete_result <- stringr::str_extract_all(string = complete_content,  pattern = stringr::regex(regex_extract_txt))

complete_result <- lapply(complete_result, FUN = function(x) {x <- x[!is.na(x) & x != ""]; return(x)})  # Replace empty listes by character(0L)
# here we will multiply lines depending on the number of result

# check if there is at least one line somewhere in the list of str_extracted =>
max_lines_to_create <- max(unlist(lapply(complete_result , length )))

# adding matches to the df passed by the user
expanded_df <- df # df with same n_row than the original one

expanded_df$row_num <- 1:nrow(expanded_df) # a valid line_number

expanded_df$list_of_matched_txt <- complete_result  # by default initialize the col' "to" (here we write a list in this col')

# expanded_df$list_of_matched_txt <- lapply(expanded_df$list_of_matched_txt, function(x) if (is.null(x)) integer(0) else x)

if(max_lines_to_create == 0){expanded_df$list_of_matched_txt <- NA}
# Fill the "list_of_matched_txt" col' in order to prevent some bug if there is no result (no match)

# Unnest with base R
flattened_df <- data.frame(row_num = rep(expanded_df$row_num # We REP each row until unnesting the list =>
            , sapply(expanded_df$list_of_matched_txt, length)),
            # sapply(expanded_df$matches, length) give length of each sublist, used for repeating value.
           values = unlist(expanded_df$list_of_matched_txt)) # and unlist(expanded_df$matches) give a raw vector.

colnames(flattened_df) <- c("row_num",   returned_col_name ) #  custom colnames provided by the user
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


