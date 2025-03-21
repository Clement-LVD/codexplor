#' Extract parameters and code for each functions of the functions df of a corpus.list
#' @param corpus A `corpus.list` object with a `functions` `data.frame`
#' @param lang_dictionnary A standard language patterns dictionnary for a language (i.e. params fn_regex_params_after_names is needed)
#' @param .verbose `logical`, default = `FALSE`. If set to `TRUE`, show a progress bar
#' @importFrom utils txtProgressBar setTxtProgressBar
extract_indented_fn_code <- function(corpus, lang_dictionnary, .verbose = F){

 regex_after_name <- lang_dictionnary$fn_regex_params_after_names

 if (.verbose) {pb <- utils::txtProgressBar(min = 0, max = 100, style = 3) }

funcs <- corpus$functions$name
n_funcs <- length(funcs)
  #### lapply within names : extract fn parameters ####
 # here we iterate within lines of the functions df (!!)
col_to_add <- sapply(seq_along(funcs) , FUN = function(i){

   if (.verbose) utils::setTxtProgressBar(pb, i /n_funcs *100 )

  fn <- corpus$functions[i,]

  nextcode <- substring( fn$content,  fn$end_pos+2, last = fn$max_pos )
  nextcode <- gsub(pattern = "^\\\\n",replacement = "",x =  nextcode)

  lines <- unlist(strsplit(nextcode, "\\\\n"))
# first line without space in the begining
  endline = which(!grepl("^\\s", lines))
  if(length(endline) == 0) endline = 2 # 'cause we want the previous line

  result <- paste(lines[1:endline[1] - 1], collapse = "\n")

 return(result)
}
)

if (.verbose) close(pb)


return(col_to_add)

}


