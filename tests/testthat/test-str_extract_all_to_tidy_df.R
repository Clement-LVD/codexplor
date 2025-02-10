# tests/testthat/test-extract_txt_before_regex.R
# library(testthat)

test_that("test-str_extract_all_to_tidy_df() returns correct results", {
text_data <- c("funcA funcB", "funcC", "Nothing here", "funcD funcE")
  pattern <- "func[A-E]"

test_that("str_extract_all_to_tidy_df extracts matches correctly", {

  result <- str_extract_all_to_tidy_df(text_data, pattern)

  expected_df <- data.frame(
    matches = c("funcA", "funcB", "funcC", "funcD", "funcE"),
    row_number = c(1, 1, 2, 4, 4)
  )

  expect_equal(result, expected_df)
})

test_that("str_extract_all_to_tidy_df handles empty matches correctly", {
  text_data <- c("Nothing here", "Still nothing")

  result <- str_extract_all_to_tidy_df(text_data, pattern)

  expect_equal(nrow(result), 0)  # Should return an empty dataframe
})

test_that("str_extract_all_to_tidy_df removes NA values when filter_unmatched is F", {
  text_data <- c("funcA funcB", NA, "funcC")
  pattern <- "func[A-C]"

  result <- str_extract_all_to_tidy_df(text_data, pattern, filter_unmatched = F)

  expected_df <- data.frame(
    matches = c("funcA", "funcB", NA, "funcC"),
    row_number = c(1, 1, 2, 3)
  )

  expect_equal(result,expected_df)
})

test_that("str_extract_all_to_tidy_df correctly assigns custom column names", {
  text_data <- c("funcA funcB", "funcC")
  pattern <- "func[A-C]"

  result <- str_extract_all_to_tidy_df(text_data, pattern,
                                       matches_colname = "extracted",
                                       row_number_colname = "index")

  expected_colnames <- c("extracted", "index")
  expect_equal(colnames(result), expected_colnames)
})
})
