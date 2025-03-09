# Given a corpus.list object, clean the comments over several lines and/or inline
clean_comments_from_lines <- function(corpus, delim_pair = NA
                                      ,  char_for_inline_comments = "#"
                                      , .verbose = F){

  #### I. Optionnaly clean multi-lines comments
  if(!is.na(delim_pair)) {

    if(.verbose) cat("\n===> Clean blocks of comments\n")

    codes_and_comments <- separate_commented_lines(texts =  corpus$codes$content
                                                   , delim_pair = delim_pair
                                                   , .verbose = .verbose)
# have answered a df with original text, comments & codelines var' (substract of original text)
# codelines are real code content : add these lines to the codes df
    corpus$codes$content <- corpus$codes$codelines

    # add the comments in the corpus comments df
 comments_to_add <- corpus$codes$content # original informations about the code lines
 comments_to_add$content <- codes_and_comments$comments # comments become the 'content'
 comments_to_add <- comments_to_add[is.na(comments_to_add$content), ] #filter empty entries
n_coms <- nrow(comments_to_add)
 if(n_coms > 0){
 if(.verbose) cat("+", n_coms, "lines of comments to the corpus$comments data.frame")
 corpus$comments <- rbind(corpus$comments, comments_to_add[, colnames(corpus$comments)])
 # we will reorder in the end
 }
  }

old_class <- class(corpus$codes)

corpus$codes <- cbind(corpus$codes , remove_text_after_char(corpus$codes$content
                                                              , char = char_for_inline_comments
                                                              , colname_uncommented = "uncommented"
                                                , colname_commented = "commented") )
# have added "uncommented" & "commented" content from the codes
class(corpus$codes) <- old_class
 # 1) Update the codes 'content' var : will not contain inline comments
 corpus$codes$content <- corpus$codes$uncommented
  corpus$codes$uncommented <- NULL

 # filter out blank lines
    corpus$codes <- filter_if_na(corpus$codes, "content")

    # add comments to the comments df of the corpus.list
  inline_comments_to_add <- which(!is.na(corpus$codes$commented))
# stop if no comments
  if(length(inline_comments_to_add) == 0) return(corpus)

# we have a 'commented' var and we wan't these comments to be a "content" var of the comments df
  add_comments <- corpus$codes[inline_comments_to_add, ]
  add_comments$content <- add_comments$commented

  # 2) or rbind these comments to the corpus.comments
   add_comments <- add_comments[, colnames(corpus$comments)]

   corpus$comments <- rbind(corpus$comments, add_comments)

   corpus$comments <- corpus$comments[order(corpus$comments$file_path,  corpus$comments$line_number), ]

   corpus$comments <- filter_if_na(corpus$comments, "content")
   corpus$comments <-   corpus$comments[!duplicated( corpus$comments), ]

return(corpus)
}
