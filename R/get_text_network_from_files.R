get_text_network_from_files <- function(folder_path = getwd()

    , filter_first_match_by_nchar = 3

    , filter_original_result_not_in = "" #c("server")

   ,  suffix_for_regex_from_the_text = ""# pas une lettre ou un chiffre !

   , prefix_for_regex_from_the_text = ""

  , regex_to_exclude_files_path = NULL #"test-"

 , filter_2nd_match_unmatched_lines = T

   , filter_first_match_results = T

   , filter_ego_link = T

 , file_path_from = 'from'
 , file_path_to = 'to'
 , match1_colname =  "first_match"

 ,  match2_colname ="second_match"
 , line_number_match2_colname = "line_number"
 , content_match1_col_name = "content_match_1" # we want to keep the full content very available

 , content_match2_col_name = "content_match_2" # we want to keep the full content very available

  ){

 # we will rename in the end so var' names are hardcoded hereafter :

  ####1) Get content from R files ####
# With the default regex of srch_pattern_in_files_get_df, fn_network indicate where the func' are defined
fn_network <-  srch_pattern_in_files_get_df(path_main_folder = folder_path
                                            , file_path_col_name = "file_path"
                                            , content_col_name = "content"
 , extracted_prefix_col_name = "first_match") #file with a func' defined by default
#we will retrieve this object and these var later

# we have 3 informations that we used hereafter :
# full content + path + a first match (default try to match each func' definition)

#### 2) List the result ####
fn_defined <- unique(fn_network$first_match) # it's the func' defined by default
#by default we have the files where each func is defined
# filter if user don't want some result + filter with nchar

fn_defined <- fn_defined[!fn_defined %in% filter_original_result_not_in]

# filter the previous matches according to nchar parameter
fn_defined <- fn_defined[which(nchar(fn_defined) > filter_first_match_by_nchar)]

fn_defined <- fn_defined[which(!is.na(fn_defined))]

# clean undesired char that will bug stringi.r
# regexx <-  escape_unescaped_chars(fn_defined)

#### 3) Construct a regex ####
# optionnally add a suffix (such as a filter from the user, capture-group, etc.)
regexx <- paste0(prefix_for_regex_from_the_text, regexx, suffix_for_regex_from_the_text)

# made a single regex and clean it from unescaped chars
regexx_complete <- paste0(regexx, collapse = "|")

regexx_complete <- fix_escaping(regexx_complete,num_escapes = 2, special_chars = c("(", ")"))

#### 4) EXTRACT #2 ####
#  match every mention of our previous matches and returning a DF
fns_called_df <- str_extract_all_to_tidy_df(string = fn_network$content
                                            , pattern = regexx_complete
 , row_number_colname = "row_number", matches_colname = "second_match"
 , filter_unmatched = filter_2nd_match_unmatched_lines)

fn_network$row_number <- seq_len(nrow(fn_network))
# we have add row_number colname in both !

#### 5) take care of the network of func' ####
# reunite matches 1 and matches 2 =>
complete_network <- merge(fns_called_df, fn_network,
                    all.x = T # we preserve each 2nd match
                   , by = "row_number")
# lines will be duplicated if + than 1 match per line

# filter the network
# not empty first_match (func_defined) value indicate that this file mention his own match
# ('internal link', recursivity or func' definition) whereas other link refer to external link
if(filter_first_match_results){complete_network <- complete_network[ which(is.na(complete_network["first_match"])) , ] }

#in the begining we have made fn_network of file_path where we've match func' definition - by default
origines_files <- unique(fn_network[which(!is.na(fn_network$first_match)), c("first_match","file_path", "content")])
colnames( origines_files ) <- c("function", "defined_in", "definition_content") # renaming for hereafter

# take original files - begining of the code - for adding the path where a func' is defined
returned_network <- merge(complete_network, origines_files
                          , by.x = "second_match"
                          , by.y = "function" # it was also 'first_match' so we've renamed
                          , all.x = TRUE)

returned_network <- returned_network[, c("file_path", "defined_in", "first_match", "second_match", "line_number", "content",  "definition_content")]

if(filter_ego_link){returned_network <- returned_network[ which( returned_network["file_path"] != returned_network["defined_in"]) , ] }

# filter if user want to filter

if(!is.null(regex_to_exclude_files_path)){

returned_network <-  returned_network[-grep(x = returned_network$file_path, pattern =  regex_to_exclude_files_path) , ]
}

colnames(returned_network) <- c(file_path_from, file_path_to, match1_colname, match2_colname, line_number_match2_colname, content_match2_col_name,  content_match1_col_name)
# finally givin the colname wanted by the user

return(returned_network)

}
