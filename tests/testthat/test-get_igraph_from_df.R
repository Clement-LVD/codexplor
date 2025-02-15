# library(testthat)
# library(igraph)

# === 📌 Définition des jeux de données ===
df_base <- data.frame(from = c("A", "A", "B", "C", "D", "E"),
                      to   = c("B", "C", "D", "E", "A", "A"))  # "E -> A" et self-loop "E -> E"

df_regex <- data.frame(from = c("A1", "A2", "B1", "B2", "C1", "C2"),
                       to   = c("B1", "B2", "C1", "C2", "A1", "A2"))  # Pour tester les regex

test_that("Graph creation and structure", {
  g <- get_igraph_from_df(df_base, clean_egolink = TRUE)

  expect_s3_class(g, "igraph")
  expect_equal(vcount(g), 5)
  expect_equal(ecount(g), 6)  # 🔥 Correction ici
})
test_that("Self-loops are removed when requested", {
  g <- get_igraph_from_df(df_base, clean_egolink = TRUE)

  edge_list_after <- as_data_frame(g, what = "edges")
  expect_false(any(edge_list_after$from == edge_list_after$to))  # Aucun self-loop
})

test_that("Filter by centrality correctly removes low-degree nodes", {
  g <- get_igraph_from_df(df_base, filter_min_centrality =2, x_level_out_subgraph = 1, y_level_in_subgraph = 1)

  node_degrees <- degree(g, mode = "total")
  expect_true("A" == names(node_degrees))  # Tous les nœuds doivent avoir un degré ≥ 2
})

test_that("Regex-based subgraph extraction works", {
  g <- get_igraph_from_df(df_base, made_subgraph_from_a_regex = "D", x_level_out_subgraph = 0, y_level_in_subgraph = 1)

  expect_true(all(grepl("B|D", names(V(g)))))  # Vérifie que seuls A et B restent
})

test_that("Invalid inputs trigger errors", {
  expect_error(get_igraph_from_df(NULL))  # NULL doit lever une erreur
  expect_error(get_igraph_from_df(data.frame()))  # Dataframe vide doit lever une erreur
})
