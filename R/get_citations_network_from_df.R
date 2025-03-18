#' Construct a Citations Network from Data Frame
#'
#' Given a `dataframe` from the user, the function extracts a network of citations by searching for patterns.
#' The function will 1st construct a pattern by adding a prefix and a suffix to each text from the `pattern_varname` column
#' Then these pattern are searched in the `content_varname` column, returning a df with "line number" where match have occured
#'
#' @param df A data frame containing the data to be processed.
#' @param content_varname `character`, default = `"content"` A character string *specifying the name of the column containing the text to be searched*.
#' Default is "content".
#' @param pattern_varname, default = `"first_match"` A character string *specifying the name of the column containing the patterns that will be matched*.
#'  Default is "first_match".
#' @param prefix_for_regex_from_string `character`, default = `""` A character string to be used as a prefix in the regex pattern.
#' @param suffix_for_regex_from_string `character`, default =  `""` A character string to be used as a suffix in the regex pattern.
#' @param keep_only_row_without_a_pattern `logical`, default = `TRUE` If `TRUE`, keeps only rows with an initial entry for constructing the pattern
#'  (i.e. lines with a character in the `pattern_varname` column of the df passed by the user will be filter out)
#' @param varname_for_matches `character`, default = `"matches"` A character string specifying the name of the column of matches in the returned df.
#' @param n_char_to_add_suffix `double`, default = `3`. Minimum number of characters to add the suffix.
#' @return A data frame with the extracted citations network.
#' @details
#' The returned data frame has 5 columns:
#' \describe{
#'   \item{\code{row_number}}{The row number of the original data frame where the text is matched.}
#'   \item{\code{matches}}{The text matched by the pattern, e.g., name of a person.}
#'   \item{\code{content}}{The text content where the pattern was searched, i.e. the column that is identified with `content_varname`}
#'   \item{\code{first_match}}{The original pattern searched for (filled with NA if keep_only_row_without_a_pattern is `TRUE`)}
#' }
#' @seealso \code{\link{get_regex_from_vector}}, \code{\link{str_extract_all_to_tidy_df}}
#' @examples
#' \dontrun{
#' df <- data.frame(content = c("Citation (Bob, 2021)", "Another Bob"), first_match = c("Bob" , NA))
#' get_citations_network_from_df(df  ) # Return only the 2nd line (match 'Bob')
#' get_citations_network_from_df(df,  keep_only_row_without_a_pattern = FALSE)
#' #will return the lines (matching 'Bob')
#' }
get_citations_network_from_df <- function(df
    , content_varname = "content"

    , pattern_varname = "first_match"
    , prefix_for_regex_from_string = "" # text before the 1st match

 ,  suffix_for_regex_from_string = ""# add text after the 1st match
, keep_only_row_without_a_pattern  = TRUE

, varname_for_matches = "matches"
, n_char_to_add_suffix = 3
){

  required_cols <- c(content_varname, pattern_varname)
  missing_cols <- required_cols[!required_cols %in% names(df)]

  if (length(missing_cols) > 0) {
    stop(paste("Columns are missing in the data.frame :",
               paste(missing_cols, collapse = ", ")))
  }
# we will return a df.
dff <- df

dff$row_number <- seq_len(nrow(df))

### 1) construct a regex with the string
regexx_complete <- get_regex_from_vector(vector = df[[pattern_varname]]
                                         ,prefix_for_regex =  prefix_for_regex_from_string
                                         , suffix_for_regex = suffix_for_regex_from_string
                                         , fix_escaping = T
                                         , n_char_to_add_suffix = n_char_to_add_suffix )

#we will retrieve this object and these var later

# 2) match every string
#  match every mention of our previous matches and returning a DF
fns_called_df <- str_extract_all_to_tidy_df(string =  dff[[content_varname]]
                                            , pattern = regexx_complete
                                            , row_number_colname = "row_number"
                                            , matches_colname = varname_for_matches)
 # we have added row_number colname in both fns_called_df AND dff !

# 3) remove our pattern added (suffix or prefix) =>
fns_called_df[[varname_for_matches]] <- gsub(perl = T, x = fns_called_df[[varname_for_matches]]
                                   , pattern = paste0("^", prefix_for_regex_from_string), replacement = "")

fns_called_df[[varname_for_matches]]  <- gsub(perl = T, x = fns_called_df[[varname_for_matches]]
                                   , pattern = paste0(  suffix_for_regex_from_string, "$"), replacement = "")

#### 4) construct the network of func' ####
# reunite matches 1 and matches 2 =>
complete_network <- merge(fns_called_df, dff,
                          all.x = T # we preserve each 2nd match
                          , by = "row_number")
# lines will be duplicated if + than 1 match per line

# filter the network
# not empty first_match (func_defined) value indicate that this file mention his own match
# ('internal link', recursivity or func' definition) whereas other link refer to external link

# so we want to suppress the autolink

 if(keep_only_row_without_a_pattern){
   row_to_exclude <- which(!is.na(complete_network[pattern_varname]))
 if(length(row_to_exclude) > 0) complete_network <- complete_network[-row_to_exclude , ] }

return(complete_network)

}
