# tests/testthat/test-srch_pattern_in_files_get_df.R
# library(testthat)

test_that("test-srch_pattern_in_files_get_df() returns correct results", {
 dir_tempp <- tempdir()
  # Exemple 1: créer un fichier R pour le test
  test_file <- tempfile(tmpdir =dir_tempp, fileext = ".R")
  # Écrire une fonction R de test dans le fichier temporaire
  content_writed <- c("my_func <- function() {return('Hello world!')}", "and more text with a lazy rat terrier activity")
  writeLines(content_writed, test_file)

  # On s'assure que le fichier existe
  expect_true(file.exists(test_file), "Le fichier temporaire existe")

 resulted_df <- srch_pattern_in_files_get_df(path_main_folder = dirname(test_file)
                                 , pattern_regex_to_match_and_remove =  "(<-|\\=) +?function"
                                 , prefix_to_add_to_pattern = ".*(?<!FUN)"
                                 ,     pattern_regex_list_files  = "\\.r$"
                                 ,content_col_name = "content",
                                 ) #by default the func' have to detect R stuff

 testthat::expect_equal(nrow(resulted_df), 2 ) #n_lines equiv

 testthat::expect_equal(resulted_df[[ncol(resulted_df)]][1], "my_func") #finding func name
 #have returned func' name IN THE LAST COL, first line
 testthat::expect_equal(resulted_df$line_number[[1]], 1  ) # have returned a line number

 testthat::expect_equal(resulted_df$content, tolower(readLines(test_file) ) ) # have returned the full text

  unlink(dir_tempp, force = T, recursive = T)

})
