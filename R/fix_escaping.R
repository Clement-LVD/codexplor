#' Escape the special characters in a string
#'
#' This function adds the designated number of escape characters (`\`) before special characters.
#'
#' @param text A character string to process.
#' @param special_chars A character vector of special characters that need escaping. Defaults are "`.`", "`(`",   "`{`","`}`",  "`[`", "`]`", and "`)`"
#' @param num_escapes Integer. Required number of `\` before special character.
#' @param use.names Boolean Should a named list with preserved name be returned. Default is `FALSE`.
#' @return A corrected string with the right number of escape characters.
#' @examples
#' \dontrun{
#' rgx <- fix_escaping("This (is) (a) test.", special_chars = c("(", ")", "?"), num_escapes = 4)
#' # Returns: "This \\\\(is\\\\) \\\\(a\\\\) test."
#' }
fix_escaping <- function(text, special_chars = c("(", ")", ".", "{", "}", "[", "]"), num_escapes = 2, use.names = F) {
  if (!is.character(special_chars) || length(special_chars) == 0) stop("special_chars must be a non-empty character vector.")
  if (!is.numeric(num_escapes) || num_escapes < 0) stop("num_escapes must be a non-negative integer.")

 texts <- sapply(text, FUN = function(text){

    # construct for each special char
  patterns <- paste0("\\\\*", "\\", special_chars)  # Match existant + char spécial
  replacements <- paste0(strrep("\\", num_escapes), special_chars)  # Correct escaping

  # Appliquer la transformation sans boucle explicite
  fixed_text <- Reduce(function(txt, i) gsub(patterns[i], replacements[i], txt, perl = TRUE),
                       seq_along(special_chars), init = text)

  return(fixed_text)
  }
    )

 if(use.names == FALSE) return(as.character(texts))

 return(unlist(use.names =use.names, texts))
}
