#' Convert an igraph object to a networkD3 visualization
#'
#' This function transforms an `igraph` graph object into a `networkD3` interactive visualization.
#' It allows customization of titles, node colors, missing link colors, and additional HTML code insertion.
#'
#' @param graph_igraph An `igraph` object representing the network.
#' @param title_h1 Character. The main title (HTML `<h1>`) displayed above the graph. Default is `"networkD3"`.
#' @param subtitle_h2 Character (optional). The subtitle (HTML `<h2>`) displayed below the main title. Default is `NULL` (no subtitle).
#' @param endnotes_h3 Character (optional). A description or note (HTML `<h3>`) displayed after the network. Default is `NULL` (no text).
#' @param colors_for_nodes Character vector. Specifies colors for nodes based on their degree and also number of separation
#' the func' will try to realize (based on indegrees or outdegrees). Default is `c("green", "grey", "black", "red")`.
#' @param color_outdeg_instead_of_indeg Logical. If `TRUE`, node colors are assigned based on out-degree instead of in-degree. Default is `FALSE`.
#' @param color_for_na_link Character. Color assigned to links when data is missing.
#'  Default is the 1st color of `colors_for_node` (`"green"`).
#' @param add_html_div_code_before_graph Character (optional). Custom HTML code inserted after the end of the network.
#' Default is `NULL` (no additional HTML).
#' @param charge `integer`, default = `-200` Numeric value indicating
#' either the strength of the node repulsion (negative value) or attraction (positive value).
#' Passed to `networkD3::forceNetwork`.
#' @param ... optional parameter passed to `networkD3::forceNetwork`
#' @examples
#' library(igraph)
#' g <- make_ring(10)
#' get_networkd3_from_igraph(g, title_h1 = "My Network")
#' @return A list with the net3d usual object from `networkD3::` and the html object from `networkD3::forceNetwork` :
#' \describe{
#'   \item{net3d}{networkD3 usual list}
#'     \item{$links}{$links is the 1st entry of a networkD3 usual list with 'source' and 'target' vectors}
#'     \item{$nodes}{$nodes is the 2nd entry of a networkD3 usual list, with the 'name' of the nodes vector}
#'   \item{forcenetwork}{networkD3::forceNetwork usual html object for interactive network visualization}
#'   }
#' @importFrom igraph V degree simplify
#' @importFrom networkD3 igraph_to_networkD3 JS forceNetwork
#' @importFrom htmlwidgets prependContent appendContent
#' @importFrom htmltools tags HTML
#' @importFrom scales col_numeric
#' @export
get_networkd3_from_igraph <- function(graph_igraph
                                     , title_h1 = "networkD3"
                                     , subtitle_h2 = NULL
                                     , endnotes_h3 = NULL

                                     , colors_for_nodes =  c("green","grey",  "black",  "red")
                                     , color_outdeg_instead_of_indeg = F
                                     , color_for_na_link = colors_for_nodes[[1]]
                                     , add_html_div_code_before_graph = NULL
                                     , ...
                                     , charge = -200

){

  # simplified subgraph `g`
  graph_igraph <- igraph::simplify(graph_igraph, remove.multiple = TRUE, remove.loops = TRUE)

  #### A. Compute degrees ####
  # 1. Convert to `networkD3`
  net3d <- networkD3::igraph_to_networkD3(graph_igraph)

  # 2. degrees calculation
   net3d$nodes$indegree <- igraph::degree(graph_igraph, mode = "in")
   net3d$nodes$outdegree <-  igraph::degree(graph_igraph, mode = "out")

values_to_cut <-  "indegree" ; other_value = "outdegree"# values used in the legend in the end!
if(color_outdeg_instead_of_indeg){ values_to_cut <-  "outdegree"; other_value = "indegree" }

##### B. Add colors depending of a degrees ####

   #scales:: function -> colors vector
color_fun <- scales::col_bin(  palette = colors_for_nodes     # COLOR pal
   ,  domain = range(net3d$nodes[[values_to_cut]]   , na.rm = TRUE) )# range

net3d$nodes$color_deg <- color_fun(net3d$nodes[[values_to_cut]])

# we have a node coloring factor
  node_colors <- net3d$nodes$color_deg
  names(node_colors) <- as.character(rownames(net3d$nodes))

#### C. COLORING EDGES #####
# we apply same color of the 'source' node if we color outdeg
  # and color of the target node for indeg coloring
if(values_to_cut ==  "indegree") {considered_node = "target"
alt_node  = "source" } # keep trace of the "other" non colorized
if(values_to_cut ==  "outdegree"){considered_node = "source"; alt_node  = "target"}

net3d$links$color_deg = NA

# render3d sometimes return a "0" as a node id so if it's a 0 we should adjust +1
adjustment_of_networkd3 = ifelse(min(c(net3d$links$source, net3d$links$target)) == 0, 1, 0)

net3d$links$color_deg <- sapply(1:nrow(net3d$links),  FUN = function(i) {
    # for each link we take the num of corresponding node (target or source) :
    num_node_with_color <- net3d$links[[considered_node]][[i]] +adjustment_of_networkd3

# we retrieve the color and send a character
    corresp_color <- as.character(node_colors[[which(names(node_colors) == num_node_with_color)]])
      # the num of node that we take the color is the names of node_colors
 return(corresp_color) }
       )

# identifying the not-colorized edges
  na_idx <- is.na(net3d$links$color_deg) #those have no matched from "from" first col'

    # color link left are NA : colorized with a color
  if(any(na_idx)){ net3d$links$color_deg[na_idx] <- color_for_na_link }

#### D. Craft Javascript colorscale ####
  # Définition du nombre d'intervalles pour le scale
n_intervals <- length(colors_for_nodes)

  breaks <- round(seq(min(net3d$nodes[[values_to_cut]]  , na.rm = TRUE)
                      , max(net3d$nodes[[values_to_cut]]  , na.rm = TRUE), length.out = n_intervals))

  # Supp duplicated
  breaks <- unique(breaks)

 range_qq_txt <- paste0(round(unique(breaks)), collapse = ", ")
  # tweak network with js code :
   not3D_colourscale_JS = networkD3::JS(paste0('d3.scaleLinear().domain([', range_qq_txt
                                              , ']).range(['
                                              , paste0('"', colors_for_nodes, collapse = '", ' )
                                              , '"]).clamp(true);') )

#if ordinal scale needed : networkD3::JS('d3.scaleOrdinal(d3.schemeCategory10)')

  #### E. Craft FORCE NETWORK ####
  dataviz_network = networkD3::forceNetwork( legend = T

                                            ,  opacityNoHover = 0.9  # Empêche le changement de flou à l'hover

                                            , Nodes = net3d$nodes
                                            , NodeID = "name", charge = charge
                                            , Group = values_to_cut,
                                            Nodesize = other_value

                                            #LES LIENS :
                                            ,  Links = net3d$links
                                            , linkWidth = networkD3::JS("function(d) { return 1; }")  # Largeur des liens
                                            , arrows = T,  Source = "source", Target = "target"
                                            ,  linkColour =  net3d$links$color_deg
                                            , opacity =1,
                                            bounded = T
                                            , zoom = TRUE
                                            , colourScale = not3D_colourscale_JS
                                           , ...)

#### F. Add html content (legend, etc.) ####
  dataviz_network <-  htmlwidgets::prependContent(dataviz_network, htmltools::tags$h1(title_h1 ) )
  # supposed to be a legend such as : "a link indicate that :"
  if(!is.null(subtitle_h2) ){
    dataviz_network <-   htmlwidgets::prependContent(dataviz_network  , htmltools::tags$h2(subtitle_h2 ) )
  }

  #   construct an html code legend for explain node coloring
  legend_html <- paste0("<div style='position:floating; top:10px; left:10px; background:white; padding:10px; border:0px;'>
  <strong>Colors (", values_to_cut,")</strong><br></div>")
  dataviz_network <- htmlwidgets::prependContent(dataviz_network,  htmltools::HTML(legend_html))

### add elements after graph ###
    if(!is.null(endnotes_h3) ){
    dataviz_network <-  htmlwidgets::appendContent(dataviz_network  ,htmltools::tags$h3(endnotes_h3) )
  }
 # dataviz_network$x$html
  #optionnal) add custom html code before graph :
if(!is.null(add_html_div_code_before_graph)) dataviz_network <- htmlwidgets::appendContent(dataviz_network, htmltools::HTML(add_html_div_code_before_graph))
# user should pass custom div style as :
  # "<div style='display:flex; align-items:center;'><div style='width:15px; height:15px; background:grey; margin-right:5px;'></div> texte du user</div>"

  # return a list and our dataviz (html widget)
  return(list(net3d = net3d, forcenetwork = dataviz_network))

}
