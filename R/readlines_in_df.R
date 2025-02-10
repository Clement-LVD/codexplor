#' Read text file with readLines and answer a df
#'
#' This function reads the content of a text file line by line and stores it in a data frame.
#' You must pick up the FIRST col' for the file_path readed, and the LAST col for the content readed
#' intermediar are additionnal info, i.e. line_number
#' @param files_to_read_path `character`
#'   Path to the text file to read.
#' @param return_lowered_text `logical`, default = `FALSE`
#'   TRUE for lowercasing the returned text. FALSE (the default) will preserve the readed text
#' @param comments `logical`, default = `FALSE`
#'   If `FALSE` - the default, lines starting with `#` are treated as comments and ignored.
#' @param .verbose `logical`, default = `TRUE`
#'   If `TRUE`, shows a progress bar while reading the file.
#' @param file_path_col_name `character`, default = `"file_path"`
#'   Column name for the file path in the output dataframe.
#' @param content_col_name `character`, default = `"content"`
#'   Column name for the file content in the output dataframe.
#' @param line_number_col_name `character`, default = `"line_number"`
#'   Column name for the line numbers in the output dataframe.
#'
#' @return A `data.frame` with 3 col' : first (`file_path` by default) contain the file_path, then `line_number` (by default) contain line_number, and LAST column (`content` by default) containing the read lines from the file.
#' \describe{
  #'   \item{file_path}{Path of the file where the match was found.}
  #'   \item{line_number}{Line number in the file.}
  #'   \item{content}{Full content of the matched line.}
  #'   \item{matches}{Extracted function name or matched pattern.}
  #' }
#'
#' @examples
#' \dontrun{
#'   df <- readlines_in_df("path/to/file.txt", case.sensitive = TRUE)
#'   contents_readed <- df[[ncol(df)]]
#'   file_path_readed <-  df[[1]]
#' }
#' @importFrom utils txtProgressBar setTxtProgressBar
#' @export
readlines_in_df <- function(files_to_read_path,
                            return_lowered_text = FALSE, comments = FALSE, .verbose = TRUE
  , file_path_col_name = "file_path"
 , content_col_name = "content"
 , line_number_col_name = "line_number"
           ) {

  n_files_to_read <- length(files_to_read_path)
if(! n_files_to_read > 0) return(NULL) #null if no file to read :s

  # Progress bar
if (.verbose) {pb <- utils::txtProgressBar(min = 0, max = 100, style = 3) }

    #read all files and transform them in dataframe
    resultats <- do.call(rbind, lapply(seq_along(files_to_read_path), function(i) {
      lignes <- readLines(files_to_read_path[i], warn = FALSE)

      # clean com'
      lignes <- trimws(lignes)
      if (!return_lowered_text) lignes <- tolower(lignes)
      if (!comments) lignes[substr(lignes, 1, 1) == "#"] <- ""  # clean line instead of com'

      # df to create
      df <- data.frame(
        file_path = files_to_read_path[i],
        line_number = seq_along(lignes),
        content = lignes,
        stringsAsFactors = FALSE
      )

      # colnames stability
      colnames(df) <- c(file_path_col_name, line_number_col_name, content_col_name)

      # update progress bar
      if (.verbose) utils::setTxtProgressBar(pb, i / n_files_to_read*100 )

      return(df)
    }))

    #close progress bar
    if (.verbose) close(pb)

    return(resultats)
  }
