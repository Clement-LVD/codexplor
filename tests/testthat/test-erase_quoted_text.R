# tests/testthat/test-test-erase_quoted_text
# library(testthat)

test_that("test-erase_quoted_text() returns correct results", {

test_that("test-erase_quoted_text", {

 sss  <- sample(1:200, 2)
n_char_replaced <- sum(nchar(sss) + 4) # 4 " will be erased !

  input <- paste0('This is a "', sss[[1]], ' and another "',sss[[2]], '"')
  # "test" a 4 lettres, mais la correspondance inclut les quotes donc 6 caractères : "test"
  # le remplacement doit donc être de 6 espaces.
  expect_equal(nchar(erase_quoted_text(input)), nchar(input)  )
})

test_that("erase_quoted_text works with single quotes", {
  input <-    "'sitrep' & 'spotrep'"
  expected <- "         &          "
  expect_equal(erase_quoted_text(input, quoting_char = "'"), expected)
})

test_that("erase_quoted_text works with a custom replacement character", {
  input <- 'Replace "text" here.'
  # La correspondance "text" fait 6 caractères, donc doit être remplacée par 6 underscores.
  expected <- 'Replace ______ here.'
  expect_equal(erase_quoted_text(input, char_for_replacing_each_char = "_"), expected)
})
})
