% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_regex_from_vector.R
\name{get_regex_from_vector}
\alias{get_regex_from_vector}
\title{Generate Regular Expression from a Character Vector}
\usage{
get_regex_from_vector(
  vector,
  prefix_for_regex = "",
  suffix_for_regex = "",
  fix_escaping = TRUE,
  n_char_to_add_suffix = 0
)
}
\arguments{
\item{vector}{\code{character} A character vector containing the elements to convert into a regular expression.}

\item{prefix_for_regex}{\code{character} A string to prepend to each element of the vector in the regex pattern.}

\item{suffix_for_regex}{\code{character} A string to append to each element of the vector in the regex pattern.}

\item{fix_escaping}{\code{logical} If \code{TRUE} escaping will be fixed.}

\item{n_char_to_add_suffix}{\code{double}, default = \code{0} The minimum number of characters for adding a suffix (default will never add a suffix)}
}
\value{
A single character string containing the regular expression pattern
created by concatenating all elements from the input vector,
with the specified prefix and suffix applied, and special characters escaped.
}
\description{
This function takes a vector of strings and returns a concatenated regular expression pattern.
It allows adding escaping before unescaped special characters
and also add a prefix and sometimes a suffix to each elements before to concatenate them into a regex.
The suffix will be added only for the texts with less characters than the \code{n_char_to_add_suffix} value
(default never add a suffix).
}
\details{
such as a list of \code{special_chars_to_escape},
a number of escaping char. to add (default is \code{num_escapes = 2}),
the escaping char. to consider, etc.
}
\examples{
\dontrun{
# Example 1: Create a regex pattern for a vector of words
words <- c("apple", "banana", "cherry")
rgx <- get_regex_from_vector(words, "^", "$")

# Example 2: Create a regex pattern for words with escaped parentheses
words <- c("foo(bar)", "baz(qux)")
rgx <- get_regex_from_vector(words, "(", ")?", fix_escaping = TRUE)
#custom pattern "(" and ")?" will no be escaped, contrary to other texts
}
}
\seealso{
\code{\link{fix_escaping}},
}
