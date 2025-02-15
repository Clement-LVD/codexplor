get_igraph_from_df <- function(edgelist
                              , directed =T
                              ,filter_min_centrality = 0
  , keep_only_by_regex = NULL
    , supp_by_regex = "get_req_"
    , made_subgraph_from_a_regex = NULL
    , x_level_out_for_subgraph = 5
    , y_level_in_for_subgraph = 2
, clean_egolink = T
    , ... # option pour un grep qui selectionne l bon node !
){
  colnames(edgelist)[1:2] <- c("from", "to")

  nett <- get_text_network_from_files()
      #### 0) chopper les données ####
    pacman::p_load(igraph) # networkD3, si on fait des dataviz

if(clean_egolink){ edgelist <-  edgelist[ which(edgelist$from != edgelist$to), ] }

    # on fait un graph avec notre edgelist de fichiers
    g <- igraph::graph_from_data_frame(edgelist, directed =directed)

      noeuds_connectes <- igraph::V(g)[which(igraph::degree(g, mode = 'total')  > filter_min_centrality)]  # Conserve uniquement ceux connectés
      # 4. Créer un sous-graphe en utilisant uniquement les nœuds et les liens valides
      g <- igraph::induced_subgraph(g, vids = noeuds_connectes)

    # et on a ENCORE un filtre avant de calculer nos stats =>
    if(!is.null(made_subgraph_from_a_regex)) {

        names_nodes <- names(igraph::V( g))

        names_nodes <- names_nodes[grep(x = names_nodes, pattern =  made_subgraph_from_a_regex, ignore.case = T, ...)]

        start_node = names_nodes


      if (start_node %in% names(igraph::V(graph))) {


      # Récupérer les nœuds atteignables en sortie (x niveaux)
      out_nodes <- igraph::ego( g, order = x_level_out_for_subgraph,
                               nodes = start_node,
                               mode = "out")[[1]]

      # Récupérer les nœuds atteignables en entrée (y niveaux)
      in_nodes <- igraph::ego( g, order = y_level_in_for_subgraph, nodes = start_node, mode = "in")[[1]]

      # Fusionner les deux ensembles de nœuds
      selected_nodes <- unique(c(out_nodes, in_nodes))

      # Créer le sous-graphe
      g <- igraph::induced_subgraph(graph, vids = selected_nodes)
 }
      # return(subgraph)
    }

    # 2. Faire un mini bilan après filtres !
    # degres_des_noeuds <-  igraph::degree(g, mode = "all")
    indegres_des_noeuds <-  igraph::degree(g, mode = "in")
    outdegres_des_noeuds <-  igraph::degree(g, mode = "out")

    # Créer un data.frame avec les noms des nœuds et leur degré
    df_nodes <- data.frame(
      node = names(indegres_des_noeuds),  # Les noms des nœuds
      indeg = indegres_des_noeuds        # La centralité de degré pour chaque nœud
      , outdeg = outdegres_des_noeuds
    )

    df_nodes <- dplyr::arrange(df_nodes, desc(indeg))
    # on va retourner cet objet au final => un mini bilan!

    # un mega message ac la table juste ci-dessus pour faire patienter le user
    {cat("\nRESULTATS => \n❗ ")
      cat(sep = "\n👉",
          paste0("in = ",  df_nodes$indeg, " / out = ", df_nodes$outdeg," => " ,df_nodes$node)
      )
      cat("\nindeg - Degré entrant (usage par d'autres fonctions = dépendance pour d'autres)","\noutdeg - Degré sortant (usage d'autres fn = 'haut-niveau')")
    }

    return(g)
  }
