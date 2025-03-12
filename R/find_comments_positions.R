### V2
# texts = c("text with /* commented content */ and other commented stuff /* here */ and even /* comments */ in comments and /* comments that never ending"
#                  , "second text with comment because of the previous never ending line", "and this is a commented line to */ with a little piece of code here !")
#
# find_comments_positions( texts, delim_pair = c( "/*" = "*/" ) )

# and we are ready for direct extraction
#' @importFrom utils txtProgressBar setTxtProgressBar
find_comments_positions <- function(texts  , delim_pair = c("/*" = "*/"), .verbose = T) {


  if(length(delim_pair) > 1) stop('Several delimiters paired chars. passed ! You have to indicate a valid delim_pair such as c("/*" = "*/")')

  # we will replace Inf value by the total line to extract when returning a standard df :
  replace_inf <- function( std_df, textt = texts ){

     std_df$start[std_df$start == -Inf] <- 0 #line with a -Inf become 0

    ends_inf <- which(std_df$end == Inf) # line with an end Inf become nchar(texts[i])
   index_texts_ends_inf <- std_df$text_id[ends_inf] #and te

   std_df$end[ends_inf] <- nchar(textt[index_texts_ends_inf])

   return(std_df)
     }

  # 2) List delimiters : return a df of position with these char (type 'open' and 'close') # only one line of text
  get_open_close_patterns_positions <- function(text,
                                                delim_pair = delim_pair) {

     # Helper function to get positions of a single pattern (open or close)
    get_positions <- function(pattern, text, type = "pattern", pair_name) {

      pos <- gregexpr(pattern, text, fixed = TRUE)[[1]]

      if (pos[1] != -1) { #if there IS matches !

        return(data.frame(symb = rep(pair_name, length(pos)),
                          type = rep(type, length(pos)),
                          pos = pos,
                          len = rep(nchar(pattern), length(pos)),
                          stringsAsFactors = FALSE)
        )
      }
      # IF no match return a DF with 0 rows and 0 values
      return(data.frame(symb = character(0),
                        type = character(0),
                        pos = numeric(0),
                        len = numeric(0),
                        stringsAsFactors = FALSE))
    }

    # Process each delimiter pair : each names() is an 'open' char
    results <- lapply(names(delim_pair), function(pair_name) {
      open_pattern <- pair_name
      close_pattern <- delim_pair[[pair_name]] # select our closing char
      open_df <- get_positions(open_pattern, text, "open", pair_name) # return a df of open char
      close_df <- get_positions(close_pattern, text , "close", pair_name) # return a df of close char
      rbind(open_df, close_df)
      #modality "open" and "close" are hardcoded herafter !
    })
    # we have constructed a list of df (each row is an element of a delim_pair passed by the user )
    # Note that the symb column report for the opening character
    # ('type' column indicate if this is an opening or closing char)
    # Combine and sort the results

    res <- do.call(rbind, results) # res : agregated df

      return(res[order(res$pos), ]) #sort by position (column pos')
  }
  # we count the closing and opening char in a df :
  # positions_std_df <-  get_open_close_patterns_positions(texts[1], delim_pair)

  ##3) We have to compute an interval from our previous df of position (only one line of text)
compute_intervals_for_a_line <- function(positions_std_df, symb ) {
# given a dataframe of positions with a "type' col for 'open' and 'close' char
  # and a 'pos' numeric (position within vector) and a len for the length of the delimiter

  # Must have a col symb (for key), a start and end column ! from the previous func'

  empty_df <-  data.frame(symb = character(0),  start = numeric(0),   end =  numeric(0),   stringsAsFactors = FALSE  )

  if(nrow(positions_std_df) == 0) return(empty_df)

  positions_df <- positions_std_df[positions_std_df$symb  == symb, ]

  # within a type of symb :
  opens <- positions_df[positions_df$type == "open", ]
  closes <- positions_df[positions_df$type == "close", ]

  close_missing <-  nrow(opens) - nrow(closes)

# add an Inf closing for ENDING the chain properly
if(close_missing > 0){ fake_closes  <- data.frame(symb = symb, type = "close", pos = rep(Inf, close_missing), len = rep(1, close_missing), stringsAsFactors = FALSE)

positions_df <-  rbind(positions_df,fake_closes)
closes <- positions_df[positions_df$type == "close", ] # update close positions_df
}

# add a '-Inf' opening for OPENING the chain properly
  if(close_missing < 0){ fake_open  <- data.frame(symb = symb, type = "open", pos = rep(-Inf, -close_missing), len = rep(1, -close_missing), stringsAsFactors = FALSE)

  positions_df <-  rbind(positions_df,fake_open)
  opens <- positions_df[positions_df$type == "open", ] # update open positions_df
  }

    # match start and ends for each pair :
    intervals_df <- data.frame(
      symb = opens$symb, # for example 2 identical symbols of opening !
      start = opens$pos, #we have their starting pos !
      end = closes$pos + (closes$len - 1), #the 1st char is already included in "ends"
      stringsAsFactors = FALSE
    )

return(intervals_df) #filter out nested intervals
}

# e.g.,
# compute_intervals_for_a_line( get_open_close_patterns_positions(texts[5], delim_pair), symb = names(delim_pair)[1] )

##### LOGIC OF THE FUNCTION AND RETURN ####
# 4) RETURN all the intervals we have to extract for multiple texts
# we will RETURN all the intervals where we have to extract within each texts passed
if (.verbose) {pb <- utils::txtProgressBar(min = 0, max = 100, style = 3) }

df  <-  lapply(seq_along(texts), function(i) {

  text <- texts[i]  # Select i-nth text

  if(nchar(text) == 0 ) return(data.frame(symb = character(0), start = character(0), end = character(0)))

  df <- get_open_close_patterns_positions(text, delim_pair)

if(nrow(df) == 0 ) return(data.frame(symb = character(0), start = character(0), end = character(0)))

   df <-  compute_intervals_for_a_line(df, symb = names(delim_pair))

    if (nrow(df) > 0) df$text_id <- i

   if (.verbose) utils::setTxtProgressBar(pb, i / length(texts)*100 )

  return(df)
})

df <- do.call(rbind, df)
if (.verbose) close(pb)

# if no delim : return the texts
if(nrow(df) == 0) return(df)

# and finally we have certainly missing lines : some have "Inf" and "-Inf" symbols
# from the compute_intervals_for_a_line function that symbolize a never ending commented line
missing_ids <- setdiff(1:max(df$text_id), df$text_id)
existing_ids <- df$text_id

if(length(missing_ids) == 0) return(replace_inf(df))
# check if it's a normal missing line or a fully commented one :


valid_missing_ids <- missing_ids[sapply(missing_ids, function(id) {
  # e.g., if missing 1st line (non-commented) : id is 1
prev_max_ids <- df$text_id[ df$text_id < id] # take all preceding ids
# so if no texts are preceding (length = 0) we will return NA into previous max_id
prev_max_id <- if (length(prev_max_ids) > 0) max(prev_max_ids, na.rm = TRUE) else NA

# return the previous max value if not an NA value, for min and max
prev_max_value <- if (!is.na(prev_max_id)) df$end[df$text_id == prev_max_id] else NA
# the maximum "end" value of the comments char in the texts BEFORE our current text !

# same for superior to id
 next_min_ids <- existing_ids[existing_ids > id] #take all following ids
 next_min_id <- if (length(next_min_ids) > 0) min(next_min_ids, na.rm = TRUE) else NA
# retain the less important or return NA
# return the start value for the corresponding id (min of the following texts id)
 next_min_value <- if (!is.na(next_min_id)) df$start[df$text_id == next_min_id] else NA

 #  we return only those with cool values (not Inf for the max and -Inf)
 any(prev_max_value == Inf, na.rm = TRUE) & any(next_min_value == -Inf, na.rm = TRUE)

})]

# if there is only normal codes lines :
if(length(valid_missing_ids) == 0) return(replace_inf(df))

# Or we add commented lines (supposed to be "commented' on several lines)
returned_df <- rbind(df, do.call(rbind, lapply(valid_missing_ids, function(i)
    data.frame(symb = "/*", start = 0, end = nchar(texts[i]), text_id = i)
  )))

returned_df <- returned_df[order(returned_df$text_id, returned_df$start, na.last = TRUE), ] # reorder

return(replace_inf(returned_df)) #in the begining of this func'
}

