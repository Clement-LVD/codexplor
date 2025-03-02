#' Construct a list of 3 Data Frames of Lines Readed From Files
#' Within a Local GitHub Repositories and/or Local Folders
#'
#' Given a Language and a folder path(s) and/or github repo(s)
#' Return a `list` of 3 dataframes. List have an additionnal `corpus.list` class. The 3 `df` are :
#'  (1) `codes` lines and (2) `comments` lines, with text-metrics about each line;
#' and (3) nodelist with global metrics over the files.
#' @param folders `character`. Default = `NULL`. A character vector of local folder paths to scan for code files.
#' @param languages `character`. Default = `"R"`. A character vector specifying the programming language(s) to include in the corpus.
#' @param repos `character`. Default = `NULL`. A character vector of GitHub repository URLs or repository identifiers to extract files from (e.g., `"user/repo"`).
#' @param .verbose `logical`. Default = `TRUE`. A logical used to silent the message in console.
#' @param ... Additional arguments passed to `srch_pattern_in_files_get_df`
#' (filtering options, depth of folder scanning, names of the returned df columns, .verbose parameter, etc.).
#'
#' @return A `list` of 3 `data.frame` containing the corpus of collected files and a nodelist :
#' `codes` and `comments` (`data.frame` with class `corpus.lines`) and `nodelist` (`data.frame` with class `corpus.nodelist`)
#' The data frames typically includes columns such as:
#' \describe{
#'   \item{\code{file_path}}{ `character` The local file path or constructed GitHub URL.}
#'   \item{\code{line_number}}{`integer` The line number of the file.}
#'   \item{\code{content}}{`character` The content in a line of the file (the `corpus.nodelist` have the full content of the file ).}
#'   \item{\code{file_ext}}{`character` File extension of the file.}
#'   \item{\code{n_char}}{`integer` Number of characters - including spacing - in a line (or the file for the `corpus.nodelist` df).}
#'   \item{\code{n_char_wo_space}}{`integer` Number of characters - without spacing - in a line (or the file for the `corpus.nodelist` df)}
#'   \item{\code{n_word}}{`integer` Number of words in a line  (or the file for the `corpus.nodelist` df).}
#'   \item{\code{n_vowel}}{`integer` Number of voyel in a line (or the file for the `corpus.nodelist` df).}
#'   \item{\code{comments}}{`logical` `TRUE` if the entire line is commented. Set to `FALSE` for the `codes` df and `TRUE` for the `comments` df.}
#'   \item{\code{commented}}{`integer` (only in the `codes` df) Content of the inlines comments (NA if there is no inline comments).}
#'   \item{\code{n_total_lines}}{`integer` (only in the `corpus.nodelist` df) Number of clines of the files *without comments*.}
#'   \item{\code{matches}}{`character` (only in the `codes` df) A 1st matched text, extracted accordingly to a pattern.}
#'   \item{\code{commented}}{`character` (only in the `codes` df) A 1st matched text, extracted accordingly to a pattern.}
#' }
#'
#' @details
#' - If `folders` is provided (one or a list), the function scans the directories and retrieves file paths matching the specified languages.
#' - If `repos` is provided (one or a list), it constructs URLs to the raw content of files from the specified GitHub repositories.
#' - Both local paths and GitHub URLs can be combined in the final output.
#'
#' The returned list is tagged
#' with the class *corpus.list*, and contains the following attributes:
#' - `date_creation` : `Date` a Date indicating when the corpus list was created (as `Sys.Date()`).
#' - `have_citations_network` : a `logical` indicating if a network of internal dependancies was processed
#' (construct_corpus don't return a citations_network so it will be set to  `FALSE`)
#' - `languages_patterns` : a dataframe with the default pattern associated with the
#'  requested languages, a subset of the `languages` parameters or entire list
#' (e.g., file extension and a regex pattern for function definition).
#' @examples
#' # Example 1: Construct a corpus from local folders
#'  corpus <- construct_corpus(folders = "~", languages = c( "R"))
#'  # corpus <- construct_corpus(folders = "~", languages = c("Python","Javascript"))
#' \dontrun{
#' # Example 2: Construct a corpus from GitHub repositories (default is R)
#' cr2 <- construct_corpus(repos = c("tidyverse/stringr", "tidyverse/readr") )
#'
#' # Example 3: Combine local folders and GitHub repositories
#' cr3 <- construct_corpus("~", "R", c("tidyverse/stringr", "tidyverse/readr"))
#' }
#' @seealso \code{\link{readlines_in_df}}, \code{\link{get_github_raw_filespath}}, \code{\link{get_def_regex_by_language}}
#' @seealso
#'   \url{https://clement-lvd.github.io/codexplor/articles/vignette_construct_corpus.html}
#' @export
construct_corpus <- function(
 folders = NULL
, languages = "R"
 , repos = NULL
, .verbose = F
, ...
){

if(.verbose) cat("\n Constructing a corpus of programming files (", languages, ") : 1. Reading files\n")
#serialized over a "language" = specific treatment from a dictionnary
# 1) get files infos associated to a language
lang_dictionnary <- get_def_regex_by_language(languages)
#=> a dataframe by languages (e.g., file ext., pattern for defining a func')
# we'll return it as an attributes of the corpus_list

# we'll iterate into a sequens of languages
sequens_of_languages <- seq_along(lang_dictionnary)

if(length(sequens_of_languages) == 0) return(NA)

# lapply within each language and return a list of dataframes with custom classes
corpus <- lapply(sequens_of_languages, function(i) {

  lang_desired <- lang_dictionnary[[i]]

  create_corpus(folders = folders,  repos= repos
                , std_dictionnary_of_language = lang_desired
                , .verbose = .verbose, ...)
  #defined hereafter for a single language
})

if(length(corpus[[1]] ) == 1 ){
# low-level function return NA => high-level function will return a NA value
  if(is.na(corpus[[1]])) warning("The corpus.list is a NA value"); return(NA) #no corpus readed = ciao

  warning("Elements are missing => create_corpus have failed to build a complete corpus.list of dataframes")
  }

# rbind each list according to their position
combined <- do.call(mapply, c(FUN = function(...) rbind(...), corpus, SIMPLIFY = FALSE))
# stockpile by names (default) when structures are coherent (here we have a proper structure definition)

# add our global attributes of class corpus.list such as the language dictionnary used
combined <- .construct.corpus.list(combined
                                   , languages_patterns = lang_dictionnary
                                   , folders = folders
                                   , repos = repos)

#add class attributes and structure (optionnal doc' & methods heritated)

return(combined)
}

# create a corpus for ONE language
#### 1) create a corpus for a unique language ####
create_corpus <- function(folders = NULL
                          , std_dictionnary_of_language
                          , repos = NULL
                          , .verbose = F
                          , ...){

  lang_desired <- std_dictionnary_of_language

  #### 1) CONSTRUCT A CORPUS of files path and/or urls ####
  urls = NULL
  files_path = NULL

  pattern_to_exclude = lang_desired$pattern_to_exclude

  if(length(pattern_to_exclude) > 0) pattern_to_exclude <- paste0(pattern_to_exclude , collapse = "|")

  # 2) construct list of files :
  files_path <- get_list_of_files(folders = folders , repos = repos
                                  , file_ext =  lang_desired$file_ext #defined according to the langage
                                  , pattern_to_exclude_path = pattern_to_exclude)

  # 3) extract lines from files
  complete_files <- readlines_in_df(files_path = files_path, .verbose = .verbose, ... )
  # add real files ext (checking if an extension default pattern return a fake file)

  if(.verbose) cat("\n ==> Compute metrics")

  if(is.null(complete_files)) return(NA)

  complete_files$file_ext <- gsub(x = basename(complete_files$file_path), ".*\\." ,replacement = "")

  # 4.1.) ADD LINES TEXT-METRICS ON ENTIRE FILES
  complete_files <- cbind(complete_files, compute_nchar_metrics(complete_files[[3]]) )

  # compute a nodelist FROM LINES : sum of these metrics is supposed to be document-level metrics
  # this func' is hereafter : a grouped stat' (end of this .R file)
  # 4.2) Aggregate by group_colname = "file_path" + sum of all the col' with a suffix ("n_")
  nodelist <- compute_nodelist(df = complete_files, group_col = "file_path"
                               , colname_content_to_concatenate = "content")
  #we've made sum of metrics on each entire file, e.g., total nchar value

  # 5.) detect the full commented lines (never clean the pseudo comments on the same line)
  # add logical to our df
  complete_files$comments <-  grepl(x = complete_files$content, pattern =  paste0("^\\s*", lang_desired$commented_line_char))
# we will separate a 1st solid corpus then with these values :

  #### 2) Construct a corpus.list ####
  # we have some func' for define class and creation_date
  corpus <- list(
    codes = complete_files[!complete_files$comments,  ] # class is crafted hereafter
    , comments = .construct.corpus.lines(complete_files[complete_files$comments,  ])
    , nodelist = .construct.nodelist(nodelist)
  )
  # classe corpus.lines and corpus.nodelist
# except 'codes' that will be cleaned more and more herafter

# filter junklines - prevent crashes (from utils.R func')
  corpus$codes <- filter_if_na(corpus$codes, "content")

#### CLEAN THE codes df in corpus list if some multi-lines comments are possible
  if(!is.na(lang_desired$delim_pair_comments_block)) {

    if(.verbose) cat("\n===> Clean blocks of comments\n")

    codes_and_comments <-  separate_commented_lines(texts = corpus$codes$content, delim_pair = lang_desired$delim_pair, .verbose = .verbose)

    corpus$codes$content <- codes_and_comments$codelines
    # filter out blank lines again

    corpus$codes <-  filter_if_na(corpus$codes, "content")

  }

# this step, exclude comments within lines of texts are here
corpus$codes <- process_vector_on_df_by_group(df = corpus$codes
                                , group_col = "file_path"
                                , func = remove_text_after_char
                                , vector_col = "content"
                                , colname_uncommented = "uncommented"
                                , colname_commented = "commented")
# this func apply a func that require a vector on a df
# BY GROUPING the df and ensuring results are as ok as the subfunctionss
corpus$codes$content <- corpus$codes$uncommented
corpus$codes$uncommented <- NULL

#### extract only exposed content as a 'code' content ####
# unested codes {} such as function definition wille be removed !

  #### Finally extract only the exposed content ####
  if (!is.na(lang_desired$delim_pair_nested_codes)) {

    paired_delim <- lang_desired$delim_pair_nested_codes

corpus$codes <- process_vector_on_df_by_group(df = corpus$codes
                                  , group_col = "file_path"
                                  , func = extract_text_outside_separators
                                  , vector_col = "content"
, open_sep = names(paired_delim), close_sep = paired_delim)

colnames(corpus$codes)[colnames(corpus$codes) == "result"] = "exposed_unested_content"

  } else corpus$codes$exposed_unested_content <-  corpus$codes$content

  if(.verbose) cat("\n ====> Perform a 1st text-extraction")

 # 5-A} Get 1st matches (risk of duplicated lines here)
  corpus$codes <- srch_pattern_in_df( df =  corpus$codes
                                      , content_col_name = "exposed_unested_content"
                                      ,  pattern = lang_desired$fn_regex )

  # remove this col' if we don't need it
  corpus$codes$exposed_unested_content <- NULL

  #### 6) finally construct the corpus.lines object ####
  corpus$codes <- .construct.corpus.lines(corpus$codes)

  if(.verbose) cat("\nCorpus created")

  # return a basic list of df with all our col'
  return(corpus)

}

#### 2) construct a nodelist
# Create a nodelist by (a) summing metrics by group (col' are defined with a regex)
# AND aggregating the text with gather_lines_to_df !
compute_nodelist <- function(df, group_col
                             , metric_pattern = "n_"
                             , colname_content_to_concatenate = NULL) {

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
   max_values_df <- data.frame(group_col = names(max_values_df)
                               , n_codelines = unlist(max_values_df))
colnames(max_values_df)[[1]] <- group_col

   # merge with nodelist : n_codelines added (total lines number)
   nodelist <- merge(nodelist, max_values_df, by = group_col, all.x = TRUE)

     }


# 2.) optionnally add a proper "text" column (full content) with gather_df_lines (add a content col' by default)
if(!is.null(colname_content_to_concatenate)){

  files_content <- gather_df_lines(df, group_col, colname_content_to_concatenate)
  files_content <- unique(files_content)
  nodelist <- merge(all.x = T, nodelist, files_content, by = group_col )

}


  return(nodelist)
}
