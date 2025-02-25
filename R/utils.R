

#### 1) lines text-metrics ####
compute_nchar_metrics <- function(text, nchar_colname = "n_char_line", nchar_nospace_colname = "n_char_wo_space_line"){

result <-   data.frame(nchar_colname = as.integer(nchar(text)),

           n_char_wo_space_line = as.integer(nchar(gsub(x = text,pattern =  " |\n", ""))))

colnames(result) <- c(nchar_colname,nchar_nospace_colname )

return(result)
  }
