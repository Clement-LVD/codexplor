# tests/testthat/test-extract_txt_before_regex.R
# library(testthat)

test_that("extract_txt_before_regex() returns correct results", {

  # Exemple 1: Test avec une simple ligne
  txt_vector <- c("This is a test <- my_function")
  result <- extract_txt_before_regex(txt_vector, pattern_regex_to_search = "function")
  testthat::expect_equal(result, "This is a test <- my_") #remove 'function' is unforgiving

  # Exemple 2: Test avec un prefix et nettoyage du pattern
  result_no_clean <- extract_txt_before_regex(txt_vector
                                               , pattern_regex_to_search = "function"
                                           , clean_match_from_pattern = F)
  testthat::expect_equal(result_no_clean, txt_vector) # doit etre comme l'original !

  # Exemple 3: Test sans filtre, renvoie ce qui est AVANT la regex ET UN NA en résultat !
  txt_vector2 <- c("First function <- test1", "Second function <- test2", "No match here")
  result_all <- extract_txt_before_regex(txt_vector2, pattern_regex_to_search = "function", filter_only_match = FALSE)
  expect_equal(result_all, c("First", "Second", NA))

  # Exemple 3-bis: NO MATCH AND FILTER only match => NA
  result_filtered <- extract_txt_before_regex(result_all, pattern_regex_to_search = "function"
                                              , filter_only_match = TRUE)
  expect_equal(result_filtered,character(0L)) # character(0) in console
  #without any result => caracter(0) since NA ARE NOT ADMITED (NA meaning no match)

  # Exemple 4: Test avec la sensibilité à la casse SANS FILTRER
  result_case_sensitive <- extract_txt_before_regex(txt_vector2
                                                    , pattern_regex_to_search = "FUNCTION", ignore_case = FALSE)
  expect_equal(result_case_sensitive, as.character(rep(NA, 3))) # + answer caractere even with NA

  # Exemple 6: Test avec un prefix personnalisé
  result_prefix <- extract_txt_before_regex(txt_vector2, pattern_regex_to_search = "function"
                                            , prefix_to_add_to_pattern = "First.*")
  expect_equal(result_prefix, c("First", NA, NA) ) # only extract the prefix before the regex and no match without this prefix + the regexa!
})
