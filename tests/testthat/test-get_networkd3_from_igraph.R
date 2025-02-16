library(testthat)
library(igraph)
library(networkD3)

test_that("get_networkd3_from_igraph works correctly", {

  n_nodes = 5
  # Créer un petit graphe igraph
  g <- make_ring(n_nodes)  # Un graphe en anneau avec 5 nœuds

  # Exécuter la fonction
  result <- get_networkd3_from_igraph(g)

  # Vérifier que l'objet retourné est bien un networkD3
  expect_s3_class(result$forcenetwork,  "forceNetwork")
  expect_type(result$net3d,  "list")
expect_equal(nrow(result$net3d$nodes), n_nodes)

expect_equal(nrow(result$net3d$links), n_nodes)

  # Vérifier que les options HTML (titres, couleurs, etc.) ne font pas planter la fonction
  result2 <- get_networkd3_from_igraph(
    g, title_h1 = "test", subtitle_h2 = "test", endnotes_h3 = "test",
    colors_for_nodes = c("blue", "orange"),
    color_outdeg_instead_of_indeg = TRUE,
    color_for_na_link = "pink",
    add_html_div_code_before_graph = "<div>Custom HTML</div>"
  )

  # Vérifier qu'on a bien un objet networkD3 même avec des options custom
  expect_s3_class(result2$forcenetwork, "forceNetwork")

})
