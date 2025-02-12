# tests/testthat/test-srch_pattern_in_files_get_df.R
# library(testthat)

test_that("test-srch_pattern_in_files_get_df() returns correct results", {
 dir_tempp <- tempdir()
  # Exemple 1: créer un fichier R pour le test
  test_file <- tempfile(tmpdir =dir_tempp, fileext = ".R")
  # Écrire une fonction R de test dans le fichier temporaire
  content_writed <- c("my_func <- function() {return('Hello world!')}", "and more text with a lazy rat terrier activity", "# and a typical R commented line !")
    writeLines(content_writed, test_file)

  # On s'assure que le fichier existe
  expect_true(file.exists(test_file), "Le fichier temporaire existe")

 resulted_df <- srch_pattern_in_files_get_df(path_main_folder = dirname(test_file)
, line_number_col_name = "line_number", extracted_txt_col_name = "match"
                                ,content_col_name = "content",
                                 ) #by default the func' have to detect R func' definition and return each line !

 test_that("test-srch_pattern_in_files_get_df() return all the lines readed", {
 testthat::expect_equal(nrow(resulted_df), 3 ) #n_lines equiv

   testthat::expect_equal(resulted_df$line_number, 1:3  ) # have returned a line number for each line

 testthat::expect_equal(resulted_df$content, gsub(x = tolower(readLines(test_file) ), pattern = "#.*", "" )) # have returned the full text

  testthat::expect_equal(resulted_df[[ncol(resulted_df)]], c("my_func" , NA, NA) ) #match a func name when a func is defined

})
 # FILTER test
test_that("test-srch_pattern_in_files_get_df() don't match when insufficient nchar()", {
 #have returned func' name IN THE LAST COL, first line


 resulted_df <- srch_pattern_in_files_get_df(path_main_folder = dirname(test_file), ignore_match_less_than_nchar = 100, comments = T

                                             ,content_col_name = "content")


 testthat::expect_equal(resulted_df[[ncol(resulted_df)]], as.character(c(NA , NA, NA) ) ) # NO matching since we filter for  match > 100 char

 testthat::expect_equal(resulted_df$content, tolower(readLines(test_file) )) # return exactly same content, lowered

})

  unlink(dir_tempp, force = T, recursive = T)

})
