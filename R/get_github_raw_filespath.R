#' Get GitHub File URLs Matching a Pattern
#'
#' This function retrieves the full URLs of files in a GitHub repository that match a specified pattern.
#'
#' @param repo **(character)** The GitHub repository in the format `"owner/repo"`. Default is `"tidyverse/stringr"`.
#' Return a list if the user have passed a list of named char (each names is a repo of the list passed)
#' @param branch **(character)** The branch to scan for files. Default is `"main"`.
#' @param pattern **(character)** A regex pattern to filter files (default is `"\\.R"`, meaning R scripts).
#' Return a list of named char if the user have passed a list of patterns
#' (NA is returned if a pattern is not associated with github files)
#'
#' @return A character vector of URLs of the matching files (https://raw.githubusercontent.com/).
#' @examples
#' \dontrun{
#' readr_fp <- get_github_raw_filespath(repo = "tidyverse/stringr", pattern = "\\.R")
#' }
#' @export
get_github_raw_filespath <- function(repo = "tidyverse/stringr", branch = NULL, pattern = "\\.R") {

   branches  <- c("main", "master", "develop")
  # if no branches we will try several names :

    if(!is.null(branch)) branches <- branch

# apply several time the func (one per pattern) :
  if(length(pattern) > 1){return(unlist(recursive = T, lapply(X = pattern
                                                , FUN = function(patt){ get_github_raw_filespath(repo = repo, pattern = patt, branch = branch) })) )}
# if several repo, return sapply list (one per repo given * per language founded)
  if(length(repo) > 1){return(sapply(X = repo, FUN = function(repee) get_github_raw_filespath(repo = repee, pattern = pattern, branch = branch)))}

  # and here after we have only a single repo and a single pattern
  repo <- gsub(pattern = "/$", replacement = "", repo)

  # construct an url to api.github :
  if (grepl("^https?://", repo)) {
    direct_access = T# we retrieve that hereafter for crafting the url!
    api_url <- paste0(repo,  "?recursive=1")  #use URL passed
  } else {
    direct_access = F

# read a github public repo FROM API.github
    generate_url <- function(repo, branch) {
# construct api.github url
api_url <- paste0("https://api.github.com/repos/", repo, "/git/trees/", branch, "?recursive=1")

#read json JSON stream
json_data <- paste(readLines(api_url, warn = FALSE), collapse = "")

      #if there is a json (non empty), return it
      if (nchar(json_data) > 0)  return(json_data)
      return(NA)  # if empty return NA (used herafter)
    }

    api_url <- NA
    # trycatch several branches (main, etc.)
json_data <- sapply(branches, function(branch) {

if (!is.na(api_url)) { return(NA) }  #stop if a valid uRL is already here

result <- suppressWarnings(tryCatch({ # try several branch
  json_data <- generate_url(repo, branch) # try to reach api
if (!is.na(json_data)) { api_url <<- json_data  } # Assign the answer  valid uRL found
          json_data  # return json from github
        }, error = function(e) NA) ) # if error return NA
    })
# we have a valid branch if all is good
branch <- names(which(!is.na(json_data)))

# unlist / filter na answers
    json_data <- unlist(json_data[!is.na(json_data)])
  }

  # Extrct files (default pattern = .R files)
  file_paths <- unlist(regmatches(json_data, gregexpr(ignore.case = T , pattern = paste0('"path":"[^"]+', pattern, '"'), text = json_data)))
  file_paths <- gsub('"path":"', "", file_paths) # Supprimer le préfixe "path"
  file_paths <- gsub('"', "", file_paths)       # Nettoyer les guillemets restants

  # construct URLs for files (github anwer relatives path)
  prefix_of_raw_url <- paste0( "https://raw.githubusercontent.com/" , repo, "/", branch, "/")

   raw_urls <- paste0(prefix_of_raw_url, file_paths)

  # we want to verify that github donc trick us with an empty vector
  if(length(raw_urls) == length(repo)){ if(gsub(x = raw_urls,pattern = prefix_of_raw_url , "") == "" ){return(NA)}}

  if(direct_access){ raw_urls <- paste0( repo ,file_paths) }

  return(raw_urls)
}
