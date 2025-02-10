#' Detect Unclosed or Mismatched Characters in Text
#'
#' This function scans through a character string (or vector of strings) to detect
#' unclosed or mismatched pairs of characters (such as parentheses, brackets, or braces)
#' as specified by the \code{open_and_close_to_test} parameter. For each occurrence
#' of an extra closing character or a missing closing for an opening character, the function
#' records the position (and optionnaly error type and relative char). Optionally, escaped characters can be ignored.
#'
#' @param text A character vector. Each element is a string in which to detect unclosed or
#' mismatched characters.
#' @param open_and_close_to_test A named character vector where the names represent opening
#' characters and the values the corresponding closing characters. The default is
#' \code{c("(" = ")", "[" = "]", "{" = "}")}.
#' @param return_list_of_position Logical. If \code{TRUE}, the function returns a vector of
#' positions where errors occur; if \code{FALSE}, it returns a detailed data frame with columns
#' \code{char}, \code{pos}, and \code{error}.
#' @param ignore_escaped Logical. If \code{TRUE}, the function removes (replaces with a space)
#' any escaped characters (those preceded by a backslash) before performing the check.
#'
#' @return Either \code{NULL} if no errors are found, a vector of positions (if \code{return_list_of_position}
#' is \code{TRUE}), or a data frame with error details (if \code{return_list_of_position} is \code{FALSE}).
#'
#' @details The function works by scanning each text element character-by-character.
#' For each opening character (as specified by \code{open_and_close_to_test}), it increments a counter
#' and stores its position. For each closing character, it checks if a matching opening character has been encountered.
#' If not, it records an error for an extra closing. After scanning, any remaining unmatched opening characters are
#' reported as missing a closing. If \code{ignore_escaped} is \code{TRUE}, any character preceded by a backslash is
#' replaced by a space before analysis.
#'
#' @examples
#' \dontrun{
#' # Example with balanced text
#' detect_unclosed_chars("a(b[c{d}e]f)g")
#'
#' # Example with an extra closing parenthesis
#' detect_unclosed_chars("a(b[c{d}e]f))g")
#'
#' # Example with a missing closing parenthesis
#' detect_unclosed_chars("a(b[c{d(e}f]g)")
#'
#' # Example returning detailed error data frame
#' detect_unclosed_chars("a(b[c{d(e}f]g)", return_list_of_position = FALSE)
#'
#' # Example ignoring escaped characters:
#' detect_unclosed_chars("a\\(b) c", ignore_escaped = TRUE)
#' # Will return position of char in the chain
#' # 4
#' }
#' @export
detect_unclosed_chars <- function(text,
                                  open_and_close_to_test = c("(" = ")", "[" = "]", "{" = "}"),
                                  return_list_of_position = TRUE,
                                  ignore_escaped = FALSE) {

  # Optionally remove escaped characters: replace any character preceded by '\' with a space
  if (ignore_escaped) {
    text <- gsub("\\\\.", " ", text)
  }

  # Initialize counters for each opening character
  # balance <- setNames(rep(0, length(open_and_close_to_test)), names(open_and_close_to_test))
  balance <- rep(0, length(open_and_close_to_test))
  names(balance) <- names(open_and_close_to_test)

  # Initialize lists to store positions of each opening character
  open_positions <- vector("list", length(open_and_close_to_test))
  names(open_positions) <-  names(open_and_close_to_test)
  # Initialize list for errors
  error_positions <- list()

  # Split text into individual characters
  chars <- unlist(strsplit(text, ""))
  indices <- seq_along(chars)

  # Function to check each character (utilizes super-assignment to update shared objects)
  check_char <- function(i, char) {
    if (char %in% names(open_and_close_to_test)) {
      balance[char] <<- balance[char] + 1
      open_positions[[char]] <<- c(open_positions[[char]], i)
    } else if (char %in% open_and_close_to_test) {
      # Determine the corresponding opening character
      open_char <- names(open_and_close_to_test)[which(open_and_close_to_test == char)]
      if (balance[open_char] > 0) {
        balance[open_char] <<- balance[open_char] - 1
        # Remove the last recorded position for this opening character
        open_positions[[open_char]] <<-  open_positions[[open_char]][-length(open_positions[[open_char]])]
          # equivalent to : head(open_positions[[open_char]], -1)
      } else {
        # Record error for an extra closing character
        error_positions <<- append(error_positions, list(list(char = char, pos = i, error = "Extra closing")))
      }
    }
  }

  # Apply check_char on each character via Map (vectorized application)
  invisible(Map(check_char, indices, chars))

  # For each opening character with a positive balance, record missing closing errors.
  remaining_errors <- lapply(names(balance[balance > 0]), function(char) {
    lapply(open_positions[[char]], function(pos) list(char = char, pos = pos, error = "Missing closing"))
  })

  # Combine error positions from extra closing and missing closing
  error_positions <- c(error_positions, unlist(remaining_errors, recursive = FALSE))

  if (length(error_positions) == 0) return(NULL)

  # Convert the list of errors to a data frame
  result_df <- do.call(rbind, lapply(error_positions, as.data.frame))

  if (return_list_of_position) return(result_df$pos)

  return(result_df)
}
