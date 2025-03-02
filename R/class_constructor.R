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

  # 1) add additionnal df if there is a df_to_add element
if (!is.null(df_to_add)) {

  # get old names
old_names <- names(corpus)

 # we verify if it's a named list (supposed to define each names)
if(length(names(df_to_add)) > 0){
  names_new_df <- names(df_to_add)

    }

if(length(names(df_to_add)) == 0){ # Controlling for names
stopifnot("To append a df to a corpus.list, you should provide :
- A vector of name(s) with same length than the vector of data.frame(s).
- Or a named list of data.frame"
 , length(names_of_df_to_add) == length(df_to_add))

  #we have a valid vector of names AND df_to_add of the same length.
  names_new_df <- names_of_df_to_add
  }

corpus <- append(corpus, df_to_add)  # Append directly the df_to_add
names(corpus) <- c(old_names, names_new_df) #complete names

}

  # we'll apply a class corpus.list => before we have boring checks
# 2) GLOBAL CHECK ON THE LIST of df
  has_citations_network <- any(sapply(corpus, function(df) inherits(df, "citations.network")))

  # 3) individuals checks are in a function hereafter
  # return a boolean if all checks are ok
if(!check_dataframes_for_corpus.list(corpus)) stop("There is an integrity problem within the corpus.list")

  ### CREATING A CORPUS LIST OBJECT
  corpus <- structure(
    corpus,
    class = c("list", "corpus.list"),
    date_creation = Sys.Date(),
    have_citations_network = has_citations_network,
    ...
  )

  return(corpus)
}

#### Check individuals dataframe of a list ####
check_dataframes_for_corpus.list <- function(df_list
  , omit_class = "citations.network"

   , required_columns = c("file_path","content", "n_char", "n_word")) {


  # return a logical - column are existing or not - and a warning if not
  check_columns <- function(df) {

    if (!is.null(omit_class) && any(inherits(df, omit_class))) { return(TRUE) }

    checks_cols <- required_columns %in% colnames(df) # boolean for each col'

    if(all(checks_cols)) return(TRUE)

    missing_cols <- required_columns[!checks_cols]
    warning("Missing column(s) in a corpus.list dataframe (classes : "
            , paste0(class(df), collapse = " & ") , ")\n => "
            , paste0(collapse = ", ", missing_cols))
    return(FALSE)
  }

  # Here list all the individuals tests on the df
  tests_list <- list(
    "A corpus. dataframe must have the required columns" = \(df) check_columns(df),
    "A corpus. dataframe should not be empty" = \(df) nrow(df) > 0
  )

  # apply these tests_list elements on a df =>
  apply_tests <- function(df) {sapply(tests_list, function(f) f(df))}

  #apply on each dataframes
  results <- sapply(df_list, apply_tests)

  # Vérifier si tous les tests passent
  all_passed <- all(results)

  # Affichage des erreurs si nécessaire
  if (!all_passed) {
    warning("Some dataframes failed the checks: "
            , paste(names(df_list)[!results], collapse = " / ")
            )
  }

  return(all_passed)
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
