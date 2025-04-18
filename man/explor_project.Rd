% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/explor_project.R
\name{explor_project}
\alias{explor_project}
\title{Turn a programing project into a Corpus and get message about files and functions}
\usage{
explor_project(folders = NULL, repos = NULL, languages = "R", head = 5, ...)
}
\arguments{
\item{folders}{\code{character} A string or list representing the path(s) of local folders path to read.}

\item{repos}{\code{character} A string or list representing the name(s) of github repos (e.g., 'tidyverse/stringr').}

\item{languages}{\code{character}. Default = \code{"R"}. A character vector specifying the programming language(s) to include in the corpus.}

\item{head}{\code{integer}. Default = \code{5}. Number of lines to print.}

\item{...}{Parameters passed to \code{construct_corpus()}. These parameters are
\itemize{
\item characters values, in order to add a prefix and a suffix to the pattern searched (e.g., \code{suffix_for_2nd_matches})
or changing the colnames (e.g., \code{file_path_from_colname}).
\item double values, e.g., \code{n_char_to_add_suffix} parameter (minimum number of characters to add the suffix).
\item logical values, e.g., \code{filter_egolink_within_a_file} (default = \code{TRUE}) and \code{exclude_quoted_content} from the research (default = \code{FALSE})
}}
}
\value{
A \code{list} of 5 \code{dataframe} : 2 of class \code{corpus.lines}, 2 \code{corpus.nodelist} and 1 \code{citations.network}
(symbolizing the edgelist of a document-to-document citations network within a programming project)
\describe{
\item{\code{from}}{\code{character} citations.network - The local file path or GitHub URL that call a function.}
\item{\code{to}}{\code{character} citations.network - The local file path or constructed GitHub URL where the function called is defined.}
\item{\code{function}}{\code{character} citations.network - The name of the function matched on a line.}
\item{\code{content_matched}}{\code{character} citations.network - The full content matched with the 2nd matches, in order to verify and craft a new regex.}
\item{\code{line_number}}{\code{character} citations.network & corpus.lines - The line number of the 2nd match (citation.network) or associated with a line (corpus.lines).}
\item{\code{file_path}}{\code{character} corpus.lines & corpus.nodelist - The local file path or constructed GitHub URL, same values as the \code{from} & \code{to} columns of the citations.network df.}
\item{\code{content}}{\code{character} corpus.lines - The content from a line.}
\item{\code{matches}}{\code{character} corpus.lines (specifically the \code{codes} data.frame)
\itemize{
\item The matched text during the 1st matches (full of \code{NA} if there is no match or if they are filtered out, the default).}
}
}
}
\description{
This function craft a corpus, according to the default settings. It will
return the corpus with a citations network of internal dependancies and print some message
}
\examples{
# Example with url from github
corpus <- explor_project(folders =  "~" )
# Return a list of df
# (from the file where a function is call => to the file were defined)
}
\seealso{
\code{\link{construct_corpus}}

\url{https://clement-lvd.github.io/codexplor/articles/vignette_analyse_citations_network_from_project.html}
\url{https://clement-lvd.github.io/codexplor/articles/vignette_construct_corpus.html}
\url{https://clement-lvd.github.io/codexplor/articles/vignette_citations.network_df_of_internal.dependencies.html}
}
