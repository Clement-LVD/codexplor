#' Read text file with readLines and answer a df
#'
#'
#' This function reads the content of a text file line by line and stores it in a data frame.
#' You must pick up the FIRST col' for the file_path readed, and the LAST col for the content readed
#' intermediar are additionnal info, i.e. line_number
#' @param files_path `character` Path(s) or url(s) to the text files to read.
#' @param return_lowered_text `logical`, default = `FALSE`
#'   TRUE for lowercasing the returned text. FALSE (the default) will preserve the readed text
#' @param .verbose `logical`, default = `TRUE`
#'   If `TRUE`, shows a progress bar while reading the file.
#' @param file_path_col_name `character`, default = `"file_path"`
#'   Column name for the file path in the output dataframe.
#' @param content_col_name `character`, default = `"content"`
#'   Column name for the file content in the output dataframe.
#' @param line_number_col_name `character`, default = `"line_number"`
#'   Column name for the line numbers in the output dataframe.
#' @param trimws_line `logical`, default = `FALSE`.  trim white space(s) at the end and the begining of each line
#' @return Return a `data.frame` with 3 columns.
#' The *last* column (`content` by default) contain the readed lines from the file.
#' \describe{
  #'   \item{file_path}{`character` Path of the file where the match was found.}
  #'   \item{line_number}{`integer` Line number in the file.}
  #'   \item{content}{`character` Content of the line.}
  #' }
#'
#' @examples
#' \dontrun{
#'   df <- readlines_in_df("path/to/file.R", case.sensitive = TRUE)
#'   contents_readed <- df[[ncol(df)]]
#'   file_path_readed <-  df[[1]]
#' }
#' @importFrom utils txtProgressBar setTxtProgressBar
readlines_in_df <- function(files_path,
                            return_lowered_text = FALSE,
                            .verbose = TRUE
  , file_path_col_name = "file_path"
 , content_col_name = "content"
 , line_number_col_name = "line_number"
 , trimws_line = FALSE
 ) {
  files_path <- files_path[!is.na(files_path)]
  n_files_to_read <- length(files_path)

  if(! n_files_to_read > 0) return(NULL) #null if no file to read :s

  names_of_var <- c(file_path_col_name, line_number_col_name, content_col_name)

  # Progress bar
if (.verbose) {pb <- utils::txtProgressBar(min = 0, max = 100, style = 3) }

    #read all files and transform them in dataframe
    resultats <- do.call(rbind, lapply(seq_along(files_path), function(i) {

      lignes <- tryCatch(readLines(files_path[i], warn = FALSE), error = function(e) e$message)

      # clean com'
      if(trimws_line) lignes <- trimws(lignes)
      if (return_lowered_text) lignes <- tolower(lignes)

      # NO LINE = return empty df
      if (length(lignes) == 0) {
        return(structure(data.frame(file_path = files_path[i], line_number = NA, content = NA, stringsAsFactors = FALSE)
                         , names = names_of_var)
               )
      }

      # df to create
      df <- structure(data.frame(
        file_path = files_path[i],
        line_number = as.integer(seq_along(lignes)),
        content = lignes,
        stringsAsFactors = FALSE
      ) , names = names_of_var# colnames customization
)
      # update progress bar
      if (.verbose) utils::setTxtProgressBar(pb, i / n_files_to_read*100 )

      return(df)
    }))

    #close progress bar
    if (.verbose) close(pb)

    return(resultats)
  }
