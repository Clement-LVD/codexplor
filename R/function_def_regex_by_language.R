#' Retrieve function definition regex patterns by programming language
#'
#' This function returns a df with regex patterns and file extensions associated with function definitions
#' for one or more specified programming languages.
#'
#' @param ... One or more programming language names (character strings).
#'
#' @return A dataframe where each row corresponds to a language and contains:
#'   -  `language`: The name (e.g., 'R')
#'   - `fn_regex`: The regex pattern used to detect function definitions in this language.
#'   - `file_ext`: The typical file extension for the language.
#'   - `local_file_ext`: The typical file extension for the language + a $ (regex for end of line).
#'
#' @details
#' This function supports multiple programming languages in a single call.
#' Language names are case-insensitive.
#'
#' @examples
#' fn_def <-function_def_regex_by_language("Python", "R")
#' fn_def <- function_def_regex_by_language("Go", "C", "JavaScript")
#'
#' @export
function_def_regex_by_language <- function(...) {
#### 1) define function regex => core behavior is catching func' names ####
functions_def_by_language_regex_pattern <- list(
  R = list(
    fn_regex = "(^| \\.|\\b)([A-Za-z0-9_\\.]+)(?=\\s*(?:<-)\\s*function)",
    file_extension = ".R"
    , pattern_to_exlude = "\\.Rcheck|test-"
  ),
  Python = list(
    fn_regex = "^\\s*def\\s+([\\w_]+)\\s*\\(",
    file_extension = ".py"
    , pattern_to_exlude = ""),
  JavaScript = list(
    fn_regex = "^\\s*function\\s+([\\w_]+)\\s*\\(",
    file_extension = ".js"
    , pattern_to_exlude = ""
  ),
  Java = list(
    fn_regex = "^\\s*(public|private|protected)?\\s*\\w+\\s+([\\w_]+)\\s*\\(",
    file_extension = ".java"
    , pattern_to_exlude = ""
  ),
  C = list(
    fn_regex = "^\\s*\\w+\\s+([\\w_]+)\\s*\\(",
    file_extension = ".c"
    , pattern_to_exlude = ""
  ),
  Cpp = list(
    fn_regex = "^\\s*\\w+(<.*>)?\\s+([\\w_]+)\\s*\\(",
    file_extension = ".cpp"
    , pattern_to_exlude = ""
  ),
  Go = list(
    fn_regex = "^\\s*func\\s+([\\w_]+)\\s*\\(",
    file_extension = ".go"
    , pattern_to_exlude = ""
  )
)

  #### 2) return this list into a dataframe ####
  languages <- tolower( c(...))  # Récupère tous les arguments passés

  available_languages <- tolower(names(functions_def_by_language_regex_pattern))

   if (!all(languages %in% available_languages)) {
    stop("Unsupported language(s) ! Available languages => ",
         paste(names(functions_def_by_language_regex_pattern), collapse = ", "))
  }

returned <- functions_def_by_language_regex_pattern[available_languages %in% languages]

lang_df <- do.call(rbind, lapply(names(returned), function(lang) {
  data.frame(language = lang,
             fn_regex = returned[[lang]]$fn_regex,
             file_ext = returned[[lang]]$file_extension,
             pattern_to_exclude = returned[[lang]]$pattern_to_exlude
             ,stringsAsFactors = FALSE)
}))
# RETURN A LIST IF NO ARG PASSED !
if(is.null(lang_df)){return(functions_def_by_language_regex_pattern)}

  lang_df$local_file_ext <- paste0(lang_df$file_ext, "$" )

return(lang_df )

}
