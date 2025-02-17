#' Convert an edge list into an igraph network
#'
#' This function takes a data frame representing an edge list and converts it into an `igraph` object.
#' It allows filtering nodes based on centrality (filter orphan by default).
#' It construct a directed network
#'
#' @param edgelist `data.frame`
#'   A data frame containing at least two columns representing the edges (source and target nodes).
#' @param directed `logical`, default = `TRUE`
#'   Indicates whether the graph should be directed (`TRUE`) or undirected (`FALSE`).
#' @param filter_min_centrality `numeric`, default = `0` (filter of the orphans)
#'   Strict minimum total degree (sum of in-degree and out-degree) required to keep a node.
#'   You have to indicate `-1` for keep the orphans (i.e. with degree = '0')
#' @param clean_egolink `logical`, default = `TRUE`
#'   If `TRUE`, self-loops (edges where `from == to`) are removed from the edge list before processing.
#' @param ... Additional arguments passed to `igraph::graph_from_dataframe` for node selection (e.g., `ignore.case = TRUE`).
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
#' @importFrom igraph graph_from_data_frame V degree induced_subgraph
#' @export
get_igraph_from_df <- function(edgelist
                              , directed =T
                              ,filter_min_centrality = 0
, clean_egolink = T
, ...
){
  # Supprimer les auto-liens si clean_egolink est TRUE
  if (clean_egolink) edgelist <- edgelist[edgelist[[1]] != edgelist[[2]], ]

  # Craft a graph
  g <- igraph::graph_from_data_frame(edgelist, directed = directed, ...)

  # Filter nodes with degree sup to filter_min_centrality
  nodes_to_keep  <- igraph::V(g)[igraph::degree(g, mode = "total") > filter_min_centrality]
  g <- igraph::induced_subgraph(g, vids = nodes_to_keep )


  return(g)
}
