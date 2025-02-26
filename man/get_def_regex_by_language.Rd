% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_def_regex_by_language.R
\name{get_def_regex_by_language}
\alias{get_def_regex_by_language}
\title{Retrieve function definition regex patterns by programming language(s)}
\usage{
get_def_regex_by_language(...)
}
\arguments{
\item{...}{\code{character} One or more programming language names (character strings).}
}
\value{
A dataframe where each row corresponds to a language and contains:
\describe{
\item{\code{language}}{\code{character} The name of the language on a row (e.g., 'R').}
\item{\code{fn_regex}}{\code{character} The line number within the file.}
\item{\code{file_ext}}{\code{character} A line from the file}
\item{\code{local_file_ext}}{\code{character} A line from the file}
}
}
\description{
This function returns a df with regex patterns and file extensions associated with function definitions
for one or more specified programming languages.
}
\details{
This function supports multiple languages in a single call.
Language names are case-insensitive.
}
\examples{
# fn_def <- get_def_regex_by_language("Python", "R" , "Go", "C", "JavaScript")

}
