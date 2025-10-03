
#### CORPUS.LIST TREATMENT METHODS ####

# a corpus.list is a list of dataframes: used herafter
#' Add comments and codeslines metrics
#' @param corpus `corpus.list` - `list` of dataframes created by `construct_corpus()`.
#' @param .verbose `logical` - Add messages if `TRUE`.
#' @return A dataframe of class 'corpus.list'.
add.lines.metrics.to.corpus.files <- function(corpus, .verbose = T){
  if (!inherits(corpus, "corpus.list")) stop("Not a 'corpus.list' object")

  # compute n lines over a file_path key
  compute_n_lines <- function(df) {

    count_by_grp <- by(df$line_number, df$file_path, function(x) length(unique(x)))

    return(
      data.frame(file_path = names(count_by_grp)
                 , n_lines  = as.vector(count_by_grp))
          )

    }

n_commentslines <-   compute_n_lines(corpus$comments)
colnames(n_commentslines)[2] <- "n_lines_comments"

n_codelines <-  compute_n_lines(corpus$codes)
colnames(n_codelines)[2] <- "n_lines_codes"

result <- merge(n_codelines, n_commentslines, by = "file_path", all = TRUE)

corpus$files <- merge(corpus$files, result, by = "file_path", all.y = F, all.x = T)

# add lines-distance metrics (from lines to files)
if(.verbose) cat("|==> Add files network : Levenshtein-distance lines similarity\n")
results <- compute_similarity_network(corpus$codes, group_col = "file_path", text_col = "content")
# add intrafile lines-level (mean) similarity metrics
corpus$files  <- merge(corpus$files  , results$nodelist_files, by.x = "file_path", by.y = "file", all.x = T, all.y = F)
# todo : add lines similarity network
corpus$files.similarity.network <- results$edges_files_similarity

return(corpus)
}

#' add network-metrics to nodelist & summarise a corpus.list
#'
#' @param corpus `corpus.list` - `list` of dataframes created by `construct_corpus()`.
#' @param .verbose `logical` - show messages if `TRUE`.
#' @return A dataframe of class 'corpus.list'.
add.stats.corpus.list <-  function(corpus, .verbose = T) {
  if (!inherits(corpus, "corpus.list")) stop("Not a 'corpus.list' object")

   corpus <- add.lines.metrics.to.corpus.files(corpus, .verbose)
  # 1) add degrees to the files and functions df
  if(any(grepl(".network",x =  names(corpus)))) corpus <-  add_degrees_to_corpus.nodelist(corpus)

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
    # for each file : FROM our path TO a unique number of fn (outdeg)
    # => is equivalent to filter out the 'to' by keeping only lines 'from' our path
    outdeg <- length(unique(corpus[[network_name]]$to[corpus[[network_name]]$from == path] ) )
    # inverted logic :filter out the 'from' by keeping only when it's to our path : indeg of our path
    indeg <- length(unique(corpus[[network_name]]$from[corpus[[network_name]]$to == path] ) )

    return(c(outdeg,indeg)) #order hardcoded
  } )

  degrees <- data.frame(do.call(rbind, indeg_outdeg_vec))
  colnames(degrees) <- c("outdeg_fn","indeg_fn" )

  corpus[[df_name]] <- .construct.nodelist(cbind(corpus[[df_name]], degrees))

  return(corpus)

}
