#' fix_escaping ensure correct escaping of special characters in a string
#'
#' This function adds the designated number of escape characters (`\`) before special characters.
#'
#' @param text A character string to process.
#' @param special_chars A character vector of special characters that need escaping.
#' @param num_escapes Integer. Required number of `\` before special character.
#' @return A corrected string with the right number of escape characters.
#' @examples
#' codexplor::fix_escaping("This \\\\(is\\) (a\\\\\\) test?"
#' , special_chars = c("(", ")", "?"), num_escapes = 4)
#' # Returns: "This \\\\(is\\\\) \\\\(a\\\\) test\\\\?"
#' @export
fix_escaping <- function(text, special_chars, num_escapes = 2) {
  if (!is.character(text) || length(text) != 1) stop("text must be a single character string.")
  if (!is.character(special_chars) || length(special_chars) == 0) stop("special_chars must be a non-empty character vector.")
  if (!is.numeric(num_escapes) || num_escapes < 0) stop("num_escapes must be a non-negative integer.")

  # Construire les expressions régulières pour chaque caractère spécial
  patterns <- paste0("\\\\*", "\\", special_chars)  # Match existant + char spécial
  replacements <- paste0(strrep("\\", num_escapes), special_chars)  # Correct escaping

  # Appliquer la transformation sans boucle explicite
  fixed_text <- Reduce(function(txt, i) gsub(patterns[i], replacements[i], txt, perl = TRUE),
                       seq_along(special_chars), init = text)

  return(fixed_text)
}
