#' Construct a Data Frame of Code Files from Local GitHub Repositories and/or Local Folders
#'
#' Build a structured data frame containing code files
#' from either GitHub repositories or local folder paths.
#' Then extract a pattern in the lines previously readed
#' (the default pattern provided is designed for matching functions names).
#' The resulting data frame provides an overview of the collected content,
#'  including file paths and/or URLs.
#'
#' @param local_folders_paths `character`. Default = `NULL`. A character vector of local folder paths to scan for code files.
#' @param languages `character`. Default = `"R"`. A character vector specifying the programming language(s) to include in the corpus.
#' @param repos `character`. Default = `NULL`. A character vector of GitHub repository URLs or repository identifiers to extract files from (e.g., `"user/repo"`).
#' @param pattern_to_exclude_path `character`. A regular expression pattern to exclude files by scanning their full names (path/filename.ext).
#' Default is `NULL` (no files are excluded).
#' @param autoclean_filespath `logical`. Default = `TRUE`.
#' Codexplor try to exclude testing files *before* to read the files of a project ; and it will try to clean the urls of the returned df
#' By default, typical testing-purpose .R files are excluded
#' (i.e. "`r get_def_regex_by_language("R")$pattern_to_exclude`")
#' , in addition to an optional `pattern_to_exclude_path` passed by the user.
#' @param ignore_match_less_than_nchar `integer`. Default = `3`. Number of characters for the 1st match to be considered valid.
#' @param pattern_to_remove `character` Default = `'https://raw.githubusercontent.com/'`
#' A pattern (regex) to remove from the files path of the edgelist (columns 1 & 2)
#' @param ... Additional arguments passed to `srch_pattern_in_files_get_df`
#' (filtering options, depth of folder scanning, names of the returned df columns, .verbose parameter, etc.).
#'
#' @return A data frame containing the corpus of collected files. The data frame typically includes columns such as:
#' \describe{
#'   \item{\code{file_path}}{ `character` The local file path or constructed GitHub URL.}
#'   \item{\code{line_number}}{`integer` The local file path or constructed GitHub URL.}
#'   \item{\code{content}}{`character` The local file path or constructed GitHub URL.}
#'   \item{\code{n_char_line}}{`integer` Total nchar of a line, including spacing.}
#'   \item{\code{n_char_wo_space_line}}{`integer` Total nchar of a line, *without* spacing.}
#'   \item{\code{nchar_wo_space_in_file}}{`integer` Sum of n_char_wo_space_line for a given file path
#'    (same value is repeated for each file path)}
#' }
#' @seealso \code{\link{srch_pattern_in_df}}, \code{\link{get_github_raw_filespath}}, \code{\link{get_def_regex_by_language}}
#' @details
#' - If `local_folders_paths` is provided (one or a list), the function scans the directories and retrieves file paths matching the specified languages.
#' - If `repos` is provided (one or a list), it constructs URLs to the raw content of files from the specified GitHub repositories.
#' - Both local paths and GitHub URLs can be combined in the final output.
#'
#' @examples
#' # Example 1: Construct a corpus from local folders
#' cr1 <- construct_corpus("~", languages = c( "Python") )
#' \dontrun{
#' # Example 2: Construct a corpus from GitHub repositories
#' cr2 <- construct_corpus(repos = c("tidyverse/stringr", "tidyverse/readr") )
#'
#' # Example 3: Combine local folders and GitHub repositories
#' cr3 <- construct_corpus("~", "R", "tidyverse/dplyr" )
#' }
#' @export
construct_corpus <- function( local_folders_paths = NULL
, languages = "R"
 , repos = NULL
, pattern_to_exclude_path = NULL
, autoclean_filespath = TRUE
, ignore_match_less_than_nchar = 3
, pattern_to_remove = "https://raw.githubusercontent.com/"
, ...
){

#### 1) CONSTRUCT A CORPUS of files path and/or urls ####
urls = NULL
files_path = NULL

#infos on the languages
lang_desired <- get_def_regex_by_language(languages)
# construct list of files :
files_path <- get_list_of_files(local_folders_paths = local_folders_paths
    , repos = repos, file_ext =  lang_desired$file_ext
 , pattern_to_exclude_path = paste0(lang_desired$pattern_to_exclude , collapse = "|"))

#extract full text : corpus of comments and corpus of code !
complete_files <-  readlines_in_df(files_path = files_path  , .verbose = F )

corpus_comments <-  complete_files[grep(x = complete_files$content,pattern =  lang_desired$commented_line_char), ]

corpus_codes <- complete_files[-grep(x = complete_files$content,pattern =  lang_desired$commented_line_char), ]


# 2-B} Get 1st matches => functions defined ! only ONE LANGUAGE BY ONE !
complete_content <- srch_pattern_in_df( df =  corpus_codes, content_col_name = "content",
                               ,  pattern = lang_desired$fn_regex , ...)
# file path 1st col / line_number 2nd / content is the 3rd col' /

# preparing the corpus : clean the files path
if(is.character(pattern_to_remove)){

  # force remove a pattern
  complete_content[[1]] <- gsub(pattern = pattern_to_remove, "", x = complete_content[[1]])

}

if(length(complete_content[[1]]) == 0) return(complete_content)

#### COMPUTE LINES METRICS ####
# return nchar metrics if more than 0 row
complete_content <- cbind(complete_content
                          , compute_nchar_metrics(text = as.character(complete_content[[3]])
                                                  , nchar_nospace_colname = "n_char_wo_space_line"
                                                  ) )

# add total files metrics since in the end it will be turned into a nodelist
sum_cat <- by(complete_content$n_char_wo_space_line, complete_content$file_path, sum)
# merge this list with our nodes
complete_content <- merge(complete_content, all.x=T

                           , data.frame(file_path = names(sum_cat), nchar_wo_space_in_file= unlist(use.names = F, sum_cat))

                                               ,  by = "file_path")

# 4) return a df
return(complete_content)

}
