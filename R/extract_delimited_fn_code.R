#' Extract code for each functions of the functions df of a corpus.list within bracket
#' Here we need a corpus$functions object with  columns for begining and end position (hardcoded colnames)
#' @param corpus A `corpus.list` object with a `functions` `data.frame`
#' @param lang_dictionnary A standard language patterns dictionnary for a language (i.e. params fn_regex_params_after_names is needed)
#' @param .verbose `logical`, default = `FALSE`. If set to `TRUE`, show a progress bar
#' @importFrom utils txtProgressBar setTxtProgressBar
extract_delimited_fn_code <- function(corpus, lang_dictionnary, .verbose = F){

 # utility function => r code is within '{' and '}'
 extract_first_delimited <- function(text, opening_char = "\\{", closing_char = "\\}") {
   # 1. Find the 1st opening char. position
   open_pos <- regexpr(pattern = opening_char, text)[1]
   if (open_pos == -1) return(NA)

   # 2. extract subtext to this opening pos
   sub_text <- substring(text, open_pos)

   # 3. find all positions within sub_text for a char of open or close
   pos_open <- gregexpr(opening_char, sub_text)[[1]]
   pos_close <- gregexpr(closing_char, sub_text)[[1]]

   # filter if no match is found (-1)
   pos_open <- pos_open[pos_open != -1]
   pos_close <- pos_close[pos_close != -1]

   # 4.combine and filter positions : +1 is opening, -1 is closing
   positions <- c(pos_open, pos_close)
   types <- c(rep(1, length(pos_open)), rep(-1, length(pos_close)))
   ord <- order(positions)
   positions <- positions[ord]
   types <- types[ord]

   # 5.compute cum sum and find where FIRST time to back to 0
   cs <- cumsum(types)
   idx <- which(cs == 0)[1]
   if (is.na(idx)) return(NA)

   # 6. La position du matching closing_char dans sub_text
   closing_pos <- positions[idx]

   # 7. Extraire le contenu entre l'ouverture et la fermeture (sans les séparateurs)
   extracted <- substring(sub_text, 2, closing_pos - 1)
   return(trimws(extracted))
 }

 if (.verbose) {pb <- utils::txtProgressBar(min = 0, max = 100, style = 3) }

funcs <- corpus$functions$name
n_funcs <- length(funcs)

  #### lapply within funcs names : extract fn parameters ####
 # here we iterate within lines of the functions df (!!)
col_to_add <- sapply(seq_along(funcs) , FUN = function(i){

   if (.verbose) utils::setTxtProgressBar(pb, i /n_funcs *100 )

  fn <- corpus$functions[i,]

# the closing pos is very precious since after that there is a code (!)
  # => we have to pursue from a previous func !
nextcode <- substring( fn$content,  fn$end_pos, last = fn$max_pos )
# at the best we have all the code, at the worst the initial text is more and more precise
# (and finally it's the same to the best scenario for the last function of the file)

# the only R code that we'll found is between {in all case : no oneliner func' admitted}

code_of_the_func <- extract_first_delimited(text = nextcode) # { fn code is typically between}

 return(trimws(code_of_the_func) )
}
)

if (.verbose) close(pb)

return(col_to_add)

}


