# ---- TESTS ----
# library(testthat)

test_that("fix_escaping correctly adds escapes", {
  expect_equal(fix_escaping("Hello (world)", special_chars = c("(", ")"), num_escapes = 2),
               "Hello \\(world\\)")
})

test_that("fix_escaping handles multiple special characters", {
  expect_equal(fix_escaping("This (is) a test?", special_chars = c("(", ")", "?"), num_escapes = 2),
               "This \\(is\\) a test\\?")
})

test_that("fix_escaping maintains already correct escaping", {
  expect_equal(fix_escaping("Here is \\(escaped\\)", special_chars = c("(", ")"), num_escapes = 2),
               "Here is \\(escaped\\)")
})

test_that("fix_escaping works with 3 levels of escaping", {
  expect_equal(fix_escaping("Match this \\(text\\)", special_chars = c("(", ")"), num_escapes = 6),
               "Match this \\\\\\(text\\\\\\)")
})

test_that("fix_escaping returns input unchanged if no special characters", {
  expect_equal(fix_escaping("Just text", special_chars = c("(", ")"), num_escapes = 2),
               "Just text")

expect_equal(fix_escaping(42, special_chars = c("("), num_escapes = 2), "42")
  })

 test_that("fix_escaping throws errors on invalid input", {
   expect_error(fix_escaping("Test", special_chars = character(0), num_escapes = 2))
  expect_error(fix_escaping("Test", special_chars = c("("), num_escapes = -1))
})
