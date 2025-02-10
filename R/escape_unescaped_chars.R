#' Escape char if unescaped, default to incorrectly enclosed characters
#'
#' @param txt The text to process.
#' @param special_char_to_escape Characters to escape.
#' @param no_escaping_if_begin_of_chain `logical`, default = `FALSE` Logical flag. Avoid escape begining of a character chain
#' @param escaping_prefix `character`, default = `"\\\\"` The prefix to escape the characters with (also used for avoid to escape).
#' @return The processed text with the correctly escaped characters.
escape_unescaped_chars <- function(txt,  special_char_to_escape = c("(", ")","[", "]", "{", "}")
                                              , no_escaping_if_begin_of_chain = FALSE, escaping_prefix  = "\\\\") {

  a_except <- ifelse(no_escaping_if_begin_of_chain, "^", "")
  exception <- paste0("(?<!", a_except, escaping_prefix, ")") # Avoid already escaped characters

  # Escape characters
  txt <- Reduce(function(x, i) {
    char_i <- special_char_to_escape[i] # dyad of char to escape
        x <- gsub(pattern = paste0(exception, "\\", char_i),
              replacement = paste0(escaping_prefix, char_i),
              x = x, perl = TRUE)
    return(x)
  }, x = seq_along(special_char_to_escape), init = txt)

  return(txt)
}
