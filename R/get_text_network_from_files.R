get_text_network_from_files <- function(functions_folder_path = getwd()

    , filter_match_by_nchar = 3

    , filter_func_name_not_in = "" #c("server")

   ,  suffix_for_regex_from_the_text = ""

   , filter_matched_line = T

   , filter_func_definition = T

   , filter_ego_link = T
  ){

  ####1) Get content from R files ####
# With the default regex of srch_pattern_in_files_get_df, fn_network indicate where the func' are defined
fn_network <-  srch_pattern_in_files_get_df(path_main_folder = functions_folder_path
                                            , file_path_col_name = "file_path", content_col_name = "content", extracted_prefix_col_name = "func_defined")

fn_defined <- unique(fn_network$func_defined)
#we have the files where each func is defined

fn_defined <- fn_defined[!fn_defined %in% filter_func_name_not_in]
#### 2) Constructing regex ####
regexx <- fn_defined[!is.na(fn_defined)]
# with name of func we will construct a regex pattern, passed to extract_txt_from_df_vars

  # filter result according to nchar parameter =>
regexx <- regexx[which(nchar(regexx) > filter_match_by_nchar)]
# optionnally add a suffix (such as a filter from the user)
regexx <- paste0(regexx, suffix_for_regex_from_the_text)

# made a single giga-regex and clean it from unescaped chars
regexx_complete <- paste0(regexx, collapse = "|")
# clean undesired char
regexx_complete <- escape_unescaped_chars(regexx_complete)

#### 3) get network of func' ####
# Extract text again from the content, again (but dynamic regex)
complete_network <- extract_txt_from_df_vars(df = fn_network, regex_extract_txt = regexx_complete
                                             , cols_for_searching_text = "content", returned_col_name = "called_name", keep_empty_results = F) # matches are func' CALLED

#### 4) filter the network ####
# we have the ego-network remaining from where the file is defined, counting as a link for now
if(filter_matched_line){complete_network <- complete_network[ which(!is.na(complete_network["called_name"])) , ] }

# not empty func_defined value indicate that this is a function definition (from the begining => ego-link or even recursivity)
if(filter_func_definition){complete_network <- complete_network[ which(is.na(complete_network["func_defined"])) , ] }

origines_files <- unique(fn_network[which(!is.na(fn_network$func_defined)), c("func_defined","file_path", "content")])
colnames( origines_files  ) <- c("function", "defined_in", "definition_content")

complete_network <- merge( complete_network, origines_files, by.x = "called_name", by.y = "function", all.x = TRUE)

returned_network <- complete_network[, c("file_path", "defined_in", "called_name", "line_number", "content",  "definition_content")]

if(filter_ego_link){returned_network <- returned_network[ which( returned_network["file_path"] != returned_network["defined_in"]) , ] }

return(returned_network)

}
