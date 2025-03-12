#' Extract parameters and code for each functions of the functions df of a corpus.list
#' @param corpus A `corpus.list` object with a `functions` `data.frame`
#' @param lang_dictionnary A standard language patterns dictionnary for a language (i.e. params fn_regex_params_after_names is needed)
#' @param .verbose `logical`, default = `FALSE`. If set to `TRUE`, show a progress bar
#' @importFrom utils txtProgressBar setTxtProgressBar
extract_fn_content <- function(corpus, lang_dictionnary, .verbose = F){

 regex_after_name <- lang_dictionnary$fn_regex_params_after_names

 # utility function
 extract_first_delimited <- function(text, opening_char = "(", closing_char = ")") {
   # 1. Trouver la position du premier caractère d'ouverture
   open_pos <- regexpr(opening_char, text, fixed = TRUE)[1]
   if (open_pos == -1) return(NA)

   # 2. Extraire le sous-texte à partir de cette position
   sub_text <- substring(text, open_pos)

   # 3. Trouver toutes les positions (dans sub_text) du caractère d'ouverture et de fermeture
   pos_open <- gregexpr(opening_char, sub_text, fixed = TRUE)[[1]]
   pos_close <- gregexpr(closing_char, sub_text, fixed = TRUE)[[1]]

   # Filtrer les valeurs -1 si aucune occurrence n'est trouvée
   pos_open <- pos_open[pos_open != -1]
   pos_close <- pos_close[pos_close != -1]

   # 4. Combiner et trier les positions avec un indicateur : +1 pour ouverture, -1 pour fermeture
   positions <- c(pos_open, pos_close)
   types <- c(rep(1, length(pos_open)), rep(-1, length(pos_close)))
   ord <- order(positions)
   positions <- positions[ord]
   types <- types[ord]

   # 5. Calculer la somme cumulative et repérer le moment où elle revient à 0
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
  #### lapply within names : extract fn parameters ####
 # here we iterate within lines of the functions df (!!)
col_to_add <- lapply(seq_along(funcs) , FUN = function(i){

   if (.verbose) utils::setTxtProgressBar(pb, i /n_funcs *100 )

  fn <- corpus$functions[i,]

 regexx<- paste0(fn$name, regex_after_name)

 match_positions <- gregexpr(regexx, fn$content, perl = TRUE)[[1]]
  if (match_positions[1] == -1) return(NA)  #nothing = NA

  start_pos <- match_positions[1]
 match_length <- attr(match_positions, "match.length")[1]
 paren_open_pos <- start_pos + match_length-1  # Position de `(` inclue (-1)

  text_after_open <- substring(fn$content, paren_open_pos)

 # 2. Repérer toutes les parenthèses non échappées dans ce sous-texte
 #    (?<!\\\\) signifie "pas précédé d'un backslash"
 matches <- gregexpr("(?<!\\\\)[()]", text_after_open, perl = TRUE)[[1]]
 if (matches[1] == -1) return(NA)  # aucun match

 # 3. Récupérer les caractères trouvés
 parens <- regmatches(text_after_open, list(matches))[[1]]
 # Créer un vecteur numérique : +1 pour "(" et -1 pour ")"
 deltas <- ifelse(parens == "(", 1, -1)

 # 4. Calculer la somme cumulative et trouver le premier indice où elle revient à 0
 cs <- cumsum(deltas)
 idx_zero <- which(cs == 0)[1]
 if (is.na(idx_zero)) return(NA)

 # La position dans fn_content de la parenthèse fermante :
 closing_pos <- paren_open_pos + matches[idx_zero] - 1

 # 5. Extraire le contenu entre la parenthèse ouvrante et la fermante (exclues)
 extracted_text <- substring(fn$content, paren_open_pos + 1, closing_pos - 1)



 # the closing pos is very precious => we have to pursue !
nextcode <- substring( fn$content,  closing_pos)

code_of_the_func <- extract_first_delimited(text = nextcode, opening_char = "{", closing_char = "}")

results <- data.frame(parameters = trimws(extracted_text)
                    ,  code = trimws(code_of_the_func)
                      )
 return(results)
}
)

if (.verbose) close(pb)

col_to_add <- do.call(rbind, col_to_add)
# add to the functions df

corpus$functions <- .construct.nodelist(cbind(corpus$functions, col_to_add))

return(corpus)

}


