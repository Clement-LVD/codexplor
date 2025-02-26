

#### 1) lines text-metrics ####
compute_nchar_metrics <- function(text, nchar_colname = "n_char_line", nchar_nospace_colname = "n_char_wo_space_line"){

result <-   data.frame(nchar_colname = as.integer(nchar(text)),

           n_char_wo_space_line = as.integer(nchar(gsub(x = text,pattern =  " |\n", ""))))

colnames(result) <- c(nchar_colname,nchar_nospace_colname )

return(result)
  }

####2) construct list of files path ####
get_list_of_files <- function(local_folders_paths = NULL, repos = NULL
                              , file_ext = "R"
                              , local_file_ext = paste0(file_ext, "$")
                              , pattern_to_exclude_path = NULL ){
files_path = NULL
urls <- NULL
  # 1} get urls from github 1st
  if(!is.null(repos)){ urls <- get_github_raw_filespath(repo = repos, pattern = file_ext) }

  if(!is.null(local_folders_paths)){ #get local filepaths

    pattern = paste0(collapse = "|", local_file_ext)

    files_path <- unlist(sapply(local_folders_paths, FUN = function(path){

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
