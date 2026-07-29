# Example Clinical Trials Tables

## Introduction

In this vignette we create a

- demographic table
- adverse event table
- response table
- time-to-event analysis table

using the `rtables` layout facility. That is, we demonstrate how the
layout based tabulation framework can specify the structure and
relations that are commonly found when analyzing clinical trials data.

Note that all the data is created using random number generators. All
`ex_*` data which is currently attached to the `rtables` package is
provided by the
[`formatters`](https://pharmaverse.github.io/formatters/) package and
was created using the publicly available
[`random.cdisc.data`](https://insightsengineering.github.io/random.cdisc.data/)
R package.

The packages used in this vignette are:

``` r

library(rtables)
library(tibble)
library(dplyr)
```

## Demographic Table

Demographic tables summarize the variables content for different
population subsets (encoded in the columns).

One feature of
[`analyze()`](https://pharmaverse.github.io/rtables/reference/analyze.md)
that we have not introduced in the previous vignette is that the
analysis function `afun` can specify multiple rows with the
[`in_rows()`](https://pharmaverse.github.io/rtables/reference/in_rows.md)
function:

``` r

ADSL <- ex_adsl # Example ADSL dataset

lyt <- basic_table() |>
  split_cols_by("ARM") |>
  analyze(vars = "AGE", afun = function(x) {
    in_rows(
      "Mean (sd)" = rcell(c(mean(x), sd(x)), format = "xx.xx (xx.xx)"),
      "Range" = rcell(range(x), format = "xx.xx - xx.xx")
    )
  })

tbl <- build_table(lyt, ADSL)
tbl
#               A: Drug X      B: Placebo     C: Combination
# ——————————————————————————————————————————————————————————
# Mean (sd)   33.77 (6.55)    35.43 (7.90)     35.43 (7.72) 
# Range       21.00 - 50.00   21.00 - 62.00   20.00 - 69.00
```

Multiple variables can be analyzed in one
[`analyze()`](https://pharmaverse.github.io/rtables/reference/analyze.md)
call:

``` r

lyt2 <- basic_table() |>
  split_cols_by("ARM") |>
  analyze(vars = c("AGE", "BMRKR1"), afun = function(x) {
    in_rows(
      "Mean (sd)" = rcell(c(mean(x), sd(x)), format = "xx.xx (xx.xx)"),
      "Range" = rcell(range(x), format = "xx.xx - xx.xx")
    )
  })

tbl2 <- build_table(lyt2, ADSL)
tbl2
#                 A: Drug X      B: Placebo     C: Combination
# ————————————————————————————————————————————————————————————
# AGE                                                         
#   Mean (sd)   33.77 (6.55)    35.43 (7.90)     35.43 (7.72) 
#   Range       21.00 - 50.00   21.00 - 62.00   20.00 - 69.00 
# BMRKR1                                                      
#   Mean (sd)    5.97 (3.55)     5.70 (3.31)     5.62 (3.49)  
#   Range       0.41 - 17.67    0.65 - 14.24     0.17 - 21.39
```

Hence, if `afun` can process different data vector types (i.e. variables
selected from the data) then we are fairly close to a standard
demographic table. Here is a function that either creates a count table
or some number summary if the argument `x` is a factor or numeric,
respectively:

``` r

s_summary <- function(x) {
  if (is.numeric(x)) {
    in_rows(
      "n" = rcell(sum(!is.na(x)), format = "xx"),
      "Mean (sd)" = rcell(c(mean(x, na.rm = TRUE), sd(x, na.rm = TRUE)), format = "xx.xx (xx.xx)"),
      "IQR" = rcell(IQR(x, na.rm = TRUE), format = "xx.xx"),
      "min - max" = rcell(range(x, na.rm = TRUE), format = "xx.xx - xx.xx")
    )
  } else if (is.factor(x)) {
    vs <- as.list(table(x))
    do.call(in_rows, lapply(vs, rcell, format = "xx"))
  } else {
    stop("type not supported")
  }
}
```

Note we use `rcell` to wrap the results in order to add formatting
instructions for `rtables`. We can use `s_summary` outside the context
of tabulation:

``` r

s_summary(ADSL$AGE)
# RowsVerticalSection (in_rows) object print method:
# ----------------------------
#    row_name formatted_cell indent_mod row_label
# 1         n            400          0         n
# 2 Mean (sd)   34.88 (7.44)          0 Mean (sd)
# 3       IQR          10.00          0       IQR
# 4 min - max  20.00 - 69.00          0 min - max
```

and

``` r

s_summary(ADSL$SEX)
# RowsVerticalSection (in_rows) object print method:
# ----------------------------
#           row_name formatted_cell indent_mod        row_label
# 1                F            222          0                F
# 2                M            166          0                M
# 3                U              9          0                U
# 4 UNDIFFERENTIATED              3          0 UNDIFFERENTIATED
```

We can now create a commonly used variant of the demographic table:

``` r

summary_lyt <- basic_table() |>
  split_cols_by(var = "ARM") |>
  analyze(c("AGE", "SEX"), afun = s_summary)

summary_tbl <- build_table(summary_lyt, ADSL)
summary_tbl
#                        A: Drug X      B: Placebo     C: Combination
# ———————————————————————————————————————————————————————————————————
# AGE                                                                
#   n                       134             134             132      
#   Mean (sd)          33.77 (6.55)    35.43 (7.90)     35.43 (7.72) 
#   IQR                    11.00           10.00           10.00     
#   min - max          21.00 - 50.00   21.00 - 62.00   20.00 - 69.00 
# SEX                                                                
#   F                       79              77               66      
#   M                       51              55               60      
#   U                        3               2               4       
#   UNDIFFERENTIATED         1               0               2
```

Note that
[`analyze()`](https://pharmaverse.github.io/rtables/reference/analyze.md)
can also be called multiple times in sequence:

``` r

summary_lyt2 <- basic_table() |>
  split_cols_by(var = "ARM") |>
  analyze("AGE", s_summary) |>
  analyze("SEX", s_summary)

summary_tbl2 <- build_table(summary_lyt2, ADSL)
summary_tbl2
#                        A: Drug X      B: Placebo     C: Combination
# ———————————————————————————————————————————————————————————————————
# AGE                                                                
#   n                       134             134             132      
#   Mean (sd)          33.77 (6.55)    35.43 (7.90)     35.43 (7.72) 
#   IQR                    11.00           10.00           10.00     
#   min - max          21.00 - 50.00   21.00 - 62.00   20.00 - 69.00 
# SEX                                                                
#   F                       79              77               66      
#   M                       51              55               60      
#   U                        3               2               4       
#   UNDIFFERENTIATED         1               0               2
```

which leads to the table identical to `summary_tbl`:

``` r

identical(summary_tbl, summary_tbl2)
# [1] TRUE
```

In clinical trials analyses the number of patients per column is often
referred to as `N` (rather than the overall population which outside of
clinical trials is commonly referred to as `N`). Column `N`s are added
by setting the `show_colcounts` argument in
[`basic_table()`](https://pharmaverse.github.io/rtables/reference/basic_table.md)
to `TRUE`:

``` r

summary_lyt3 <- basic_table(show_colcounts = TRUE) |>
  split_cols_by(var = "ARMCD") |>
  analyze(c("AGE", "SEX"), s_summary)

summary_tbl3 <- build_table(summary_lyt3, ADSL)
summary_tbl3
#                          ARM A           ARM B           ARM C    
#                         (N=134)         (N=134)         (N=132)   
# ——————————————————————————————————————————————————————————————————
# AGE                                                               
#   n                       134             134             132     
#   Mean (sd)          33.77 (6.55)    35.43 (7.90)    35.43 (7.72) 
#   IQR                    11.00           10.00           10.00    
#   min - max          21.00 - 50.00   21.00 - 62.00   20.00 - 69.00
# SEX                                                               
#   F                       79              77              66      
#   M                       51              55              60      
#   U                        3               2               4      
#   UNDIFFERENTIATED         1               0               2
```

### Variations on the Demographic Table

We will now show a couple of variations of the demographic table that we
developed above. These variations are in structure and not in analysis,
hence they don’t require a modification to the `s_summary` function.

We will start with a standard table analyzing the variables `AGE` and
`BMRKR2` variables:

``` r

lyt <- basic_table(show_colcounts = TRUE) |>
  split_cols_by(var = "ARM") |>
  analyze(c("AGE", "BMRKR2"), s_summary)

tbl <- build_table(lyt, ADSL)
tbl
#                 A: Drug X      B: Placebo     C: Combination
#                  (N=134)         (N=134)         (N=132)    
# ————————————————————————————————————————————————————————————
# AGE                                                         
#   n                134             134             132      
#   Mean (sd)   33.77 (6.55)    35.43 (7.90)     35.43 (7.72) 
#   IQR             11.00           10.00           10.00     
#   min - max   21.00 - 50.00   21.00 - 62.00   20.00 - 69.00 
# BMRKR2                                                      
#   LOW              50              45               40      
#   MEDIUM           37              56               42      
#   HIGH             47              33               50
```

Assume we would like to have this analysis carried out per gender
encoded in the row space:

``` r

lyt <- basic_table(show_colcounts = TRUE) |>
  split_cols_by(var = "ARM") |>
  split_rows_by("SEX") |>
  analyze(c("AGE", "BMRKR2"), s_summary)

tbl <- build_table(lyt, ADSL)
tbl
#                      A: Drug X      B: Placebo     C: Combination
#                       (N=134)         (N=134)         (N=132)    
# —————————————————————————————————————————————————————————————————
# F                                                                
#   AGE                                                            
#     n                   79              77               66      
#     Mean (sd)      32.76 (6.09)    34.12 (7.06)     35.20 (7.43) 
#     IQR                9.00            8.00             6.75     
#     min - max      21.00 - 47.00   23.00 - 58.00   21.00 - 64.00 
#   BMRKR2                                                         
#     LOW                 26              21               26      
#     MEDIUM              21              38               17      
#     HIGH                32              18               23      
# M                                                                
#   AGE                                                            
#     n                   51              55               60      
#     Mean (sd)      35.57 (7.08)    37.44 (8.69)     35.38 (8.24) 
#     IQR                11.00           9.00            11.00     
#     min - max      23.00 - 50.00   21.00 - 62.00   20.00 - 69.00 
#   BMRKR2                                                         
#     LOW                 21              23               11      
#     MEDIUM              15              18               23      
#     HIGH                15              14               26      
# U                                                                
#   AGE                                                            
#     n                    3               2               4       
#     Mean (sd)      31.67 (3.21)    31.00 (5.66)     35.25 (3.10) 
#     IQR                3.00            4.00             3.25     
#     min - max      28.00 - 34.00   27.00 - 35.00   31.00 - 38.00 
#   BMRKR2                                                         
#     LOW                  2               1               1       
#     MEDIUM               1               0               2       
#     HIGH                 0               1               1       
# UNDIFFERENTIATED                                                 
#   AGE                                                            
#     n                    1               0               2       
#     Mean (sd)       28.00 (NA)          NA          45.00 (1.41) 
#     IQR                0.00             NA              1.00     
#     min - max      28.00 - 28.00    Inf - -Inf     44.00 - 46.00 
#   BMRKR2                                                         
#     LOW                  1               0               2       
#     MEDIUM               0               0               0       
#     HIGH                 0               0               0
```

We will now subset `ADSL` to include only males and females in the
analysis in order to reduce the number of rows in the table:

``` r

ADSL_M_F <- filter(ADSL, SEX %in% c("M", "F"))

lyt2 <- basic_table(show_colcounts = TRUE) |>
  split_cols_by(var = "ARM") |>
  split_rows_by("SEX") |>
  analyze(c("AGE", "BMRKR2"), s_summary)

tbl2 <- build_table(lyt2, ADSL_M_F)
tbl2
#                      A: Drug X      B: Placebo     C: Combination
#                       (N=130)         (N=132)         (N=126)    
# —————————————————————————————————————————————————————————————————
# F                                                                
#   AGE                                                            
#     n                   79              77               66      
#     Mean (sd)      32.76 (6.09)    34.12 (7.06)     35.20 (7.43) 
#     IQR                9.00            8.00             6.75     
#     min - max      21.00 - 47.00   23.00 - 58.00   21.00 - 64.00 
#   BMRKR2                                                         
#     LOW                 26              21               26      
#     MEDIUM              21              38               17      
#     HIGH                32              18               23      
# M                                                                
#   AGE                                                            
#     n                   51              55               60      
#     Mean (sd)      35.57 (7.08)    37.44 (8.69)     35.38 (8.24) 
#     IQR                11.00           9.00            11.00     
#     min - max      23.00 - 50.00   21.00 - 62.00   20.00 - 69.00 
#   BMRKR2                                                         
#     LOW                 21              23               11      
#     MEDIUM              15              18               23      
#     HIGH                15              14               26      
# U                                                                
#   AGE                                                            
#     n                    0               0               0       
#     Mean (sd)           NA              NA               NA      
#     IQR                 NA              NA               NA      
#     min - max       Inf - -Inf      Inf - -Inf       Inf - -Inf  
#   BMRKR2                                                         
#     LOW                  0               0               0       
#     MEDIUM               0               0               0       
#     HIGH                 0               0               0       
# UNDIFFERENTIATED                                                 
#   AGE                                                            
#     n                    0               0               0       
#     Mean (sd)           NA              NA               NA      
#     IQR                 NA              NA               NA      
#     min - max       Inf - -Inf      Inf - -Inf       Inf - -Inf  
#   BMRKR2                                                         
#     LOW                  0               0               0       
#     MEDIUM               0               0               0       
#     HIGH                 0               0               0
```

Note that the `UNDIFFERENTIATED` and `U` levels still show up in the
table. This is because tabulation respects the factor levels and level
order, exactly as the `split` and `table` function do. If empty levels
should be dropped then `rtables` needs to know that at splitting time
via the `split_fun` argument in
[`split_rows_by()`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md).
There are a number of predefined functions. For this example
[`drop_split_levels()`](https://pharmaverse.github.io/rtables/reference/split_funcs.md)
is required to drop the empty levels at splitting time. Splitting is a
big topic and will be eventually addressed in a specific package
vignette.

``` r

lyt3 <- basic_table(show_colcounts = TRUE) |>
  split_cols_by(var = "ARM") |>
  split_rows_by("SEX", split_fun = drop_split_levels, child_labels = "visible") |>
  analyze(c("AGE", "BMRKR2"), s_summary)

tbl3 <- build_table(lyt3, ADSL_M_F)
tbl3
#                   A: Drug X      B: Placebo     C: Combination
#                    (N=130)         (N=132)         (N=126)    
# ——————————————————————————————————————————————————————————————
# F                                                             
#   AGE                                                         
#     n                79              77               66      
#     Mean (sd)   32.76 (6.09)    34.12 (7.06)     35.20 (7.43) 
#     IQR             9.00            8.00             6.75     
#     min - max   21.00 - 47.00   23.00 - 58.00   21.00 - 64.00 
#   BMRKR2                                                      
#     LOW              26              21               26      
#     MEDIUM           21              38               17      
#     HIGH             32              18               23      
# M                                                             
#   AGE                                                         
#     n                51              55               60      
#     Mean (sd)   35.57 (7.08)    37.44 (8.69)     35.38 (8.24) 
#     IQR             11.00           9.00            11.00     
#     min - max   23.00 - 50.00   21.00 - 62.00   20.00 - 69.00 
#   BMRKR2                                                      
#     LOW              21              23               11      
#     MEDIUM           15              18               23      
#     HIGH             15              14               26
```

In the table above the labels `M` and `F` are not very descriptive. You
can add the full labels as follows:

``` r

ADSL_M_F_l <- ADSL_M_F |>
  mutate(lbl_sex = case_when(
    SEX == "M" ~ "Male",
    SEX == "F" ~ "Female",
    SEX == "U" ~ "Unknown",
    SEX == "UNDIFFERENTIATED" ~ "Undifferentiated"
  ))

lyt4 <- basic_table(show_colcounts = TRUE) |>
  split_cols_by(var = "ARM") |>
  split_rows_by("SEX", labels_var = "lbl_sex", split_fun = drop_split_levels, child_labels = "visible") |>
  analyze(c("AGE", "BMRKR2"), s_summary)

tbl4 <- build_table(lyt4, ADSL_M_F_l)
tbl4
#                   A: Drug X      B: Placebo     C: Combination
#                    (N=130)         (N=132)         (N=126)    
# ——————————————————————————————————————————————————————————————
# Female                                                        
#   AGE                                                         
#     n                79              77               66      
#     Mean (sd)   32.76 (6.09)    34.12 (7.06)     35.20 (7.43) 
#     IQR             9.00            8.00             6.75     
#     min - max   21.00 - 47.00   23.00 - 58.00   21.00 - 64.00 
#   BMRKR2                                                      
#     LOW              26              21               26      
#     MEDIUM           21              38               17      
#     HIGH             32              18               23      
# Male                                                          
#   AGE                                                         
#     n                51              55               60      
#     Mean (sd)   35.57 (7.08)    37.44 (8.69)     35.38 (8.24) 
#     IQR             11.00           9.00            11.00     
#     min - max   23.00 - 50.00   21.00 - 62.00   20.00 - 69.00 
#   BMRKR2                                                      
#     LOW              21              23               11      
#     MEDIUM           15              18               23      
#     HIGH             15              14               26
```

For the next table variation we only stratify by gender for the `AGE`
analysis. To do this the `nested` argument has to be set to `FALSE` in
[`analyze()`](https://pharmaverse.github.io/rtables/reference/analyze.md)
call:

``` r

lyt5 <- basic_table(show_colcounts = TRUE) |>
  split_cols_by(var = "ARM") |>
  split_rows_by("SEX", labels_var = "lbl_sex", split_fun = drop_split_levels, child_labels = "visible") |>
  analyze("AGE", s_summary, show_labels = "visible") |>
  analyze("BMRKR2", s_summary, nested = FALSE, show_labels = "visible")

tbl5 <- build_table(lyt5, ADSL_M_F_l)
tbl5
#                   A: Drug X      B: Placebo     C: Combination
#                    (N=130)         (N=132)         (N=126)    
# ——————————————————————————————————————————————————————————————
# Female                                                        
#   AGE                                                         
#     n                79              77               66      
#     Mean (sd)   32.76 (6.09)    34.12 (7.06)     35.20 (7.43) 
#     IQR             9.00            8.00             6.75     
#     min - max   21.00 - 47.00   23.00 - 58.00   21.00 - 64.00 
# Male                                                          
#   AGE                                                         
#     n                51              55               60      
#     Mean (sd)   35.57 (7.08)    37.44 (8.69)     35.38 (8.24) 
#     IQR             11.00           9.00            11.00     
#     min - max   23.00 - 50.00   21.00 - 62.00   20.00 - 69.00 
# BMRKR2                                                        
#   LOW                47              44               37      
#   MEDIUM             36              56               40      
#   HIGH               47              32               49
```

Once we split the rows into groups (`Male` and `Female` here) one might
want to summarize groups: usually by showing count and column
percentages. This is especially important if we have missing data. For
example, if we create the above table but add missing data to the `AGE`
variable:

``` r

insert_NAs <- function(x) {
  x[sample(c(TRUE, FALSE), length(x), TRUE, prob = c(0.2, 0.8))] <- NA
  x
}

set.seed(1)
ADSL_NA <- ADSL_M_F_l |>
  mutate(AGE = insert_NAs(AGE))

lyt6 <- basic_table(show_colcounts = TRUE) |>
  split_cols_by(var = "ARM") |>
  split_rows_by(
    "SEX",
    labels_var = "lbl_sex",
    split_fun = drop_split_levels,
    child_labels = "visible"
  ) |>
  analyze("AGE", s_summary) |>
  analyze("BMRKR2", s_summary, nested = FALSE, show_labels = "visible")

tbl6 <- build_table(lyt6, filter(ADSL_NA, SEX %in% c("M", "F")))
tbl6
#                 A: Drug X      B: Placebo     C: Combination
#                  (N=130)         (N=132)         (N=126)    
# ————————————————————————————————————————————————————————————
# Female                                                      
#   n                65              61               54      
#   Mean (sd)   32.71 (6.07)    34.33 (7.31)     34.61 (6.78) 
#   IQR             9.00            10.00            6.75     
#   min - max   21.00 - 47.00   23.00 - 58.00   21.00 - 54.00 
# Male                                                        
#   n                44              44               50      
#   Mean (sd)   35.66 (6.78)    36.93 (8.18)     35.64 (8.42) 
#   IQR             10.50           8.25            10.75     
#   min - max   24.00 - 48.00   21.00 - 58.00   20.00 - 69.00 
# BMRKR2                                                      
#   LOW              47              44               37      
#   MEDIUM           36              56               40      
#   HIGH             47              32               49
```

Here it is not easy to see how many females and males there are in each
arm as `n` represents the number of non-missing data elements in the
variables. Groups within rows that are defined by splitting can be
summarized with
[`summarize_row_groups()`](https://pharmaverse.github.io/rtables/reference/summarize_row_groups.md),
for example:

``` r

lyt7 <- basic_table(show_colcounts = TRUE) |>
  split_cols_by(var = "ARM") |>
  split_rows_by("SEX", labels_var = "lbl_sex", split_fun = drop_split_levels) |>
  summarize_row_groups() |>
  analyze("AGE", s_summary) |>
  analyze("BMRKR2", afun = s_summary, nested = FALSE, show_labels = "visible")

tbl7 <- build_table(lyt7, filter(ADSL_NA, SEX %in% c("M", "F")))
tbl7
#                 A: Drug X      B: Placebo     C: Combination
#                  (N=130)         (N=132)         (N=126)    
# ————————————————————————————————————————————————————————————
# Female         79 (60.8%)      77 (58.3%)       66 (52.4%)  
#   n                65              61               54      
#   Mean (sd)   32.71 (6.07)    34.33 (7.31)     34.61 (6.78) 
#   IQR             9.00            10.00            6.75     
#   min - max   21.00 - 47.00   23.00 - 58.00   21.00 - 54.00 
# Male           51 (39.2%)      55 (41.7%)       60 (47.6%)  
#   n                44              44               50      
#   Mean (sd)   35.66 (6.78)    36.93 (8.18)     35.64 (8.42) 
#   IQR             10.50           8.25            10.75     
#   min - max   24.00 - 48.00   21.00 - 58.00   20.00 - 69.00 
# BMRKR2                                                      
#   LOW              47              44               37      
#   MEDIUM           36              56               40      
#   HIGH             47              32               49
```

There are a couple of things to note here:

- Group summaries produce “content” rows. Visually, it’s impossible to
  distinguish data rows from content rows. Their difference is justified
  (and it’s an important design decision) because when we paginate
  tables the content rows are by default repeated if a group gets
  divided via pagination.
- Conceptually the content rows summarize the patient population which
  is analyzed and hence are often the count & group percentages (default
  behavior of
  [`summarize_row_groups()`](https://pharmaverse.github.io/rtables/reference/summarize_row_groups.md)).

We can recreate this default behavior (count percentage) by defining a
`cfun` for illustrative purposes here as it results in the same table as
above:

``` r

lyt8 <- basic_table(show_colcounts = TRUE) |>
  split_cols_by(var = "ARM") |>
  split_rows_by("SEX", labels_var = "lbl_sex", split_fun = drop_split_levels) |>
  summarize_row_groups(cfun = function(df, labelstr, .N_col, ...) {
    in_rows(
      rcell(nrow(df) * c(1, 1 / .N_col), format = "xx (xx.xx%)"),
      .labels = labelstr
    )
  }) |>
  analyze("AGE", s_summary) |>
  analyze("BEP01FL", afun = s_summary, nested = FALSE, show_labels = "visible")

tbl8 <- build_table(lyt8, filter(ADSL_NA, SEX %in% c("M", "F")))
tbl8
#                 A: Drug X      B: Placebo     C: Combination
#                  (N=130)         (N=132)         (N=126)    
# ————————————————————————————————————————————————————————————
# Female         79 (60.77%)     77 (58.33%)     66 (52.38%)  
#   n                65              61               54      
#   Mean (sd)   32.71 (6.07)    34.33 (7.31)     34.61 (6.78) 
#   IQR             9.00            10.00            6.75     
#   min - max   21.00 - 47.00   23.00 - 58.00   21.00 - 54.00 
# Male           51 (39.23%)     55 (41.67%)     60 (47.62%)  
#   n                44              44               50      
#   Mean (sd)   35.66 (6.78)    36.93 (8.18)     35.64 (8.42) 
#   IQR             10.50           8.25            10.75     
#   min - max   24.00 - 48.00   21.00 - 58.00   20.00 - 69.00 
# BEP01FL                                                     
#   Y                67              63               65      
#   N                63              69               61
```

Note that `cfun`, like `afun` (which is used in
[`analyze()`](https://pharmaverse.github.io/rtables/reference/analyze.md)),
can operate on either variables, passed via the `x` argument, or
`data.frame`s or `tibble`s, which are passed via the `df` argument
(`afun` can optionally request `df` too). Unlike `afun`, `cfun` must
accept `labelstr` as the second argument which gives the default group
label (factor level from splitting) and hence it could be modified:

``` r

lyt9 <- basic_table() |>
  split_cols_by(var = "ARM") |>
  split_rows_by("SEX", labels_var = "lbl_sex", split_fun = drop_split_levels, child_labels = "hidden") |>
  summarize_row_groups(cfun = function(df, labelstr, .N_col, ...) {
    in_rows(
      rcell(nrow(df) * c(1, 1 / .N_col), format = "xx (xx.xx%)"),
      .labels = paste0(labelstr, ": count (perc.)")
    )
  }) |>
  analyze("AGE", s_summary) |>
  analyze("BEP01FL", s_summary, nested = FALSE, show_labels = "visible")

tbl9 <- build_table(lyt9, filter(ADSL_NA, SEX %in% c("M", "F")))
tbl9
#                           A: Drug X      B: Placebo     C: Combination
# ——————————————————————————————————————————————————————————————————————
# Female: count (perc.)    79 (60.77%)     77 (58.33%)     66 (52.38%)  
#   n                          65              61               54      
#   Mean (sd)             32.71 (6.07)    34.33 (7.31)     34.61 (6.78) 
#   IQR                       9.00            10.00            6.75     
#   min - max             21.00 - 47.00   23.00 - 58.00   21.00 - 54.00 
# Male: count (perc.)      51 (39.23%)     55 (41.67%)     60 (47.62%)  
#   n                          44              44               50      
#   Mean (sd)             35.66 (6.78)    36.93 (8.18)     35.64 (8.42) 
#   IQR                       10.50           8.25            10.75     
#   min - max             24.00 - 48.00   21.00 - 58.00   20.00 - 69.00 
# BEP01FL                                                               
#   Y                          67              63               65      
#   N                          63              69               61
```

### Using Layouts

Layouts have a couple of advantages over tabulating the tables directly:

- the creation of layouts requires the analyst to describe the problem
  in an abstract way
  - i.e. they separate the analyses description from the actual data
- referencing variable names happens via strings (no non-standard
  evaluation (NSE) is needed, though this is arguably either a feature
  or a shortcoming)
- layouts can be reused

Here is an example that demonstrates the reusability of layouts:

``` r

adsl_lyt <- basic_table(show_colcounts = TRUE) |>
  split_cols_by("ARM") |>
  analyze(c("AGE", "SEX"), afun = s_summary)

adsl_lyt
# A Pre-data Table Layout
# 
# Column-Split Structure:
# ARM (lvls) 
# 
# Row-Split Structure:
# AGE:SEX (** multivar analysis **)
```

We can now build a table for `ADSL`

``` r

adsl_tbl <- build_table(adsl_lyt, ADSL)
adsl_tbl
#                        A: Drug X      B: Placebo     C: Combination
#                         (N=134)         (N=134)         (N=132)    
# ———————————————————————————————————————————————————————————————————
# AGE                                                                
#   n                       134             134             132      
#   Mean (sd)          33.77 (6.55)    35.43 (7.90)     35.43 (7.72) 
#   IQR                    11.00           10.00           10.00     
#   min - max          21.00 - 50.00   21.00 - 62.00   20.00 - 69.00 
# SEX                                                                
#   F                       79              77               66      
#   M                       51              55               60      
#   U                        3               2               4       
#   UNDIFFERENTIATED         1               0               2
```

or for all patients that are older than 18:

``` r

adsl_f_tbl <- build_table(lyt, ADSL |> filter(AGE > 18))
# Warning in min(x): no non-missing arguments to min; returning Inf
# Warning in max(x): no non-missing arguments to max; returning -Inf
adsl_f_tbl
#                      A: Drug X      B: Placebo     C: Combination
#                       (N=134)         (N=134)         (N=132)    
# —————————————————————————————————————————————————————————————————
# F                                                                
#   AGE                                                            
#     n                   79              77               66      
#     Mean (sd)      32.76 (6.09)    34.12 (7.06)     35.20 (7.43) 
#     IQR                9.00            8.00             6.75     
#     min - max      21.00 - 47.00   23.00 - 58.00   21.00 - 64.00 
#   BMRKR2                                                         
#     LOW                 26              21               26      
#     MEDIUM              21              38               17      
#     HIGH                32              18               23      
# M                                                                
#   AGE                                                            
#     n                   51              55               60      
#     Mean (sd)      35.57 (7.08)    37.44 (8.69)     35.38 (8.24) 
#     IQR                11.00           9.00            11.00     
#     min - max      23.00 - 50.00   21.00 - 62.00   20.00 - 69.00 
#   BMRKR2                                                         
#     LOW                 21              23               11      
#     MEDIUM              15              18               23      
#     HIGH                15              14               26      
# U                                                                
#   AGE                                                            
#     n                    3               2               4       
#     Mean (sd)      31.67 (3.21)    31.00 (5.66)     35.25 (3.10) 
#     IQR                3.00            4.00             3.25     
#     min - max      28.00 - 34.00   27.00 - 35.00   31.00 - 38.00 
#   BMRKR2                                                         
#     LOW                  2               1               1       
#     MEDIUM               1               0               2       
#     HIGH                 0               1               1       
# UNDIFFERENTIATED                                                 
#   AGE                                                            
#     n                    1               0               2       
#     Mean (sd)       28.00 (NA)          NA          45.00 (1.41) 
#     IQR                0.00             NA              1.00     
#     min - max      28.00 - 28.00    Inf - -Inf     44.00 - 46.00 
#   BMRKR2                                                         
#     LOW                  1               0               2       
#     MEDIUM               0               0               0       
#     HIGH                 0               0               0
```

## Adverse Events

There are a number of different adverse event tables. We will now
present two tables that show adverse events by ID and then by grade and
by ID.

This time we won’t use the `ADAE` dataset from
[`random.cdisc.data`](https://insightsengineering.github.io/random.cdisc.data/)
but rather generate a dataset on the fly (see [Adrian’s 2016 Phuse
paper](https://github.com/waddella/phuse2016_adverse_events)):

``` r

set.seed(1)

lookup <- tribble(
  ~AEDECOD,                          ~AEBODSYS,                                         ~AETOXGR,
  "HEADACHE",                        "NERVOUS SYSTEM DISORDERS",                        "5",
  "BACK PAIN",                       "MUSCULOSKELETAL AND CONNECTIVE TISSUE DISORDERS", "2",
  "GINGIVAL BLEEDING",               "GASTROINTESTINAL DISORDERS",                      "1",
  "HYPOTENSION",                     "VASCULAR DISORDERS",                              "3",
  "FAECES SOFT",                     "GASTROINTESTINAL DISORDERS",                      "2",
  "ABDOMINAL DISCOMFORT",            "GASTROINTESTINAL DISORDERS",                      "1",
  "DIARRHEA",                        "GASTROINTESTINAL DISORDERS",                      "1",
  "ABDOMINAL FULLNESS DUE TO GAS",   "GASTROINTESTINAL DISORDERS",                      "1",
  "NAUSEA (INTERMITTENT)",           "GASTROINTESTINAL DISORDERS",                      "2",
  "WEAKNESS",                        "MUSCULOSKELETAL AND CONNECTIVE TISSUE DISORDERS", "3",
  "ORTHOSTATIC HYPOTENSION",         "VASCULAR DISORDERS",                              "4"
)

normalize <- function(x) x / sum(x)
weightsA <- normalize(c(0.1, dlnorm(seq(0, 5, length.out = 25), meanlog = 3)))
weightsB <- normalize(c(0.2, dlnorm(seq(0, 5, length.out = 25))))

N_pop <- 300
ADSL2 <- data.frame(
  USUBJID = seq(1, N_pop, by = 1),
  ARM = sample(c("ARM A", "ARM B"), N_pop, TRUE),
  SEX = sample(c("F", "M"), N_pop, TRUE),
  AGE = 20 + rbinom(N_pop, size = 40, prob = 0.7)
)

l.adae <- mapply(
  ADSL2$USUBJID,
  ADSL2$ARM,
  ADSL2$SEX,
  ADSL2$AGE,
  FUN = function(id, arm, sex, age) {
    n_ae <- sample(0:25, 1, prob = if (arm == "ARM A") weightsA else weightsB)
    i <- sample(seq_len(nrow(lookup)), size = n_ae, replace = TRUE, prob = c(6, rep(1, 10)) / 16)
    lookup[i, ] |>
      mutate(
        AESEQ = seq_len(n()),
        USUBJID = id, ARM = arm, SEX = sex, AGE = age
      )
  },
  SIMPLIFY = FALSE
)

ADAE2 <- do.call(rbind, l.adae)
ADAE2 <- ADAE2 |>
  mutate(
    ARM = factor(ARM, levels = c("ARM A", "ARM B")),
    AEDECOD = as.factor(AEDECOD),
    AEBODSYS = as.factor(AEBODSYS),
    AETOXGR = factor(AETOXGR, levels = as.character(1:5))
  ) |>
  select(USUBJID, ARM, AGE, SEX, AESEQ, AEDECOD, AEBODSYS, AETOXGR)

ADAE2
# # A tibble: 3,118 × 8
#    USUBJID ARM     AGE SEX   AESEQ AEDECOD               AEBODSYS        AETOXGR
#      <dbl> <fct> <dbl> <chr> <int> <fct>                 <fct>           <fct>  
#  1       1 ARM A    45 F         1 NAUSEA (INTERMITTENT) GASTROINTESTIN… 2      
#  2       1 ARM A    45 F         2 HEADACHE              NERVOUS SYSTEM… 5      
#  3       1 ARM A    45 F         3 HEADACHE              NERVOUS SYSTEM… 5      
#  4       1 ARM A    45 F         4 HEADACHE              NERVOUS SYSTEM… 5      
#  5       1 ARM A    45 F         5 HEADACHE              NERVOUS SYSTEM… 5      
#  6       1 ARM A    45 F         6 HEADACHE              NERVOUS SYSTEM… 5      
#  7       1 ARM A    45 F         7 HEADACHE              NERVOUS SYSTEM… 5      
#  8       1 ARM A    45 F         8 HEADACHE              NERVOUS SYSTEM… 5      
#  9       1 ARM A    45 F         9 HEADACHE              NERVOUS SYSTEM… 5      
# 10       1 ARM A    45 F        10 FAECES SOFT           GASTROINTESTIN… 2      
# # ℹ 3,108 more rows
```

### Adverse Events By ID

We start by defining an events summary function:

``` r

s_events_patients <- function(x, labelstr, .N_col) {
  in_rows(
    "Total number of patients with at least one event" =
      rcell(length(unique(x)) * c(1, 1 / .N_col), format = "xx (xx.xx%)"),
    "Total number of events" = rcell(length(x), format = "xx")
  )
}
```

So, for a population of `5` patients where

- one patient has 2 `AE`s
- one patient has 1 `AE`
- three patients have no `AE`s

we would get the following summary:

``` r

s_events_patients(x = c("id 1", "id 1", "id 2"), .N_col = 5)
# RowsVerticalSection (in_rows) object print method:
# ----------------------------
#                                           row_name formatted_cell indent_mod
# 1 Total number of patients with at least one event     2 (40.00%)          0
# 2                           Total number of events              3          0
#                                          row_label
# 1 Total number of patients with at least one event
# 2                           Total number of events
```

The `.N_col` argument is a special keyword argument by which
[`build_table()`](https://pharmaverse.github.io/rtables/reference/build_table.md)
passes the population size for each respective column. For a list of
keyword arguments for the functions passed to `afun` in
[`analyze()`](https://pharmaverse.github.io/rtables/reference/analyze.md),
refer to the documentation with
[`?analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md).

We now use the `s_events_patients` summary function in a tabulation:

``` r

adae_lyt <- basic_table(show_colcounts = TRUE) |>
  split_cols_by("ARM") |>
  analyze("USUBJID", s_events_patients)

adae_tbl <- build_table(adae_lyt, ADAE2)
adae_tbl
#                                                       ARM A         ARM B    
#                                                     (N=2060)       (N=1058)  
# —————————————————————————————————————————————————————————————————————————————
# Total number of patients with at least one event   114 (5.53%)   150 (14.18%)
# Total number of events                                2060           1058
```

Note that the column `N`s are wrong as by default they are set to the
number of rows per group (i.e. number of `AE`s per arm here). This also
affects the percentages. For this table we are interested in the number
of patients per column/arm which is usually taken from `ADSL` (var
`ADSL2` here).

`rtables` handles this by allowing us to override how the column counts
are computed. We can specify an `alt_counts_df` in
[`build_table()`](https://pharmaverse.github.io/rtables/reference/build_table.md).
When we do this, `rtables` calculates the column counts by applying the
same column faceting to `alt_counts_df` as it does to the primary data
during tabulation:

``` r

adae_adsl_tbl <- build_table(adae_lyt, ADAE2, alt_counts_df = ADSL2)
adae_adsl_tbl
#                                                       ARM A          ARM B    
#                                                      (N=146)        (N=154)   
# ——————————————————————————————————————————————————————————————————————————————
# Total number of patients with at least one event   114 (78.08%)   150 (97.40%)
# Total number of events                                 2060           1058
```

Alternatively, if the desired column counts are already calculated, they
can be specified directly via the `col_counts` argument to
[`build_table()`](https://pharmaverse.github.io/rtables/reference/build_table.md),
though specifying an `alt_counts_df` is the preferred mechanism (the
number of rows will be used, but no duplicate checking!!!).

We next calculate this information per system organ class:

``` r

adae_soc_lyt <- basic_table(show_colcounts = TRUE) |>
  split_cols_by("ARM") |>
  analyze("USUBJID", s_events_patients) |>
  split_rows_by("AEBODSYS", child_labels = "visible", nested = FALSE) |>
  summarize_row_groups("USUBJID", cfun = s_events_patients)

adae_soc_tbl <- build_table(adae_soc_lyt, ADAE2, alt_counts_df = ADSL2)
adae_soc_tbl
#                                                         ARM A          ARM B    
#                                                        (N=146)        (N=154)   
# ————————————————————————————————————————————————————————————————————————————————
# Total number of patients with at least one event     114 (78.08%)   150 (97.40%)
# Total number of events                                   2060           1058    
# GASTROINTESTINAL DISORDERS                                                      
#   Total number of patients with at least one event   114 (78.08%)   130 (84.42%)
#   Total number of events                                 760            374     
# MUSCULOSKELETAL AND CONNECTIVE TISSUE DISORDERS                                 
#   Total number of patients with at least one event   98 (67.12%)    81 (52.60%) 
#   Total number of events                                 273            142     
# NERVOUS SYSTEM DISORDERS                                                        
#   Total number of patients with at least one event   113 (77.40%)   133 (86.36%)
#   Total number of events                                 787            420     
# VASCULAR DISORDERS                                                              
#   Total number of patients with at least one event   93 (63.70%)    75 (48.70%) 
#   Total number of events                                 240            122
```

We now have to add a count table of `AEDECOD` for each `AEBODSYS`. The
default
[`analyze()`](https://pharmaverse.github.io/rtables/reference/analyze.md)
behavior for a factor is to create the count table per level (using
`rtab_inner`):

``` r

adae_soc_lyt2 <- basic_table(show_colcounts = TRUE) |>
  split_cols_by("ARM") |>
  split_rows_by("AEBODSYS", child_labels = "visible", indent_mod = 1) |>
  summarize_row_groups("USUBJID", cfun = s_events_patients) |>
  analyze("AEDECOD", indent_mod = -1)

adae_soc_tbl2 <- build_table(adae_soc_lyt2, ADAE2, alt_counts_df = ADSL2)
adae_soc_tbl2
#                                                           ARM A          ARM B    
#                                                          (N=146)        (N=154)   
# ——————————————————————————————————————————————————————————————————————————————————
#   GASTROINTESTINAL DISORDERS                                                      
#     Total number of patients with at least one event   114 (78.08%)   130 (84.42%)
#     Total number of events                                 760            374     
#     ABDOMINAL DISCOMFORT                                   113             65     
#     ABDOMINAL FULLNESS DUE TO GAS                          119             65     
#     BACK PAIN                                               0              0      
#     DIARRHEA                                               107             53     
#     FAECES SOFT                                            122             58     
#     GINGIVAL BLEEDING                                      147             71     
#     HEADACHE                                                0              0      
#     HYPOTENSION                                             0              0      
#     NAUSEA (INTERMITTENT)                                  152             62     
#     ORTHOSTATIC HYPOTENSION                                 0              0      
#     WEAKNESS                                                0              0      
#   MUSCULOSKELETAL AND CONNECTIVE TISSUE DISORDERS                                 
#     Total number of patients with at least one event   98 (67.12%)    81 (52.60%) 
#     Total number of events                                 273            142     
#     ABDOMINAL DISCOMFORT                                    0              0      
#     ABDOMINAL FULLNESS DUE TO GAS                           0              0      
#     BACK PAIN                                              135             75     
#     DIARRHEA                                                0              0      
#     FAECES SOFT                                             0              0      
#     GINGIVAL BLEEDING                                       0              0      
#     HEADACHE                                                0              0      
#     HYPOTENSION                                             0              0      
#     NAUSEA (INTERMITTENT)                                   0              0      
#     ORTHOSTATIC HYPOTENSION                                 0              0      
#     WEAKNESS                                               138             67     
#   NERVOUS SYSTEM DISORDERS                                                        
#     Total number of patients with at least one event   113 (77.40%)   133 (86.36%)
#     Total number of events                                 787            420     
#     ABDOMINAL DISCOMFORT                                    0              0      
#     ABDOMINAL FULLNESS DUE TO GAS                           0              0      
#     BACK PAIN                                               0              0      
#     DIARRHEA                                                0              0      
#     FAECES SOFT                                             0              0      
#     GINGIVAL BLEEDING                                       0              0      
#     HEADACHE                                               787            420     
#     HYPOTENSION                                             0              0      
#     NAUSEA (INTERMITTENT)                                   0              0      
#     ORTHOSTATIC HYPOTENSION                                 0              0      
#     WEAKNESS                                                0              0      
#   VASCULAR DISORDERS                                                              
#     Total number of patients with at least one event   93 (63.70%)    75 (48.70%) 
#     Total number of events                                 240            122     
#     ABDOMINAL DISCOMFORT                                    0              0      
#     ABDOMINAL FULLNESS DUE TO GAS                           0              0      
#     BACK PAIN                                               0              0      
#     DIARRHEA                                                0              0      
#     FAECES SOFT                                             0              0      
#     GINGIVAL BLEEDING                                       0              0      
#     HEADACHE                                                0              0      
#     HYPOTENSION                                            104             58     
#     NAUSEA (INTERMITTENT)                                   0              0      
#     ORTHOSTATIC HYPOTENSION                                136             64     
#     WEAKNESS                                                0              0
```

The `indent_mod` argument enables relative indenting changes if the tree
structure of the table does not result in the desired indentation by
default.

This table so far is however not the usual adverse event table as it
counts the total number of events and not the number of subjects for one
or more events for a particular term. To get the correct table we need
to write a custom analysis function:

``` r

table_count_once_per_id <- function(df, termvar = "AEDECOD", idvar = "USUBJID") {
  x <- df[[termvar]]
  id <- df[[idvar]]

  counts <- table(x[!duplicated(id)])

  in_rows(
    .list = as.vector(counts),
    .labels = names(counts)
  )
}

table_count_once_per_id(ADAE2)
# RowsVerticalSection (in_rows) object print method:
# ----------------------------
#                         row_name formatted_cell indent_mod
# 1           ABDOMINAL DISCOMFORT             23          0
# 2  ABDOMINAL FULLNESS DUE TO GAS             21          0
# 3                      BACK PAIN             20          0
# 4                       DIARRHEA              7          0
# 5                    FAECES SOFT             11          0
# 6              GINGIVAL BLEEDING             15          0
# 7                       HEADACHE            100          0
# 8                    HYPOTENSION             16          0
# 9          NAUSEA (INTERMITTENT)             21          0
# 10       ORTHOSTATIC HYPOTENSION             14          0
# 11                      WEAKNESS             16          0
#                        row_label
# 1           ABDOMINAL DISCOMFORT
# 2  ABDOMINAL FULLNESS DUE TO GAS
# 3                      BACK PAIN
# 4                       DIARRHEA
# 5                    FAECES SOFT
# 6              GINGIVAL BLEEDING
# 7                       HEADACHE
# 8                    HYPOTENSION
# 9          NAUSEA (INTERMITTENT)
# 10       ORTHOSTATIC HYPOTENSION
# 11                      WEAKNESS
```

So the desired `AE` table is:

``` r

adae_soc_lyt3 <- basic_table(show_colcounts = TRUE) |>
  split_cols_by("ARM") |>
  split_rows_by("AEBODSYS", child_labels = "visible", indent_mod = 1) |>
  summarize_row_groups("USUBJID", cfun = s_events_patients) |>
  analyze("AEDECOD", afun = table_count_once_per_id, show_labels = "hidden", indent_mod = -1)

adae_soc_tbl3 <- build_table(adae_soc_lyt3, ADAE2, alt_counts_df = ADSL2)
adae_soc_tbl3
#                                                           ARM A          ARM B    
#                                                          (N=146)        (N=154)   
# ——————————————————————————————————————————————————————————————————————————————————
#   GASTROINTESTINAL DISORDERS                                                      
#     Total number of patients with at least one event   114 (78.08%)   130 (84.42%)
#     Total number of events                                 760            374     
#     ABDOMINAL DISCOMFORT                                    24             28     
#     ABDOMINAL FULLNESS DUE TO GAS                           18             26     
#     BACK PAIN                                               0              0      
#     DIARRHEA                                                17             17     
#     FAECES SOFT                                             17             14     
#     GINGIVAL BLEEDING                                       18             25     
#     HEADACHE                                                0              0      
#     HYPOTENSION                                             0              0      
#     NAUSEA (INTERMITTENT)                                   20             20     
#     ORTHOSTATIC HYPOTENSION                                 0              0      
#     WEAKNESS                                                0              0      
#   MUSCULOSKELETAL AND CONNECTIVE TISSUE DISORDERS                                 
#     Total number of patients with at least one event   98 (67.12%)    81 (52.60%) 
#     Total number of events                                 273            142     
#     ABDOMINAL DISCOMFORT                                    0              0      
#     ABDOMINAL FULLNESS DUE TO GAS                           0              0      
#     BACK PAIN                                               58             45     
#     DIARRHEA                                                0              0      
#     FAECES SOFT                                             0              0      
#     GINGIVAL BLEEDING                                       0              0      
#     HEADACHE                                                0              0      
#     HYPOTENSION                                             0              0      
#     NAUSEA (INTERMITTENT)                                   0              0      
#     ORTHOSTATIC HYPOTENSION                                 0              0      
#     WEAKNESS                                                40             36     
#   NERVOUS SYSTEM DISORDERS                                                        
#     Total number of patients with at least one event   113 (77.40%)   133 (86.36%)
#     Total number of events                                 787            420     
#     ABDOMINAL DISCOMFORT                                    0              0      
#     ABDOMINAL FULLNESS DUE TO GAS                           0              0      
#     BACK PAIN                                               0              0      
#     DIARRHEA                                                0              0      
#     FAECES SOFT                                             0              0      
#     GINGIVAL BLEEDING                                       0              0      
#     HEADACHE                                               113            133     
#     HYPOTENSION                                             0              0      
#     NAUSEA (INTERMITTENT)                                   0              0      
#     ORTHOSTATIC HYPOTENSION                                 0              0      
#     WEAKNESS                                                0              0      
#   VASCULAR DISORDERS                                                              
#     Total number of patients with at least one event   93 (63.70%)    75 (48.70%) 
#     Total number of events                                 240            122     
#     ABDOMINAL DISCOMFORT                                    0              0      
#     ABDOMINAL FULLNESS DUE TO GAS                           0              0      
#     BACK PAIN                                               0              0      
#     DIARRHEA                                                0              0      
#     FAECES SOFT                                             0              0      
#     GINGIVAL BLEEDING                                       0              0      
#     HEADACHE                                                0              0      
#     HYPOTENSION                                             44             31     
#     NAUSEA (INTERMITTENT)                                   0              0      
#     ORTHOSTATIC HYPOTENSION                                 49             44     
#     WEAKNESS                                                0              0
```

Note that we are missing the overall summary in the first two rows. This
can be added with an initial
[`analyze()`](https://pharmaverse.github.io/rtables/reference/analyze.md)
call.

``` r

adae_soc_lyt4 <- basic_table(show_colcounts = TRUE) |>
  split_cols_by("ARM") |>
  analyze("USUBJID", afun = s_events_patients) |>
  split_rows_by("AEBODSYS", child_labels = "visible", indent_mod = 1, section_div = "") |>
  summarize_row_groups("USUBJID", cfun = s_events_patients) |>
  analyze("AEDECOD", table_count_once_per_id, show_labels = "hidden", indent_mod = -1)

adae_soc_tbl4 <- build_table(adae_soc_lyt4, ADAE2, alt_counts_df = ADSL2)
adae_soc_tbl4
#                                                           ARM A          ARM B    
#                                                          (N=146)        (N=154)   
# ——————————————————————————————————————————————————————————————————————————————————
# Total number of patients with at least one event       114 (78.08%)   150 (97.40%)
# Total number of events                                     2060           1058    
#   GASTROINTESTINAL DISORDERS                                                      
#     Total number of patients with at least one event   114 (78.08%)   130 (84.42%)
#     Total number of events                                 760            374     
#     ABDOMINAL DISCOMFORT                                    24             28     
#     ABDOMINAL FULLNESS DUE TO GAS                           18             26     
#     BACK PAIN                                               0              0      
#     DIARRHEA                                                17             17     
#     FAECES SOFT                                             17             14     
#     GINGIVAL BLEEDING                                       18             25     
#     HEADACHE                                                0              0      
#     HYPOTENSION                                             0              0      
#     NAUSEA (INTERMITTENT)                                   20             20     
#     ORTHOSTATIC HYPOTENSION                                 0              0      
#     WEAKNESS                                                0              0      
# 
#   MUSCULOSKELETAL AND CONNECTIVE TISSUE DISORDERS                                 
#     Total number of patients with at least one event   98 (67.12%)    81 (52.60%) 
#     Total number of events                                 273            142     
#     ABDOMINAL DISCOMFORT                                    0              0      
#     ABDOMINAL FULLNESS DUE TO GAS                           0              0      
#     BACK PAIN                                               58             45     
#     DIARRHEA                                                0              0      
#     FAECES SOFT                                             0              0      
#     GINGIVAL BLEEDING                                       0              0      
#     HEADACHE                                                0              0      
#     HYPOTENSION                                             0              0      
#     NAUSEA (INTERMITTENT)                                   0              0      
#     ORTHOSTATIC HYPOTENSION                                 0              0      
#     WEAKNESS                                                40             36     
# 
#   NERVOUS SYSTEM DISORDERS                                                        
#     Total number of patients with at least one event   113 (77.40%)   133 (86.36%)
#     Total number of events                                 787            420     
#     ABDOMINAL DISCOMFORT                                    0              0      
#     ABDOMINAL FULLNESS DUE TO GAS                           0              0      
#     BACK PAIN                                               0              0      
#     DIARRHEA                                                0              0      
#     FAECES SOFT                                             0              0      
#     GINGIVAL BLEEDING                                       0              0      
#     HEADACHE                                               113            133     
#     HYPOTENSION                                             0              0      
#     NAUSEA (INTERMITTENT)                                   0              0      
#     ORTHOSTATIC HYPOTENSION                                 0              0      
#     WEAKNESS                                                0              0      
# 
#   VASCULAR DISORDERS                                                              
#     Total number of patients with at least one event   93 (63.70%)    75 (48.70%) 
#     Total number of events                                 240            122     
#     ABDOMINAL DISCOMFORT                                    0              0      
#     ABDOMINAL FULLNESS DUE TO GAS                           0              0      
#     BACK PAIN                                               0              0      
#     DIARRHEA                                                0              0      
#     FAECES SOFT                                             0              0      
#     GINGIVAL BLEEDING                                       0              0      
#     HEADACHE                                                0              0      
#     HYPOTENSION                                             44             31     
#     NAUSEA (INTERMITTENT)                                   0              0      
#     ORTHOSTATIC HYPOTENSION                                 49             44     
#     WEAKNESS                                                0              0
```

Finally, if we wanted to prune the 0 count rows we can do that with the
[`trim_rows()`](https://pharmaverse.github.io/rtables/reference/trim_rows.md)
function:

``` r

trim_rows(adae_soc_tbl4)
#                                                           ARM A          ARM B    
#                                                          (N=146)        (N=154)   
# ——————————————————————————————————————————————————————————————————————————————————
# Total number of patients with at least one event       114 (78.08%)   150 (97.40%)
# Total number of events                                     2060           1058    
#   GASTROINTESTINAL DISORDERS                                                      
#     Total number of patients with at least one event   114 (78.08%)   130 (84.42%)
#     Total number of events                                 760            374     
#     ABDOMINAL DISCOMFORT                                    24             28     
#     ABDOMINAL FULLNESS DUE TO GAS                           18             26     
#     DIARRHEA                                                17             17     
#     FAECES SOFT                                             17             14     
#     GINGIVAL BLEEDING                                       18             25     
#     NAUSEA (INTERMITTENT)                                   20             20     
# 
#   MUSCULOSKELETAL AND CONNECTIVE TISSUE DISORDERS                                 
#     Total number of patients with at least one event   98 (67.12%)    81 (52.60%) 
#     Total number of events                                 273            142     
#     BACK PAIN                                               58             45     
#     WEAKNESS                                                40             36     
# 
#   NERVOUS SYSTEM DISORDERS                                                        
#     Total number of patients with at least one event   113 (77.40%)   133 (86.36%)
#     Total number of events                                 787            420     
#     HEADACHE                                               113            133     
# 
#   VASCULAR DISORDERS                                                              
#     Total number of patients with at least one event   93 (63.70%)    75 (48.70%) 
#     Total number of events                                 240            122     
#     HYPOTENSION                                             44             31     
#     ORTHOSTATIC HYPOTENSION                                 49             44
```

Pruning is a larger topic with a [separate `rtables` package
vignette](https://pharmaverse.github.io/rtables/latest-tag/articles/sorting_pruning.html).

### Adverse Events By ID and By Grade

The adverse events table by ID and by grade shows how many patients had
at least one adverse event per grade for different subsets of the data
(e.g. defined by system organ class).

For this table we do not show the zero count grades. Note that we add
the “overall” groups with a custom split function.

``` r

table_count_grade_once_per_id <- function(df,
                                          labelstr = "",
                                          gradevar = "AETOXGR",
                                          idvar = "USUBJID",
                                          grade_levels = NULL) {
  id <- df[[idvar]]
  grade <- df[[gradevar]]

  if (!is.null(grade_levels)) {
    stopifnot(all(grade %in% grade_levels))
    grade <- factor(grade, levels = grade_levels)
  }

  id_sel <- !duplicated(id)

  in_rows(
    "--Any Grade--" = sum(id_sel),
    .list = as.list(table(grade[id_sel]))
  )
}

table_count_grade_once_per_id(ex_adae, grade_levels = 1:5)
# RowsVerticalSection (in_rows) object print method:
# ----------------------------
#        row_name formatted_cell indent_mod     row_label
# 1 --Any Grade--            365          0 --Any Grade--
# 2             1            131          0             1
# 3             2             70          0             2
# 4             3             74          0             3
# 5             4             25          0             4
# 6             5             65          0             5
```

All of the layouting concepts needed to create this table have already
been introduced so far:

``` r

adae_grade_lyt <- basic_table(show_colcounts = TRUE) |>
  split_cols_by("ARM") |>
  analyze(
    "AETOXGR",
    afun = table_count_grade_once_per_id,
    extra_args = list(grade_levels = 1:5),
    var_labels = "- Any adverse events -",
    show_labels = "visible"
  ) |>
  split_rows_by("AEBODSYS", child_labels = "visible", indent_mod = 1) |>
  summarize_row_groups(cfun = table_count_grade_once_per_id, format = "xx", indent_mod = 1) |>
  split_rows_by("AEDECOD", child_labels = "visible", indent_mod = -2) |>
  analyze(
    "AETOXGR",
    afun = table_count_grade_once_per_id,
    extra_args = list(grade_levels = 1:5),
    show_labels = "hidden"
  )

adae_grade_tbl <- build_table(adae_grade_lyt, ADAE2, alt_counts_df = ADSL2)
adae_grade_tbl
#                                                      ARM A     ARM B 
#                                                     (N=146)   (N=154)
# —————————————————————————————————————————————————————————————————————
# - Any adverse events -                                               
#   --Any Grade--                                       114       150  
#   1                                                   32        34   
#   2                                                   22        30   
#   3                                                   11        21   
#   4                                                    8         6   
#   5                                                   41        59   
#   GASTROINTESTINAL DISORDERS                                         
#         --Any Grade--                                 114       130  
#         1                                             77        96   
#         2                                             37        34   
#         3                                              0         0   
#         4                                              0         0   
#         5                                              0         0   
#     ABDOMINAL DISCOMFORT                                             
#       --Any Grade--                                   68        49   
#       1                                               68        49   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     ABDOMINAL FULLNESS DUE TO GAS                                    
#       --Any Grade--                                   73        51   
#       1                                               73        51   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     BACK PAIN                                                        
#       --Any Grade--                                    0         0   
#       1                                                0         0   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     DIARRHEA                                                         
#       --Any Grade--                                   68        40   
#       1                                               68        40   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     FAECES SOFT                                                      
#       --Any Grade--                                   76        44   
#       1                                                0         0   
#       2                                               76        44   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     GINGIVAL BLEEDING                                                
#       --Any Grade--                                   80        52   
#       1                                               80        52   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     HEADACHE                                                         
#       --Any Grade--                                    0         0   
#       1                                                0         0   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     HYPOTENSION                                                      
#       --Any Grade--                                    0         0   
#       1                                                0         0   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     NAUSEA (INTERMITTENT)                                            
#       --Any Grade--                                   83        50   
#       1                                                0         0   
#       2                                               83        50   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     ORTHOSTATIC HYPOTENSION                                          
#       --Any Grade--                                    0         0   
#       1                                                0         0   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     WEAKNESS                                                         
#       --Any Grade--                                    0         0   
#       1                                                0         0   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#   MUSCULOSKELETAL AND CONNECTIVE TISSUE DISORDERS                    
#         --Any Grade--                                 98        81   
#         1                                              0         0   
#         2                                             58        45   
#         3                                             40        36   
#         4                                              0         0   
#         5                                              0         0   
#     ABDOMINAL DISCOMFORT                                             
#       --Any Grade--                                    0         0   
#       1                                                0         0   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     ABDOMINAL FULLNESS DUE TO GAS                                    
#       --Any Grade--                                    0         0   
#       1                                                0         0   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     BACK PAIN                                                        
#       --Any Grade--                                   79        62   
#       1                                                0         0   
#       2                                               79        62   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     DIARRHEA                                                         
#       --Any Grade--                                    0         0   
#       1                                                0         0   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     FAECES SOFT                                                      
#       --Any Grade--                                    0         0   
#       1                                                0         0   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     GINGIVAL BLEEDING                                                
#       --Any Grade--                                    0         0   
#       1                                                0         0   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     HEADACHE                                                         
#       --Any Grade--                                    0         0   
#       1                                                0         0   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     HYPOTENSION                                                      
#       --Any Grade--                                    0         0   
#       1                                                0         0   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     NAUSEA (INTERMITTENT)                                            
#       --Any Grade--                                    0         0   
#       1                                                0         0   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     ORTHOSTATIC HYPOTENSION                                          
#       --Any Grade--                                    0         0   
#       1                                                0         0   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     WEAKNESS                                                         
#       --Any Grade--                                   73        43   
#       1                                                0         0   
#       2                                                0         0   
#       3                                               73        43   
#       4                                                0         0   
#       5                                                0         0   
#   NERVOUS SYSTEM DISORDERS                                           
#         --Any Grade--                                 113       133  
#         1                                              0         0   
#         2                                              0         0   
#         3                                              0         0   
#         4                                              0         0   
#         5                                             113       133  
#     ABDOMINAL DISCOMFORT                                             
#       --Any Grade--                                    0         0   
#       1                                                0         0   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     ABDOMINAL FULLNESS DUE TO GAS                                    
#       --Any Grade--                                    0         0   
#       1                                                0         0   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     BACK PAIN                                                        
#       --Any Grade--                                    0         0   
#       1                                                0         0   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     DIARRHEA                                                         
#       --Any Grade--                                    0         0   
#       1                                                0         0   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     FAECES SOFT                                                      
#       --Any Grade--                                    0         0   
#       1                                                0         0   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     GINGIVAL BLEEDING                                                
#       --Any Grade--                                    0         0   
#       1                                                0         0   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     HEADACHE                                                         
#       --Any Grade--                                   113       133  
#       1                                                0         0   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                               113       133  
#     HYPOTENSION                                                      
#       --Any Grade--                                    0         0   
#       1                                                0         0   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     NAUSEA (INTERMITTENT)                                            
#       --Any Grade--                                    0         0   
#       1                                                0         0   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     ORTHOSTATIC HYPOTENSION                                          
#       --Any Grade--                                    0         0   
#       1                                                0         0   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     WEAKNESS                                                         
#       --Any Grade--                                    0         0   
#       1                                                0         0   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#   VASCULAR DISORDERS                                                 
#         --Any Grade--                                 93        75   
#         1                                              0         0   
#         2                                              0         0   
#         3                                             44        31   
#         4                                             49        44   
#         5                                              0         0   
#     ABDOMINAL DISCOMFORT                                             
#       --Any Grade--                                    0         0   
#       1                                                0         0   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     ABDOMINAL FULLNESS DUE TO GAS                                    
#       --Any Grade--                                    0         0   
#       1                                                0         0   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     BACK PAIN                                                        
#       --Any Grade--                                    0         0   
#       1                                                0         0   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     DIARRHEA                                                         
#       --Any Grade--                                    0         0   
#       1                                                0         0   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     FAECES SOFT                                                      
#       --Any Grade--                                    0         0   
#       1                                                0         0   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     GINGIVAL BLEEDING                                                
#       --Any Grade--                                    0         0   
#       1                                                0         0   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     HEADACHE                                                         
#       --Any Grade--                                    0         0   
#       1                                                0         0   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     HYPOTENSION                                                      
#       --Any Grade--                                   66        43   
#       1                                                0         0   
#       2                                                0         0   
#       3                                               66        43   
#       4                                                0         0   
#       5                                                0         0   
#     NAUSEA (INTERMITTENT)                                            
#       --Any Grade--                                    0         0   
#       1                                                0         0   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0   
#     ORTHOSTATIC HYPOTENSION                                          
#       --Any Grade--                                   70        54   
#       1                                                0         0   
#       2                                                0         0   
#       3                                                0         0   
#       4                                               70        54   
#       5                                                0         0   
#     WEAKNESS                                                         
#       --Any Grade--                                    0         0   
#       1                                                0         0   
#       2                                                0         0   
#       3                                                0         0   
#       4                                                0         0   
#       5                                                0         0
```

## Response Table

The response table that we will create here is composed of 3 parts:

1.  Binary response table
2.  Unstratified analysis comparison vs. control group
3.  Multinomial response table

Let’s start with the first part which is fairly simple to derive:

``` r

ADRS_BESRSPI <- ex_adrs |>
  filter(PARAMCD == "BESRSPI") |>
  mutate(
    rsp = factor(AVALC %in% c("CR", "PR"), levels = c(TRUE, FALSE), labels = c("Responders", "Non-Responders")),
    is_rsp = (rsp == "Responders")
  )

s_proportion <- function(x, .N_col) {
  in_rows(
    .list = lapply(
      as.list(table(x)),
      function(xi) rcell(xi * c(1, 1 / .N_col), format = "xx.xx (xx.xx%)")
    )
  )
}

rsp_lyt <- basic_table(show_colcounts = TRUE) |>
  split_cols_by("ARMCD", ref_group = "ARM A") |>
  analyze("rsp", s_proportion, show_labels = "hidden")

rsp_tbl <- build_table(rsp_lyt, ADRS_BESRSPI)
rsp_tbl
#                       ARM A            ARM B             ARM C     
#                      (N=134)          (N=134)           (N=132)    
# ———————————————————————————————————————————————————————————————————
# Responders       114.00 (85.07%)   90.00 (67.16%)   120.00 (90.91%)
# Non-Responders   20.00 (14.93%)    44.00 (32.84%)    12.00 (9.09%)
```

Note that we did set the `ref_group` argument in
[`split_cols_by()`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)
which for the current table had no effect as we only use the cell data
for the responder and non-responder counts. The `ref_group` argument is
needed for the part 2 and 3 of the table.

We will now look the implementation of part 2: unstratified analysis
comparison vs. control group. Let’s start with the analysis function:

``` r

s_unstrat_resp <- function(x, .ref_group, .in_ref_col) {
  if (.in_ref_col) {
    return(in_rows(
      "Difference in Response Rates (%)" = rcell(numeric(0)),
      "95% CI (Wald, with correction)" = rcell(numeric(0)),
      "p-value (Chi-Squared Test)" = rcell(numeric(0)),
      "Odds Ratio (95% CI)" = rcell(numeric(0))
    ))
  }

  fit <- stats::prop.test(
    x = c(sum(x), sum(.ref_group)),
    n = c(length(x), length(.ref_group)),
    correct = FALSE
  )

  fit_glm <- stats::glm(
    formula = rsp ~ group,
    data = data.frame(
      rsp = c(.ref_group, x),
      group = factor(rep(c("ref", "x"), times = c(length(.ref_group), length(x))), levels = c("ref", "x"))
    ),
    family = binomial(link = "logit")
  )

  in_rows(
    "Difference in Response Rates (%)" = non_ref_rcell(
      (mean(x) - mean(.ref_group)) * 100,
      .in_ref_col,
      format = "xx.xx"
    ),
    "95% CI (Wald, with correction)" = non_ref_rcell(
      fit$conf.int * 100,
      .in_ref_col,
      format = "(xx.xx, xx.xx)"
    ),
    "p-value (Chi-Squared Test)" = non_ref_rcell(
      fit$p.value,
      .in_ref_col,
      format = "x.xxxx | (<0.0001)"
    ),
    "Odds Ratio (95% CI)" = non_ref_rcell(
      c(
        exp(stats::coef(fit_glm)[-1]),
        exp(stats::confint.default(fit_glm, level = .95)[-1, , drop = FALSE])
      ),
      .in_ref_col,
      format = "xx.xx (xx.xx - xx.xx)"
    )
  )
}

s_unstrat_resp(
  x = ADRS_BESRSPI |> filter(ARM == "A: Drug X") |> pull(is_rsp),
  .ref_group = ADRS_BESRSPI |> filter(ARM == "B: Placebo") |> pull(is_rsp),
  .in_ref_col = FALSE
)
# RowsVerticalSection (in_rows) object print method:
# ----------------------------
#                           row_name     formatted_cell indent_mod
# 1 Difference in Response Rates (%)              17.91          0
# 2   95% CI (Wald, with correction)      (7.93, 27.89)          0
# 3       p-value (Chi-Squared Test)             0.0006          0
# 4              Odds Ratio (95% CI) 2.79 (1.53 - 5.06)          0
#                          row_label
# 1 Difference in Response Rates (%)
# 2   95% CI (Wald, with correction)
# 3       p-value (Chi-Squared Test)
# 4              Odds Ratio (95% CI)
```

Hence we can now add the next vignette to the table:

``` r

rsp_lyt2 <- basic_table(show_colcounts = TRUE) |>
  split_cols_by("ARMCD", ref_group = "ARM A") |>
  analyze("rsp", s_proportion, show_labels = "hidden") |>
  analyze(
    "is_rsp", s_unstrat_resp,
    show_labels = "visible",
    var_labels = "Unstratified Response Analysis"
  )

rsp_tbl2 <- build_table(rsp_lyt2, ADRS_BESRSPI)
rsp_tbl2
#                                           ARM A              ARM B                ARM C       
#                                          (N=134)            (N=134)              (N=132)      
# ——————————————————————————————————————————————————————————————————————————————————————————————
# Responders                           114.00 (85.07%)     90.00 (67.16%)      120.00 (90.91%)  
# Non-Responders                       20.00 (14.93%)      44.00 (32.84%)       12.00 (9.09%)   
# Unstratified Response Analysis                                                                
#   Difference in Response Rates (%)                           -17.91                5.83       
#   95% CI (Wald, with correction)                        (-27.89, -7.93)       (-1.94, 13.61)  
#   p-value (Chi-Squared Test)                                 0.0006               0.1436      
#   Odds Ratio (95% CI)                                  0.36 (0.20 - 0.65)   1.75 (0.82 - 3.75)
```

Next we will add part 3: the multinomial response table. To do so, we
are adding a row-split by response level, and then doing the same thing
as we did for the binary response table above.

``` r

s_prop <- function(df, .N_col) {
  in_rows(
    "95% CI (Wald, with correction)" = rcell(binom.test(nrow(df), .N_col)$conf.int * 100, format = "(xx.xx, xx.xx)")
  )
}

s_prop(
  df = ADRS_BESRSPI |> filter(ARM == "A: Drug X", AVALC == "CR"),
  .N_col = sum(ADRS_BESRSPI$ARM == "A: Drug X")
)
# RowsVerticalSection (in_rows) object print method:
# ----------------------------
#                         row_name formatted_cell indent_mod
# 1 95% CI (Wald, with correction) (49.38, 66.67)          0
#                        row_label
# 1 95% CI (Wald, with correction)
```

We can now create the final response table with all three parts:

``` r

rsp_lyt3 <- basic_table(show_colcounts = TRUE) |>
  split_cols_by("ARMCD", ref_group = "ARM A") |>
  analyze("rsp", s_proportion, show_labels = "hidden") |>
  analyze(
    "is_rsp", s_unstrat_resp,
    show_labels = "visible", var_labels = "Unstratified Response Analysis"
  ) |>
  split_rows_by(
    var = "AVALC",
    split_fun = reorder_split_levels(neworder = c("CR", "PR", "SD", "PD", "NE"), drlevels = TRUE),
    nested = FALSE
  ) |>
  summarize_row_groups() |>
  analyze("AVALC", afun = s_prop)

rsp_tbl3 <- build_table(rsp_lyt3, ADRS_BESRSPI)
rsp_tbl3
#                                           ARM A              ARM B                ARM C       
#                                          (N=134)            (N=134)              (N=132)      
# ——————————————————————————————————————————————————————————————————————————————————————————————
# Responders                           114.00 (85.07%)     90.00 (67.16%)      120.00 (90.91%)  
# Non-Responders                       20.00 (14.93%)      44.00 (32.84%)       12.00 (9.09%)   
# Unstratified Response Analysis                                                                
#   Difference in Response Rates (%)                           -17.91                5.83       
#   95% CI (Wald, with correction)                        (-27.89, -7.93)       (-1.94, 13.61)  
#   p-value (Chi-Squared Test)                                 0.0006               0.1436      
#   Odds Ratio (95% CI)                                  0.36 (0.20 - 0.65)   1.75 (0.82 - 3.75)
# CR                                     78 (58.2%)          55 (41.0%)           97 (73.5%)    
#   95% CI (Wald, with correction)     (49.38, 66.67)      (32.63, 49.87)       (65.10, 80.79)  
# PR                                     36 (26.9%)          35 (26.1%)           23 (17.4%)    
#   95% CI (Wald, with correction)     (19.58, 35.20)      (18.92, 34.41)       (11.38, 24.99)  
# SD                                     20 (14.9%)          44 (32.8%)           12 (9.1%)     
#   95% CI (Wald, with correction)      (9.36, 22.11)      (24.97, 41.47)       (4.79, 15.34)   
# PD                                      0 (0.0%)            0 (0.0%)             0 (0.0%)     
#   95% CI (Wald, with correction)      (0.00, 2.72)        (0.00, 2.72)         (0.00, 2.76)   
# NE                                      0 (0.0%)            0 (0.0%)             0 (0.0%)     
#   95% CI (Wald, with correction)      (0.00, 2.72)        (0.00, 2.72)         (0.00, 2.76)
```

In the case that we wanted to rename the levels of `AVALC` and remove
the CI for `NE` we could do that as follows:

``` r

rsp_label <- function(x) {
  rsp_full_label <- c(
    CR = "Complete Response (CR)",
    PR = "Partial Response (PR)",
    SD = "Stable Disease (SD)",
    `NON CR/PD` = "Non-CR or Non-PD (NON CR/PD)",
    PD = "Progressive Disease (PD)",
    NE = "Not Evaluable (NE)",
    Missing = "Missing",
    `NE/Missing` = "Missing or unevaluable"
  )
  stopifnot(all(x %in% names(rsp_full_label)))
  rsp_full_label[x]
}


rsp_lyt4 <- basic_table(show_colcounts = TRUE) |>
  split_cols_by("ARMCD", ref_group = "ARM A") |>
  analyze("rsp", s_proportion, show_labels = "hidden") |>
  analyze(
    "is_rsp", s_unstrat_resp,
    show_labels = "visible", var_labels = "Unstratified Response Analysis"
  ) |>
  split_rows_by(
    var = "AVALC",
    split_fun = keep_split_levels(c("CR", "PR", "SD", "PD"), reorder = TRUE),
    nested = FALSE
  ) |>
  summarize_row_groups(cfun = function(df, labelstr, .N_col) {
    in_rows(nrow(df) * c(1, 1 / .N_col), .formats = "xx (xx.xx%)", .labels = rsp_label(labelstr))
  }) |>
  analyze("AVALC", afun = s_prop) |>
  analyze("AVALC", afun = function(x, .N_col) {
    in_rows(rcell(sum(x == "NE") * c(1, 1 / .N_col), format = "xx.xx (xx.xx%)"), .labels = rsp_label("NE"))
  }, nested = FALSE)

rsp_tbl4 <- build_table(rsp_lyt4, ADRS_BESRSPI)
# Modifying subtable (or row) names to ensure uniqueness among direct siblings
# [AVALC  -> { AVALC, AVALC[2] }]
#   To control table names use split_rows_by*(, parent_name =.) or  analyze(., table_names = .) when analyzing a single variable, or analyze(., parent_name = .) when analyzing multiple variables in a single call.FALSE
rsp_tbl4
#                                           ARM A              ARM B                ARM C       
#                                          (N=134)            (N=134)              (N=132)      
# ——————————————————————————————————————————————————————————————————————————————————————————————
# Responders                           114.00 (85.07%)     90.00 (67.16%)      120.00 (90.91%)  
# Non-Responders                       20.00 (14.93%)      44.00 (32.84%)       12.00 (9.09%)   
# Unstratified Response Analysis                                                                
#   Difference in Response Rates (%)                           -17.91                5.83       
#   95% CI (Wald, with correction)                        (-27.89, -7.93)       (-1.94, 13.61)  
#   p-value (Chi-Squared Test)                                 0.0006               0.1436      
#   Odds Ratio (95% CI)                                  0.36 (0.20 - 0.65)   1.75 (0.82 - 3.75)
# Complete Response (CR)                 78 (58.21%)        55 (41.04%)          97 (73.48%)    
#   95% CI (Wald, with correction)     (49.38, 66.67)      (32.63, 49.87)       (65.10, 80.79)  
# Partial Response (PR)                  36 (26.87%)        35 (26.12%)          23 (17.42%)    
#   95% CI (Wald, with correction)     (19.58, 35.20)      (18.92, 34.41)       (11.38, 24.99)  
# Stable Disease (SD)                    20 (14.93%)        44 (32.84%)           12 (9.09%)    
#   95% CI (Wald, with correction)      (9.36, 22.11)      (24.97, 41.47)       (4.79, 15.34)   
# Progressive Disease (PD)                0 (0.00%)          0 (0.00%)            0 (0.00%)     
#   95% CI (Wald, with correction)      (0.00, 2.72)        (0.00, 2.72)         (0.00, 2.76)   
# Not Evaluable (NE)                    0.00 (0.00%)        0.00 (0.00%)         0.00 (0.00%)
```

Note that the table is missing the rows gaps to make it more readable.
The row spacing feature is on the `rtables` roadmap and will be
implemented in future.

## Time to Event Analysis Table

The time to event analysis table that will be constructed consists of
four parts:

1.  Overall subject counts
2.  Censored subjects summary
3.  Cox proportional-hazards analysis
4.  Time-to-event analysis

The table is constructed by sequential use of the
[`analyze()`](https://pharmaverse.github.io/rtables/reference/analyze.md)
function, with four custom analysis functions corresponding to each of
the four parts listed above. In addition the table includes referential
footnotes relevant to the table contents. The table will be faceted
column-wise by arm.

First we will start by loading the necessary packages and preparing the
data to be used in the construction of this table.

``` r

library(survival)

adtte <- ex_adaette |>
  dplyr::filter(PARAMCD == "AETTE2", SAFFL == "Y")

# Add censoring to data for example
adtte[adtte$AVAL > 1.0, ] <- adtte[adtte$AVAL > 1.0, ] |> mutate(AVAL = 1.0, CNSR = 1)

adtte2 <- adtte |>
  mutate(CNSDTDSC = ifelse(CNSDTDSC == "", "__none__", CNSDTDSC))
```

The `adtte` dataset will be used in preparing the models while the
`adtte2` dataset handles missing values in the “Censor Date Description”
column and will be used to produce the final table. We add censoring
into the data for example purposes.

Next we create a basic analysis function, `a_count_subjs` which prints
the overall unique subject counts and percentages within the data.

``` r

a_count_subjs <- function(x, .N_col) {
  in_rows(
    "Subjects with Adverse Events n (%)" = rcell(length(unique(x)) * c(1, 1 / .N_col), format = "xx (xx.xx%)")
  )
}
```

Then an analysis function is created to generate the counts of censored
subjects for each level of a factor variable in the dataset. In this
case the `cnsr_counter` function will be applied with the `CNSDTDSC`
variable which contains a censor date description for each censored
subject.

``` r

cnsr_counter <- function(df, .var, .N_col) {
  x <- df[!duplicated(df$USUBJID), .var]
  x <- x[x != "__none__"]
  lapply(table(x), function(xi) rcell(xi * c(1, 1 / .N_col), format = "xx (xx.xx%)"))
}
```

This function generates counts and fractions of unique subjects
corresponding to each factor level, excluding missing values (uncensored
patients).

A Cox proportional-hazards (Cox P-H) analysis is generated next with a
third custom analysis function, `a_cph`. Prior to creating the analysis
function, the Cox P-H model is fit to our data using the
[`coxph()`](https://rdrr.io/pkg/survival/man/coxph.html) and
[`Surv()`](https://rdrr.io/pkg/survival/man/Surv.html) functions from
the `survival` package. Then this model is used as input to the `a_cph`
analysis function which returns hazard ratios, 95% confidence intervals,
and p-values comparing against the reference group - in this case the
leftmost column.

``` r

cph <- coxph(Surv(AVAL, CNSR == 0) ~ ACTARM + STRATA1, ties = "exact", data = adtte)

a_cph <- function(df, .var, .in_ref_col, .ref_full, full_cox_fit) {
  if (.in_ref_col) {
    ret <- replicate(3, list(rcell(NULL)))
  } else {
    curtrt <- df[[.var]][1]
    coefs <- coef(full_cox_fit)
    sel_pos <- grep(curtrt, names(coefs), fixed = TRUE)
    hrval <- exp(coefs[sel_pos])
    sdf <- survdiff(Surv(AVAL, CNSR == 0) ~ ACTARM + STRATA1, data = rbind(df, .ref_full))
    pval <- (1 - pchisq(sdf$chisq, length(sdf$n) - 1)) / 2
    ci_val <- exp(unlist(confint(full_cox_fit)[sel_pos, ]))
    ret <- list(
      rcell(hrval, format = "xx.x"),
      rcell(ci_val, format = "(xx.x, xx.x)"),
      rcell(pval, format = "x.xxxx | (<0.0001)")
    )
  }
  in_rows(
    .list = ret,
    .names = c("Hazard ratio", "95% confidence interval", "p-value (one-sided stratified log rank)")
  )
}
```

The fourth and final analysis function, `a_tte`, generates a time to
first adverse event table with three rows corresponding to Median, 95%
Confidence Interval, and Min Max respectively. First a survival table is
constructed from the summary table of a survival model using the
[`survfit()`](https://rdrr.io/pkg/survival/man/survfit.html) and
[`Surv()`](https://rdrr.io/pkg/survival/man/Surv.html) functions from
the `survival` package. This table is then given as input to `a_tte`
which produces the table of time to first adverse event consisting of
the previously mentioned summary statistics.

``` r

surv_tbl <- as.data.frame(
  summary(survfit(Surv(AVAL, CNSR == 0) ~ ACTARM, data = adtte, conf.type = "log-log"))$table
) |>
  tibble::rownames_to_column("ACTARM") |>
  dplyr::mutate(
    ACTARM = factor(gsub("ACTARM=", "", ACTARM), levels = levels(adtte$ACTARM)),
    ind = FALSE
  )

a_tte <- function(df, .var, kp_table) {
  ind <- grep(df[[.var]][1], row.names(kp_table), fixed = TRUE)
  minmax <- range(df[["AVAL"]])
  mm_val_str <- format_value(minmax, format = "xx.x, xx.x")
  rowfn <- list()
  if (all(df$CNSR[df$AVAL == minmax[2]])) {
    mm_val_str <- paste0(mm_val_str, "*")
    rowfn <- "* indicates censoring"
  }
  in_rows(
    Median = kp_table[ind, "median", drop = TRUE],
    "95% confidence interval" = unlist(kp_table[ind, c("0.95LCL", "0.95UCL")]),
    "Min Max" = mm_val_str,
    .formats = c("xx.xx", "xx.xx - xx.xx", "xx"),
    .row_footnotes = list(NULL, NULL, rowfn)
  )
}
```

Additionally, the `a_tte` function creates a referential footnote within
the table to indicate where censoring occurred in the data.

Now we are able to use these four analysis functions to build our time
to event analysis table.

``` r

lyt <- basic_table(show_colcounts = TRUE) |>
  ## Column faceting
  split_cols_by("ARM", ref_group = "A: Drug X") |>
  ## Overall count
  analyze("USUBJID", a_count_subjs, show_labels = "hidden") |>
  ## Censored subjects summary
  analyze("CNSDTDSC", cnsr_counter, var_labels = "Censored Subjects", show_labels = "visible") |>
  ## Cox P-H analysis
  analyze("ARM", a_cph, extra_args = list(full_cox_fit = cph), show_labels = "hidden") |>
  ## Time-to-event analysis
  analyze(
    "ARM", a_tte,
    var_labels = "Time to first adverse event", show_labels = "visible",
    extra_args = list(kp_table = surv_tbl),
    table_names = "kapmeier"
  )

tbl_tte <- build_table(lyt, adtte2)
```

We set the `show_colcounts` argument of
[`basic_table()`](https://pharmaverse.github.io/rtables/reference/basic_table.md)
to `TRUE` to first print the total subject counts for each column. Next
we use
[`split_cols_by()`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)
to split the table into three columns corresponding to the three
different levels of `ARM`, and specify that the first arm, `"A: Drug X"`
should act as the reference group to be compared against - this
reference group is used for the Cox P-H analysis. Then we call
[`analyze()`](https://pharmaverse.github.io/rtables/reference/analyze.md)
sequentially using each of the four custom analysis functions as
argument `afun` and specifying additional arguments where necessary.
Then we use
[`build_table()`](https://pharmaverse.github.io/rtables/reference/build_table.md)
to construct our `rtable` using the `adtte2` dataset.

Finally, we annotate the table using the `fnotes_at_path()` function to
specify that product-limit estimates are used to calculate the
statistics listed under the “Time to first adverse event” heading within
the table. The referential footnote created earlier in the time-to-event
analysis function (`a_tte`) is also displayed.

``` r

fnotes_at_path(
  tbl_tte,
  c("ma_USUBJID_CNSDTDSC_ARM_kapmeier", "kapmeier")
) <- "Product-limit (Kaplan-Meier) estimates."

tbl_tte
#                                             A: Drug X      B: Placebo     C: Combination
#                                              (N=134)         (N=134)         (N=132)    
# ————————————————————————————————————————————————————————————————————————————————————————
# Subjects with Adverse Events n (%)        134 (100.00%)   134 (100.00%)   132 (100.00%) 
# Censored Subjects                                                                       
#   Clinical Cut Off                          6 (4.48%)       3 (2.24%)      14 (10.61%)  
#   Completion or Discontinuation             9 (6.72%)       5 (3.73%)       9 (6.82%)   
#   End of AE Reporting Period               14 (10.45%)      7 (5.22%)      14 (10.61%)  
#   Preferred Term                           11 (8.21%)       5 (3.73%)       13 (9.85%)  
# Hazard ratio                                                   0.7             1.0      
# 95% confidence interval                                    (0.5, 0.9)       (0.8, 1.4)  
# p-value (one-sided stratified log rank)                      0.1070           0.4880    
# Time to first adverse event {1}                                                         
#   Median                                                                                
#   95% confidence interval                                                               
#   Min Max {2}                               0.0, 1.0*       0.0, 1.0*       0.0, 1.0*   
# ————————————————————————————————————————————————————————————————————————————————————————
# 
# {1} - Product-limit (Kaplan-Meier) estimates.
# {2} - * indicates censoring
# ————————————————————————————————————————————————————————————————————————————————————————
```
