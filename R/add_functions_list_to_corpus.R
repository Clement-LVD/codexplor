#' Compute a function list from the codes df of a corpus.list object
#'
#' @param corpus A `corpus.list` object with at least the 'codes' dataframe
#' @param lang_dictionnary `list` A language patterns dictionnary specific to one language
#' @return a `list` of class `corpus.list`
add_functions_list_to_corpus <- function(corpus
   , lang_dictionnary
  ){

  lang_desired <- lang_dictionnary

  #unify code into a single bloc
  fn_nodelist <- compute_nodelist(corpus$codes, group_col = "file_path"
                                  , colname_content_to_concatenate = "content")

  # suppress the comments
  fn_nodelist$censored_content <- censor_quoted_text(text = fn_nodelist$content, char_for_replacing_each_char = "_")

  paired_delim <- lang_desired$delim_pair_nested_codes

  # and extract unested text
  fn_nodelist$exposed_content <- extract_text_outside_separators(texts = fn_nodelist$censored_content
                                                                 , open_sep = names(paired_delim)
                                                                 , close_sep = paired_delim
                                                                 ,escape_char = lang_desired$escaping_char)

  # 5-A} Get 1st matches
  fn_nodelist <- srch_pattern_in_df( df =  fn_nodelist
                                     , content_col_name = "exposed_content"
                                     ,  pattern = lang_desired$fn_regex
                                     , duplicated_lines_are_normal = T
  )
  # files without func => matches = NA / Creation order within the file is the order(!)
  # add n fonctions defined within the file to the 'files' df (nodelist of documents)

  n_functions_defined <- by(fn_nodelist$matches, INDICES = fn_nodelist$file_path, FUN = function(x) sum(!is.na(x)))

  n_functions_defined <- data.frame(func = n_functions_defined, file_path = names(n_functions_defined))

   # completing the files nodelist
  old_class <- class(corpus$files)
  corpus$files <- merge(corpus$files, n_functions_defined, by ="file_path")
class( corpus$files ) <- old_class

  # corpus of func'
  corpus$functions <- fn_nodelist[!is.na(fn_nodelist$matches), c("matches", "file_path", "content", "exposed_content")]

  colnames(corpus$functions)[1] <- "name"

corpus$functions <- .construct.nodelist(corpus$functions)

return(corpus)
}
