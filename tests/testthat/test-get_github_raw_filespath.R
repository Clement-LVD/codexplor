# tests/testthat/test-srch_pattern_in_files_get_df.R
# library(testthat)

test_that("test-get_github_raw_filespath() returns correct results", {

  readr_fp <- get_github_raw_filespath(repo = "tidyverse/readr", pattern = "\\.R")

# testthat::expect_true(length(readr_fp) > 1) # have results

testthat::expect_true(all(grep(x =readr_fp , pattern = "^https://raw.githubusercontent.com/tidyverse/readr")) ) #begin with the url

testthat::expect_true(all(grep(x =readr_fp , pattern = ".R$")) ) #finish by .R



})
