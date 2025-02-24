  # library(testthat)

test_that("get_citations_network_from_df works correctly", {

  # Début des tests
  test_that("Extract text and filter autolinks", {
    df <- data.frame(
      content = c(
        "Cet article cite (Smith, 2021)",
        "Référence à (Johnson, 2022)",
        "Une autre citation (Smith, 2021)",
        "Pas de citation ici"
      ),
      first_match = c("Doe",  "Smith","Johnson", NA),
      stringsAsFactors = FALSE
    )


    result <- get_citations_network_from_df(df, keep_only_row_without_a_pattern = F )

    # Vérifie que le résultat contient le réseau de citations attendu
    expect_true(is.data.frame(result))
    expect_gt(nrow(result), 0)
    expect_equal(names(result), c("row_number", "matches",  "content", "first_match"))

    # Vérifie que l'autolink a bien été exclu par défaut
    expect_false(any(result$from == result$to))
  })

  test_that("Inclusion des autolinks si paramètre spécifié", {
    df <- data.frame(
      content = c(
        "Cet article cite (Smith, 2021)",
        "Référence à (Johnson, 2022)",
        "Une autre citation (Smith, 2021)",
        "Pas de citation ici"
      ),
      first_match = c("Smith", "Johnson", "Smith", NA),
      stringsAsFactors = FALSE
    )

    # On force l'inclusion des autolinks
    result <- get_citations_network_from_df(df, keep_only_row_without_a_pattern = F)

    # Vérifie que l'autolink est présent cette fois
    expect_true(any(result$matches == result$first_match))
  })

  test_that("Aucun résultat si tous les liens sont des autolinks", {
    df <- data.frame(
      content = c(
        "Cet article cite (Smith, 2021)",
        "Référence à (Johnson, 2022)"
      ),
      first_match = c("Smith, 2021", "Johnson, 2022"),
      stringsAsFactors = FALSE
    )

    result <- get_citations_network_from_df(df)

    # Vérifie que le résultat est un data.frame vide
    expect_true(is.data.frame(result))
    expect_equal(nrow(result), 0)
  })

  test_that("Paramètres personnalisés pour les colonnes", {
    df <- data.frame(
      texte = c(
        "Cet article cite (Smith, 2021)",
        "Référence à (Johnson, 2022)"
      ),
      motif = c("Smith, 2021", "Johnson, 2022"),
      stringsAsFactors = FALSE
    )

    result <- get_citations_network_from_df(keep_only_row_without_a_pattern = F,
      df,
      content_varname = "texte",
      pattern_varname = "motif"
    )

    expect_true(is.data.frame(result))
    expect_gt(nrow(result), 0)
  })


})
