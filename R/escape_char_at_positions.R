#' Escape characters at specific positions
#'
#' @param txt The text to process (character).
#' @param positions The positions at which to escape characters.
#' @param escaping_prefix The prefix to escape the characters with.
#' @return The processed text with escaped characters at specific positions.
escape_char_at_positions <- function(txt, positions, escaping_prefix = "\\\\") {
  # Sort positions in decreasing order to avoid issues with shifting positions
  positions <- sort(positions, decreasing = TRUE)

  # Escape characters at the specified positions
  modified_text <- Reduce(function(x, pos) {
    if (pos <= nchar(x)) {
      char_to_replace <- substr(x, pos, pos)
      x <- paste0(substr(x, 1, pos - 1), escaping_prefix, char_to_replace, substr(x, pos + 1, nchar(x)))
    }
    return(x)
  }, positions, init = txt)

  return(modified_text)
}
