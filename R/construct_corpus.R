#' Construct a list of DataFrames of Lines Readed From Files
#' from Local GitHub Repositories and/or Local Folders
#'
#' Given a Language and a folder path(s) and/or github repo(s)
#' Build a list of 2 samely-structured dataframes containing files
#' from either GitHub repositories or local folder paths.
#'
#' @param local_folders_paths `character`. Default = `NULL`. A character vector of local folder paths to scan for code files.
#' @param languages `character`. Default = `"R"`. A character vector specifying the programming language(s) to include in the corpus.
#' @param repos `character`. Default = `NULL`. A character vector of GitHub repository URLs or repository identifiers to extract files from (e.g., `"user/repo"`).
#' @param ... Additional arguments passed to `srch_pattern_in_files_get_df`
#' (filtering options, depth of folder scanning, names of the returned df columns, .verbose parameter, etc.).
#'
#' @return A list of 4 dataframes containing the corpus of collected files : `codes` and `comments`. The data frames typically includes columns such as:
#' \describe{
#'   \item{\code{file_path}}{ `character` The local file path or constructed GitHub URL.}
#'   \item{\code{line_number}}{`integer` The line number of the file.}
#'   \item{\code{content}}{`character` The content in the line.}
#'   \item{\code{n_char}}{`integer` Number of characters - including spacing.}
#'   \item{\code{n_char_wo_space}}{`integer` Number of char. without spacing.}
#'   \item{\code{n_word}}{`integer` Number of words.}
#'   \item{\code{n_vowel}}{`integer` Number of voyel.}
#'   \item{\code{matches}}{`character` A 1st text, extracted accordingly to a pattern.}
#' }
#' @seealso \code{\link{readlines_in_df}}, \code{\link{get_github_raw_filespath}}, \code{\link{get_def_regex_by_language}}
#' @details
#' - If `local_folders_paths` is provided (one or a list), the function scans the directories and retrieves file paths matching the specified languages.
#' - If `repos` is provided (one or a list), it constructs URLs to the raw content of files from the specified GitHub repositories.
#' - Both local paths and GitHub URLs can be combined in the final output.
#'
#' @examples
#' # Example 1: Construct a corpus from local folders
#' cr1 <- construct_corpus("~", languages = c( "R") )
#' \dontrun{
#' # Example 2: Construct a corpus from GitHub repositories (default is R)
#' cr2 <- construct_corpus(repos = c("tidyverse/stringr", "tidyverse/readr") )
#'
#' # Example 3: Combine local folders and GitHub repositories
#' cr3 <- construct_corpus("~", "R", "c("tidyverse/stringr", "tidyverse/readr"))#' }
#' @export
construct_corpus <- function(
 local_folders_paths = NULL
, languages = "R"
 , repos = NULL

, ...
){

#### 1) CONSTRUCT A CORPUS of files path and/or urls ####
urls = NULL
files_path = NULL

# 1) get files infos associated to a language
lang_desired <- get_def_regex_by_language(languages)
#=> a dataframe by languages (e.g., file ext., pattern for defining a func')

# 2) construct list of files :
files_path <- get_list_of_files(local_folders_paths = local_folders_paths , repos = repos
    , file_ext =  lang_desired$file_ext #defined according to the langage
    , pattern_to_exclude_path = paste0(lang_desired$pattern_to_exclude , collapse = "|"))

# 3) extract lines from files
complete_files <- readlines_in_df(files_path = files_path, .verbose = F, ... )

# 4) add lines metrics
complete_files <- cbind(complete_files, compute_nchar_metrics(complete_files[[3]]) )

# => group_colname = "file_path", metric_pattern = "n_"
nodelist <- compute_nodelist(df = complete_files, group_col = "file_path")

# detect the commented lines
complete_files$comments <-  grepl(x = complete_files$content, pattern =  lang_desired$commented_line_char)

#### 4) Construct a corpus ####
# list of codes (non-commented) and commented line
col_to_keep <- !(names(complete_files) %in% c("comments"))

corpus <- list(
codes = complete_files[!complete_files$comments, col_to_keep ] # erasing the comments column
,comments = complete_files[complete_files$comments, col_to_keep ]
, nodelist = nodelist
            )

# 5-A} Get 1st matches
# => functions defined ! (here we are only ONE LANGUAGE BY ONE)
corpus$codes <- srch_pattern_in_df( df =  corpus$codes, content_col_name = "content",
                               ,  pattern = lang_desired$fn_regex , ...)

corpus$lang_desired <- lang_desired # from the begining !

# return a list of df with all our col'
# compcorpus# compute a nodelist FROM LINES : sum of these metrics is supposed to be document-level metrics
# this func' is hereafter : a grouped stat' (end of this .R file)

return(corpus)
}


construct_ex_corpus <- function(corpus
, pattern_to_exclude_path = NULL
, ignore_match_less_than_nchar = 3
, pattern_to_remove = "https://raw.githubusercontent.com/"
, ...
){



# file path 1st col / line_number 2nd / content is the 3rd col' /

# preparing the corpus : clean the files path
if(is.character(pattern_to_remove)){

  # force remove a pattern
  matched_codes[[1]] <- gsub(pattern = pattern_to_remove, "", x = matched_codes[[1]])

}

if(length(matched_codes[[1]]) == 0) return(matched_codes)


# 4) return a list (!!)
return(matched_codes)

}


#### 2) construct a nodelist
# Create a nodelist by summing metrics by group (col' are defined with a regex)
compute_nodelist <- function(df, group_col, metric_pattern = "n_") {

  # Check if the grouping column exists
  if (!group_col %in% colnames(df)) {
    stop(paste("Column", group_col, "does not exist in the dataframe."))
  }

  # Find columns matching the metric pattern
  metric_cols <- grep(metric_pattern, colnames(df), value = TRUE)
  metric_cols <- metric_cols[sapply(df[, metric_cols], is.numeric)]

  if (length(metric_cols) == 0) {
    warning("No metric columns found with the pattern: ", metric_pattern)

    return(nodelist)
    }

  # Aggregate by summing metrics by the group column
  nodelist <- stats::aggregate(df[, metric_cols],
                        by = list(df[[group_col]]),
                        FUN = sum)

  # Rename the grouping column to its original name
  colnames(nodelist)[1] <- group_col

  return(nodelist)
}
