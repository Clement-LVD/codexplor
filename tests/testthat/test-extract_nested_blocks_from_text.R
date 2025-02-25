test_that("Test des blocs extraits avec une seule instruction", {
  # Test avec une seule instruction
  texte <- "Voici un (exemple (avec un texte (imbriqué))
  et [un autre exemple])."

  result <- extract_nested_blocks_from_text(texte)

  # Vérification du nombre de blocs extraits
  expect_equal(nrow(result), 4)
})

test_that("Test de plusieurs instructions", {
  # Test avec plusieurs instructions
  texte <-   "Voici un (exemple (avec un texte (imbriqué)) et [un autre exemple]). MAIS ENSUITE (ceci)"


  result <- extract_nested_blocks_from_text(texte)

  # Vérification du nombre de blocs extraits
  expect_equal(nrow(result), 5)

  # Vérification de l'instruction_id
  expect_equal(result$level, c(1, 2, 2, 3, 1))

  # Vérification des group_ids
  expect_equal(result$group_id, c(1, 1, 1, 1, 2))


})

test_that("Test avec plusieurs types de délimiteurs", {
  # Test avec des délimiteurs personnalisés
  texte <- "Voici un {exemple (peut-etre [avec des délimiteurs mixtes] à tester)} [mais pas trop]."

  result <- extract_nested_blocks_from_text(texte, delims =  c("[" = "]", "(" = ")", "{"="}"  ))

  # Vérification du nombre de blocs extraits
  expect_equal(nrow(result), 4)

  # Vérification des blocs extraits : smallest at last
  expect_equal(result$block[4], c(
    "[mais pas trop]"
  ))

  # Vérification de l'instruction_id et group_id
  expect_equal(result$level, c(1:3, 1))
  expect_equal(result$group_id, c(1, 1, 1,2))
})

test_that("Test avec des délimiteurs imbriqués mixtes", {
  # Test avec des délimiteurs imbriqués mixtes
  texte <- "Voici un (texte [qui (contient des éléments (imbriqués))] à tester)"
  result <- extract_nested_blocks_from_text(texte, c("(" = ")") )

  # Vérification des blocs extraits
  expect_equal(result$block, c(
    "(texte [qui (contient des éléments (imbriqués))] à tester)",
    "(contient des éléments (imbriqués))",
    "(imbriqués)"
  ))

  # Vérification des IDs d'instruction et de groupe
  expect_equal(result$level, c(1, 2, 3))
  expect_equal(result$group_id, c(1, 1, 1))
})

test_that("Test avec des délimiteurs vides", {
  # Test avec des délimiteurs vides (aucun parenthèses dans le texte)
  texte <- "Pas de parenthèses ici"
  result <- extract_nested_blocks_from_text(texte)

  # Aucun bloc extrait
  expect_equal(result, NULL)
})

test_that("Test avec texte contenant seulement des délimiteurs", {
  # Test avec texte contenant seulement des délimiteurs
  texte <- "( ( ( ) ) ) but there [is (another)]"
  result <- extract_nested_blocks_from_text(texte)

  # Vérification de l'extraction correcte des blocs
  expect_equal(result$block, c(
    "( ( ( ) ) )",
    "( ( ) )",
    "( )", "[is (another)]" , "(another)"
  ))

  # Vérification des group_ids
  expect_equal(result$group_id, c(1, 1, 1, 2,2))
})

