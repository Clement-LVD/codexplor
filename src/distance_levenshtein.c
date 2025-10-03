#include <R.h>
#include <Rinternals.h>
#include <string.h>
#include <stdlib.h>

/* ===========================================
 Memory-efficient Levenshtein similarity
 - Uses only 2 rows (prev/curr)
 - Returns similarity in percentage [0-100]
 =========================================== */
static inline double levenshtein_similarity(const char *s1, int len1,
                                            const char *s2, int len2) {
  int maxlen = (len1 > len2) ? len1 : len2;
  if(maxlen == 0) return 100.0; // Both strings empty → 100%

  if(len1 > len2){ const char *tmp = s1; s1 = s2; s2 = tmp; int t = len1; len1 = len2; len2 = t; }

  int *prev = (int*) R_alloc(len1+1, sizeof(int));
  int *curr = (int*) R_alloc(len1+1, sizeof(int));

  for(int i=0; i<=len1; i++) prev[i] = i;

  for(int j=1; j<=len2; j++){
    curr[0] = j;
    char c2 = s2[j-1];
    for(int i=1; i<=len1; i++){
      int cost = (s1[i-1] == c2) ? 0 : 1;
      int del = prev[i]+1;
      int ins = curr[i-1]+1;
      int sub = prev[i-1]+cost;
      int min = del; if(ins<min) min=ins; if(sub<min) min=sub;
      curr[i] = min;
    }
    int *tmp = prev; prev = curr; curr = tmp;
  }

  return 100.0 * (1.0 - ((double)prev[len1]/(double)maxlen));
}

/* ===========================================
 Precompute all pair indices (i,j) for
 upper triangle of matrix
 =========================================== */
static inline void idx_to_pair(int idx, int n, int *i, int *j){
  int row = 0, s = idx;
  while(s >= n-1-row){ s -= n-1-row; row++; }
  *i = row;
  *j = row + 1 + s;
}

/* ===========================================
 Main function callable from R via .Call
 - Sequential, cache-friendly
 - Progress bar using [ ] and [X]
 =========================================== */
SEXP pairwise_levenshtein(SEXP strings){
  if(!isString(strings)) error("Argument must be a character vector");

  int n = LENGTH(strings);
  int n_pairs = n*(n-1)/2;

  SEXP from = PROTECT(allocVector(INTSXP, n_pairs));
  SEXP to   = PROTECT(allocVector(INTSXP, n_pairs));
  SEXP sim  = PROTECT(allocVector(REALSXP, n_pairs));

  const char **vec = (const char**) R_alloc(n, sizeof(char*));
  int *lengths = (int*) R_alloc(n, sizeof(int));
  for(int i=0; i<n; i++){
    vec[i] = CHAR(STRING_ELT(strings, i));
    lengths[i] = strlen(vec[i]);
  }

  int *idx_i = (int*) R_alloc(n_pairs, sizeof(int));
  int *idx_j = (int*) R_alloc(n_pairs, sizeof(int));
  int k=0;
  for(int i=0; i<n; i++){
    for(int j=i+1; j<n; j++){
      idx_i[k] = i;
      idx_j[k] = j;
      k++;
    }
  }

  // Progress bar setup
  int n_segments = 10;
  int next_threshold = n_pairs / n_segments;
  int seg_count = 0;
  Rprintf("\nProgress: [          ]"); // initial empty bar
  R_FlushConsole();

  for(int p=0; p<n_pairs; p++){
    if(p % 1000 == 0) R_CheckUserInterrupt(); // allow user interrupt

    int i = idx_i[p];
    int j = idx_j[p];

    REAL(sim)[p] = levenshtein_similarity(vec[i], lengths[i],
         vec[j], lengths[j]);
    INTEGER(from)[p] = i+1;
    INTEGER(to)[p]   = j+1;

    // Update progress bar
    if(p >= next_threshold*(seg_count+1) && seg_count < n_segments){
      seg_count++;
      Rprintf("\rProgress: [");
      for(int s=0; s<n_segments; s++){
        if(s < seg_count) Rprintf("X"); else Rprintf(" ");
      }
      Rprintf("]");
      R_FlushConsole();
    }
  }

  // Ensure bar ends at 100%
  Rprintf("\rProgress: [XXXXXXXXXX]\n");
  R_FlushConsole();

  // Construct data.frame
  SEXP df = PROTECT(allocVector(VECSXP,3));
  SET_VECTOR_ELT(df,0,from);
  SET_VECTOR_ELT(df,1,to);
  SET_VECTOR_ELT(df,2,sim);

  SEXP names = PROTECT(allocVector(STRSXP,3));
  SET_STRING_ELT(names,0,mkChar("from"));
  SET_STRING_ELT(names,1,mkChar("to"));
  SET_STRING_ELT(names,2,mkChar("similarity"));
  setAttrib(df,R_NamesSymbol,names);

  SEXP row_names = PROTECT(allocVector(INTSXP,2));
  INTEGER(row_names)[0] = NA_INTEGER;
  INTEGER(row_names)[1] = -n_pairs;
  setAttrib(df,R_RowNamesSymbol,row_names);
  setAttrib(df,R_ClassSymbol,mkString("data.frame"));

  UNPROTECT(6);
  return df;
}
