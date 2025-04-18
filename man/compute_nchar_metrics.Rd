% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/compute_nchar_metrics.R
\name{compute_nchar_metrics}
\alias{compute_nchar_metrics}
\title{Get lines text-metrics from a df}
\usage{
compute_nchar_metrics(text)
}
\arguments{
\item{text}{\code{character}. A character vector of texts.}
}
\value{
A \code{data.frame} sorted in the same order as the \code{character} vector provided by the user, providing for each element of the vector :
\describe{
\item{\code{n_char}}{\code{character} Number of characters - including spacing - in a line.}
\item{\code{n_char_wo_space}}{\code{character} Number of characters - without spacing - in a line.}
\item{\code{word_count_colname}}{\code{character} Number of words in a line.}
\item{\code{vowel_count_colname}}{\code{character} Number of vowels in a line.}
}
}
\description{
Given a \code{character} vector, return a \code{data.frame} with lines text-mining metrics :
values are related to each element of the vector provided by the user.
}
\examples{
\dontrun{
# Example 1: Construct a corpus from local folders
 text = c("the lazy lazy lazy rat terrier jump over the quick brown fox"
 , "cause lazy rat terrier are the best dog")
 compute_nchar_metrics(text)
}
}
