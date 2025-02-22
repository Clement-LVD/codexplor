# Test pour la fonction `get_regex_from_vector()`
# library(testthat)
# Test avec des préfixes et suffixes basiques
test_that("get_regex_from_vector fonctionne avec des préfixes et suffixes simples", {
  words <- c("apple", "banana", "cherry")
  result <- get_regex_from_vector(words, "^", "$")
  # Résultat attendu : "^apple$|^banana$|^cherry$"
  expected <- "^apple$|^banana$|^cherry$"
  expect_equal(result, expected)
})

# Test special char to escape
test_that("get_regex_from_vector échappe les caractères spéciaux", {
  words <- c("foo(bar)", "baz(qux)")
  result <- get_regex_from_vector(words, prefix_for_regex = "^",suffix_for_regex =  "$")
  # Résultat attendu : "^foo\\(bar\\)$|^baz\\(qux\\)$"
  expected <- "^foo\\(bar\\)$|^baz\\(qux\\)$"
  expect_equal(result, expected)
})

# Test avec un seul élément dans le vecteur
test_that("get_regex_from_vector work with only one element", {
  word <- "apple"
  result <- get_regex_from_vector(word, "^", "$")
  # Résultat attendu : "^apple$"
  expected <- "^apple$"
  expect_equal(result, expected)
})

# Test avec des caractères spéciaux dans le vecteur sans les échapper
test_that("get_regex_from_vector modify (escaping) special char.", {
  words <- c("apple", "banana(", "cherry)")
  result <- get_regex_from_vector(words, "^", "$")
  # Résultat attendu : "^apple$|^banana($|^cherry)$"
  expected <- "^apple$|^banana\\($|^cherry\\)$"
  expect_equal(result, expected)
})

# Test avec un vecteur vide
test_that("get_regex_from_vector retourne une chaîne vide pour un vecteur vide", {
  empty_vector <- character(0)
  result <- get_regex_from_vector(empty_vector, "^", "$")
  # Résultat attendu : ""
  expected <- ""
  expect_equal(result, expected)
})

# Test avec un préfixe et suffixe spécifiques
test_that("get_regex_from_vector fonctionne avec des préfixes et suffixes personnalisés", {
  words <- c("cat", "dog", "bird")
  result <- get_regex_from_vector(words, "(", ")")
  # Résultat attendu : "(cat)|(dog)|(bird)"
  expected <- "(cat)|(dog)|(bird)"
  expect_equal(result, expected)
})
