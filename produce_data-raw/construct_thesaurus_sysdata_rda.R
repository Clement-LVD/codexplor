#### Code for constructing the patterns associated with languages

# several list will be exported at the end
fn_basenames <- "[a-zA-Z_\\.][a-zA-Z0-9_\\.]*" # anytext 0-9 A-Z and _
parenthesis_open = "\\("

fn_names <- paste0("\\s+", fn_basenames,   #   space 1 and + before : we clean it after
                   "(?="     # lookahead for a parenthesis
                   , parenthesis_open  , ")" ) # end of lookahead

# r will be : fn_name\\s+(<-|=)\\s+function\\(

#### 0) Infos (and Examples) about the structure ####
# we retrieve hereafter the Definition_Keyword
ref_languages <- list(
  R = list(Example = "hello <- function() { }"
           , Definition_Keyword = "function"
           , Operator_After_Keyword = "\\("
           , Operator_After_Name ="<-|="
          , Start_Instructions_operator = "{"
          , prefix_to_exclude = "FUN"
          , regex_fn_parameters_after_names = "\\s*(<-|=)\\s*function\\("
           , anonymous = T # this is a random func assigned in an object
           ),
  #the operator and function stuff will be unmatched (?:

  Python = list(Example = "def hello(): pass"
                , Definition_Keyword = "def"
                , Operator_After_Keyword = ""
                , Operator_After_Name = "\\("

               , Start_Instructions_operator = ":"
               , prefix_to_exclude = ""
               , regex_fn_parameters_after_names =  "\\("
                , anonymous = F
                 ),

JavaScript = list(Example = "function hello() { }"
                    , Definition_Keyword = "function"
                    , Operator_After_Keyword = ""
                    , Operator_After_Name = "\\("
                  , Start_Instructions_operator = "{"
                  , prefix_to_exclude = ""
                  , regex_fn_parameters_after_names =  "\\("
                  , anonymous = F

                  )
  # Java = list(Example = "public static void hello() { }"
  #             , Operator_After_Name = "()"
  #             , Definition_Keyword = "public static void"
  #             , Instructions_operator = "{}"
  #             , Operator_Before_Keyword = NA),


)
# add a regex according to the type : define func' (all languages) or not (only R)
ref_languages <- lapply(ref_languages, FUN = function(x){

  if(!x$anonymous){
  x$regex_func_name <- paste0( "(?<=", x$Definition_Keyword, ")",  fn_names  , "(?=" , x$Operator_After_Name  , ")")
# and given a real fn name paster before (!) we want also a light regex to exclude the names and catch the after-text
   }# R hereafter
  if(x$anonymous)  {
     x$regex_func_name <- paste0( "(^|\\.|\\b)" # begin of a word
                                              , "(?!" ,  x$prefix_to_exclude, ")"
                                               , fn_basenames
                                            , "\\s*(?=(?:", x$Operator_After_Name,  ")" #lookahead fusionné
                                          , "\\s*" ,"(?:" , x$Definition_Keyword, x$Operator_After_Keyword , "))" )}

  # only r is anonymous
     return(x)
})
# e.g., a 'normal' regex will look like that for r :  "(^|\\.|\\b)([A-Za-z0-9_\\.]+)(?=\\s*(?:<-)\\s*function)

# step 2, given a name of func :
# in R we retrieve that with name <-|= function(PARAMETERS !){CODE !}
# other languages we retrieve name(PARAMETERS !){CODE !}

# stringr::str_extract_all(string = "def hello(): pass", pattern =ref_languages$Python$regex_func_name)
# stringr::str_extract_all(string ="function myFunction() { return 42; }", pattern =ref_languages$JavaScript$regex_func_name  )
# stringr::str_extract_all(string ="deff <- function() { return 42; }", pattern =ref_languages$R$regex_func_name  )

#### 2) define function regex => core behavior is catching func' names ####
# here datas are sorted as a list but will be returned as a df by a func'
list_language_patterns <- list(
  R = list(
    fn_regex = ref_languages$R$regex_func_name,
    file_extension = ".R"
    , commented_line_char = "#"
    , delim_pair_comments_block = NA
    , pattern_to_exclude = "\\.Rcheck|test-|vignettes|/doc/"
    , escaping_char = '\\'
    ,  fn_regex_params_after_names = ref_languages$R$regex_fn_parameters_after_names
  ),
  Python = list(
    fn_regex = list(main_definition = ref_languages$Python$regex_func_name   # [^\\(]+: 1 or + char BUT NOT A  '(' (function name).
                  # , lambda_func = "\\w+\\s*(?==\\s*lambda)"
                  ) # \\s*: space (0 or +) & \\w+: chars. alphanumeric
    , file_extension = ".py"
    , commented_line_char = "#"     # Python (Python)
    , delim_pair_comments_block = NA
    , pattern_to_exclude = NULL
    , escaping_char = "\\"
    ,  fn_regex_params_after_names = ref_languages$Python$regex_fn_parameters_after_names
    ),

  JavaScript = list(
    fn_regex = list(
      main_definition = ref_languages$JavaScript$regex_func_name
       # , regex_variable_fn = ref_languages$R$regex_func_name #lol
      # , regex_method_arrow <- "(\\w+)\\s*(?=\\s*=\\s*\\(.*\\)\\s*=>)" # ou en objet :
    )
    , file_extension = ".js"
    , commented_line_char = "\\/\\/" # for //
    , delim_pair_comments_block = c("/*" = "*/")  # JavaScript (JavaScript)
    , pattern_to_exclude = NULL
    , escaping_char = "\\"
    ,  fn_regex_params_after_names = ref_languages$JavaScript$regex_fn_parameters_after_names

  )
)

# add pattern at the end of existing values
language_pattern <- lapply( list_language_patterns, FUN = function(entry) {
  entry$delim_pair_nested_codes = c("\\{" = "\\}")
  # entry$local_file_ext <- paste0(entry$file_ext, "$" )
  entry$fn_regex <- paste0(entry$fn_regex, collapse = "|" )
  return(entry)

}  )


usethis::use_data(ref_languages, language_pattern, internal = TRUE, overwrite = T)
