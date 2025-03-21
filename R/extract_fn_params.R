#' Extract parameters for each functions of the functions df of a corpus.list
#' @param corpus A `corpus.list` object with a `functions` `data.frame`
#' @param lang_dictionnary A standard language patterns dictionnary for a language (i.e. params fn_regex_params_after_names is needed)
#' @param .verbose `logical`, default = `FALSE`. If set to `TRUE`, show a progress bar
#' @importFrom utils txtProgressBar setTxtProgressBar
extract_fn_params <- function(corpus, lang_dictionnary, .verbose = F){

 regex_after_name <- lang_dictionnary$fn_regex_params_after_names

 if (.verbose) {pb <- utils::txtProgressBar(min = 0, max = 100, style = 3) }

funcs <- corpus$functions$name
n_funcs <- length(funcs)
  #### lapply within names : extract fn parameters ####
 # here we iterate within lines of the functions df
col_to_add <- lapply(seq_along(funcs) , FUN = function(i){

   if (.verbose) utils::setTxtProgressBar(pb, i /n_funcs *100 )

  fn <- corpus$functions[i,]

 regexx <- paste0(fn$name, regex_after_name)
# append a regex that follow the name -> to begining of params
 # so just '(' for python but '<-|= function(' for r

 match_positions <- gregexpr(regexx, fn$content, perl = TRUE)[[1]]
  if (match_positions[1] == -1) return(NA)  #nothing = NA

  start_pos <- match_positions[1]
 match_length <- attr(match_positions, "match.length")[1]
 paren_open_pos <- start_pos + match_length-1  # Position de `(` inclue (-1)

  text_after_open <- substring(fn$content, paren_open_pos)

 # 2. get all unescaped parenthesis within this sub-text
 #    (?<!\\\\) is "not preceided by a backslash"
 matches <- gregexpr("(?<!\\\\)[()]", text_after_open, perl = TRUE)[[1]]
 if (matches[1] == -1) return(NA)  #no match

 # 3. get founded char.
 parens <- regmatches(text_after_open, list(matches))[[1]]
 # numeric vector : +1 for "(" ; -1 for ")"
 deltas <- ifelse(parens == "(", 1, -1)

 # 4. compute  cum. sum and find 1st indice with 0
 cs <- cumsum(deltas)
 idx_zero <- which(cs == 0)[1]
 if (is.na(idx_zero)) return(NA)

 # this is the last parenthesis position :
 closing_pos <- paren_open_pos + matches[idx_zero] - 1

 # 5. extract text between these opening_pos and closing_pos (exluding)
 extracted_text <- substring(fn$content, paren_open_pos + 1, closing_pos - 1)

# this text is the parameters of the func !
return(data.frame(params = trimws(extracted_text), end_pos = closing_pos, max_pos = nchar(fn$content)) )

})

if (.verbose) close(pb)

col_to_add <- do.call(rbind, col_to_add)

junks_params <- censor_quoted_text(col_to_add$params)
# add metrics to the functions df
# match all content separated by a , or end of line
# matches <- gregexpr("(?<!['\"]).+?(?=,|$)(?![^']*['\"])", col_to_add$params, perl = TRUE)

  # Extract matched elements
  # extracted_args <- regmatches( col_to_add$params, matches)

split_params <- function(txt) {
  parts <- strsplit(txt, ",(?![^()]*\\))", perl = TRUE)[[1]]
  trimws(parts)
}

# Appliquer cette fonction à chaque élément du vecteur
result <- lapply(col_to_add$params, split_params)


#   add a n_params metrics :
  col_to_add$n_params <- sapply(result, length)

return(col_to_add)

}


