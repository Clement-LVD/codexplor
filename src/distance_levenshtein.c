#include <R.h>
#include <Rinternals.h>
#include <string.h>
#include <stdlib.h>

//classical Levenshtein dist
int distance_levenshtein(const char *s1, const char *s2) {
    int len1 = strlen(s1);
    int len2 = strlen(s2);

    // dynamics matrix (size (len1+1) x (len2+1))
    int *d = (int*) R_alloc((len1 + 1) * (len2 + 1), sizeof(int));

    for (int i = 0; i <= len1; i++) d[i*(len2+1)] = i;
    for (int j = 0; j <= len2; j++) d[j] = j;

    for (int i = 1; i <= len1; i++) {
        for (int j = 1; j <= len2; j++) {
            int cost = (s1[i-1] == s2[j-1]) ? 0 : 1;
            int del = d[(i-1)*(len2+1) + j] + 1;
            int ins = d[i*(len2+1) + (j-1)] + 1;
            int sub = d[(i-1)*(len2+1) + (j-1)] + cost;
            int min = del;
            if (ins < min) min = ins;
            if (sub < min) min = sub;
            d[i*(len2+1) + j] = min;
        }
    }

    int result = d[len1*(len2+1) + len2];
    return result;
}

// return similarity (%) = 100 * (1 - distance / maxlen)
double levenshtein_similarity(const char *s1, const char *s2) {
    int len1 = strlen(s1);
    int len2 = strlen(s2);
    int maxlen = (len1 > len2) ? len1 : len2;
    if (maxlen == 0) return 100.0; // 2 empty chain = 100%

    int dist = distance_levenshtein(s1, s2);
    return 100.0 * (1.0 - ((double)dist / (double)maxlen));
}

// call it from r
SEXP pairwise_levenshtein(SEXP strings) {
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
            REAL(sim)[k] = levenshtein_similarity(s1, s2);
            INTEGER(from)[k] = i + 1;
            INTEGER(to)[k]   = j + 1;
            k++;
        }
    }

    // construct data.frame
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
