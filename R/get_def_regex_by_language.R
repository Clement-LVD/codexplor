#' Retrieve function definition regex patterns by programming language(s)
#'
#' This function returns a `df` with informations for each language (each row),
#'  e.g., file extensions associated and regex pattern for matching commented lines and functions definitions)
#' for one or more specified programming languages.
#' @param languages `character`, default = `"R"` A programming language to match (character strings).
#' @param ... `character` One or more programming language names (character strings).
#'
#' @return A `list` where each entry corresponds to a language and contains:
#' \describe{
#'   \item{\code{language}}{`character` The name of the language on a row, e.g., 'R'.}
#'   \item{\code{fn_regex}}{`character` A regex dedicated to catch the function names, as soon as a function is defined within a file.}
#'   \item{\code{file_extension }}{`character` The typical programming file extension, e.g., ".R" for the R language.}
#'   \item{\code{commented_line_char}}{`character` The pattern symbolizing a commented line, i.e. content is commented after that pattern.}
#'   \item{\code{delim_pair_comments_block}}{`character` list indicating the - open and close - characters that symbolizes a multi-lines comment, in addition to the `commented_line_char` one-liner syntax.}
#'   \item{\code{delim_pair_nested_codes}}{`character` list indicating the - open and close - characters that symbolizes a multi-lines block of code.}
#'   \item{\code{pattern_to_exclude }}{`character` `The pattern of typical programming files to exclude from the analyses, e.g., "\\.Rcheck|test-|vignettes" for the R language.}
#'   \item{\code{local_file_ext}}{`character` The typical programming file extension turned into a regex, by pasting `"$"` to the end of `file_extension` value.}
#' }
#' @details
#' This function supports multiple languages in a single call.
#' Language names are case-insensitive.
#' @examples
#' fn_def <- get_def_regex_by_language("Python", "R" , "JavaScript")
#' names(fn_def) ; str(fn_def[[1]])
#' @export
get_def_regex_by_language <- function(languages = NULL, ...) {

#### 0) Thesaurus of languages ####
list_language_patterns <- language_pattern

if(is.null(languages)) return(list_language_patterns)

#### 1) filter accordingly to the desired language(s) ####
  languages <- tolower( c(languages, ...))  # Récupère tous les arguments passés

 lowered_lang_names <- tolower(names(list_language_patterns))

non_available <- languages[!languages %in% lowered_lang_names]

if(length(non_available) > 0) {
    warning("Unsupported language(s) (" , paste0(collapse = ", ", non_available), ") !\n Available languages => ",
         paste(names(list_language_patterns), collapse = ", "))
}

# return what match language strictly
returned <- list_language_patterns[lowered_lang_names %in% languages]

# RETURN A COMPLETE LIST IF NO ARG PASSED !
if(is.null(returned)){return(list_language_patterns)}

return(returned )

}
