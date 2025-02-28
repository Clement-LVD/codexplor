#' Retrieve function definition regex patterns by programming language(s)
#'
#' This function returns a `df` with informations for each language (each row),
#'  e.g., file extensions associated and regex pattern for matching commented lines and functions definitions)
#' for one or more specified programming languages.
#'
#' @param ... `character` One or more programming language names (character strings).
#'
#' @return A dataframe where each row corresponds to a language and contains:
#' \describe{
#'   \item{\code{language}}{`character` The name of the language on a row (e.g., 'R').}
#'   \item{\code{fn_regex}}{`character` The line number within the file.}
#'   \item{\code{file_ext}}{`character` A line from the file}
#'   \item{\code{local_file_ext}}{`character` A line from the file}
#' }
#' @details
#' This function supports multiple languages in a single call.
#' Language names are case-insensitive.
#' @examples
#' # fn_def <- get_def_regex_by_language("Python", "R" , "Go", "C", "JavaScript")
#'
#' @export
get_def_regex_by_language <- function(...) {
#### 1) define function regex => core behavior is catching func' names ####
def_by_language_regex_pattern <- list(
  R = list(
    fn_regex = "(^| \\.|\\b)([A-Za-z0-9_\\.]+)(?=\\s*(?:<-)\\s*function)",
    file_extension = ".R"
    , commented_line_char = "\\s?#"
    , pattern_to_exclude = "\\.Rcheck|test-|Vignette"
  ),
  Python = list(
    fn_regex = "^\\s*def\\s+([\\w_]+)\\s*\\(",
    file_extension = ".py"
    , commented_line_char = "#"
    , pattern_to_exclude = NA),
  JavaScript = list(
    fn_regex = "^\\s*function\\s+([\\w_]+)\\s*\\(",
    file_extension = ".js"
    , commented_line_char = "//|/*"

    , pattern_to_exclude = NA
  ),
  Java = list(
    fn_regex = "^\\s*(public|private|protected)?\\s*\\w+\\s+([\\w_]+)\\s*\\(",
    file_extension = ".java"
    , commented_line_char = "//|/*"

    , pattern_to_exclude = NA
  ),
  C = list(
    fn_regex = "^\\s*\\w+\\s+([\\w_]+)\\s*\\(",
    file_extension = ".c"
    , commented_line_char = "//|/*"

    , pattern_to_exclude = NA
  ),
  Cpp = list(
    fn_regex = "^\\s*\\w+(<.*>)?\\s+([\\w_]+)\\s*\\(",
    file_extension = ".cpp"
    , commented_line_char = "//|/*"

    , pattern_to_exclude = NA
  ),
  Go = list(
    fn_regex = "^\\s*func\\s+([\\w_]+)\\s*\\(",
    file_extension = ".go"
    , commented_line_char = "//|/*"
    , pattern_to_exclude = NA
  )
)



  #### 1) return this list into a dataframe ####
lang_df <- do.call(rbind, lapply(seq_along(def_by_language_regex_pattern), function(i) {
  # Convertir chaque sous-liste en dataframe avec les noms comme colonnes
 lg_row <- def_by_language_regex_pattern[i]
  data.frame(language = names(lg_row)
                           , lg_row[[1]]
                           , stringsAsFactors = FALSE
                            )  }))

lang_df$local_file_ext <- paste0(lang_df$file_ext, "$" )

#### 2) filter accordingly to the desired language(s) ####
  languages <- tolower( c(...))  # Récupère tous les arguments passés

 lowered_lang_df_languages <- tolower(lang_df$language)

non_available <- languages[!languages %in% lowered_lang_df_languages]

if(length(non_available) > 0) {
    warning("Unsupported language(s) (" , paste0(collapse = ", ", non_available), ") !\n Available languages => ",
         paste(lang_df$language, collapse = ", "))
  }
# return what match language strictly
returned <- lang_df[lowered_lang_df_languages %in% languages,]

# RETURN A COMPLETE LIST IF NO ARG PASSED !
if(is.null(returned)){return(lang_df)}


return(returned )

}
