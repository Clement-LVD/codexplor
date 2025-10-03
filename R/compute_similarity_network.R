#' Compute a similarity network
#'
#' Based on a lines to lines Levenchtein distance (% of similarity) between lines.
#' Assuming lines are from several files. Used for adding stats to corpus (methods_stats)
#' @param df `data.frame` - A data.frame with a vector of char and a group col
#' @param group_col `character` - Name of the group vector
#' @param text_col `character` - Name of the text column vector, i.e. the vector used for compute similarity
#' @importFrom stats aggregate
compute_similarity_network <- function(df, group_col, text_col){

  dist_network <- .Call("pairwise_levenshtein", df[[text_col]])
# lines-metrics : answer an edgelist of position in the vector
  dist_network$from_file <- df[[group_col]][dist_network$from]
  dist_network$to_file <- df[[group_col]][dist_network$to]

  # --- 1. intra-file (nodelist) ---
  intra <- dist_network[dist_network$from_file == dist_network$to_file, ] # intrafile metrics

  res <- by(intra$similarity, intra$from_file, mean)

   nodelist <- data.frame(
    file = names(res),
    intrafile_codelines_similar_mean = as.numeric(res)
  )
    # nodelist
  # todo : add lines similarity network

  # --- 2. extra-file (edgelist) ---
  extra <- dist_network[dist_network$from_file != dist_network$to_file, ]

  #order before a fusion ! (A,B) = (B,A)
  extra$from <- pmin(extra$from_file, extra$to_file)
  extra$to <- pmax(extra$from_file, extra$to_file)

  # mean of similarity by pair (from = to)
  edgelist <- stats::aggregate(similarity ~ from + to, data=extra, FUN=mean)
  # edgelist
  results <- list(edges_lines_similarity = dist_network
                  , edges_files_similarity = edgelist
                 , nodelist_files =  nodelist )
  return(results)
}
