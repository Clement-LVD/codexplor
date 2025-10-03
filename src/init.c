#include <R.h>
#include <Rinternals.h>
#include <R_ext/Rdynload.h>

extern SEXP pairwise_similarity(SEXP);
extern SEXP pairwise_levenshtein(SEXP);

static const R_CallMethodDef CallEntries[] = {
  {"pairwise_similarity", (DL_FUNC) &pairwise_similarity, 1},
  {"pairwise_levenshtein", (DL_FUNC) &pairwise_levenshtein, 1},
  {NULL, NULL, 0}
};

void R_init_codexplor(DllInfo *dll) {
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
}
