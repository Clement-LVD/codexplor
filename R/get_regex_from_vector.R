#' Generate Regular Expression from a Character Vector
#'
#' This function takes a vector of strings and returns a concatenated regular expression pattern.
#' It allows adding escaping before unescaped special characters
#' and also add a prefix and sometimes a suffix to each elements before to concatenate them into a regex.
#' The suffix will be added only for the texts with less characters than the `n_char_to_add_suffix` value
#' (default never add a suffix).
#'
#' @param vector `character` A character vector containing the elements to convert into a regular expression.
#' @param prefix_for_regex `character` A string to prepend to each element of the vector in the regex pattern.
#' @param suffix_for_regex `character` A string to append to each element of the vector in the regex pattern.
#' @param fix_escaping `logical` If `TRUE` escaping will be fixed.
#' @param n_char_to_add_suffix `double`, default = `0` The minimum number of characters for adding a suffix (default will never add a suffix)
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
#' rgx <- get_regex_from_vector(words, "(", ")?", fix_escaping = TRUE)
#' #custom pattern "(" and ")?" will no be escaped, contrary to other texts
#'
#' @export
get_regex_from_vector <- function(vector, prefix_for_regex = "", suffix_for_regex =""
                                  ,  fix_escaping = TRUE
                                  , n_char_to_add_suffix = 0

    ){
  if(length(vector) == 0) return("")
#### 1) List the result ####
fn_defined <- unique(vector) # it's the func' defined by default

fn_defined <- fn_defined[which(!is.na(fn_defined))]

if(fix_escaping) {fn_defined <-  fix_escaping(fn_defined )}

#### 2) Construct a regex ####
regexx <-  sapply(fn_defined
                     , FUN = function(x){
     # verify the nchar before adding a suffix
if(nchar(x) < n_char_to_add_suffix){
return(paste0(prefix_for_regex, x, suffix_for_regex))
} # or don't add the suffix (too much char already) :
return(paste0(prefix_for_regex, x))
                       })

# optionnally add a suffix (such as a filter from the user, capture-group, etc.)

# made a single regex and clean it from unescaped chars
regexx_complete <- paste0(regexx, collapse = "|")


return(regexx_complete)
}
