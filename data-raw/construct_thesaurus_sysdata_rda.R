#### Code for constructing the patterns associated with languages

# several list will be exported at the end
fn_basenames <- "[a-zA-Z_][a-zA-Z0-9_]*" # anytext 0-9 A-Z and _
parenthesis_open = "\\("

fn_names <- paste0("\\s+", fn_basenames,   #   space 1 and + before : we clean it after
                   "(?="     # lookahead for a parenthesis
                   , parenthesis_open  , ")" ) # end of lookahead

# r will be : fn_name\\s+(<-|=)\\s+function\\(

#### 0) Infos (and Examples) about the structure ####
# we retrieve hereafter the Definition_Keyword
ref_languages <- list(
  R = list(Example = "hello <- function() { }"
           , Operator_After_Name = "" #R is deviant
           , Definition_Keyword = "function"
           , Operator_After_Keyword = "\\("
           , Operator_Before_Keyword ="<-|="
           , define = F # this is a random func assigned in an object
           ),
  #the operator and function stuff will be unmatched (?:

  Python = list(Example = "def hello(): pass"
                , Operator_After_Name = "\\("
                , Definition_Keyword = "def"
                , Operator_After_Keyword = ":"
                , Operator_Before_Keyword = ""
                , define = T
                 ),

JavaScript = list(Example = "function hello() { }"
                    , Operator_After_Name = "\\("
                    , Definition_Keyword = "function"
                    , Operator_After_Keyword = "{}"
                    , Operator_Before_Keyword = ""
                  , define = T

                  )
  # Java = list(Example = "public static void hello() { }"
  #             , Operator_After_Name = "()"
  #             , Definition_Keyword = "public static void"
  #             , Operator_After_Keyword = "{}"
  #             , Operator_Before_Keyword = NA),


)
# add a regex according to the type : define func' (all languages) or not (only R)
ref_languages <- lapply(ref_languages, FUN = function(x){

  if(x$define) x$regex_func_name <- paste0( "(?<=", x$Definition_Keyword, ")",  fn_names  , "(?=" , x$Operator_After_Name  , ")")

  if(!x$define)  x$regex_func_name <- paste0(fn_basenames
                                            , "(?=", x$Operator_Before_Keyword,  ")" #lookahead
                                          , "(?="  , x$Definition_Keyword, x$Operator_After_Keyword , ")" )
# only r
     return(x)
})


# stringr::str_extract_all(string = "def hello(): pass", pattern =ref_languages$Python$regex_func_name)
# stringr::str_extract_all(string ="function myFunction() { return 42; }", pattern =ref_languages$JavaScript$regex_func_name  )

#### 2) define function regex => core behavior is catching func' names ####
# here datas are sorted as a list but will be returned as a df by a func'
list_language_patterns <- list(
  R = list(
    fn_regex = ref_languages$R$regex_func_name,
    file_extension = ".R"
    , commented_line_char = "#"
    , delim_pair_comments_block = NA
    , pattern_to_exclude = "\\.Rcheck|test-|vignettes"
  ),
  Python = list(
    fn_regex = list(main_definition = ref_languages$Python$regex_func_name   # [^\\(]+: 1 or + char BUT NOT A  '(' (function name).
                  # , lambda_func = "\\w+\\s*(?==\\s*lambda)"
                  ) # \\s*: space (0 or +) & \\w+: chars. alphanumeric
    , file_extension = ".py"
    , commented_line_char = "#"     # Python (Python)
    , delim_pair_comments_block = NA
    , pattern_to_exclude = NA),

  JavaScript = list(
    fn_regex = list(
      main_definition = ref_languages$JavaScript$regex_func_name
       # , regex_variable_fn = ref_languages$R$regex_func_name #lol
      # , regex_method_arrow <- "(\\w+)\\s*(?=\\s*=\\s*\\(.*\\)\\s*=>)" # ou en objet :
    )
    , file_extension = ".js"
    , commented_line_char = "\\s?//"
    , delim_pair_comments_block = c("/*" = "*/")  # JavaScript (JavaScript)
    , pattern_to_exclude = NA
  )
)

# add pattern at the end of existing values
language_pattern <- lapply( list_language_patterns, FUN = function(entry) {
  entry$delim_pair_nested_codes = c("\\{" = "\\}")
  entry$local_file_ext <- paste0(entry$file_ext, "$" )
  entry$fn_regex <- paste0(entry$fn_regex, collapse = "|" )
  return(entry)

}  )


usethis::use_data(ref_languages, language_pattern, internal = TRUE, overwrite = T)
