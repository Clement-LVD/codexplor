test_that("readlines_in_df works correctly", {
  # Créer un fichier temporaire .R pour tester
  temp_file <- tempfile(fileext = ".R")
  repeat_line = sample.int(size = 1, n = 50) # on crée un certain nbre de lignes
  writeLines(rep("Line", repeat_line), temp_file)

  # Tester la fonction = lire des lignes
  df <- readlines_in_df(temp_file)

  # Vérifier que la sortie est bien un data.frame avec 3 lignes
  expect_s3_class(df, "data.frame") # répond un df
  expect_equal(nrow(df), repeat_line) #lis un fichier de 3 lignes = doit répondre un df de 3 lignes !

  # Nettoyage
  unlink(temp_file)
})
