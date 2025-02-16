#' Get GitHub File URLs Matching a Pattern
#'
#' This function retrieves the full URLs of files in a GitHub repository that match a specified pattern.
#'
#' @param repo **(character)** The GitHub repository in the format `"owner/repo"`. Default is `"tidyverse/tidyverse"`.
#' @param branch **(character)** The branch to scan for files. Default is `"main"`.
#' @param pattern **(character)** A regex pattern to filter files (default is `"\\.R"`, meaning R scripts).
#'
#' @return A character vector of URLs of the matching files (https://raw.githubusercontent.com/).
#' @examples
#' \dontrun{
#' readr_fp <- get_github_raw_filespath(repo = "tidyverse/readr", pattern = "\\.R")
#' }
#' @export
get_github_raw_filespath <- function(repo = "tidyverse/ggplot", branch = "main", pattern = "\\.R") {

  repo <- gsub(pattern = "/$", replacement = "", repo)

  # construct an url to api.github :
  if (grepl("^https?://", repo)) {
    direct_access = T# we retrieve that hereafter for crafting the url!
    api_url <- paste0(repo,  "?recursive=1")  #use URL passed
  } else {
    direct_access = F
  api_url <- paste0("https://api.github.com/repos/",repo, "/git/trees/", branch, "?recursive=1") }

  #read json JSON stream
  json_data <- paste(readLines(api_url, warn = FALSE), collapse = "")

  # Extrct files (default pattern = .R files)
  file_paths <- unlist(regmatches(json_data, gregexpr(ignore.case = T , pattern = paste0('"path":"[^"]+', pattern, '"'), text = json_data)))
  file_paths <- gsub('"path":"', "", file_paths) # Supprimer le préfixe "path"
  file_paths <- gsub('"', "", file_paths)       # Nettoyer les guillemets restants

  # construct URLs for files (github anwer relatives path)
  raw_urls <- paste0( "https://raw.githubusercontent.com/" , repo, "/", branch, "/", file_paths)
  if(direct_access){ raw_urls <- paste0( repo ,file_paths) }

  return(raw_urls)
}
