
#### CORPUS.LIST TREATMENT METHODS ####
# a corpus.list is a list of dataframes

#' add network-metrics to nodelist & summarise a corpus.list
#'
#' @param corpus `corpus.list` `list` of dataframes created by `construct_corpus()`.
#' @return A dataframe of class 'corpus.list'.
add.stats.corpus.list <-  function(corpus) {
  if (!inherits(corpus, "corpus.list")) stop("Not a 'corpus.list' object")

  if(!any(grepl(".network",x =  names(corpus)))) return(corpus)
# if there is a network :

    # 1) add degrees to the files and functions df
corpus <-  add_degrees_to_corpus.nodelist(corpus)

return(corpus)
}

# add degrees to Df of the corpus.list
add_degrees_to_corpus.nodelist <- function(corpus
                                           , df_name = c( "files","functions")
                                           , key_name =  c("file_path", "name")

                                           ){

  if (length(df_name) > 1) {
    return(Reduce(function(corp, i) {
      add_degrees_to_corpus.nodelist(corp, df_name = df_name[i], key_name = key_name[i])
    }, seq_along(df_name), init = corpus))
  }


  network_name = paste0(df_name, ".network")

  # 1) add degrees to the files
  indeg_outdeg_vec <- lapply(corpus[[df_name]][[key_name]], FUN = function(path){
    indeg <- length(unique(corpus[[network_name]]$to[corpus[[network_name]]$from == path] ) )
    outdeg <-length(unique(corpus[[network_name]]$from[corpus[[network_name]]$to == path] ) )
    return(c(indeg,outdeg))
  } )

  degrees <- data.frame(do.call(rbind, indeg_outdeg_vec))
  colnames(degrees) <- c("indeg_fn", "outdeg_fn")

  corpus[[df_name]] <- .construct.nodelist(cbind(corpus[[df_name]], degrees))

  return(corpus)

}
