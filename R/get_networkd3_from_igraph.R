get_networkd3_from_igraph <- function(graph_igraph
                                     , titre_h1 = "networkD3"
                                     , sous_titre = NULL
                                     , mini_texte = NULL

                                     , colors_for_nodes =  c("grey", "black", "orange",  "red")
                                     , color_outdeg_instead_of_indeg = F
                                     , color_for_na_link = "green"

){

  # pacman::p_load(networkD3, htmlwidgets, tidyverse, igraph, stats, tibble)

  # 3. Convertir en `networkD3`
  net3d <- networkD3::igraph_to_networkD3(graph_igraph)
  # le graph sera aussi retourné ds une liste
  igraph::V(graph_igraph)$indeg =  igraph::degree(graph_igraph, mode = "in")
  igraph::V(graph_igraph)$outdeg = igraph::degree(graph_igraph, mode = "out")

  # Ajouter les attributs des nœuds (ex : indeg, outdeg)
  net3d$nodes$indeg <- igraph::V(graph_igraph)$indeg
  net3d$nodes$outdeg <- igraph::V(graph_igraph)$outdeg

  # Normalize degrees (indeg OR outdeg for coloring)
#### add couleurs ####
values_to_cut <-  "indeg"
if(color_outdeg_instead_of_indeg){ values_to_cut <-  "outdeg" }
# standardized distrib by quartiles = 5 values !
qq <- stats::quantile( net3d$nodes[[values_to_cut]] )

# compute theorical interval
breaks <- unique(sort(c(-Inf, c(qq[[1]] , qq[[2]], qq[[3]], qq[[4]], qq[[5]], Inf))))

# apply a color depending (value to cut is indeg  or outdeg)
net3d$nodes$color_deg <- cut(net3d$nodes[[values_to_cut]], breaks = breaks

 , labels = colors_for_nodes[seq_len(length(breaks) -1)], include.lowest = TRUE)

# we have a node coloring factor !
  node_colors <- setNames(net3d$nodes$color_deg, as.character(rownames(net3d$nodes)))

  node_colors <- append(node_colors, factor(levels =color_for_na_link ))
  # MATCH the source node if we color outdeg, or the target node for indeg coloring
if(values_to_cut ==  "indeg") {considered_node = "target" ; alt_node  = "source" } # the "target" or "to" node
if(values_to_cut ==  "outdeg"){considered_node = "source"; alt_node  = "target"} # the "target" or "to" node

  net3d$links$color_deg  <- node_colors[match(net3d$links[[considered_node]], names(node_colors))]

  # net3d$links$color_deg  <- node_colors[match(net3d$links$source, names(node_colors))]

  na_idx <- is.na(net3d$links$color_deg) #those have no matched from "from" first col'

    # couleur lien entrant (détection depuis 'to' = lien entrant !) alt_node
  if(any(na_idx) & !is.null(color_for_na_link)){ net3d$links$color_deg[na_idx] <- color_for_na_link }
  # or we color also the other link style
  if(any(na_idx) & is.null(color_for_na_link)){ net3d$links$color_deg[na_idx] <- node_colors[match(net3d$links[[alt_node]][na_idx], names(node_colors))] }
    # net3d$links$color_deg[na_idx] <- node_colors[match(net3d$links$target[na_idx], names(node_colors))]

  # DEFINITION DES COULEURS DE NOEUDS (net3d$nodes$type)
  # on regarde si le user veut définir le type ou non

  # colors_for_nodes = c("grey", "black", "orange",  "red") # par défaut un truc du genre
  range_qq_txt <- paste0(unique(qq[1:5]), collapse = ", ")
  # enfin on doit faire une instruction javascript pour tweaker notre graphique
  # soit sur base d'une échelle linéaire :
  not3D_colourscale_JS = networkD3::JS(paste0('d3.scaleLinear().domain([', range_qq_txt
                                              , ']).range(['
                                              , paste0('"', colors_for_nodes, collapse = '", ' )
                                              , '"]);') )
  # soit ordinale !
  # networkD3::JS('d3.scaleOrdinal(d3.schemeCategory10)')

  ####UN FORCE NETWORK ####
  reseau_dataviz = networkD3::forceNetwork( legend = T

                                            ,  opacityNoHover = 0.9  # Empêche le changement de flou à l'hover

                                            , Nodes = net3d$nodes
                                            , NodeID = "name", charge = -5
                                            , Group = "outdeg",
                                            Nodesize = "indeg"

                                            #LES LIENS :
                                            ,  Links = net3d$links
                                            , linkWidth = networkD3::JS("function(d) { return 1; }")  # Largeur des liens
                                            , arrows = T,  Source = "source", Target = "target"
                                            ,  linkColour =  net3d$links$color_deg
                                            , opacity =1, bounded = T
                                            , zoom = TRUE
                                           , colourScale = not3D_colourscale_JS)





  # ,  colourScale =networkD3::JS("d3.scaleOrdinal().domain([1, 3]).range(['#FF5733', '#33FFCE']);")
  # Injecter du JavaScript pour donner un titre à la légende
  reseau_dataviz <-  htmlwidgets::prependContent(reseau_dataviz,  htmltools::tags$h1(titre_h1) )
  # "Un lien sortant indique qu'une fonction en déclenche une autre"
  if(!is.null(sous_titre) ){
    reseau_dataviz <-   htmlwidgets::prependContent(reseau_dataviz  , htmltools::tags$h2(sous_titre) )
  }
  if(!is.null(mini_texte) ){
    reseau_dataviz <-  htmlwidgets::prependContent(reseau_dataviz  , htmltools::tags$h3(mini_texte) )
  }
  # retourne une liste et notre dataviz (html widget)
  return(list(net3d_list = net3d, reseau_dataviz = reseau_dataviz))

}
