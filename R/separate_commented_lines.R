#' Separate commented and non-commented lines from text
#'
#' This function extracts and separates commented and non-commented parts from a given vector of texts.
#' It uses a specified delimiter pair to identify comments and returns a data frame with the full text,
#' extracted comments, and remaining code lines.
#'
#' @param texts `character` vector containing text with possible comments.
#' @param delim_pair `character` A named character vector of length 1, where the name is the opening delimiter
#' (e.g., `"/*"`) and the value is the closing delimiter (e.g., `"*/"`).
#' @param .verbose `logical`, default = `TRUE` Return a progress bar if set to `TRUE`
#'
#' @return A data frame with three columns:
#' \describe{
#'   \item{text}{The original text.}
#'   \item{comments}{The extracted comments, concatenated together if multiple are found.}
#'   \item{codelines}{The remaining text after removing comments.}
#' }
#'
#' @examples
#' texts <- c(
#'   "Code snippet /* first comment */ and more code /* second comment */",
#'   "Another line /* only a comment */",
#'   "A line with no comments"
#' )
#'
#' separate_commented_lines(texts, delim_pair = c("/*" = "*/"), .verbose = FALSE)
#'
#' @export
separate_commented_lines <- function( texts
                                      , delim_pair = c( "/*" = "*/" )
                                      , .verbose = T
                                     ){

  # we will return a dataframe in the end
  returned_df <- data.frame(id = seq_along(texts), text = texts)

  # and we fill it with texts extracted from a vector (pair of values)
  # for A SINGLE LINE OF TEXT : we extract several pattern (mapply)
  extract_text_from_cell <- function(text, start, end) {
    extracted_parts <- mapply(substr, text, start, end)
    return(paste0(extracted_parts, collapse = ""))
  } # here mapply apply a boucle on i (implicit behavior)
  # e.g., 1st element of 'start' is used with 1st element of 'end', then 2nd ones, etc.


#### 1)  find the positions of comments
comments <- find_comments_positions(texts = texts, delim_pair = delim_pair, .verbose = .verbose)

# add the comments to returned_df
returned_df$comments <- sapply(seq_along(texts), FUN = function(i){

  if(!i %in% comments$text_id) return(NA) # empty text if it's NOT in the return of find_comments_positions

  comments_on_i <- comments[comments$text_id == i, ]

return(extract_text_from_cell(text = texts[i], start = comments_on_i$start, end = comments_on_i$end))
})

# extract valide lines for each text
codelines <- sapply(seq_along(texts), FUN = function(i){

  if(!i %in% comments$text_id) return(texts[i]) # return full text if it's NOT in the return of find_comments_positions

comments_on_i <- comments[comments$text_id == i, ]
# we reverse this single table, accordingly to a max value that is the nchar of a text entry
valid_rows <- reverse_intervals(start = comments_on_i$start, end = comments_on_i$end, n_max = nchar(texts[i]))

extracted_parts <- mapply(substr, texts[i], valid_rows$start, valid_rows$end)
return(paste0(extracted_parts, collapse = ""))
} #return concatenated texts for a line
)

codelines[nchar(codelines)==0] <- NA

returned_df$codelines = codelines
returned_df$id <- NULL
return(returned_df)
}
