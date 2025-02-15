#' Convert an edge list into an igraph network
#'
#' This function takes a data frame representing an edge list and converts it into an `igraph` object.
#' It allows filtering nodes based on centrality and extracting subgraphs based on a regular expression.
#'
#' @param edgelist `data.frame`
#'   A data frame containing at least two columns representing the edges (source and target nodes).
#' @param directed `logical`, default = `TRUE`
#'   Indicates whether the graph should be directed (`TRUE`) or undirected (`FALSE`).
#' @param filter_min_centrality `numeric`, default = `0`
#'   Minimum total degree (sum of in-degree and out-degree) required to keep a node in the graph.
#' @param made_subgraph_from_a_regex `character`, default = `NULL`
#'   A regex pattern used to select a starting node for subgraph extraction.
#'   If `NULL`, no subgraph extraction is performed.
#' @param x_level_out_subgraph `integer`, default = `5`
#'   Number of levels outward to include when extracting a subgraph.
#' @param y_level_in_subgraph `integer`, default = `2`
#'   Number of levels inward to include when extracting a subgraph.
#' @param clean_egolink `logical`, default = `TRUE`
#'   If `TRUE`, self-loops (edges where `from == to`) are removed from the edge list before processing.
#' @param ... Additional arguments passed to `grep` for node selection (e.g., `ignore.case = TRUE`).
#'
#' @return An `igraph` object representing the processed graph.
#'
#' @details
#' - **Step 1:** Cleans the edge list (removes self-loops if `clean_egolink = TRUE`).
#' - **Step 2:** Constructs an `igraph` object.
#' - **Step 3:** Filters nodes with a total degree above `filter_min_centrality`.
#' - **Step 4 (optional):** Extracts a subgraph based on `made_subgraph_from_a_regex` and ego-level constraints.
#'
#' @examples
#' # Example edge list
#' edgelist <- data.frame(from = c("A", "B", "C", "D", "E"),
#'                        to   = c("B", "C", "A", "A", "A"))
#'
#' # Create a directed igraph object with minimal filtering
#' g <- get_igraph_from_df(edgelist, directed = TRUE)
#'
#' # Create an undirected graph with a degree filter
#' g <- get_igraph_from_df(edgelist, directed = FALSE, filter_min_centrality = 2)
#'
#' # Extract a subgraph based on a regex
#' g_out <- get_igraph_from_df(edgelist, made_subgraph_from_a_regex = "B", x_level_out_subgraph = 0)
#' g_in <- get_igraph_from_df(edgelist, made_subgraph_from_a_regex = "B", y_level_in_subgraph =0)

#' @import igraph
#' @export
get_igraph_from_df <- function(edgelist
                              , directed =T
                              ,filter_min_centrality = 0
    , made_subgraph_from_a_regex = NULL
    , x_level_out_subgraph = 5
    , y_level_in_subgraph = 2
, clean_egolink = T
    , ... # option pour un grep qui selectionne l bon node !
){
  # Renommer les colonnes de l'edgelist
  colnames(edgelist)[1:2] <- c("from", "to")

  # Supprimer les auto-liens si clean_egolink est TRUE
  if (clean_egolink) edgelist <- edgelist[edgelist$from != edgelist$to, ]

  # Créer le graph
  g <- igraph::graph_from_data_frame(edgelist, directed = directed)

  # Filtrer les nœuds avec un degré supérieur à filter_min_centrality
  nodes_to_keep  <- igraph::V(g)[igraph::degree(g, mode = "total") > filter_min_centrality]
  g <- igraph::induced_subgraph(g, vids = nodes_to_keep )

# Extract subgraph based on regex
  if (!is.null(made_subgraph_from_a_regex)) {
    start_node <- grep(made_subgraph_from_a_regex, names(V(g)), value = TRUE)
    if (length(start_node) > 0) {
      # Nœuds atteignables en sortie (x niveaux)
      out_nodes <- unlist(ego(g, order = x_level_out_subgraph, nodes = start_node, mode = "out"))
      # Nœuds atteignables en entrée (y niveaux)
      in_nodes <- unlist(ego(g, order = y_level_in_subgraph, nodes = start_node, mode = "in"))
      # Fusionner les deux ensembles de nœuds
      selected_nodes <- unique(c(out_nodes, in_nodes))
      g <- igraph::induced_subgraph(g, vids = selected_nodes)
    }
  }
  return(g)
}
