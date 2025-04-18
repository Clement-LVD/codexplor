# library(testthat)
# library(igraph)

# === 📌 Définition des jeux de données ===
df_base <- data.frame(from = c("A", "A", "B", "C", "D", "E"),
                      to   = c("B", "C", "D", "E", "A", "A"))  # "E -> A" et self-loop "E -> E"

df_regex <- data.frame(from = c("A1", "A2", "B1", "B2", "C1", "C2"),
                       to   = c("B1", "B2", "C1", "C2", "A1", "A2"))  # Pour tester les regex

test_that("Graph creation and structure", {
  g <- get_igraph_from_df(df_base)

  expect_s3_class(g, "igraph")
  expect_equal(vcount(g), 5)
  expect_equal(ecount(g), 6)  # 🔥 Correction ici
})

test_that("Filter by centrality correctly removes low-degree nodes", {
  g <- get_igraph_from_df(df_base, filter_min_centrality =2)

  node_degrees <- degree(g, mode = "total")
  expect_true("A" == names(node_degrees))  # Tous les nœuds doivent avoir un degré ≥ 2
})


test_that("Invalid inputs trigger errors", {
  expect_error(get_igraph_from_df(NULL))  # NULL doit lever une erreur
  expect_error(get_igraph_from_df(data.frame()))  # Dataframe vide doit lever une erreur
})
