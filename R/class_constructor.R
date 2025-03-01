#### CORPUS.LIST MAIN CORPUS OBJECT ####
# a corpus.list is a list of dataframes

#' Create a corpus.list from a list or append a dataframe to a corpus.list
#'
#' @param corpus `corpus.list` `list` of dataframes created by `construct_corpus()`.
#' @param df_to_add `list` of `data.frame` or a single `data.frame` to append to the corpus.list. If data.frame(s) without a name are provided, names should be provided with `names_of_df_to_add`
#' @param names_of_df_to_add `character` vector of names to append to the corpus.list, if anonymous materials is provided (unamed df or list of unamed df).
#' @param ... Additionnal attributes (e.g., keep trace of the languages analyzed).
#' @return A dataframe of class 'corpus.list'.
.construct.corpus.list <- function(corpus, df_to_add = NULL, names_of_df_to_add = NULL, ...) {

  # If a df is about to be added: just append it
  # but verify names 1st : all object quit these functions with names
if (!is.null(df_to_add)) {

if(length(names(df_to_add)) > 0){
old_names <- names(corpus)
corpus <- append(corpus, df_to_add)  # Append directly
names(corpus) <- c(old_names, names(df_to_add))
    }

if(length(names(df_to_add)) == 0){ # we want names !
    stopifnot("A valid vector of name(s) of the same length than the vector of data.frame(s) is passed to .construct.corpus.list, to append a df to a corpus.list"
              , length(names_of_df_to_add) == length(df_to_add))

    }
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
