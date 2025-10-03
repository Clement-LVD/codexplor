# test c level algorithmic
test_that("pairwise - simple - similarity count all lines correctly", {

  res1 <- expect_silent(.Call("pairwise_similarity", c("chat", 'chiens', "chats", "chien")))
  expect_equal(res1$similarity, c(100/3, 80, 40, 100/3, 83.3333333, 40))

  res <- expect_silent(.Call("pairwise_levenshtein", c("chat", 'chiens', "chats", "chien")))

  expect_equal(res$similarity, c(100/3, 80, 40, 50, 83.3333333, 40))

})
