
#### CORPUS.LIST TREATMENT METHODS ####
# a corpus.list is a list of dataframes

#' add network-metrics to nodelist & summarise a corpus.list
#'
#' @param corpus `corpus.list` `list` of dataframes created by `construct_corpus()`.
#' @return A dataframe of class 'corpus.list'.
add.stats.corpus.list <-  function(corpus) {
  if (!inherits(corpus, "corpus.list")) stop("Not a 'corpus.list' object")

  if(!"internal.dependencies" %in% names(corpus)) return(corpus)
# if there is an internal.dependencies network :

    # 1) add degrees to the files
indeg_outdeg_vec <- lapply(corpus$files$file_path, FUN = function(path){
  indeg <- length(unique(corpus$internal.dependencies$to[corpus$internal.dependencies$from == path] ) )
  outdeg <-length(unique(corpus$internal.dependencies$from[corpus$internal.dependencies$to == path] ) )
return(c(indeg,outdeg))
  } )

degrees <- data.frame(do.call(rbind, indeg_outdeg_vec))
colnames(degrees) <- c("indeg_fn", "outdeg_fn")

# add these degrees to corpus files
corpus$files <- .construct.nodelist(cbind(corpus$files, degrees))

return(corpus)
}
