#TESTS VARIOUS LANGUAGES RETURNED BY get_def_regex_by_language
test_that("get_def_regex_by_language works correctly", {
### test python
  test_that("Regex extract fn names in Python", {
    python_code <- '
    def greet(name):
        return "Hello, " + name + "!"

    def add(a, b):
        return a + b

    def multiply(a, b):
        return a * b

    sayHello = lambda name="Guest": "Hello, " + name + "!"

    def calculate(operation, a, b):
        return operation(a, b)

    def sum(*numbers):
        return sum(numbers)

    person = {
        "name": "Alice",
        "greet": lambda: "Hello, " + "Alice" + "!"
    }
    '

    # Regex obtenue via
    regex <- get_def_regex_by_language("python")[[1]]$fn_regex

        # Extraction de noms de fonctions
    def_matches <- trimws(regmatches(python_code, gregexpr(regex, python_code, perl = TRUE))[[1]])

    expected_names <- c("greet", "add", "multiply", "sayHello",  "calculate",  "sum")

    expect_equal(def_matches, expected_names)
  })

  ###test javascript
js_code <- c('
  function greet(name) { return "Hello, " + name + "!"; }',
             'const add = function(a, b) { return a + b; }',
             'const multiply = (a, b) => a * b;',
             'function sayHello(name = "Guest") { return "Hello, " + name + "!"; }',
             'function calculate(operation, a, b) { return operation(a, b); }',
             'function sum(...numbers) { return numbers.reduce((acc, num) => acc + num, 0); }',
             'const person = { name: "Alice", greet: function() { return "Hello, " + this.name + "!"; } };',
             'const obj = { sayHi: () => "Hi!" };')


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
