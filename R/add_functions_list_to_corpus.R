#' Compute a function list from the codes df of a corpus.list object
#'
#' @param corpus A `corpus.list` object with at least the 'codes' dataframe
#' @param lang_dictionnary `list` A language patterns dictionnary specific to one language
#' @param .verbose `logical`, default = `FALSE`. If set to `TRUE`, show a progress bar when extracting content
#' @param sep `character`, default = `' '` A character chain of separator, in order to concatenate lines
#' @param fn_to_exclude `character` A vector of values that will not be returned such as a match.
#' @return a `list` of class `corpus.list` with exposed functions names and file path
add_functions_list_to_corpus <- function(corpus
   , lang_dictionnary, .verbose = F, sep = " "
   , fn_to_exclude = NULL
  ){

  lang_desired <- lang_dictionnary

  #unify code into a single bloc
  fn_nodelist <- compute_nodelist(corpus$codes, group_col = "file_path"
                                  , colname_content_to_concatenate = "content",sep = sep )

  # suppress the texts
  fn_nodelist$censored_content <- censor_quoted_text(text = fn_nodelist$content, char_for_replacing_each_char = "_")

  # and extract unested text if necessary (R files)
  if( lang_desired$delimited_fn_codes ){
  fn_nodelist$exposed_content <- extract_text_outside_separators(texts = fn_nodelist$censored_content
                                                                 , open_sep = "{"
                                                                 , close_sep = "}"
                                                                 ,escape_char = lang_desired$escaping_char)
  } else fn_nodelist$exposed_content  <-  fn_nodelist$censored_content

  # 5-A} Get 1st matches
  fn_nodelist <- srch_pattern_in_df( df =  fn_nodelist
                                     , content_col_name = "exposed_content"
                                     ,  pattern = lang_desired$fn_regex
                                     , duplicated_lines_are_normal = T
                                     , match_to_exclude = fn_to_exclude
  )
  # files without func => matches = NA / Creation order within the file is the order(!)
  # add n fonctions defined within the file to the 'files' df (nodelist of documents)

  n_functions_defined <- by(fn_nodelist$matches, INDICES = fn_nodelist$file_path, FUN = function(x) sum(!is.na(x)))
# here the colname in the returned df : n_func
  n_functions_defined <- data.frame(n_func = n_functions_defined, file_path = names(n_functions_defined))
  n_functions_defined <- n_functions_defined[!duplicated(n_functions_defined),]
   # completing the files nodelist
  corpus$files <- .construct.nodelist(merge(corpus$files, n_functions_defined, by ="file_path"))

  # creation of a corpus of func'
  corpus$functions <- fn_nodelist[!is.na(fn_nodelist$matches), c("matches", "file_path", "content", "exposed_content")]

  colnames(corpus$functions)[1] <- "name"
  corpus$functions <- .construct.nodelist(corpus$functions[!duplicated(corpus$functions), ]  )

return(corpus)
}
