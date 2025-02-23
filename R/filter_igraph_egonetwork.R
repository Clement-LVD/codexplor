#' Extract an ego-subgraph based on a regex pattern
#'
#' Given a `igraph` object and a pattern (regex), this function will return
#' an ego-subgraph of these node(s), within specified depths from them.
#' If the graph is directed, the nodes are filtered as an ego-network *within specified depths*
#'
#' @param graph_igraph An igraph object representing the graph.
#' @param regex `character` A character string representing the regex pattern to filter nodes.
#' @param degrees_in_filter `integer`, default = `2`. An integer specifying the depth of inward reachable nodes (default is 2).
#' @param degrees_out_filter `integer`, default = `2`. An integer specifying the depth of outward reachable nodes (default is 2).
#' @return An igraph object representing the filtered subgraph.
#' @importFrom igraph ego induced_subgraph V
#'
#' @examples
#' g <- igraph::make_ring(10, directed = TRUE)
#' igraph::V(g)$name <- as.character(1:10)
#' subg_2_lvl_out <- filter_igraph_egonetwork(g,  regex= "1$", 0, 2)
#' plot(subg_2_lvl_out)
#' @export
filter_igraph_egonetwork <- function(graph_igraph, regex, degrees_in_filter = 2, degrees_out_filter = 2) {
  if (!is.null(regex)) {
    start_node_names <- grep(regex,  names(igraph::V(graph_igraph)), value = TRUE)
    start_nodes <- igraph::V(graph_igraph)[names(igraph::V(graph_igraph)) %in% start_node_names]
    # we will suppress NULL !
      # Inward reachable nodes (y levels)
      in_nodes <- unlist( igraph::ego(graph_igraph, order = degrees_in_filter, nodes = start_nodes, mode = "in"))
      # Outward reachable nodes (x levels)
      out_nodes <- unlist( igraph::ego(graph_igraph, order = degrees_out_filter, nodes = start_nodes, mode = "out"))
      # Merge both sets of nodes
      selected_nodes <- unique(c(out_nodes, in_nodes))
      graph_igraph <-  igraph::induced_subgraph(graph_igraph, vids = selected_nodes)
    }

  return(graph_igraph)
}
