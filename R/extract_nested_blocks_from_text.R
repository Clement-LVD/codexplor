#' Extract Nested Blocks and Assign Group IDs and Deep Levels
#'
#' Assuming the user have passed a character vector, this function extracts nested blocks
#'  of text (e.g., Within (Parenth.)), delimited by a specified opening and a closing characters.
#'  It returns a data frame with :
#'  - the index of the input string ;
#'  - the extracted block (including delimiters) ;
#'  - a group_id common to all blocks nested within the same outer block;
#'  - a deep-level numeric indicator, within the longest block
#' @param text `character` vector containing one or more text(s)
#' @param delims `list` of characters symbolizing opening and closing characters, default = `c("(" = ")", "[" = "]", "{" = "}")`.
#' @param return_text_col `logical`, default = `FALSE` Return a `text` column if set to TRUE
#' @return A data frame with 4 or 5 columns :
#' \describe{
#'   \item{\code{instruction_id}}{Numeric (row_number)}
#'   \item{\code{block}}{Character (text extracted, surrounded by delimiters)}
#'   \item{\code{level}}{Numeric (level of imbrication of a block surrounded by the delimiters, from `1` to `Inf`)}
#'   \item{\code{group_id.}}{Numeric, symbolize the imbrication within a same block, i.e. surrounded by global delimiters)}
#'   \item{\code{text}}{Original characters vector passed by the user (optionnally returned)}
#' }
#' @export
#'
#' @examples
#' text <- "Voici un (exemple (avec un texte (imbriqué)) et [un autre exemple]). MAIS ENSUITE (ceci)"
#' extract_nested_blocks_from_text(text)

extract_nested_blocks_from_text <- function(text, delims = c("(" = ")", "[" = "]", "{" = "}"), return_text_col = TRUE) {

  #  fix_escaping is defined elsewhere
  #e.g., fix_escaping <- function(x) gsub("([\\[\\](){}^$.|?*+\\-])", "\\\\\\1", x)

  # Extract position of openning delimiters and corresponding closing char
  get_positions <- function(ouvrant, fermant) {
    pos_open  <- unlist(gregexpr(codexplor::fix_escaping(ouvrant), text, perl = TRUE))
    pos_close <- unlist(gregexpr(codexplor::fix_escaping(fermant), text, perl = TRUE))
    data.frame(
      pos    = c(pos_open, pos_close),
      type   = c(rep(1, length(pos_open)), rep(-1, length(pos_close))),
      opener = rep(ouvrant, length(pos_open) + length(pos_close))
    )
  }
  #this func' create a df with the position of a char, thetype ["open" (1) and "close" (-1)]
  # and "opener" is a constant for catch char. and humain reading : "(", "[", "{"

  # Récupérer les positions pour tous les délimiteurs
  positions_df <- do.call(rbind, mapply(get_positions, names(delims), delims, SIMPLIFY = FALSE))
  positions_df <- positions_df[order(positions_df$pos), ]
  #we have a df of all the position of these respective char

  # We made a R-for-loop hereafter
  stack <- list()
  results <- list()
  group_id = 1

  # Apply each row (vector of position)
  apply(positions_df, 1, function(row) {
    # Convertir les valeurs pour être sûrs de leur type
    pos_val   <- as.numeric(row["pos"])
    type_val  <- as.numeric(row["type"])
    opener_val<- row["opener"]

    if (type_val == 1) {
      # À chaque ouverture ( on empile un  élément avec un group_id unique
      stack <<- c(list(list(pos = pos_val, opener = opener_val

                            , level = length(stack) + 1

                            ,group_id = group_id )), stack)
    } else {
      # Pour une fermeture, on vérifie que le haut de la pile correspond au même délimiteur
      if (length(stack) > 0 && stack[[1]]$opener == opener_val) {
        start   <- stack[[1]]$pos
        end     <- pos_val
        level   <- stack[[1]]$level
        stack   <<- stack[-1]  # dépile


        # Le délimiteur fermant attendu est celui correspondant à l’ouverture
        closing_delim <- delims[[opener_val]]
        # Extraire le bloc (en incluant le délimiteur fermant)
        block <- substr(text, start, end + nchar(closing_delim) - 1)
        # Conserver le bloc si non vide
        if (nchar(block) > 0) {
          # here we return a block of code =>
          current_bloc <- data.frame(block = block, level = level, group_id = group_id
                                     , stringsAsFactors = FALSE)

          results <<- append(results, list(current_bloc))
          # update group_id counter
          if(current_bloc$level == 1) group_id <<- group_id +1

        }
      }
    }
  })

  # Conversion de la liste de résultats en data.frame (si au moins un bloc a été extrait)
  if (length(results) == 0) return(NULL)

  # results <- lapply(results, FUN = function(df) df[order(decreasing = T, df$level), ])

  df <- do.call(rbind, results)

  df <- df[nchar(df$block) > 0, ] #filter fake result

  df <- df[order(df$group_id, df$level), ]

 if(return_text_col) df$text <- text #add text col'

  return(df)
}


