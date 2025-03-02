
#### CORPUS.LIST TREATMENT METHODS ####
# a corpus.list is a list of dataframes

#' add network-metrics to nodelist & summarise a corpus.list
#'
#' @param corpus `corpus.list` `list` of dataframes created by `construct_corpus()`.
#' @return A dataframe of class 'corpus.list'.
add.stats.corpus.list <-  function(corpus) {
  if (!inherits(corpus, "corpus.list")) stop("Not a 'corpus.list' object")

  # 1) add degrees
indeg_outdeg_vec <- lapply(corpus$nodelist$file_path, FUN = function(path){
  indeg <- length(unique(corpus$citations.network$to[corpus$citations.network$from == path] ) )
  outdeg <-length(unique(corpus$citations.network$from[corpus$citations.network$to == path] ) )
return(c(indeg,outdeg))
  } )

degrees <- data.frame(do.call(rbind, indeg_outdeg_vec))
colnames(degrees) <- c("indeg", "outdeg")
corpus$nodelist <- cbind(corpus$nodelist, degrees)

return(corpus)
}
