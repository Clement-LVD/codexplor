# Fichier JavaScript de test
test_that("get_def_regex_by_language works correctly", {

js_code <- c('
  function greet(name) { return "Hello, " + name + "!"; }',
             'const add = function(a, b) { return a + b; }',
             'const multiply = (a, b) => a * b;',
             'function sayHello(name = "Guest") { return "Hello, " + name + "!"; }',
             'function calculate(operation, a, b) { return operation(a, b); }',
             'function sum(...numbers) { return numbers.reduce((acc, num) => acc + num, 0); }',
             'const person = { name: "Alice", greet: function() { return "Hello, " + this.name + "!"; } };',
             'const obj = { sayHi: () => "Hi!" };')

# en js il y a plein de maniere de définir des fonctions
rgx <- list(
regex_variable_fn <- "(\\w+)\\s*(?=\\s*=\\s*function\\s*\\()"
# ou en objet :
, regex_method_arrow <- "(\\w+)\\s*(?=\\s*=\\s*\\(.*\\)\\s*=>)"

)

lapply(rgx, FUN = function(rgx){unlist(regmatches(js_code, regexec(perl = T, rgx, js_code))) })

# Regex obtenue via
regex <- get_def_regex_by_language("javascript")[[1]]$fn_regex

test_that("Regex extract fn names in javascript", {

   matches <- trimws( unlist(regmatches(js_code, regexec(perl = T, regex, js_code))))
  # similar to what our matching functions do

   matches <- unique(matches[nchar(matches) != 0])

    expected_names <- c( "greet"   ,  "add"   ,    "multiply"  , "sayHello"  , "calculate" , "sum"   )

      expect_equal(matches, expected_names)
})
}
)
