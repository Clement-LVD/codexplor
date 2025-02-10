#' Extract Text Before a Regex Pattern
#'
#' This function extracts all text - by default - before a specified regex pattern, from a vector of strings.
#' The extracted text is returned, with optional modifications to remove the matched pattern
#' or filter non-matching results.
#'
#' @param txt_vector `character`
#' A character vector in which the pattern will be searched and the text before the pattern will be extracted.
#'
#' @param pattern_regex_to_search `character`
#' The regex pattern to search for. The matched pattern will be removed by default, unless `clean_match_from_pattern` is set to `FALSE`.
#'
#' @param ignore_case `logical`, default = `TRUE`
#' If `TRUE`, the pattern search will ignore case. If `FALSE`, the search will be case-sensitive.
#'
#' @param clean_match_from_pattern `logical`, default = `TRUE`
#' If `TRUE`, the matched pattern is removed from the returned results. If `FALSE`, the pattern will remain in the result.
#'
#' @param filter_only_match `logical`, default = `FALSE`
#' If `TRUE`, only the non-NA matches are returned. If `FALSE`, the returned vector will have the same length as the input.
#'
#' @param trimws `logical`, default = `TRUE`
#' If `TRUE`, remove leading and tail unwanted white spaces with trimws
#'
#' @param prefix_to_add_to_pattern `character`, default = `".*"`
#' A regex prefix to add before the main pattern. This text will be included in the result, but not removed, by default.
#'
#' @return A `character` vector of extracted text before the specified pattern. If `filter_only_match` is `TRUE`, only the matching results are returned.
#'
#' @examples
#' txt_vector <- c("my_func_one <- function\\(", "my_func_2 <- function\\(")
#' object_names <- codexplor::extract_txt_before_regex(txt_vector
#' , pattern_regex_to_search = " ?(<-|\\=)")
#' # Return : "my_func_one"  "my_func_2"    "another_func"
#'
#' func_defined <-  codexplor::extract_txt_before_regex(txt_vector
#' , pattern_regex_to_search = " ?(<-|\\=) ?function"
#' , clean_match_from_pattern = TRUE)
#' # Return : "my_func_one" "my_func_2"   NA
#'
#' func_with_suffix_one <-  codexplor::extract_txt_before_regex(txt_vector
#' , prefix_to_add_to_pattern = ".*_one.*"
#' , pattern_regex_to_search = " ?(<-|\\=) ?function", clean_match_from_pattern = TRUE)
#' # Return :  "my_func_one" NA            NA
#' @importFrom stringr str_remove_all str_remove_all
#' @export
extract_txt_before_regex <- function(txt_vector = NULL
                    , pattern_regex_to_search = NULL
                    , prefix_to_add_to_pattern = ".*"
                    , ignore_case = T
                    , clean_match_from_pattern = T
                    ,filter_only_match = F
                    , trimws = T

){

  if(is.null(pattern_regex_to_search)){ warning("\nFunc' extract_all_txt_before_regex() => NO PATTERN TO SEARCH FOR ! ") ; return(NA)}

# the complete main_pattern we extract hereafter :
  main_pattern = paste0(prefix_to_add_to_pattern, pattern_regex_to_search)

  # extract all text with stringr
   matched_txt <- stringr::str_extract(  string = txt_vector
   , pattern = stringr::regex( paste0(main_pattern, collapse = "|" ) # [pasted in case the user have passed a list]
                               , ignore_case = ignore_case)

  )
  # remove the pattern from matched text (optionnal)
  if(clean_match_from_pattern){
    matched_txt <- stringr::str_remove_all(string = matched_txt
                                    , pattern = stringr::regex(ignore_case = ignore_case
                                                        ,paste0(pattern_regex_to_search,  collapse = "|" )))
  }

# remove white spaces
   if(trimws){matched_txt <-  trimws(matched_txt)}

#filter if user want filtered results (lost position in the vector :s)

  if(filter_only_match){  matched_txt <- matched_txt[which(!is.na(matched_txt) )  ]

  }

  return(matched_txt)

}

