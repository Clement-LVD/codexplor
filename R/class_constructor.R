#### class constructor for various df of corpus_list : ####

###### 1) ######
#' Construct a corpus.lines dataframe
#'
#' @param df A dataframe containing a 'line_text' column.
#' @return A dataframe of class 'corpus.lines'.
#' @export
.construct.corpus.lines <- function(df ) {
  required_cols <- c("content", "comments")
  if (!all(required_cols %in% colnames(df))) {
    stop("The dataframe must contain the columns : 'content' & 'comments'")
  }

  class(df) <-  c("corpus.lines", "data.frame")

  return(df)
}

#' @title Print Method for corpus.lines
#' @description
#' Custom print method for objects of class 'corpus.lines'. Adds a header before printing the object.
#'
#' @param x An object of class 'corpus.lines'.
#' @param ... Additional parameters for the print function.
#'
#' @export
print.corpus.lines <- function(x,...) {

  comments <- unique(x$comments)

  cat("corpus.lines : files are decomposed by lines.", nrow(x), " row(s) from "
      , length(unique(x$file_path, na.rm = T)),"files \n")
  NextMethod("print", x)
}


#' Construct a corpus.nodelist dataframe
#'
#' @param df A dataframe containing a 'line_text' column.
#' @return A dataframe of class 'corpus.nodelist'.
#' @export
.construct.nodelist <- function(df) {
  required_cols <- c("file_path")
  if (!all(required_cols %in% colnames(df))) {
    stop("The dataframe must contain the column: file_path")
  }

 class(df) <-  c( "corpus.nodelist", "data.frame")

  return(df)
}

#' Print a corpus.nodelist dataframe
#' @title Print Method for corpus_lines
#' @description
#' Custom print method for objects of class 'corpus.nodelist'. Adds a header before printing the object.
#'
#' @param x An object of class 'corpus.nodelist'.
#' @param ... Additional parameters for the print function.
#'
#' @export
print.corpus.nodelist<- function(x,...) {
  cat("corpus.nodelist : files are decomposed by files path(s) or url(s).", nrow(x), " row(s) from "
      , length(x$file_path),"files \n")
  NextMethod("print", x)
}
