#' Construct a list of 3 Data Frames of Lines Readed From Files
#' Within a Local GitHub Repositories and/or Local Folders
#'
#' Given a Language and a folder path(s) and/or github repo(s)
#' The 3 dataframes are :
#' a corpus of (1) `codes` lines and (2) `comments` lines with text-metrics over the lines,
#' and (3) nodelist with global metrics over the files.
#' The returned list is a S3 "corpus_list" (standard S3 list with attributes and name)
#' @param folders `character`. Default = `NULL`. A character vector of local folder paths to scan for code files.
#' @param languages `character`. Default = `"R"`. A character vector specifying the programming language(s) to include in the corpus.
#' @param repos `character`. Default = `NULL`. A character vector of GitHub repository URLs or repository identifiers to extract files from (e.g., `"user/repo"`).
#' @param ... Additional arguments passed to `srch_pattern_in_files_get_df`
#' (filtering options, depth of folder scanning, names of the returned df columns, .verbose parameter, etc.).
#'
#' @return A list of 3 dataframes containing the corpus of collected files : `codes`, `comments` and `nodelist`
#' The data frames typically includes columns such as:
#' \describe{
#'   \item{\code{file_path}}{ `character` The local file path or constructed GitHub URL.}
#'   \item{\code{line_number}}{`integer` The line number of the file.}
#'   \item{\code{content}}{`character` The content in a line of the file.}
#'   \item{\code{file_ext}}{`character` File extension of the file.}
#'   \item{\code{n_char}}{`integer` Number of characters - including spacing - in a line  (or the file for the `nodelist` df).}
#'   \item{\code{n_char_wo_space}}{`integer` Number of characters - without spacing - in a line (or the file for the `nodelist` df)}
#'   \item{\code{n_word}}{`integer` Number of words in a line  (or the file for the `nodelist` df).}
#'   \item{\code{n_vowel}}{`integer` Number of voyel in a line (or the file for the `nodelist` df).}
#'   \item{\code{matches}}{`character` (only in the `codes` df) A 1st matched text, extracted accordingly to a pattern.}
#'   \item{\code{n_total_lines}}{`integer` (only in the `nodelist` df) Number of lines of the files (with and without comments).}
#'   \item{\code{n_total_lines}}{`integer` (only in the `nodelist` df) Number of clines of the files *without comments*.}
#'   \item{\code{text}}{`character` (only in the `nodelist` df) The concatenated text from the lines readed.}
#' }
#'
#' @details
#' - If `folders` is provided (one or a list), the function scans the directories and retrieves file paths matching the specified languages.
#' - If `repos` is provided (one or a list), it constructs URLs to the raw content of files from the specified GitHub repositories.
#' - Both local paths and GitHub URLs can be combined in the final output.
#'
#' The returned list is tagged
#' with the class *corpus_list*, and contains the following attributes:
#' - `date_creation` : `Date` a Date indicating when the corpus list was created (as `Sys.Date()`).
#' - `citations_network` : a `logical` indicating if a citations_network was processed
#' (construct_corpus don't return a citations_network so it will be set to  `FALSE`)
#' - `languages_patterns` : a dataframe with the default pattern associated with the
#'  requested languages, a subset of the `languages` parameters or entire list
#' (e.g., file extension and a regex pattern for function definition).
#' @examples {
#' # Example 1: Construct a corpus from local folders
#'     cr1 <- construct_corpus(folders = "~", languages = c("Python", "R"))
#'
#'     \dontrun{
#' # Example 2: Construct a corpus from GitHub repositories (default is R)
#' cr2 <- construct_corpus(repos = c("tidyverse/stringr", "tidyverse/readr") )
#'
#' # Example 3: Combine local folders and GitHub repositories
#' cr3 <- construct_corpus("~", "R", "c("tidyverse/stringr", "tidyverse/readr"))
#' }}
#' @seealso \code{\link{readlines_in_df}}, \code{\link{get_github_raw_filespath}}, \code{\link{get_def_regex_by_language}}
#' @seealso
#'   \url{https://clement-lvd.github.io/codexplor/articles/vignette_construct_corpus.html}
#' @export
construct_corpus <- function(
 folders = NULL
, languages = "R"
 , repos = NULL

, ...
){
#serialized over a "language" = specific treatment from a dictionnary
# 1) get files infos associated to a language
lang_dictionnary <- get_def_regex_by_language(languages)
#=> a dataframe by languages (e.g., file ext., pattern for defining a func')
# we'll return it as an attributes of the corpus_list

# we'll iterate into a sequens of languages
sequens_of_languages <- seq_along(lang_dictionnary[[1]])

if(length(sequens_of_languages) == 0) return(NA)

# lapply within each language until the end of the fun'
results <- lapply(sequens_of_languages, function(i) {

  lang_desired <- lang_dictionnary[i, ]


#### 1) CONSTRUCT A CORPUS of files path and/or urls ####
urls = NULL
files_path = NULL

# 2) construct list of files :
files_path <- get_list_of_files(folders = folders , repos = repos
    , file_ext =  lang_desired$file_ext #defined according to the langage
    , pattern_to_exclude_path = paste0(lang_desired$pattern_to_exclude , collapse = "|"))

# 3) extract lines from files
complete_files <- readlines_in_df(files_path = files_path, .verbose = F, ... )
# add real files ext (checking if an extension default pattern return a fake file)

if(is.null(complete_files)) return(NA)

complete_files$file_ext <- gsub(x = basename(complete_files$file_path), ".*\\." ,replacement = "")

# 4.1.) ADD LINES TEXT-METRICS
complete_files <- cbind(complete_files, compute_nchar_metrics(complete_files[[3]]) )

# 4.2.) detect the commented lines
complete_files$comments <-  grepl(x = complete_files$content, pattern =  lang_desired$commented_line_char)

# 5) Aggregate by group_colname = "file_path", e.g., sum of col' with a metric_pattern ("n_")
nodelist <- compute_nodelist(df = complete_files, group_col = "file_path"
                             , colname_content_to_concatenate = "content")


#### 6) Construct a corpus ####
# list of codes (non-commented) and commented line
col_to_keep <- !(names(complete_files) %in% c("comments"))

corpus <- list(
codes = complete_files[!complete_files$comments, col_to_keep ] # erasing the comments column
,comments = complete_files[complete_files$comments, col_to_keep ]
, nodelist = nodelist
            )

# 5-A} Get 1st matches (maybe duplicated lines here : xxx beurk xxx)
# => functions defined ! (here we are only ONE LANGUAGE BY ONE)
corpus$codes <- srch_pattern_in_df( df =  corpus$codes, content_col_name = "content",
                               ,  pattern = lang_desired$fn_regex )

corpus <- structure(
  corpus,           # La liste de dataframes
  class = c("corpus_list", "list")  # claim a custom 'corpus_list' class (list heritage)
, date_creation = Sys.Date()
, citations_network = F
, languages_patterns = lang_dictionnary # our params from the begining of this function

  )
#add class attributes and structure (optionnal doc' & methods heritated)

# return a list of df with all our col'
# compute a nodelist FROM LINES : sum of these metrics is supposed to be document-level metrics
# this func' is hereafter : a grouped stat' (end of this .R file)

return(corpus)

})
#we have a 'result' under lapply
### DEAL WITH THE END OF THE LAPPLY BOUCLE
# return a structured list of class corpus_list

stored_attributes <- attributes(results[[1]]) # each have the same attributes

# rbind each list according to their position
combined <- do.call(mapply, c(FUN = function(...) rbind(...), results, SIMPLIFY = FALSE))
# stockpile by names (default) when structures are coherent (here we have a proper structure definition)
# ironnically we lost the attributes along the way
attributes(combined) <- stored_attributes

return(combined)
}




#### 2) construct a nodelist
# Create a nodelist by (a) summing metrics by group (col' are defined with a regex)
# AND aggregating the text with gather_lines_to_df !
compute_nodelist <- function(df, group_col, metric_pattern = "n_", colname_content_to_concatenate = NULL) {

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

# adding n_lines
  # Aggregate by summing metrics by the group column
  nodelist <- stats::aggregate(df[, metric_cols],
                        by = list(df[[group_col]]),
                        FUN = sum)

  # Rename the grouping column to its original name
  colnames(nodelist)[1] <- group_col

  # add n_lines_of_code
  nodelist$n_total_lines <- tapply(df[[group_col]], df[[group_col]], length)[nodelist[[group_col]] ]

  if(all(c("comments") %in% colnames(df))) {
   df_filtered <- df[df$comments == FALSE, ]

      # compute n_codeslines
   max_values_df <- by(df_filtered$comments, df_filtered[[group_col]], FUN = length)

   # convert into a df and add a proper "group_colname" before the merging
   max_values_df <- data.frame(group_col = names(max_values_df), n_codelines = unlist(max_values_df))
colnames(max_values_df)[[1]] <- group_col
   # merge with nodelist : n_codelines added
   nodelist <- merge(nodelist, max_values_df, by = group_col, all.x = TRUE)

     }


# 2.) optionnally add a proper "text" column (full content) with gather_df_lines (add a text col')
if(!is.null(colname_content_to_concatenate)){

  files_content <- gather_df_lines(df, group_col, colname_content_to_concatenate)
  files_content <- unique(files_content)
  # here : xxx must separe into another function  doing these grouped stats xxx
  # f. ex. : example <- extract_nested_blocks_from_text(files_content$text[1])
  #
  nodelist <- merge(all.x = T, nodelist, files_content, by = group_col )

}


  return(nodelist)
}
