/* string_similarity.c */
#include <R.h>
#include <Rinternals.h>
#include <string.h>

double similarity(const char *s1, const char *s2) {
  int len1 = strlen(s1);
  int len2 = strlen(s2);
  int maxlen = (len1 > len2) ? len1 : len2;
  if (maxlen == 0) return 100.0;
  int matches = 0;
  for (int i = 0; i < maxlen; i++) {
    char c1 = (i < len1) ? s1[i] : '\0';
    char c2 = (i < len2) ? s2[i] : '\0';
    if (c1 == c2) matches++;
  }
  return 100.0 * ((double)matches / (double)maxlen);
}

SEXP pairwise_similarity(SEXP strings) {
  if (!isString(strings)) error("Argument must be a character vector");
  int n = LENGTH(strings);
  int n_pairs = n * (n - 1) / 2;

  SEXP from = PROTECT(allocVector(INTSXP, n_pairs));
  SEXP to   = PROTECT(allocVector(INTSXP, n_pairs));
  SEXP sim  = PROTECT(allocVector(REALSXP, n_pairs));

  int k = 0;
  for (int i = 0; i < n; i++) {
    for (int j = i + 1; j < n; j++) {
      const char *s1 = CHAR(STRING_ELT(strings, i));
      const char *s2 = CHAR(STRING_ELT(strings, j));
      REAL(sim)[k] = similarity(s1, s2);
      INTEGER(from)[k] = i + 1;
      INTEGER(to)[k]   = j + 1;
      k++;
    }
  }

  SEXP df = PROTECT(allocVector(VECSXP, 3));
  SET_VECTOR_ELT(df, 0, from);
  SET_VECTOR_ELT(df, 1, to);
  SET_VECTOR_ELT(df, 2, sim);

  SEXP names = PROTECT(allocVector(STRSXP, 3));
  SET_STRING_ELT(names, 0, mkChar("from"));
  SET_STRING_ELT(names, 1, mkChar("to"));
  SET_STRING_ELT(names, 2, mkChar("similarity"));
  setAttrib(df, R_NamesSymbol, names);

  SEXP row_names = PROTECT(allocVector(INTSXP, 2));
  INTEGER(row_names)[0] = NA_INTEGER;
  INTEGER(row_names)[1] = -n_pairs;
  setAttrib(df, R_RowNamesSymbol, row_names);
  setAttrib(df, R_ClassSymbol, mkString("data.frame"));

  UNPROTECT(6);
  return df;
}
