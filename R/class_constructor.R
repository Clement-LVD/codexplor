#### CORPUS.LIST MAIN CORPUS OBJECT ####
# a corpus.list is a list of dataframes

#' Create a corpus.list from a list or append a dataframe to a corpus.list
#'
#' @param corpus A list of dataframes.
#' @param df_to_add A dataframe to append to the corpus.list.
#' @param ... Additionnal attributes (e.g., keep trace of the languages analyzed).
#' @return A dataframe of class 'corpus.list'.
.construct.corpus.list <- function(corpus, df_to_add = NULL, ...) {

  # If a df is about to be added: just append it
  if (!is.null(df_to_add)) {
    stopifnot(is.data.frame(df_to_add))
    corpus <- c(corpus, list(df_to_add))  # Append directly
  }
# here the user have to define a class accordingly :
  #### TESTS
  has_citations_network <- any(sapply(corpus, function(df) inherits(df, "citations.network")))

  all_have_file_path <- all(sapply(corpus, function(df) {
    is_network <- any(grepl("network", class(df)))  # TRUE if class contains "network"

    if (is_network | "file_path" %in% colnames(df)) {
      return(TRUE)
    } else {
      warning(paste(
        "A 'file_path' column is missing in a dataframe of your corpus.list",
        "(classes:", paste(class(df), collapse = ", "), ")"
      ))
      return(FALSE)
    }
  }))

  # Stop execution if some non-network dataframes are missing 'file_path'
  if (!all_have_file_path) {
    stop("Some dataframe(s) of your corpus.list don't have a 'file_path' column (except networks)")
  }

  ### CREATING A CORPUS LIST OBJECT
  corpus <- structure(
    corpus,
    class = c("list", "corpus.list"),
    date_creation = Sys.Date(),
    citations_network = has_citations_network,
    ...
  )

  return(corpus)
}



# corpus list contains dataframes

#### class constructor for various df of corpus_list : ####

###### 1) corpus.lines ######
#' Construct a corpus.lines dataframe
#'
#' @param df A dataframe containing a 'line_text' column.
#' @return A dataframe of class 'corpus.lines'.
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

#### corpus.nodelist ####
#' Construct a corpus.nodelist dataframe
#'
#' @param df A dataframe containing a 'line_text' column.
#' @return A dataframe of class 'corpus.nodelist'.
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
