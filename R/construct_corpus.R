#' Construct a Data Frame of Code Files from Local GitHub Repositories and/or Local Folders
#'
#' This function builds a structured data frame containing code files
#' from either GitHub repositories or local folder paths.
#' Then it **try to extract function names** according to a dictionary
#' of functions definition.
#' The resulting data frame provides an overview of the collected content,
#'  including file paths, URLs (if applicable), and languages.
#'
#' @param local_folders_paths A character vector of local folder paths to scan for code files. Default is `NULL`.
#' @param languages A character vector specifying the programming language(s) to include in the corpus. Default is `"R"`.
#' @param repos A character vector of GitHub repository URLs or repository identifiers (e.g., `"user/repo"`) to extract files from. Default is `NULL`.
#' @param ... Additional arguments passed to `srch_pattern_in_files_get_df`
#' (e.g., filtering criteria, depth of folder scanning, names of returned df col').
#'
#' @return A data frame containing the corpus of collected files. The data frame typically includes columns such as:
#' \describe{
#'   \item{\code{file_path}}{Character. The local file path or constructed GitHub URL.}
#' }
#' @seealso \code{\link{srch_pattern_in_files_get_df}}, \code{\link{get_github_raw_filespath}}, \code{\link{function_def_regex_by_language}}
#' @details
#' - If `local_folders_paths` is provided (one or a list), the function scans the directories and retrieves file paths matching the specified languages.
#' - If `repos` is provided (one or a list), it constructs URLs to the raw content of files from the specified GitHub repositories.
#' - Both local paths and GitHub URLs can be combined in the final output.
#'
#' @examples
#' # Example 1: Construct a corpus from local folders
#' corp_myself <- construct_corpus(local_folders_paths = "~", languages = c("R", "Python"))
#'
#' # Example 2: Construct a corpus from GitHub repositories
#' corp_strreadr <- construct_corpus(repos = c("tidyverse/stringr", "tidyverse/readr"), "R")
#'
#' # Example 3: Combine local folders and GitHub repositories
#' corp_me_and_dplyr <- construct_corpus("~", repos = "tidyverse/dplyr", c("R", "Cpp"))
#'
#' @export
construct_corpus <- function( local_folders_paths = NULL
, languages = "R"
 , repos = NULL
, ...
){

#### 1) CONSTRUCT A CORPUS of files path and/or urls ####
urls = NULL
files_path = NULL

# get regex of func' definition AND pattern of the files
lang_desired <- function_def_regex_by_language(languages)

# 1-A} get urls from github 1st
if(!is.null(repos)){ urls <- get_github_raw_filespath(repo = repos, pattern = lang_desired$file_ext) }

if(!is.null(local_folders_paths)){ #get local filepaths

pattern = paste0(collapse = "|",lang_desired$local_file_ext )

files_path <- unlist(sapply(local_folders_paths, FUN = function(path){ list.files(recursive = T, full.names = T, path = path, pattern = pattern) }))

}

files_path <- as.character(c(files_path, urls)) #the files.path + url

#### 1-B} Get content from R files ####
complete_content <-  srch_pattern_in_files_get_df(files_path = files_path,
                               ,pattern = paste0(lang_desired$fn_regex, collapse = "|")
                               , ...)

 # (DEFINITION of func' according to the lang desired regex = function name are matched)

#### GET A 2nd match from the 1st ####
return(complete_content)

}
