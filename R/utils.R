####1) construct list of files path ####
get_list_of_files <- function(folders = NULL, repos = NULL
                              , file_ext = "R"
                              , local_file_ext = paste0(file_ext, "$")
                              , pattern_to_exclude_path = NULL ){
files_path = NULL
urls <- NULL
  # 1} get urls from github 1st
  if(!is.null(repos)){ urls <- get_github_raw_filespath(repo = repos, pattern = file_ext) }

  if(!is.null(folders)){ #get local filepaths

    pattern = paste0(collapse = "|", local_file_ext)

    files_path <- unlist(sapply(folders, FUN = function(path){

      list.files(recursive = T, full.names = T, path = path, pattern = pattern)
    }))

  }

  files_path <- as.character(unlist(c(files_path, urls)) )#the files.path + url

  # eliminate some patterns (e.g., '.Rcheck' for R project)
  files_to_exclude = NULL

  if(!is.null(pattern_to_exclude_path)) files_to_exclude = grep(x=files_path, pattern = pattern_to_exclude_path)

  if(length(files_to_exclude)>0) files_path <- files_path[-files_to_exclude]

return(files_path)

}


#### cleaning paths and urls ####
# we'll clean paths AFTER the Citations Network
clean_paths <- function(df
                        , file_path_col = 1
                        , pattern_to_exclude_path = NULL
                        , ignore_match_less_than_nchar = 3
                        , pattern_to_remove = "https://raw.githubusercontent.com/"
                        , ...
){


  # file path 1st col / line_number 2nd / content is the 3rd col' /

  # preparing the corpus : clean the files path
  if(is.character(pattern_to_remove)){

    # force remove a pattern from the 1st_col
    df[[file_path_col]] <- gsub(pattern = pattern_to_remove, "", x = df[[file_path_col]])

  }

  if(length(df[[file_path_col]]) == 0) return(df)


  # 4) return a list (!!)
  return(df)

}

