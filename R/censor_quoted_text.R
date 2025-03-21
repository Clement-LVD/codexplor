#' Censor or erase quoted substrings in a text
#'
#' This function takes a `character` string or vector and replaces each character
#' in each quoted substrings with a replacement character (by default "_"). When
#' suppress_quoting_char is FALSE (the default), the function preserves the original
#' opening and closing quotes and only censors the inner content. When TRUE, the quotes
#' are also replaced.
#'
#' @param text A character string containing the text to process.
#' @param char_for_replacing_each_char A single character string to be used for replacing
#'   each character in the substring.
#' @param suppress_quoting_char Logical. If TRUE, the quoting characters are replaced as well;
#'   if FALSE (default), they are preserved.
#' @return A character string with the content inside each quoted substring censored.
#' @examples
#' # Censor quoted content and keep the quotes:
#' text <- c("Example: \"Rat-terrier\" (aka 'Teddy Roosevelt Terrier')"
#' , "have served into a 'Truffe-terrier company'.")
#' censor_quoted_text(text, char_for_replacing_each_char = "_", suppress_quoting_char = FALSE)
#' # Remove quoted content and also remove the quotes:
#' censor_quoted_text(text, char_for_replacing_each_char = "", suppress_quoting_char = TRUE)
#' @export
censor_quoted_text <- function(text, char_for_replacing_each_char = "_", suppress_quoting_char = FALSE) {

  #1) FInd positions of " & '
# Helper function to find positions of quoted substrings.
find_quoted_positions <- function(text) {

  pattern <- "([\"'])(?:\\\\.|(?!\\1)[^\\\\])*\\1"
  # Regex explanation:
  # (["'])               : Capture an opening quote (either " or ')
  # (?:\\. | (?!\1)[^\\])* : Repeatedly match either an escaped character (like \") or any character that
  #                          is not a backslash and not the same as the captured opening quote (using negative lookahead)
  # \1                   : Match the same quote as captured in the first group to close the substring.

  # Use gregexpr to obtain match positions (perl = TRUE for advanced regex features)
    pos <- gregexpr(pattern, text, perl = TRUE)[[1]]

    # If no matches found, return empty vectors
  if (pos[1] == -1) return(list(starts = integer(0), ends = integer(0)))
  lengths <- attr(pos, "match.length")

  # Start positions are given by the result of gregexpr
    return(list(starts = pos, ends = pos + lengths - 1))
}
# recursive behavior if several texts :
if(length(text) > 1){

 texts <- sapply(X = text, FUN = function(txt){
if(is.na(txt)) return(txt)

   censor_quoted_text(text = txt
                       , char_for_replacing_each_char = char_for_replacing_each_char
                       , suppress_quoting_char =suppress_quoting_char )

  } )
  return(unlist(texts))
 }

positions <- find_quoted_positions(text)

  # If no positions provided, return text unchanged
  if (length(positions$starts) == 0) {
    return(text)
  }

  # Extract original quoted substrings using vectorized mapply
  original_substrings <- mapply(function(start, end) {
    substring(text, start, end)
  }, positions$starts, positions$ends, USE.NAMES = FALSE, SIMPLIFY = TRUE)

  # For each original substring, build a censored version.
  new_substrings <- mapply(function(orig) {
    n <- nchar(orig)
    if (suppress_quoting_char) {
      # Replace the entire substring (quotes and content) with the replacement character repeated.
     return(paste(rep(char_for_replacing_each_char, n), collapse = "") )
    }

    if (!suppress_quoting_char) {
      # OR Keep the first and last characters (the quotes) and replace the inner content.
      if (n >= 2) {
        inner_length <- n - 2 #leng. without the quoting char

         # construct a replacement chain of same leng(empty if no content) :
        inner_replacement <- if (inner_length > 0) paste(rep(char_for_replacing_each_char, inner_length), collapse = "") else ""
# and we return the text wit the quotation char
        paste0(substr(orig, 1, 1), inner_replacement, substr(orig, n, n))
      } else {
        # Edge case: if the quoted string is only one character long.
        paste(rep(char_for_replacing_each_char, n), collapse = "")
      }
    }
  }, original_substrings, USE.NAMES = FALSE, SIMPLIFY = TRUE)

  # Create a match object from positions (as expected by regmatches)
  m <- positions$starts
  attr(m, "match.length") <- positions$ends - positions$starts + 1

  # Use regmatches replacement: this replaces the matched segments in text with new_substrings.
  regmatches(text, list(m)) <- list(new_substrings)

  return(text)
}
