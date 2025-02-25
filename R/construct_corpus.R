#' Construct a Data Frame of Code Files from Local GitHub Repositories and/or Local Folders
#'
#' This function builds a structured data frame containing code files
#' from either GitHub repositories or local folder paths.
#' Then it try to extract function names in the lines previously readed
#' , according to the default pattern designed for matching functions names.
#' The resulting data frame provides an overview of the collected content,
#'  including file paths, URLs (if applicable), and languages.
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
#'   \item{\code{file_path}}{Character. The local file path or constructed GitHub URL.}
#' }
#' @seealso \code{\link{srch_pattern_in_files_get_df}}, \code{\link{get_github_raw_filespath}}, \code{\link{get_def_regex_by_language}}
#' @details
#' - If `local_folders_paths` is provided (one or a list), the function scans the directories and retrieves file paths matching the specified languages.
#' - If `repos` is provided (one or a list), it constructs URLs to the raw content of files from the specified GitHub repositories.
#' - Both local paths and GitHub URLs can be combined in the final output.
#'
#' @examples
#' # Example 1: Construct a corpus from local folders
#' cr1 <- construct_corpus("~", languages = c("R", "Python"), .verbose = FALSE)
#'
#' # Example 2: Construct a corpus from GitHub repositories
#' cr2 <- construct_corpus(repos = c("tidyverse/stringr", "tidyverse/readr"), .verbose = FALSE)
#'
#' # Example 3: Combine local folders and GitHub repositories
#' cr3 <- construct_corpus("~", c("R", "Cpp"), "tidyverse/dplyr", .verbose = FALSE)
#'
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

# 1) get regex of func' definition AND pattern of the files
lang_desired <- codexplor::get_def_regex_by_language(languages)

# 2-A} get urls from github 1st
if(!is.null(repos)){ urls <- get_github_raw_filespath(repo = repos, pattern = lang_desired$file_ext) }

if(!is.null(local_folders_paths)){ #get local filepaths

pattern = paste0(collapse = "|",lang_desired$local_file_ext )

files_path <- unlist(sapply(local_folders_paths, FUN = function(path){ list.files(recursive = T, full.names = T, path = path, pattern = pattern) }))

}

files_path <- as.character(unlist(c(files_path, urls)) )#the files.path + url

# eliminate some patterns (e.g., '.Rcheck' for R project)
files_to_exclude = NULL
if(autoclean_filespath){ # use the pattern from our dictionnary (e.g., exclude ".Rcheck" if R language)
  files_to_exclude = grep(x=files_path, pattern = paste0(lang_desired$pattern_to_exclude , collapse = "|")  )
}
  if(!is.null(pattern_to_exclude_path)) files_to_exclude = grep(x=files_path, pattern = pattern_to_exclude_path)

  if(length(files_to_exclude)>0) files_path <- files_path[-files_to_exclude]


# 2-B} Get content from R files
complete_content <-  srch_pattern_in_files_get_df(files_path = files_path,
                               ,pattern = paste0(lang_desired$fn_regex, collapse = "|")
                               , ...)

# in this stage we need  to clean the files path before claiming that it's a 'cool corpus to analyze'
if(is.character(pattern_to_remove)){

  # force remove a pattern
  complete_content[, 1:2] <- lapply(complete_content[, 1:2], function(col) gsub(pattern = pattern_to_remove, "", x = col))

}
 # (DEFINITION of func' according to the lang desired regex = function name are matched)

return(complete_content)

}
