#' erase_quoted_text() will replace every character of text Between Quotes and the quotes themselves
#'
#' This function scans each element of a character vector for text enclosed by a specified quoting character
#' (by default the double quote, ". For each occurrence found, it replaces the entire matched string
#' (including the quoting characters) with a string composed of as many copies of a replacement character
#' (default is a single space) as there were characters in the matched string. This way, the overall length
#' of the element remains unchanged.
#'
#' @param text A character vector. Each element is a string in which quoted text will be replaced.
#' @param char_for_replacing_each_char A character string (of length 1) used as the replacement for each
#' character in the quoted portion. The default is a single space (\code{" "}).
#' @param quoting_char A character string (of length 1) indicating the quoting character to be used.
#' The default is the double quote ". For example, use ' for single quotes.
#'
#' @return A character vector of the same length as \code{text}, with the quoted segments replaced, including the 2 quotes
#' (beginning and end of the match). The replacement will be operated by replacing each char by the
#' \code{char_for_replacing_each_char} characters (by default a space).
#'
#' @examples
#' \dontrun{
#' # Example 1: Using the default (double quotes)
#' text1 <- 'This is a "test" and another "example".'
#' erase_quoted_text(text1)
#' # Expected output: "This is a "    " and another "       "."
#'
#' # Example 2: Using single quotes as delimiters
#' text2 <- "Here a 'sample' and another 'demo'."
#' erase_quoted_text(text2, quoting_char = "'")
#'
#' # Example 3: Using underscore as the replacement character
#' text3 <- 'Replace "text" here.'
#' erase_quoted_text(text3, char_for_replacing_each_char = "_")
#' }
#' @export
erase_quoted_text <- function(text, char_for_replacing_each_char = " "

                              , quoting_char = '"' ) {
  # Trouver les correspondances de texte entre guillemets simples
  regex_quoted_text = paste0(quoting_char, "([^", quoting_char, "]*)", quoting_char)

  # the default is : "'([^']*)'" , and if the user pass '"' it will be turned into '"([^"]*)"'
  matches <- gregexpr(regex_quoted_text, text)

  # Extraire les chaînes correspondantes
  matched_strings <- regmatches(text, matches)

  # for each text in list with FORCE ATTRIBUTION
 .junk <- lapply(seq_along(text), function(i) {
    # Si des correspondances existent dans ce texte
    text_to_change <- matched_strings[[i]]

    if (length(text_to_change) > 0) {
      # Pour chaque texte trouvé entre guillemets dans ce texte
      lapply(seq_along(text_to_change), function(y_on_i) {
        n_char_text_y <- nchar(text_to_change[[y_on_i]])  # Longueur du texte à remplacer

        # Remplacer chaque correspondance par des espaces de la même longueur
        text[i] <<- gsub(x = text[i],
                         pattern = text_to_change[[y_on_i]],
                         replacement = paste0(rep(char_for_replacing_each_char, n_char_text_y), collapse = ""))
      })
    }
  })

  return(text)
}

