# Introspecting Tables

The packages used in this vignette are `rtables` and `dplyr`:

``` r

library(rtables)
library(dplyr)
```

## Introduction

First, let’s set up a simple table.

``` r

lyt <- basic_table() |>
  split_cols_by("ARMCD", show_colcounts = TRUE, colcount_format = "N=xx") |>
  split_cols_by("STRATA2", show_colcounts = TRUE) |>
  split_rows_by("STRATA1") |>
  add_overall_col("All") |>
  summarize_row_groups() |>
  analyze("AGE", afun = max, format = "xx.x")

tbl <- build_table(lyt, ex_adsl)
tbl
#                  ARM A                     ARM B                     ARM C                       
#                  N=134                     N=134                     N=132                       
#             S1           S2           S1           S2           S1           S2                  
#           (N=73)       (N=61)       (N=67)       (N=67)       (N=56)       (N=76)         All    
# —————————————————————————————————————————————————————————————————————————————————————————————————
# A       18 (24.7%)   20 (32.8%)   22 (32.8%)   22 (32.8%)   14 (25.0%)   26 (34.2%)   122 (30.5%)
#   max      40.0         46.0         62.0         50.0         47.0         45.0         62.0    
# B       28 (38.4%)   19 (31.1%)   19 (28.4%)   26 (38.8%)   18 (32.1%)   25 (32.9%)   135 (33.8%)
#   max      48.0         47.0         58.0         58.0         46.0         64.0         64.0    
# C       27 (37.0%)   22 (36.1%)   26 (38.8%)   19 (28.4%)   24 (42.9%)   25 (32.9%)   143 (35.8%)
#   max      48.0         50.0         48.0         51.0         69.0         50.0         69.0
```

## Getting Started

We can get basic table dimensions, the number of rows, and the number of
columns with the following code:

``` r

dim(tbl)
# [1] 6 7
nrow(tbl)
# [1] 6
ncol(tbl)
# [1] 7
```

## Detailed Table Structure

The
[`table_structure()`](https://pharmaverse.github.io/rtables/reference/table_structure.md)
function prints a summary of a table’s row structure at one of two
levels of detail. By default, it summarizes the structure at the
subtable level.

``` r

table_structure(tbl)
# [TableTree] STRATA1
#  [TableTree] A [cont: 1 x 7]
#   [ElementaryTable] AGE (1 x 7)
#  [TableTree] B [cont: 1 x 7]
#   [ElementaryTable] AGE (1 x 7)
#  [TableTree] C [cont: 1 x 7]
#   [ElementaryTable] AGE (1 x 7)
```

When the `detail` argument is set to `"row"`, however, it provides a
more detailed row-level summary which acts as a useful alternative to
how we might normally use the
[`str()`](https://pharmaverse.github.io/rtables/reference/int_methods.md)
function to interrogate compound nested lists.

``` r

table_structure(tbl, detail = "row") # or "subtable"
# TableTree: [STRATA1] (STRATA1)
#   labelrow: [STRATA1] (STRATA1) - <not visible>
#   children: 
#     TableTree: [A] (A)
#       labelrow: [A] (A) - <not visible>
#       content:
#         ElementaryTable: [A@content] ()
#           labelrow: [] () - <not visible>
#           children: 
#             ContentRow: [A] (A)
#       children: 
#         ElementaryTable: [AGE] (AGE)
#           labelrow: [AGE] (AGE) - <not visible>
#           children: 
#             DataRow: [max] (max)
#     TableTree: [B] (B)
#       labelrow: [B] (B) - <not visible>
#       content:
#         ElementaryTable: [B@content] ()
#           labelrow: [] () - <not visible>
#           children: 
#             ContentRow: [B] (B)
#       children: 
#         ElementaryTable: [AGE] (AGE)
#           labelrow: [AGE] (AGE) - <not visible>
#           children: 
#             DataRow: [max] (max)
#     TableTree: [C] (C)
#       labelrow: [C] (C) - <not visible>
#       content:
#         ElementaryTable: [C@content] ()
#           labelrow: [] () - <not visible>
#           children: 
#             ContentRow: [C] (C)
#       children: 
#         ElementaryTable: [AGE] (AGE)
#           labelrow: [AGE] (AGE) - <not visible>
#           children: 
#             DataRow: [max] (max)
```

Similarly, for columns we can see how the tree is structured with the
following call:

``` r

coltree_structure(tbl)
# [root] (no pos)
#    [ARMCD] (no pos)
#      [ARM A] (ARMCD: ARM A)
#        [S1] (ARMCD: ARM A -> STRATA2: S1)
#        [S2] (ARMCD: ARM A -> STRATA2: S2)
#      [ARM B] (ARMCD: ARM B)
#        [S1] (ARMCD: ARM B -> STRATA2: S1)
#        [S2] (ARMCD: ARM B -> STRATA2: S2)
#      [ARM C] (ARMCD: ARM C)
#        [S1] (ARMCD: ARM C -> STRATA2: S1)
#        [S2] (ARMCD: ARM C -> STRATA2: S2)
#    [All] (no pos)
#      [All] (All: All)
```

Further information about the column structure can be found in the
vignette on
[`col_counts`](https://pharmaverse.github.io/rtables/latest-tag/articles/col_counts.html).

The
[`make_row_df()`](https://rdrr.io/pkg/formatters/man/make_row_df.html)
and
[`make_col_df()`](https://pharmaverse.github.io/rtables/reference/make_col_df.md)
functions each create a `data.frame` with a variety of information about
the table’s structure. Most useful for introspection purposes are the
`label`, `name`, `abs_rownumber`, `path` and `node_class` columns (the
remainder of the information in the returned `data.frame` is used for
pagination)

``` r

make_row_df(tbl)[, c("label", "name", "abs_rownumber", "path", "node_class")]
#   label name abs_rownumber         path node_class
# 1     A    A             1 STRATA1,.... ContentRow
# 2   max  max             2 STRATA1,....    DataRow
# 3     B    B             3 STRATA1,.... ContentRow
# 4   max  max             4 STRATA1,....    DataRow
# 5     C    C             5 STRATA1,.... ContentRow
# 6   max  max             6 STRATA1,....    DataRow
```

There is also a wrapper function,
[`row_paths()`](https://pharmaverse.github.io/rtables/reference/make_col_row_df.md)
available for `make_row_df` to display only the row path structure:

``` r

row_paths(tbl)
# [[1]]
# [1] "STRATA1"  "A"        "@content" "A"       
# 
# [[2]]
# [1] "STRATA1" "A"       "AGE"     "max"    
# 
# [[3]]
# [1] "STRATA1"  "B"        "@content" "B"       
# 
# [[4]]
# [1] "STRATA1" "B"       "AGE"     "max"    
# 
# [[5]]
# [1] "STRATA1"  "C"        "@content" "C"       
# 
# [[6]]
# [1] "STRATA1" "C"       "AGE"     "max"
```

By default
[`make_row_df()`](https://rdrr.io/pkg/formatters/man/make_row_df.html)
summarizes only visible rows, but setting `visible_only` to `FALSE`
gives us a structural summary of the table with the full hierarchy of
subtables, including those that are not represented directly by any
visible rows:

``` r

make_row_df(tbl, visible_only = FALSE)[, c("label", "name", "abs_rownumber", "path", "node_class")]
#    label      name abs_rownumber         path      node_class
# 1          STRATA1            NA      STRATA1       TableTree
# 2                A            NA   STRATA1, A       TableTree
# 3        A@content            NA STRATA1,.... ElementaryTable
# 4      A         A             1 STRATA1,....      ContentRow
# 5              AGE            NA STRATA1,.... ElementaryTable
# 6    max       max             2 STRATA1,....         DataRow
# 7                B            NA   STRATA1, B       TableTree
# 8        B@content            NA STRATA1,.... ElementaryTable
# 9      B         B             3 STRATA1,....      ContentRow
# 10             AGE            NA STRATA1,.... ElementaryTable
# 11   max       max             4 STRATA1,....         DataRow
# 12               C            NA   STRATA1, C       TableTree
# 13       C@content            NA STRATA1,.... ElementaryTable
# 14     C         C             5 STRATA1,....      ContentRow
# 15             AGE            NA STRATA1,.... ElementaryTable
# 16   max       max             6 STRATA1,....         DataRow
```

[`make_col_df()`](https://pharmaverse.github.io/rtables/reference/make_col_df.md)
similarly accepts `visible_only`, though here the meaning is slightly
different, indicating whether only *leaf* columns should be summarized
(defaults to `TRUE`) or whether higher level groups of columns -
analogous to subtables in row space - should be summarized as well.

``` r

make_col_df(tbl)[, c("label", "name", "abs_pos", "path", "leaf_indices")]
#   label name abs_pos         path leaf_indices
# 1    S1   S1       1 ARMCD, A....            1
# 2    S2   S2       2 ARMCD, A....            2
# 3    S1   S1       3 ARMCD, A....            3
# 4    S2   S2       4 ARMCD, A....            4
# 5    S1   S1       5 ARMCD, A....            5
# 6    S2   S2       6 ARMCD, A....            6
# 7   All  All       7     All, All            7
```

``` r

make_col_df(tbl, visible_only = FALSE)[, c("label", "name", "abs_pos", "path", "leaf_indices")]
#    label  name abs_pos         path leaf_indices
# 1  ARM A ARM A      NA ARMCD, ARM A         1, 2
# 2     S1    S1       1 ARMCD, A....            1
# 3     S2    S2       2 ARMCD, A....            2
# 4  ARM B ARM B      NA ARMCD, ARM B         3, 4
# 5     S1    S1       3 ARMCD, A....            3
# 6     S2    S2       4 ARMCD, A....            4
# 7  ARM C ARM C      NA ARMCD, ARM C         5, 6
# 8     S1    S1       5 ARMCD, A....            5
# 9     S2    S2       6 ARMCD, A....            6
# 10   All   All       7     All, All            7
```

Similarly, there is wrapper function
[`col_paths()`](https://pharmaverse.github.io/rtables/reference/make_col_row_df.md)
available, which displays only the column structure:

``` r

col_paths(tbl)
# [[1]]
# [1] "ARMCD"   "ARM A"   "STRATA2" "S1"     
# 
# [[2]]
# [1] "ARMCD"   "ARM A"   "STRATA2" "S2"     
# 
# [[3]]
# [1] "ARMCD"   "ARM B"   "STRATA2" "S1"     
# 
# [[4]]
# [1] "ARMCD"   "ARM B"   "STRATA2" "S2"     
# 
# [[5]]
# [1] "ARMCD"   "ARM C"   "STRATA2" "S1"     
# 
# [[6]]
# [1] "ARMCD"   "ARM C"   "STRATA2" "S2"     
# 
# [[7]]
# [1] "All" "All"
```

The
[`row_paths_summary()`](https://pharmaverse.github.io/rtables/reference/row_paths_summary.md)
and
[`col_paths_summary()`](https://pharmaverse.github.io/rtables/reference/row_paths_summary.md)
functions wrap the respective `make_*_df` functions, printing the
`name`, `node_class`, and `path` information (in the row case), or the
`label` and `path` information (in the column case), indented to
illustrate table structure:

``` r

row_paths_summary(tbl)
# rowname    node_class    path                   
# ————————————————————————————————————————————————
# A          ContentRow    STRATA1, A, @content, A
#   max      DataRow       STRATA1, A, AGE, max   
# B          ContentRow    STRATA1, B, @content, B
#   max      DataRow       STRATA1, B, AGE, max   
# C          ContentRow    STRATA1, C, @content, C
#   max      DataRow       STRATA1, C, AGE, max
```

``` r

col_paths_summary(tbl)
# label    path                     
# ——————————————————————————————————
# ARM A    ARMCD, ARM A             
#   S1     ARMCD, ARM A, STRATA2, S1
#   S2     ARMCD, ARM A, STRATA2, S2
# ARM B    ARMCD, ARM B             
#   S1     ARMCD, ARM B, STRATA2, S1
#   S2     ARMCD, ARM B, STRATA2, S2
# ARM C    ARMCD, ARM C             
#   S1     ARMCD, ARM C, STRATA2, S1
#   S2     ARMCD, ARM C, STRATA2, S2
# All      All, All
```

## Insights on Value Format Structure

We can gain insight into the value formatting structure of a table using
[`table_shell()`](https://pharmaverse.github.io/rtables/reference/table_shell.md),
which returns a table with the same output as
[`print()`](https://rdrr.io/r/base/print.html) but with the cell values
replaced by their underlying format strings (e.g. instead of `40.0`,
`xx.x` is displayed, and so on). This is useful for understanding the
structure of the table, and for debugging purposes. Another useful tool
is the
[`value_formats()`](https://pharmaverse.github.io/rtables/reference/value_formats.md)
function which instead of a table returns a matrix of the format strings
for each cell value in the table.

See below the printout for the above examples:

``` r

table_shell(tbl)
#                  ARM A                     ARM B                     ARM C                      
#                  N=134                     N=134                     N=132                      
#             S1           S2           S1           S2           S1           S2                 
#           (N=73)       (N=61)       (N=67)       (N=67)       (N=56)       (N=76)        All    
# ————————————————————————————————————————————————————————————————————————————————————————————————
# A       xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)
#   max      xx.x         xx.x         xx.x         xx.x         xx.x         xx.x         xx.x   
# B       xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)
#   max      xx.x         xx.x         xx.x         xx.x         xx.x         xx.x         xx.x   
# C       xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)
#   max      xx.x         xx.x         xx.x         xx.x         xx.x         xx.x         xx.x
```

``` r

value_formats(tbl)
#     ARM A.S1     ARM A.S2     ARM B.S1     ARM B.S2     ARM C.S1    
# A   "xx (xx.x%)" "xx (xx.x%)" "xx (xx.x%)" "xx (xx.x%)" "xx (xx.x%)"
# max "xx.x"       "xx.x"       "xx.x"       "xx.x"       "xx.x"      
# B   "xx (xx.x%)" "xx (xx.x%)" "xx (xx.x%)" "xx (xx.x%)" "xx (xx.x%)"
# max "xx.x"       "xx.x"       "xx.x"       "xx.x"       "xx.x"      
# C   "xx (xx.x%)" "xx (xx.x%)" "xx (xx.x%)" "xx (xx.x%)" "xx (xx.x%)"
# max "xx.x"       "xx.x"       "xx.x"       "xx.x"       "xx.x"      
#     ARM C.S2     All         
# A   "xx (xx.x%)" "xx (xx.x%)"
# max "xx.x"       "xx.x"      
# B   "xx (xx.x%)" "xx (xx.x%)"
# max "xx.x"       "xx.x"      
# C   "xx (xx.x%)" "xx (xx.x%)"
# max "xx.x"       "xx.x"
```

## Applications

Knowing the structure of an `rtable` object is helpful for retrieving
specific values from the table. For examples, see the [Path Based Cell
Value
Accessing](https://pharmaverse.github.io/rtables/latest-tag/articles/subsetting_tables.html#path-based-cell-value-accessing)
section of the Subsetting and Manipulating Table Contents vignette.

Understanding table structure is also important for post-processing
processes such as sorting and pruning. More details on this are covered
in the [Pruning and Sorting Tables
vignette](https://pharmaverse.github.io/rtables/latest-tag/articles/sorting_pruning.html)
vignette.

## Summary

In this vignette you have learned a number of utility functions that are
available for examining the underlying structure of `rtable` objects.
