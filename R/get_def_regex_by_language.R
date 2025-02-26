#' Retrieve function definition regex patterns by programming language(s)
#'
#' This function returns a df with regex patterns and file extensions associated with function definitions
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
functions_def_by_language_regex_pattern <- list(
  R = list(
    fn_regex = "(^| \\.|\\b)([A-Za-z0-9_\\.]+)(?=\\s*(?:<-)\\s*function)",
    file_extension = ".R"
    , commented_line_char = "\\s?#"
    , pattern_to_exlude = "\\.Rcheck|test-|Vignette"
  ),
  Python = list(
    fn_regex = "^\\s*def\\s+([\\w_]+)\\s*\\(",
    file_extension = ".py"
    , commented_line_char = "#"
    , pattern_to_exlude = NA),
  JavaScript = list(
    fn_regex = "^\\s*function\\s+([\\w_]+)\\s*\\(",
    file_extension = ".js"
    , commented_line_char = "//|/*"

    , pattern_to_exlude = NA
  ),
  Java = list(
    fn_regex = "^\\s*(public|private|protected)?\\s*\\w+\\s+([\\w_]+)\\s*\\(",
    file_extension = ".java"
    , commented_line_char = "//|/*"

    , pattern_to_exlude = NA
  ),
  C = list(
    fn_regex = "^\\s*\\w+\\s+([\\w_]+)\\s*\\(",
    file_extension = ".c"
    , commented_line_char = "//|/*"

    , pattern_to_exlude = NA
  ),
  Cpp = list(
    fn_regex = "^\\s*\\w+(<.*>)?\\s+([\\w_]+)\\s*\\(",
    file_extension = ".cpp"
    , commented_line_char = "//|/*"

    , pattern_to_exlude = NA
  ),
  Go = list(
    fn_regex = "^\\s*func\\s+([\\w_]+)\\s*\\(",
    file_extension = ".go"
    , commented_line_char = "//|/*"
    , pattern_to_exlude = NA
  )
)

  #### 2) return this list into a dataframe ####
  languages <- tolower( c(...))  # Récupère tous les arguments passés

  available_languages <- tolower(names(functions_def_by_language_regex_pattern))

non_available <- languages[!languages %in% available_languages]

if(length(non_available) > 1) {
    stop("Unsupported language(s) (" , paste0(collapse = ", ", non_available), ") !\n Available languages => ",
         paste(names(functions_def_by_language_regex_pattern), collapse = ", "))
  }

returned <- functions_def_by_language_regex_pattern[available_languages %in% languages]

lang_df <- do.call(rbind, lapply(names(returned), function(lang) {
  data.frame(language = lang
            , fn_regex = returned[[lang]]$fn_regex
           , file_ext = returned[[lang]]$file_extension
            , commented_line_char =  returned[[lang]]$commented_line_char
             ,pattern_to_exclude = returned[[lang]]$pattern_to_exlude
             ,stringsAsFactors = FALSE)
}))
# RETURN A LIST IF NO ARG PASSED !
if(is.null(lang_df)){return(functions_def_by_language_regex_pattern)}

  lang_df$local_file_ext <- paste0(lang_df$file_ext, "$" )

return(lang_df )

}
