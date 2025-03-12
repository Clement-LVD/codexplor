#' Get lines text-metrics from a df
#'
#' Given a `character` vector, return a `data.frame` with lines text-mining metrics :
#' values are related to each element of the vector provided by the user.
#' @param text `character`. A character vector of texts.
#' @param nchar_colname `character`. Default = `""n_char""`. `character` indicating the colname for total nchar().
#' @param nchar_nospace_colname `character`. Default = `"n_char_wo_space"`. `character` indicating the colname for nchar() without space.
#' @param word_count_colname `character`. Default = `"n_word"`. `character` indicating the colname for a word count.
#' @param vowel_count_colname `character`. Default = `"n_vowel"`. `character` indicating the colname for a vowel count (as a syllab count).
#' @return A `data.frame` sorted in the same order as the `character` vector provided by the user, providing for each element of the vector :
#' \describe{
#'   \item{\code{n_char}}{`character` Number of characters - including spacing - in a line.}
#'   \item{\code{n_char_wo_space}}{`character` Number of characters - without spacing - in a line.}
#'   \item{\code{word_count_colname}}{`character` Number of words in a line.}
#'   \item{\code{vowel_count_colname}}{`character` Number of vowels in a line.}
#' }
#' @examples
#' # Example 1: Construct a corpus from local folders
#'  texts = c("the lazy rat terrier jump over the quick brown fox"
#'  , "cause lazy rat terrier are the best dog")
#'  compute_nchar_metrics(texts)
#' @export
compute_nchar_metrics <- function(text,
                                  nchar_colname = "n_char",
                                  nchar_nospace_colname = "n_char_wo_space",
                                  word_count_colname = "n_word",
                                  vowel_count_colname = "n_vowel") {

    # Remove spaces and newlines for character count without spaces
  txt_wo_space <- gsub(x = text, pattern = " |\n", "")

  # Compute words metrics
    words = strsplit(text, "\\s+")
    word_count = lengths(words)
word_count[is.na(words)] = NA

# compute all other metrics
  result <- data.frame(
    # Character count
    nchar = as.integer(nchar(text)),

    # Character count without spaces
    n_char_wo_space_line = as.integer(nchar(txt_wo_space)),

    # Word count
    word_count = as.integer(word_count) ,

    # Approximate syllable count (counting vowel groups as syllables)
    vowel_count =  as.integer(sapply(gregexpr("[aeiouyAEIOUY]+", text), function(x) sum(x > 0)))
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



