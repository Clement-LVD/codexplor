#' Concatenate text by a common key
#'
#' This function concatenates text spread across multiple rows
#' based on a common key, using only base R functions.
#'
#' @param df A data.frame containing the data
#' @param key_colname `character` The column used as the grouping key (character string)
#' @param text `character` The column containing the text to be concatenated (character string)
#' @param sep `character` The separator used to concatenate the text (default is " ")
#' @param trimws `logical`, default = `TRUE` If `TRUE`, suppress leading, tail and double white spaces
#' @return A data.frame with the text concatenated by key
#' @examples
#' # Create a sample data.frame
#' df <- data.frame(id = c(1, 1, 1, 2, 2, 3),
#'  text = c("Hello ", "world ", " !", "How", "are    you?", " Test "))
#' # Use the function to concatenate text by 'id'
#' gather_df_lines(df, key = "id", text = "text")
#' @export
gather_df_lines <- function(df, key_colname, text, sep = " ", trimws = T) {

  if (!is.data.frame(df)) {
    stop("'df' must be a data.frame.")
  }

  # check column existence
  if (!key_colname %in% names(df) | !text %in% names(df)) {
    stop("No ", key_colname, " column in the data.frame.")
  }

  #  tapply concatenate text
  text_concat <- tapply(
    df[[text]],
    df[[key_colname]],
    function(x) paste(x, collapse = sep)
  )

  # Convert to data.frame
  result <- data.frame(
    key = names(text_concat),
    text = as.character(text_concat),
    row.names = NULL
  )

  # Conver key (factor -> caracter or num)
  # result[[1]] <- type.convert(result[[1]], as.is = TRUE)
  names(result)[1] <- key_colname

 if(trimws){ result$text <- gsub("\\s+", " ", result$text )  # Replace multiple spaces with a single space
  result$text <- trimws(result$text)}

  return(result)
}
