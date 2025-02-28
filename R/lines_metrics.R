

#### 1) lines text-metrics ####
#simple stats here will affect all corpus :
compute_nchar_metrics <- function(text,
                                  nchar_colname = "n_char",
                                  nchar_nospace_colname = "n_char_wo_space",
                                  word_count_colname = "n_word",
                                  vowel_count_colname = "n_vowel") {

  # Remove spaces and newlines for character count without spaces
  txt_wo_space <- gsub(x = text, pattern = " |\n", "")

  # Compute metrics
  result <- data.frame(
    # Character count
    nchar_colname = as.integer(nchar(text)),

    # Character count without spaces
    n_char_wo_space_line = as.integer(nchar(txt_wo_space)),

    # Word count
    word_count = as.integer(lengths(strsplit(text, "\\s+"))),

    # Approximate syllable count (counting vowel groups as syllables)
    vowel_count = as.integer(sapply(gregexpr("[aeiouyAEIOUY]+", text), function(x) sum(x > 0)))
  )

  # Rename columns to custom names
  colnames(result) <- c(nchar_colname, nchar_nospace_colname, word_count_colname, vowel_count_colname)

  return(result)
}


# Adapted compute_nchar_metrics to work on a list of dataframes
compute_nchar_metrics_list <- function(df_list, col_name, ...) {

  # If col_name is a single name, repeat it for each dataframe in the list
  if (length(col_name) == 1) {
    col_name <- rep(col_name, length(df_list))
  }

  # Apply the computation to each dataframe in the list
  result <- mapply(function(df, col) {
    if (!col %in% colnames(df)) {
      stop(paste("Column", col, "does not exist in the dataframe."))
    }

    # Use compute_nchar_metrics on the specified column
    metrics <- compute_nchar_metrics(df[[col]], ...) # typically name
    return(    cbind(df, metrics) )

  }, df_list, col_name, SIMPLIFY = FALSE)

  return(result)
}



