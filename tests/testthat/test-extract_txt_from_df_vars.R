# tests/testthat/test-extract_txt_before_regex.R
# library(testthat)

test_that("test-extract_txt_from_df_vars() returns correct results", {
   df_test <- data.frame(
      A = c("Hello World", "Pattern matching here", "Test123"),
      B = c("This is a test", "Hello World again", "Pattern not found"),
      stringsAsFactors = FALSE
    )

  test_that("extract_txt_from_df_vars ne filtre pas les résultats vides lorsque filter_empty_results est FALSE", {

    # Test avec `keep_empty_results = T` pour garder toutes les lignes
    result <- extract_txt_from_df_vars(df_test,regex_extract_txt =  "World",cols_for_searching_text =  1:2,keep_empty_results = T)

    # Vérifier qu'aucune ligne n'a été filtrée
    expect_equal(nrow(result), 3)  # Il devrait y avoir 3 lignes
    expect_equal(c("World","World",NA), result$to)  # Chaque ligne a un match, même si c'est NA
  })

  test_that("extract_txt_from_df_vars filtre les résultats vides lorsque keep_empty_results est F", {

    # Test avec `filter_empty_results = TRUE` pour filtrer les résultats vides
    result <- extract_txt_from_df_vars(df_test, "NonMatchingPattern", 1:2, keep_empty_results =  F)

    # Vérifier que seules les lignes avec des résultats non vides sont retournées
    expect_equal(nrow(result), 0)  # Aucun match, donc 0 ligne
  })

  test_that("extract_txt_from_df_vars fonctionne avec un nom de colonne personnalisé pour les matches", {

  # Test avec un nom de colonne personnalisé pour les matches
  result <- extract_txt_from_df_vars(df_test, "World", 1:2, keep_empty_results = TRUE,returned_col_name =  "custom_match")

  # Vérifier que la colonne a bien été créée avec le nom personnalisé
  expect_true("custom_match" %in% colnames(result))
})
})
