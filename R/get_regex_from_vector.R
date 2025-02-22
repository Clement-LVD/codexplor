#' Generate Regular Expression from a Character Vector
#'
#' This function takes a vector of strings and returns a concatenated regular expression pattern.
#' It allows adding a prefix and/or suffix to each element and escaping special characters.
#'
#' @param vector A character vector containing the elements to convert into a regular expression.
#' @param prefix_for_regex A string to prepend to each element of the vector in the regex pattern.
#' @param suffix_for_regex A string to append to each element of the vector in the regex pattern.
#' @param fix_escaping A boolean, indicating if escaping should be fixed. Default is TRUE
#' @param ... Passed to fix_escaping
#' @details
#' such as a list of `special_chars_to_escape`,
#' a number of escaping char. to add (default is `num_escapes = 2`),
#' the escaping char. to consider, etc.
#' @seealso \code{\link{fix_escaping}},
#' @return A single character string containing the regular expression pattern
#' created by concatenating all elements from the input vector,
#' with the specified prefix and suffix applied, and special characters escaped.
#' @examples
#' # Example 1: Create a regex pattern for a vector of words
#' words <- c("apple", "banana", "cherry")
#' rgx <- get_regex_from_vector(words, "^", "$")
#'
#' # Example 2: Create a regex pattern for words with escaped parentheses
#' words <- c("foo(bar)", "baz(qux)")
#' rgx <- get_regex_from_vector(words, "(", ")?", c("(", ")"), fix_escaping = TRUE)
#' #here we don't escape our custom pattern "(" and ")?" even if escaping of other will be fixed
#'
#' @export
get_regex_from_vector <- function(vector, prefix_for_regex = "", suffix_for_regex ="",  fix_escaping = TRUE, ...
    ){
  if(length(vector) == 0) return("")
#### 1) List the result ####
fn_defined <- unique(vector) # it's the func' defined by default

fn_defined <- fn_defined[which(!is.na(fn_defined))]

if(fix_escaping) {fn_defined <-  fix_escaping(fn_defined )}

#### 2) Construct a regex ####
# optionnally add a suffix (such as a filter from the user, capture-group, etc.)
regexx <- paste0(prefix_for_regex, fn_defined, suffix_for_regex)

# made a single regex and clean it from unescaped chars
regexx_complete <- paste0(regexx, collapse = "|")


return(regexx_complete)
}
