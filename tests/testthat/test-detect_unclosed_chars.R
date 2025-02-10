# tests/testthat/test-detect_unclosed_chars.R
# library(testthat)

test_that("test-detect_unclosed_chars() returns correct results", {

  test_that("Balanced text returns NULL", {
    expect_null(detect_unclosed_chars("a(b[c{d}e]f)g"))
  })

  test_that("Extra closing returns position vector", {
    res <- detect_unclosed_chars("a(b[c{d}e]f))g")
    expect_true(!is.null(res))
    # On s'attend à ce que la fonction retourne un vecteur de positions
    expect_true(is.numeric(res))
  })

  test_that("Missing closing returns detailed error", {
    detailed <- detect_unclosed_chars("a(b[c{d(e}f]g)", return_list_of_position = FALSE)
    expect_true(is.data.frame(detailed))
    # On s'attend à trouver au moins une erreur indiquant "Missing closing"
    expect_true(any(grepl("Missing closing", detailed$error)))
  })

  test_that("ignore_escaped works correctly", {
    # Si ignore_escaped est TRUE, les caractères échappés ne devraient pas être pris en compte ds la détection d'erreur.
    text <- "a\\(b) c"
    expect_null(detect_unclosed_chars(text, ignore_escaped = F))

    # Si ignore_escaped est T, le caractère échappé sera traité
    detailed <- detect_unclosed_chars(text, ignore_escaped = T, return_list_of_position = FALSE)
    expect_true(any(grepl("Extra closing", detailed$error)))
  })
})
