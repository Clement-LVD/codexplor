### apply a functions that take a single vector
# to a dataframe by group : vector is separated according
# to a group_col value in the df and the vector_col is given
# to the func() given by the user
# e.g., we want to group by document (file path)
# the 1st col passed is turned into a VECTOR from the df (!!)
process_vector_on_df_by_group <- function(df, group_col, func, vector_col = "content", ...) {

  old_class <- class(df) # preserve class
  # 1. Add an identifier to preserve the original order of rows
  df$.id_order <- seq_len(nrow(df))

  # 2. Split the dataframe by the grouping key (e.g., file_path)
  df_split <- split(df, df[[group_col]])

  # 3. Apply the function to each group using the designated column (vector_col)
  processed_list <- lapply(df_split, function(sub_df) {
    # Apply the user-provided function to the column of text content
    result <- func(sub_df[[vector_col]], ...)

    # Ensure the result is returned in the same order as the input (no reordering)
    # If the result is a dataframe with multiple columns, add them to the original df
    if (is.data.frame(result)) {
      # Ensure we keep the order of rows intact
      result <- result[order(sub_df$.id_order), , drop = FALSE]
    }
# If it's just a vector or single column result, bind it back (blindy)
cbind(sub_df, result) #and return that
  })

  # 4. Reassemble the dataframe into one and reorder by the original order
  df_final <- do.call(rbind, processed_list)

  # Reorder the dataframe to match the original order of rows
  df_final <- df_final[order(df_final$.id_order), ]
# since we've split by group we have maybe lost the order

  # Remove the temporary column used for ordering
  df_final$.id_order <- NULL

  class(df_final) <- old_class

  return(df_final)
}


#### 0) filter blank lines of a df on a col ####
filter_if_na <- function(df, col_to_verify){

  lines_to_filter_out <- which(is.na(df[[col_to_verify]]))

if(length(lines_to_filter_out) > 0) df <- df[-lines_to_filter_out, ]
return(df)}

#### 0) remove comments ####
# Function to remove text after a specific character, excluding content inside quotes
remove_text_after_char <- function(text, char = "#"
                                   ,colname_uncommented = "uncommented"
                                   , colname_commented = "commented") {

   result <- lapply(text, function(line) {

    pos <- regexpr(char, line)
    if (pos == -1) return(data.frame(text = line, comment = NA))
    # If no char (#) is found, return the original line and NA

    # text BEFORE the first #
    before_hash <- substr(line, 1, pos - 1)

    # Comptabiliser les guillemets (") ou apostrophes (') avant le #
   quotes <- gregexpr('["\']', before_hash)

   quote_count <- length(which(quotes[[1]] != -1))
    # If no count at all before remove text after #
    if (quote_count == 0 | quote_count %% 2 == 0) {
return(data.frame(text = substr(line, 1, pos - 1),
                        comment = substr(line, pos, nchar(line) ))
      )
    } #erased text is maybe in a line between " & ' but osef
     # Otherwise, return the original line (if the quote count is odd)
    return(data.frame(text = line, comment = NA))
  })

  # Convert the list into a data frame
  result_df <- do.call(rbind, result)

  colnames(result_df) <- c(colname_uncommented, colname_commented)

  return(result_df)
}




#### 1-A.1.) Count opening and closing characters per line
# used in the next func :
# text = c(" test /* commentaire */ /* debut commenté", "commente ", " */ encore test but this /* comment */ ")
# count_opening_and_closing_chars_level(text, open = "/\\*", close = "\\*/")
# text <- "char '\\{' quoted that we don't want to match {and a real parenhesis}"

# count_opening_and_closing_chars_level(text, escape_char = "\\\\")

# text = c(" test 'commentaire ' debut commenté", 'commente ', ' "  encore test but this /* comment */ " ')
# count_opening_and_closing_chars_level(text,open = '\\"', close = "'")

count_opening_and_closing_chars_level <- function(texts, open = "\\{", close = "\\}", escape_char = NULL) {

  if(!is.null(escape_char)){
    escape_char <- fix_escaping(num_escapes = 4, special_chars = "\\",text = escape_char) #we are in r

  open <- paste0("(?<!" ,escape_char, ")", open); close <-  paste0("(?<!" ,escape_char,  ")", close)
  }

  # for a given entry and a given char : count the occurences of this char
  count_occurrences <- function(line, pattern) {
    if (is.na(line)) return(0)
    matches <- unlist(gregexpr(pattern, line, perl = TRUE))
    return(max(0, length(which(matches != -1))))
  } # return a valid count

# count opening and closing char with that func :
  opens <- sapply(texts, count_occurrences, pattern = open)
  closes <- sapply(texts, count_occurrences, pattern = close)

  # determine a level at the end of each line :
  level <- cumsum(opens - closes)
  # return a dataframe for each texts (row) :
  data.frame(line_number = seq_along(texts),
             open_count   = opens,
             close_count  = closes,
             level_end_of_line = level)
}
# THE LEVEL OF THE LAST LINE should be 0 in a normal programming file

# 1.A.2.) Extract text that is NOT between the specified separators.
# text = c("test { commentaire }   debut {commenté", "commente ", "*/ encore test } /* comment */ ")
# extract_text_outside_separators(text) #, open_sep = "\\*/", close_sep = "/\\*"

# Main function: extract text NOT inside the separators.
extract_text_outside_separators <- function(texts, open_sep = "\\{", close_sep = "\\}", add_infos_when_repairing = NULL, escape_char = NULL) {
  # Balance the text if needed by appending extra closing characters
  df <- count_opening_and_closing_chars_level(texts, open = open_sep, close = close_sep, escape_char = escape_char)
  extra_levels <- df$level_end_of_line[nrow(df)]

    # Only append closing characters if extra_levels is greater than 0
    if (extra_levels > 0) {
      cat("\n"); cat("Content is fixed by adding", extra_levels, "closing separator(s)"); cat(texts)

      if(!is.null(add_infos_when_repairing)) cat("\n=> " , add_infos_when_repairing, "\n")

       actual_close <- sub("^\\\\", "", close_sep)
      # Ensure we do not append anything when extra_levels is 0 or negative
      texts[length(texts)] <- paste0(texts[length(texts)], paste(rep(actual_close, extra_levels), collapse = ""))
    }
  # send a warning if all the text is returned
    if (extra_levels < 0) {
      warning("Text has extra closing separators (unexpected negative levels).")

if(!is.null(add_infos_when_repairing)) warning("\n => " , add_infos_when_repairing)

    }

  # Use recursive regex if separators are literal "{" and "}"
  if (open_sep == "\\{" && close_sep == "\\}") {
    # This pattern matches balanced braces (requires PCRE recursion support)
    pattern <- "\\{(?:(?>[^{}]+)|(?R))*\\}"
  } else {
    # Fallback non-greedy pattern for simple (non-nested) cases
    pattern <- paste0(open_sep, ".*?", close_sep)
  }

  # Remove all text enclosed by the separators
  cleaned_text <- gsub(pattern, "", texts, perl = TRUE)

  # Final cleanup: collapse spaces and trim.
  cleaned_text <- gsub("\\s+", " ", cleaned_text)
  trimws(cleaned_text)
}

# Example usage:
# text_lines <- c(  "This is {an {example} of} text",  "with {nested separators} and another {block}.",
  # "A line with an {unclosed separator" )

# extract_text_outside_separators(text_lines, open_sep = "\\{", close_sep = "\\}")

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

return(unique(files_path))

}


#### cleaning paths and urls ####
# we'll clean paths AFTER the Citations Network
# and only if there is a single folder or repos

# givin a test <- clean_paths(corpus$codes)
clean_paths <- function(df
                      , pattern_to_remove = NULL
                     , github_pattern_to_remove = "https://raw.githubusercontent.com/"
                        , ...
){

  if(is.data.frame(df) ){
    old_class <- class(df)
    new_df <- apply(simplify =T, df, MARGIN = 2, FUN = function(vector){ clean_paths(df = vector  , pattern_to_remove = NULL) } )
   new_df <- as.data.frame(new_df)
     class(new_df) <- old_class
    }
  # file path 1st col / line_number 2nd / content is the 3rd col' /

  if(!is.character(df)) return(df)

  vector = df
  # force remove a pattern
  if(is.character(pattern_to_remove)){vector  <- gsub(pattern = pattern_to_remove, "", x = vector)  }
  if(is.character(github_pattern_to_remove)){vector  <- gsub(pattern = github_pattern_to_remove, "", x = vector)  }

  return(vector)

}

#### 2) inverted intervals ####
reverse_intervals <- function(start, end, n_max) {
  # Vérifier que start et end sont bien de la même longueur
  if (length(start) != length(end)) stop("start and end don't have the same length : they should be.")

  # user have passed an interval, e.g., start[1]:end[1] are non-desired values

  new_starts <- c(1, end + 1)

    # Fin des nouveaux intervalles (juste avant chaque début d'intervalle suivant)
  new_ends <- c(start - 1, n_max)

  # Supprimer les intervalles invalides (cas où start[i] == end[i] + 1)
  valid <- new_starts <= new_ends

  # Retourner le dataframe des intervalles inversés
  return(data.frame(start = new_starts[valid], end = new_ends[valid]))
}

