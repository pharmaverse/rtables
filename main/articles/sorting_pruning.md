# Pruning and Sorting Tables

### Introduction

Often we want to filter or reorder elements of a table in ways that take
into account the table structure. For example:

- Sorting subtables corresponding to factor levels so that most commonly
  observed levels occur first in the table.
- Sorting rows within a single subtable
- Removing subtables which represent 0 observations or which after other
  filtering contain 0 rows.

### A Table In Need of Attention

``` r

library(rtables)
library(dplyr)

raw_lyt <- basic_table() |>
  split_cols_by("ARM") |>
  split_cols_by("SEX") |>
  split_rows_by("RACE") |>
  summarize_row_groups() |>
  split_rows_by("STRATA1") |>
  summarize_row_groups() |>
  analyze("AGE")

raw_tbl <- build_table(raw_lyt, DM)
raw_tbl
#                                                                  A: Drug X                                              B: Placebo                                           C: Combination                   
#                                                 F            M           U      UNDIFFERENTIATED       F            M           U      UNDIFFERENTIATED       F            M           U      UNDIFFERENTIATED
# ——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
# ASIAN                                       44 (62.9%)   35 (68.6%)   0 (NA%)       0 (NA%)        37 (66.1%)   31 (62.0%)   0 (NA%)       0 (NA%)        40 (65.6%)   44 (64.7%)   0 (NA%)       0 (NA%)     
#   A                                         15 (21.4%)   12 (23.5%)   0 (NA%)       0 (NA%)        14 (25.0%)   6 (12.0%)    0 (NA%)       0 (NA%)        15 (24.6%)   16 (23.5%)   0 (NA%)       0 (NA%)     
#     Mean                                      30.40        34.42        NA             NA            35.43        30.33        NA             NA            37.40        36.25        NA             NA       
#   B                                         16 (22.9%)   8 (15.7%)    0 (NA%)       0 (NA%)        13 (23.2%)   16 (32.0%)   0 (NA%)       0 (NA%)        10 (16.4%)   12 (17.6%)   0 (NA%)       0 (NA%)     
#     Mean                                      33.75        34.88        NA             NA            32.46        30.94        NA             NA            33.30        35.92        NA             NA       
#   C                                         13 (18.6%)   15 (29.4%)   0 (NA%)       0 (NA%)        10 (17.9%)   9 (18.0%)    0 (NA%)       0 (NA%)        15 (24.6%)   16 (23.5%)   0 (NA%)       0 (NA%)     
#     Mean                                      36.92        35.60        NA             NA            34.00        31.89        NA             NA            33.47        31.38        NA             NA       
# BLACK OR AFRICAN AMERICAN                   18 (25.7%)   10 (19.6%)   0 (NA%)       0 (NA%)        12 (21.4%)   12 (24.0%)   0 (NA%)       0 (NA%)        13 (21.3%)   14 (20.6%)   0 (NA%)       0 (NA%)     
#   A                                          5 (7.1%)     1 (2.0%)    0 (NA%)       0 (NA%)         5 (8.9%)     2 (4.0%)    0 (NA%)       0 (NA%)         4 (6.6%)     4 (5.9%)    0 (NA%)       0 (NA%)     
#     Mean                                      31.20        33.00        NA             NA            28.00        30.00        NA             NA            30.75        36.50        NA             NA       
#   B                                         7 (10.0%)     3 (5.9%)    0 (NA%)       0 (NA%)         3 (5.4%)     3 (6.0%)    0 (NA%)       0 (NA%)         6 (9.8%)     6 (8.8%)    0 (NA%)       0 (NA%)     
#     Mean                                      36.14        34.33        NA             NA            29.67        32.00        NA             NA            36.33        31.00        NA             NA       
#   C                                          6 (8.6%)    6 (11.8%)    0 (NA%)       0 (NA%)         4 (7.1%)    7 (14.0%)    0 (NA%)       0 (NA%)         3 (4.9%)     4 (5.9%)    0 (NA%)       0 (NA%)     
#     Mean                                      31.33        39.67        NA             NA            34.50        34.00        NA             NA            33.00        36.50        NA             NA       
# WHITE                                       8 (11.4%)    6 (11.8%)    0 (NA%)       0 (NA%)        7 (12.5%)    7 (14.0%)    0 (NA%)       0 (NA%)        8 (13.1%)    10 (14.7%)   0 (NA%)       0 (NA%)     
#   A                                          2 (2.9%)     1 (2.0%)    0 (NA%)       0 (NA%)         3 (5.4%)     3 (6.0%)    0 (NA%)       0 (NA%)         1 (1.6%)     5 (7.4%)    0 (NA%)       0 (NA%)     
#     Mean                                      34.00        45.00        NA             NA            29.33        33.33        NA             NA            35.00        32.80        NA             NA       
#   B                                          4 (5.7%)     3 (5.9%)    0 (NA%)       0 (NA%)         1 (1.8%)     4 (8.0%)    0 (NA%)       0 (NA%)         3 (4.9%)     1 (1.5%)    0 (NA%)       0 (NA%)     
#     Mean                                      37.00        43.67        NA             NA            48.00        36.75        NA             NA            34.33        36.00        NA             NA       
#   C                                          2 (2.9%)     2 (3.9%)    0 (NA%)       0 (NA%)         3 (5.4%)     0 (0.0%)    0 (NA%)       0 (NA%)         4 (6.6%)     4 (5.9%)    0 (NA%)       0 (NA%)     
#     Mean                                      35.50        44.00        NA             NA            44.67          NA         NA             NA            38.50        35.00        NA             NA       
# AMERICAN INDIAN OR ALASKA NATIVE             0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)     
#   A                                          0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)     
#     Mean                                        NA           NA         NA             NA              NA           NA         NA             NA              NA           NA         NA             NA       
#   B                                          0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)     
#     Mean                                        NA           NA         NA             NA              NA           NA         NA             NA              NA           NA         NA             NA       
#   C                                          0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)     
#     Mean                                        NA           NA         NA             NA              NA           NA         NA             NA              NA           NA         NA             NA       
# MULTIPLE                                     0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)     
#   A                                          0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)     
#     Mean                                        NA           NA         NA             NA              NA           NA         NA             NA              NA           NA         NA             NA       
#   B                                          0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)     
#     Mean                                        NA           NA         NA             NA              NA           NA         NA             NA              NA           NA         NA             NA       
#   C                                          0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)     
#     Mean                                        NA           NA         NA             NA              NA           NA         NA             NA              NA           NA         NA             NA       
# NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER    0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)     
#   A                                          0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)     
#     Mean                                        NA           NA         NA             NA              NA           NA         NA             NA              NA           NA         NA             NA       
#   B                                          0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)     
#     Mean                                        NA           NA         NA             NA              NA           NA         NA             NA              NA           NA         NA             NA       
#   C                                          0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)     
#     Mean                                        NA           NA         NA             NA              NA           NA         NA             NA              NA           NA         NA             NA       
# OTHER                                        0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)     
#   A                                          0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)     
#     Mean                                        NA           NA         NA             NA              NA           NA         NA             NA              NA           NA         NA             NA       
#   B                                          0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)     
#     Mean                                        NA           NA         NA             NA              NA           NA         NA             NA              NA           NA         NA             NA       
#   C                                          0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)     
#     Mean                                        NA           NA         NA             NA              NA           NA         NA             NA              NA           NA         NA             NA       
# UNKNOWN                                      0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)     
#   A                                          0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)     
#     Mean                                        NA           NA         NA             NA              NA           NA         NA             NA              NA           NA         NA             NA       
#   B                                          0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)     
#     Mean                                        NA           NA         NA             NA              NA           NA         NA             NA              NA           NA         NA             NA       
#   C                                          0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)         0 (0.0%)     0 (0.0%)    0 (NA%)       0 (NA%)     
#     Mean                                        NA           NA         NA             NA              NA           NA         NA             NA              NA           NA         NA             NA
```

### Trimming

#### Trimming Rows

Trimming represents a convenience wrapper around simple, direct
subsetting of the rows of a `TableTree`.

We use the
[`trim_rows()`](https://pharmaverse.github.io/rtables/reference/trim_rows.md)
function with our table and a criteria function. All rows where the
criteria function returns `TRUE` will be removed, and all others will be
retained.

**NOTE**: Each row is kept or removed completely independently, with no
awareness of the surrounding structure. This means, for example, that a
subtree could have all its analysis rows removed and not be removed
itself. This can easily result in a *degenerate table* which has an
invalid structure (see
[`?validate_table_struct`](https://pharmaverse.github.io/rtables/reference/validate_table_struct.md));
for this reason trimming is generally not suggested for tables with
non-trivial row structures. For structure-aware filtering of a table, we
will use *pruning* described in the next section.

A *trimming function* accepts a `TableRow` object and returns `TRUE` if
the row should be removed.

The default trimming function removes rows in which all columns have no
values in them, i.e. that have all `NA` values or all `0` values:

``` r

trim_rows(raw_tbl)
#                                                  A: Drug X                                              B: Placebo                                           C: Combination                   
#                                 F            M           U      UNDIFFERENTIATED       F            M           U      UNDIFFERENTIATED       F            M           U      UNDIFFERENTIATED
# ——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
# ASIAN                       44 (62.9%)   35 (68.6%)   0 (NA%)       0 (NA%)        37 (66.1%)   31 (62.0%)   0 (NA%)       0 (NA%)        40 (65.6%)   44 (64.7%)   0 (NA%)       0 (NA%)     
#   A                         15 (21.4%)   12 (23.5%)   0 (NA%)       0 (NA%)        14 (25.0%)   6 (12.0%)    0 (NA%)       0 (NA%)        15 (24.6%)   16 (23.5%)   0 (NA%)       0 (NA%)     
#     Mean                      30.40        34.42        NA             NA            35.43        30.33        NA             NA            37.40        36.25        NA             NA       
#   B                         16 (22.9%)   8 (15.7%)    0 (NA%)       0 (NA%)        13 (23.2%)   16 (32.0%)   0 (NA%)       0 (NA%)        10 (16.4%)   12 (17.6%)   0 (NA%)       0 (NA%)     
#     Mean                      33.75        34.88        NA             NA            32.46        30.94        NA             NA            33.30        35.92        NA             NA       
#   C                         13 (18.6%)   15 (29.4%)   0 (NA%)       0 (NA%)        10 (17.9%)   9 (18.0%)    0 (NA%)       0 (NA%)        15 (24.6%)   16 (23.5%)   0 (NA%)       0 (NA%)     
#     Mean                      36.92        35.60        NA             NA            34.00        31.89        NA             NA            33.47        31.38        NA             NA       
# BLACK OR AFRICAN AMERICAN   18 (25.7%)   10 (19.6%)   0 (NA%)       0 (NA%)        12 (21.4%)   12 (24.0%)   0 (NA%)       0 (NA%)        13 (21.3%)   14 (20.6%)   0 (NA%)       0 (NA%)     
#   A                          5 (7.1%)     1 (2.0%)    0 (NA%)       0 (NA%)         5 (8.9%)     2 (4.0%)    0 (NA%)       0 (NA%)         4 (6.6%)     4 (5.9%)    0 (NA%)       0 (NA%)     
#     Mean                      31.20        33.00        NA             NA            28.00        30.00        NA             NA            30.75        36.50        NA             NA       
#   B                         7 (10.0%)     3 (5.9%)    0 (NA%)       0 (NA%)         3 (5.4%)     3 (6.0%)    0 (NA%)       0 (NA%)         6 (9.8%)     6 (8.8%)    0 (NA%)       0 (NA%)     
#     Mean                      36.14        34.33        NA             NA            29.67        32.00        NA             NA            36.33        31.00        NA             NA       
#   C                          6 (8.6%)    6 (11.8%)    0 (NA%)       0 (NA%)         4 (7.1%)    7 (14.0%)    0 (NA%)       0 (NA%)         3 (4.9%)     4 (5.9%)    0 (NA%)       0 (NA%)     
#     Mean                      31.33        39.67        NA             NA            34.50        34.00        NA             NA            33.00        36.50        NA             NA       
# WHITE                       8 (11.4%)    6 (11.8%)    0 (NA%)       0 (NA%)        7 (12.5%)    7 (14.0%)    0 (NA%)       0 (NA%)        8 (13.1%)    10 (14.7%)   0 (NA%)       0 (NA%)     
#   A                          2 (2.9%)     1 (2.0%)    0 (NA%)       0 (NA%)         3 (5.4%)     3 (6.0%)    0 (NA%)       0 (NA%)         1 (1.6%)     5 (7.4%)    0 (NA%)       0 (NA%)     
#     Mean                      34.00        45.00        NA             NA            29.33        33.33        NA             NA            35.00        32.80        NA             NA       
#   B                          4 (5.7%)     3 (5.9%)    0 (NA%)       0 (NA%)         1 (1.8%)     4 (8.0%)    0 (NA%)       0 (NA%)         3 (4.9%)     1 (1.5%)    0 (NA%)       0 (NA%)     
#     Mean                      37.00        43.67        NA             NA            48.00        36.75        NA             NA            34.33        36.00        NA             NA       
#   C                          2 (2.9%)     2 (3.9%)    0 (NA%)       0 (NA%)         3 (5.4%)     0 (0.0%)    0 (NA%)       0 (NA%)         4 (6.6%)     4 (5.9%)    0 (NA%)       0 (NA%)     
#     Mean                      35.50        44.00        NA             NA            44.67          NA         NA             NA            38.50        35.00        NA             NA
```

#### Trimming Columns

There are currently no special utilities for trimming columns but we can
remove the empty columns with fairly straightforward column subsetting
using the
[`col_counts()`](https://pharmaverse.github.io/rtables/reference/col_accessors.md)
function:

``` r

coltrimmed <- raw_tbl[, col_counts(raw_tbl) > 0]
# Note: method with signature 'VTableTree#missing#ANY' chosen for function '[',
#  target signature 'TableTree#missing#logical'.
#  "VTableTree#ANY#logical" would also be valid
h_coltrimmed <- head(coltrimmed, n = 14)
h_coltrimmed
#                                    A: Drug X                B: Placebo              C: Combination     
#                                 F            M            F            M            F            M     
# ———————————————————————————————————————————————————————————————————————————————————————————————————————
# ASIAN                       44 (62.9%)   35 (68.6%)   37 (66.1%)   31 (62.0%)   40 (65.6%)   44 (64.7%)
#   A                         15 (21.4%)   12 (23.5%)   14 (25.0%)   6 (12.0%)    15 (24.6%)   16 (23.5%)
#     Mean                      30.40        34.42        35.43        30.33        37.40        36.25   
#   B                         16 (22.9%)   8 (15.7%)    13 (23.2%)   16 (32.0%)   10 (16.4%)   12 (17.6%)
#     Mean                      33.75        34.88        32.46        30.94        33.30        35.92   
#   C                         13 (18.6%)   15 (29.4%)   10 (17.9%)   9 (18.0%)    15 (24.6%)   16 (23.5%)
#     Mean                      36.92        35.60        34.00        31.89        33.47        31.38   
# BLACK OR AFRICAN AMERICAN   18 (25.7%)   10 (19.6%)   12 (21.4%)   12 (24.0%)   13 (21.3%)   14 (20.6%)
#   A                          5 (7.1%)     1 (2.0%)     5 (8.9%)     2 (4.0%)     4 (6.6%)     4 (5.9%) 
#     Mean                      31.20        33.00        28.00        30.00        30.75        36.50   
#   B                         7 (10.0%)     3 (5.9%)     3 (5.4%)     3 (6.0%)     6 (9.8%)     6 (8.8%) 
#     Mean                      36.14        34.33        29.67        32.00        36.33        31.00   
#   C                          6 (8.6%)    6 (11.8%)     4 (7.1%)    7 (14.0%)     3 (4.9%)     4 (5.9%) 
#     Mean                      31.33        39.67        34.50        34.00        33.00        36.50
```

Now, it is interesting to see how this table is structured:

``` r

table_structure(h_coltrimmed)
# [TableTree] RACE
#  [TableTree] ASIAN [cont: 1 x 6]
#   [TableTree] STRATA1
#    [TableTree] A [cont: 1 x 6]
#     [ElementaryTable] AGE (1 x 6)
#    [TableTree] B [cont: 1 x 6]
#     [ElementaryTable] AGE (1 x 6)
#    [TableTree] C [cont: 1 x 6]
#     [ElementaryTable] AGE (1 x 6)
#  [TableTree] BLACK OR AFRICAN AMERICAN [cont: 1 x 6]
#   [TableTree] STRATA1
#    [TableTree] A [cont: 1 x 6]
#     [ElementaryTable] AGE (1 x 6)
#    [TableTree] B [cont: 1 x 6]
#     [ElementaryTable] AGE (1 x 6)
#    [TableTree] C [cont: 1 x 6]
#     [ElementaryTable] AGE (1 x 6)
```

For a deeper understanding of the fundamental structures in `rtables`,
we suggest taking a look at slides 69-76 of this [Slide
deck](https://docs.google.com/presentation/d/1ygQE9UaoXY6C_FiQLkiYtXB_OnkVbXvsMIY6_MQPbx0/edit?usp=sharing).

In brief, it is important to notice how `[TableTree] RACE` is the root
of the table that is split (with `split_rows_by("RACE") |>`) into two
subtables: `[TableTree] ASIAN [cont: 1 x 6]` and
`[TableTree] BLACK OR AFRICAN AMERICAN [cont: 1 x 6]`. These are then
“described” with `summarize_row_groups() |>`, which creates for every
split a “content” table containing 1 row (the 1 in `cont: 1 x 6`), which
when rendered takes the place of `LabelRow`.

Each of these two subtables then contain a `STRATA1` table, representing
the further `split_rows_by("STRATA1")` in the layout, which, similar to
the `RACE` table, is split into subtables: one for each strata which
have similar content tables; Each individual strata subtable, then,
contains an `ElementaryTable` (whose children are individual rows)
generated by the `analyze("AGE")` layout directive,
i.e. `[ElementaryTable] AGE (1 x 6)`.

This subtable and row structure is very important for both sorting and
pruning; values in “content” (`ContentRow`) and “value” (`DataRow`) rows
use different access functions and they should be treated differently.

Another interesting function that can be used to understand the
connection between row names and their representational path is the
following:

``` r

row_paths_summary(h_coltrimmed)
# rowname                      node_class    path                                                                
# ———————————————————————————————————————————————————————————————————————————————————————————————————————————————
# ASIAN                        ContentRow    RACE, ASIAN, @content, ASIAN                                        
#   A                          ContentRow    RACE, ASIAN, STRATA1, A, @content, A                                
#     Mean                     DataRow       RACE, ASIAN, STRATA1, A, AGE, Mean                                  
#   B                          ContentRow    RACE, ASIAN, STRATA1, B, @content, B                                
#     Mean                     DataRow       RACE, ASIAN, STRATA1, B, AGE, Mean                                  
#   C                          ContentRow    RACE, ASIAN, STRATA1, C, @content, C                                
#     Mean                     DataRow       RACE, ASIAN, STRATA1, C, AGE, Mean                                  
# BLACK OR AFRICAN AMERICAN    ContentRow    RACE, BLACK OR AFRICAN AMERICAN, @content, BLACK OR AFRICAN AMERICAN
#   A                          ContentRow    RACE, BLACK OR AFRICAN AMERICAN, STRATA1, A, @content, A            
#     Mean                     DataRow       RACE, BLACK OR AFRICAN AMERICAN, STRATA1, A, AGE, Mean              
#   B                          ContentRow    RACE, BLACK OR AFRICAN AMERICAN, STRATA1, B, @content, B            
#     Mean                     DataRow       RACE, BLACK OR AFRICAN AMERICAN, STRATA1, B, AGE, Mean              
#   C                          ContentRow    RACE, BLACK OR AFRICAN AMERICAN, STRATA1, C, @content, C            
#     Mean                     DataRow       RACE, BLACK OR AFRICAN AMERICAN, STRATA1, C, AGE, Mean
```

### Pruning

Pruning is similar in outcome to trimming, but more powerful and more
complex, as it takes structure into account.

Pruning is applied recursively, in that at each structural unit
(subtable, row) it applies the pruning function both at that level and
to all it’s children (up to a user-specifiable maximum depth).

The default pruning function, for example, determines if a subtree is
empty by:

1.  Removing all children which contain a single content row which
    contains all zeros or all `NA`s
2.  Removing rows which contain either all zeros or all `NA`s
3.  Removing the full subtree if no unpruned children remain

``` r

pruned <- prune_table(coltrimmed)
pruned
#                                    A: Drug X                B: Placebo              C: Combination     
#                                 F            M            F            M            F            M     
# ———————————————————————————————————————————————————————————————————————————————————————————————————————
# ASIAN                       44 (62.9%)   35 (68.6%)   37 (66.1%)   31 (62.0%)   40 (65.6%)   44 (64.7%)
#   A                         15 (21.4%)   12 (23.5%)   14 (25.0%)   6 (12.0%)    15 (24.6%)   16 (23.5%)
#     Mean                      30.40        34.42        35.43        30.33        37.40        36.25   
#   B                         16 (22.9%)   8 (15.7%)    13 (23.2%)   16 (32.0%)   10 (16.4%)   12 (17.6%)
#     Mean                      33.75        34.88        32.46        30.94        33.30        35.92   
#   C                         13 (18.6%)   15 (29.4%)   10 (17.9%)   9 (18.0%)    15 (24.6%)   16 (23.5%)
#     Mean                      36.92        35.60        34.00        31.89        33.47        31.38   
# BLACK OR AFRICAN AMERICAN   18 (25.7%)   10 (19.6%)   12 (21.4%)   12 (24.0%)   13 (21.3%)   14 (20.6%)
#   A                          5 (7.1%)     1 (2.0%)     5 (8.9%)     2 (4.0%)     4 (6.6%)     4 (5.9%) 
#     Mean                      31.20        33.00        28.00        30.00        30.75        36.50   
#   B                         7 (10.0%)     3 (5.9%)     3 (5.4%)     3 (6.0%)     6 (9.8%)     6 (8.8%) 
#     Mean                      36.14        34.33        29.67        32.00        36.33        31.00   
#   C                          6 (8.6%)    6 (11.8%)     4 (7.1%)    7 (14.0%)     3 (4.9%)     4 (5.9%) 
#     Mean                      31.33        39.67        34.50        34.00        33.00        36.50   
# WHITE                       8 (11.4%)    6 (11.8%)    7 (12.5%)    7 (14.0%)    8 (13.1%)    10 (14.7%)
#   A                          2 (2.9%)     1 (2.0%)     3 (5.4%)     3 (6.0%)     1 (1.6%)     5 (7.4%) 
#     Mean                      34.00        45.00        29.33        33.33        35.00        32.80   
#   B                          4 (5.7%)     3 (5.9%)     1 (1.8%)     4 (8.0%)     3 (4.9%)     1 (1.5%) 
#     Mean                      37.00        43.67        48.00        36.75        34.33        36.00   
#   C                          2 (2.9%)     2 (3.9%)     3 (5.4%)     0 (0.0%)     4 (6.6%)     4 (5.9%) 
#     Mean                      35.50        44.00        44.67          NA         38.50        35.00
```

We can also use the
[`low_obs_pruner()`](https://pharmaverse.github.io/rtables/reference/trim_prune_funs.md)
pruning function constructor to create a pruning function which removes
subtrees with content summaries whose first entries for each column sum
or average are below a specified number. (In the default summaries the
first entry per column is the count).

``` r

pruned2 <- prune_table(coltrimmed, low_obs_pruner(10, "mean"))
pruned2
#                   A: Drug X                B: Placebo              C: Combination     
#                F            M            F            M            F            M     
# ——————————————————————————————————————————————————————————————————————————————————————
# ASIAN      44 (62.9%)   35 (68.6%)   37 (66.1%)   31 (62.0%)   40 (65.6%)   44 (64.7%)
#   A        15 (21.4%)   12 (23.5%)   14 (25.0%)   6 (12.0%)    15 (24.6%)   16 (23.5%)
#     Mean     30.40        34.42        35.43        30.33        37.40        36.25   
#   B        16 (22.9%)   8 (15.7%)    13 (23.2%)   16 (32.0%)   10 (16.4%)   12 (17.6%)
#     Mean     33.75        34.88        32.46        30.94        33.30        35.92   
#   C        13 (18.6%)   15 (29.4%)   10 (17.9%)   9 (18.0%)    15 (24.6%)   16 (23.5%)
#     Mean     36.92        35.60        34.00        31.89        33.47        31.38
```

Note that because the pruning is being applied recursively, only the
`ASIAN` subtree remains because even though the full
`BLACK OR AFRICAN AMERICAN` subtree encompassed enough observations, the
strata within it did not. We can take care of this by setting the
`stop_depth` for pruning to `1`.

``` r

pruned3 <- prune_table(coltrimmed, low_obs_pruner(10, "sum"), stop_depth = 1)
pruned3
#                                    A: Drug X                B: Placebo              C: Combination     
#                                 F            M            F            M            F            M     
# ———————————————————————————————————————————————————————————————————————————————————————————————————————
# ASIAN                       44 (62.9%)   35 (68.6%)   37 (66.1%)   31 (62.0%)   40 (65.6%)   44 (64.7%)
#   A                         15 (21.4%)   12 (23.5%)   14 (25.0%)   6 (12.0%)    15 (24.6%)   16 (23.5%)
#     Mean                      30.40        34.42        35.43        30.33        37.40        36.25   
#   B                         16 (22.9%)   8 (15.7%)    13 (23.2%)   16 (32.0%)   10 (16.4%)   12 (17.6%)
#     Mean                      33.75        34.88        32.46        30.94        33.30        35.92   
#   C                         13 (18.6%)   15 (29.4%)   10 (17.9%)   9 (18.0%)    15 (24.6%)   16 (23.5%)
#     Mean                      36.92        35.60        34.00        31.89        33.47        31.38   
# BLACK OR AFRICAN AMERICAN   18 (25.7%)   10 (19.6%)   12 (21.4%)   12 (24.0%)   13 (21.3%)   14 (20.6%)
#   A                          5 (7.1%)     1 (2.0%)     5 (8.9%)     2 (4.0%)     4 (6.6%)     4 (5.9%) 
#     Mean                      31.20        33.00        28.00        30.00        30.75        36.50   
#   B                         7 (10.0%)     3 (5.9%)     3 (5.4%)     3 (6.0%)     6 (9.8%)     6 (8.8%) 
#     Mean                      36.14        34.33        29.67        32.00        36.33        31.00   
#   C                          6 (8.6%)    6 (11.8%)     4 (7.1%)    7 (14.0%)     3 (4.9%)     4 (5.9%) 
#     Mean                      31.33        39.67        34.50        34.00        33.00        36.50   
# WHITE                       8 (11.4%)    6 (11.8%)    7 (12.5%)    7 (14.0%)    8 (13.1%)    10 (14.7%)
#   A                          2 (2.9%)     1 (2.0%)     3 (5.4%)     3 (6.0%)     1 (1.6%)     5 (7.4%) 
#     Mean                      34.00        45.00        29.33        33.33        35.00        32.80   
#   B                          4 (5.7%)     3 (5.9%)     1 (1.8%)     4 (8.0%)     3 (4.9%)     1 (1.5%) 
#     Mean                      37.00        43.67        48.00        36.75        34.33        36.00   
#   C                          2 (2.9%)     2 (3.9%)     3 (5.4%)     0 (0.0%)     4 (6.6%)     4 (5.9%) 
#     Mean                      35.50        44.00        44.67          NA         38.50        35.00
```

We can also see that pruning to a lower number of observations, say, to
a total of `16`, with no `stop_depth` removes some but not all of the
strata from our third race (`WHITE`).

``` r

pruned4 <- prune_table(coltrimmed, low_obs_pruner(16, "sum"))
pruned4
#                                    A: Drug X                B: Placebo              C: Combination     
#                                 F            M            F            M            F            M     
# ———————————————————————————————————————————————————————————————————————————————————————————————————————
# ASIAN                       44 (62.9%)   35 (68.6%)   37 (66.1%)   31 (62.0%)   40 (65.6%)   44 (64.7%)
#   A                         15 (21.4%)   12 (23.5%)   14 (25.0%)   6 (12.0%)    15 (24.6%)   16 (23.5%)
#     Mean                      30.40        34.42        35.43        30.33        37.40        36.25   
#   B                         16 (22.9%)   8 (15.7%)    13 (23.2%)   16 (32.0%)   10 (16.4%)   12 (17.6%)
#     Mean                      33.75        34.88        32.46        30.94        33.30        35.92   
#   C                         13 (18.6%)   15 (29.4%)   10 (17.9%)   9 (18.0%)    15 (24.6%)   16 (23.5%)
#     Mean                      36.92        35.60        34.00        31.89        33.47        31.38   
# BLACK OR AFRICAN AMERICAN   18 (25.7%)   10 (19.6%)   12 (21.4%)   12 (24.0%)   13 (21.3%)   14 (20.6%)
#   A                          5 (7.1%)     1 (2.0%)     5 (8.9%)     2 (4.0%)     4 (6.6%)     4 (5.9%) 
#     Mean                      31.20        33.00        28.00        30.00        30.75        36.50   
#   B                         7 (10.0%)     3 (5.9%)     3 (5.4%)     3 (6.0%)     6 (9.8%)     6 (8.8%) 
#     Mean                      36.14        34.33        29.67        32.00        36.33        31.00   
#   C                          6 (8.6%)    6 (11.8%)     4 (7.1%)    7 (14.0%)     3 (4.9%)     4 (5.9%) 
#     Mean                      31.33        39.67        34.50        34.00        33.00        36.50   
# WHITE                       8 (11.4%)    6 (11.8%)    7 (12.5%)    7 (14.0%)    8 (13.1%)    10 (14.7%)
#   B                          4 (5.7%)     3 (5.9%)     1 (1.8%)     4 (8.0%)     3 (4.9%)     1 (1.5%) 
#     Mean                      37.00        43.67        48.00        36.75        34.33        36.00
```

### Sorting

#### Sorting Fundamentals

Sorting of an `rtables` table is done **at a path**, meaning a sort
operation will occur at a particular location within the table, and the
*direct children* of the element at that path will be reordered. This
occurs whether those children are subtables themselves, or individual
rows. Sorting is done via the
[`sort_at_path()`](https://pharmaverse.github.io/rtables/reference/sort_at_path.md)
function, which accepts both a (row) path and a scoring function. See
the [pathing
vignette](https://pharmaverse.github.io/rtables/articles/pathing.md) for
details about paths.

A *score function* accepts a subtree or `TableRow` and returns a single
orderable (typically numeric) value. Within the subtable currently being
sorted, the children are then reordered by the value of the score
function. Importantly, “content” (`ContentRow`) and “values” (`DataRow`)
need to be treated differently in the scoring function as they are
retrieved: the *content* of a subtable is retrieved via the
`content _table` accessor.

The
[`cont_n_allcols()`](https://pharmaverse.github.io/rtables/reference/score_funs.md)
scoring function provided by `rtables`, works by scoring subtables by
the sum of the first elements in the first row of the subtable’s
*content* table. Note that this function fails if the child being scored
does not have a content function (i.e., if
[`summarize_row_groups()`](https://pharmaverse.github.io/rtables/reference/summarize_row_groups.md)
was not used at the corresponding point in the layout). We can see this
in it’s definition, below:

``` r

cont_n_allcols
# function (tt) 
# {
#     ctab <- content_table(tt)
#     if (NROW(ctab) == 0) {
#         stop("cont_n_allcols score function used at subtable [", 
#             obj_name(tt), "] that has no content table.")
#     }
#     sum(sapply(row_values(tree_children(ctab)[[1]]), function(cv) cv[1]))
# }
# <bytecode: 0x5630b61ba478>
# <environment: namespace:rtables>
```

Therefore, a fundamental difference between pruning and sorting is that
sorting occurs at particular places in the table, as defined by a path.

For example, we can sort the strata values (`ContentRow`) by observation
counts within just the `ASIAN` subtable:

``` r

sort_at_path(pruned, path = c("RACE", "ASIAN", "STRATA1"), scorefun = cont_n_allcols)
#                                    A: Drug X                B: Placebo              C: Combination     
#                                 F            M            F            M            F            M     
# ———————————————————————————————————————————————————————————————————————————————————————————————————————
# ASIAN                       44 (62.9%)   35 (68.6%)   37 (66.1%)   31 (62.0%)   40 (65.6%)   44 (64.7%)
#   A                         15 (21.4%)   12 (23.5%)   14 (25.0%)   6 (12.0%)    15 (24.6%)   16 (23.5%)
#     Mean                      30.40        34.42        35.43        30.33        37.40        36.25   
#   C                         13 (18.6%)   15 (29.4%)   10 (17.9%)   9 (18.0%)    15 (24.6%)   16 (23.5%)
#     Mean                      36.92        35.60        34.00        31.89        33.47        31.38   
#   B                         16 (22.9%)   8 (15.7%)    13 (23.2%)   16 (32.0%)   10 (16.4%)   12 (17.6%)
#     Mean                      33.75        34.88        32.46        30.94        33.30        35.92   
# BLACK OR AFRICAN AMERICAN   18 (25.7%)   10 (19.6%)   12 (21.4%)   12 (24.0%)   13 (21.3%)   14 (20.6%)
#   A                          5 (7.1%)     1 (2.0%)     5 (8.9%)     2 (4.0%)     4 (6.6%)     4 (5.9%) 
#     Mean                      31.20        33.00        28.00        30.00        30.75        36.50   
#   B                         7 (10.0%)     3 (5.9%)     3 (5.4%)     3 (6.0%)     6 (9.8%)     6 (8.8%) 
#     Mean                      36.14        34.33        29.67        32.00        36.33        31.00   
#   C                          6 (8.6%)    6 (11.8%)     4 (7.1%)    7 (14.0%)     3 (4.9%)     4 (5.9%) 
#     Mean                      31.33        39.67        34.50        34.00        33.00        36.50   
# WHITE                       8 (11.4%)    6 (11.8%)    7 (12.5%)    7 (14.0%)    8 (13.1%)    10 (14.7%)
#   A                          2 (2.9%)     1 (2.0%)     3 (5.4%)     3 (6.0%)     1 (1.6%)     5 (7.4%) 
#     Mean                      34.00        45.00        29.33        33.33        35.00        32.80   
#   B                          4 (5.7%)     3 (5.9%)     1 (1.8%)     4 (8.0%)     3 (4.9%)     1 (1.5%) 
#     Mean                      37.00        43.67        48.00        36.75        34.33        36.00   
#   C                          2 (2.9%)     2 (3.9%)     3 (5.4%)     0 (0.0%)     4 (6.6%)     4 (5.9%) 
#     Mean                      35.50        44.00        44.67          NA         38.50        35.00
# B and C are swapped as the global count (sum of all column counts) of strata C is higher than the one of strata B
```

#### Wildcards in Sort Paths

A sorting path can contain one or more instances of the “\*” wildcard.
Each of these indicates that the children of each subtable matching this
`*` element of the path should be sorted **separately** as indicated by
the remainder of the path after the `*` and the score function.

Thus we can extend our sorting of strata within the `ASIAN` subtable to
all race-specific subtables by using the wildcard:

``` r

sort_at_path(pruned, path = c("RACE", "*", "STRATA1"), scorefun = cont_n_allcols)
#                                    A: Drug X                B: Placebo              C: Combination     
#                                 F            M            F            M            F            M     
# ———————————————————————————————————————————————————————————————————————————————————————————————————————
# ASIAN                       44 (62.9%)   35 (68.6%)   37 (66.1%)   31 (62.0%)   40 (65.6%)   44 (64.7%)
#   A                         15 (21.4%)   12 (23.5%)   14 (25.0%)   6 (12.0%)    15 (24.6%)   16 (23.5%)
#     Mean                      30.40        34.42        35.43        30.33        37.40        36.25   
#   C                         13 (18.6%)   15 (29.4%)   10 (17.9%)   9 (18.0%)    15 (24.6%)   16 (23.5%)
#     Mean                      36.92        35.60        34.00        31.89        33.47        31.38   
#   B                         16 (22.9%)   8 (15.7%)    13 (23.2%)   16 (32.0%)   10 (16.4%)   12 (17.6%)
#     Mean                      33.75        34.88        32.46        30.94        33.30        35.92   
# BLACK OR AFRICAN AMERICAN   18 (25.7%)   10 (19.6%)   12 (21.4%)   12 (24.0%)   13 (21.3%)   14 (20.6%)
#   C                          6 (8.6%)    6 (11.8%)     4 (7.1%)    7 (14.0%)     3 (4.9%)     4 (5.9%) 
#     Mean                      31.33        39.67        34.50        34.00        33.00        36.50   
#   B                         7 (10.0%)     3 (5.9%)     3 (5.4%)     3 (6.0%)     6 (9.8%)     6 (8.8%) 
#     Mean                      36.14        34.33        29.67        32.00        36.33        31.00   
#   A                          5 (7.1%)     1 (2.0%)     5 (8.9%)     2 (4.0%)     4 (6.6%)     4 (5.9%) 
#     Mean                      31.20        33.00        28.00        30.00        30.75        36.50   
# WHITE                       8 (11.4%)    6 (11.8%)    7 (12.5%)    7 (14.0%)    8 (13.1%)    10 (14.7%)
#   B                          4 (5.7%)     3 (5.9%)     1 (1.8%)     4 (8.0%)     3 (4.9%)     1 (1.5%) 
#     Mean                      37.00        43.67        48.00        36.75        34.33        36.00   
#   A                          2 (2.9%)     1 (2.0%)     3 (5.4%)     3 (6.0%)     1 (1.6%)     5 (7.4%) 
#     Mean                      34.00        45.00        29.33        33.33        35.00        32.80   
#   C                          2 (2.9%)     2 (3.9%)     3 (5.4%)     0 (0.0%)     4 (6.6%)     4 (5.9%) 
#     Mean                      35.50        44.00        44.67          NA         38.50        35.00
# All subtables, i.e. ASIAN, BLACK..., and WHITE, are reordered separately
```

The above is equivalent to separately calling the following:

``` r

tmptbl <- sort_at_path(pruned, path = c("RACE", "ASIAN", "STRATA1"), scorefun = cont_n_allcols)
tmptbl <- sort_at_path(tmptbl, path = c("RACE", "BLACK OR AFRICAN AMERICAN", "STRATA1"), scorefun = cont_n_allcols)
tmptbl <- sort_at_path(tmptbl, path = c("RACE", "WHITE", "STRATA1"), scorefun = cont_n_allcols)
tmptbl
#                                    A: Drug X                B: Placebo              C: Combination     
#                                 F            M            F            M            F            M     
# ———————————————————————————————————————————————————————————————————————————————————————————————————————
# ASIAN                       44 (62.9%)   35 (68.6%)   37 (66.1%)   31 (62.0%)   40 (65.6%)   44 (64.7%)
#   A                         15 (21.4%)   12 (23.5%)   14 (25.0%)   6 (12.0%)    15 (24.6%)   16 (23.5%)
#     Mean                      30.40        34.42        35.43        30.33        37.40        36.25   
#   C                         13 (18.6%)   15 (29.4%)   10 (17.9%)   9 (18.0%)    15 (24.6%)   16 (23.5%)
#     Mean                      36.92        35.60        34.00        31.89        33.47        31.38   
#   B                         16 (22.9%)   8 (15.7%)    13 (23.2%)   16 (32.0%)   10 (16.4%)   12 (17.6%)
#     Mean                      33.75        34.88        32.46        30.94        33.30        35.92   
# BLACK OR AFRICAN AMERICAN   18 (25.7%)   10 (19.6%)   12 (21.4%)   12 (24.0%)   13 (21.3%)   14 (20.6%)
#   C                          6 (8.6%)    6 (11.8%)     4 (7.1%)    7 (14.0%)     3 (4.9%)     4 (5.9%) 
#     Mean                      31.33        39.67        34.50        34.00        33.00        36.50   
#   B                         7 (10.0%)     3 (5.9%)     3 (5.4%)     3 (6.0%)     6 (9.8%)     6 (8.8%) 
#     Mean                      36.14        34.33        29.67        32.00        36.33        31.00   
#   A                          5 (7.1%)     1 (2.0%)     5 (8.9%)     2 (4.0%)     4 (6.6%)     4 (5.9%) 
#     Mean                      31.20        33.00        28.00        30.00        30.75        36.50   
# WHITE                       8 (11.4%)    6 (11.8%)    7 (12.5%)    7 (14.0%)    8 (13.1%)    10 (14.7%)
#   B                          4 (5.7%)     3 (5.9%)     1 (1.8%)     4 (8.0%)     3 (4.9%)     1 (1.5%) 
#     Mean                      37.00        43.67        48.00        36.75        34.33        36.00   
#   A                          2 (2.9%)     1 (2.0%)     3 (5.4%)     3 (6.0%)     1 (1.6%)     5 (7.4%) 
#     Mean                      34.00        45.00        29.33        33.33        35.00        32.80   
#   C                          2 (2.9%)     2 (3.9%)     3 (5.4%)     0 (0.0%)     4 (6.6%)     4 (5.9%) 
#     Mean                      35.50        44.00        44.67          NA         38.50        35.00
```

It is possible to understand better pathing with
[`table_structure()`](https://pharmaverse.github.io/rtables/reference/table_structure.md)
that highlights the tree-like structure and the node names:

``` r

table_structure(pruned)
# [TableTree] RACE
#  [TableTree] ASIAN [cont: 1 x 6]
#   [TableTree] STRATA1
#    [TableTree] A [cont: 1 x 6]
#     [ElementaryTable] AGE (1 x 6)
#    [TableTree] B [cont: 1 x 6]
#     [ElementaryTable] AGE (1 x 6)
#    [TableTree] C [cont: 1 x 6]
#     [ElementaryTable] AGE (1 x 6)
#  [TableTree] BLACK OR AFRICAN AMERICAN [cont: 1 x 6]
#   [TableTree] STRATA1
#    [TableTree] A [cont: 1 x 6]
#     [ElementaryTable] AGE (1 x 6)
#    [TableTree] B [cont: 1 x 6]
#     [ElementaryTable] AGE (1 x 6)
#    [TableTree] C [cont: 1 x 6]
#     [ElementaryTable] AGE (1 x 6)
#  [TableTree] WHITE [cont: 1 x 6]
#   [TableTree] STRATA1
#    [TableTree] A [cont: 1 x 6]
#     [ElementaryTable] AGE (1 x 6)
#    [TableTree] B [cont: 1 x 6]
#     [ElementaryTable] AGE (1 x 6)
#    [TableTree] C [cont: 1 x 6]
#     [ElementaryTable] AGE (1 x 6)
```

or with `row_paths_summary`:

``` r

row_paths_summary(pruned)
# rowname                      node_class    path                                                                
# ———————————————————————————————————————————————————————————————————————————————————————————————————————————————
# ASIAN                        ContentRow    RACE, ASIAN, @content, ASIAN                                        
#   A                          ContentRow    RACE, ASIAN, STRATA1, A, @content, A                                
#     Mean                     DataRow       RACE, ASIAN, STRATA1, A, AGE, Mean                                  
#   B                          ContentRow    RACE, ASIAN, STRATA1, B, @content, B                                
#     Mean                     DataRow       RACE, ASIAN, STRATA1, B, AGE, Mean                                  
#   C                          ContentRow    RACE, ASIAN, STRATA1, C, @content, C                                
#     Mean                     DataRow       RACE, ASIAN, STRATA1, C, AGE, Mean                                  
# BLACK OR AFRICAN AMERICAN    ContentRow    RACE, BLACK OR AFRICAN AMERICAN, @content, BLACK OR AFRICAN AMERICAN
#   A                          ContentRow    RACE, BLACK OR AFRICAN AMERICAN, STRATA1, A, @content, A            
#     Mean                     DataRow       RACE, BLACK OR AFRICAN AMERICAN, STRATA1, A, AGE, Mean              
#   B                          ContentRow    RACE, BLACK OR AFRICAN AMERICAN, STRATA1, B, @content, B            
#     Mean                     DataRow       RACE, BLACK OR AFRICAN AMERICAN, STRATA1, B, AGE, Mean              
#   C                          ContentRow    RACE, BLACK OR AFRICAN AMERICAN, STRATA1, C, @content, C            
#     Mean                     DataRow       RACE, BLACK OR AFRICAN AMERICAN, STRATA1, C, AGE, Mean              
# WHITE                        ContentRow    RACE, WHITE, @content, WHITE                                        
#   A                          ContentRow    RACE, WHITE, STRATA1, A, @content, A                                
#     Mean                     DataRow       RACE, WHITE, STRATA1, A, AGE, Mean                                  
#   B                          ContentRow    RACE, WHITE, STRATA1, B, @content, B                                
#     Mean                     DataRow       RACE, WHITE, STRATA1, B, AGE, Mean                                  
#   C                          ContentRow    RACE, WHITE, STRATA1, C, @content, C                                
#     Mean                     DataRow       RACE, WHITE, STRATA1, C, AGE, Mean
```

Note in the latter we see content rows as those with paths following
`@content`, e.g., `ASIAN, @content, ASIAN`. The first of these at a
given path (i.e., `<path>, @content, <>` are the rows which will be used
by the scoring functions which begin with `cont_`.

We can directly sort the ethnicity by observations in increasing order:

``` r

ethsort <- sort_at_path(pruned, path = c("RACE"), scorefun = cont_n_allcols, decreasing = FALSE)
ethsort
#                                    A: Drug X                B: Placebo              C: Combination     
#                                 F            M            F            M            F            M     
# ———————————————————————————————————————————————————————————————————————————————————————————————————————
# WHITE                       8 (11.4%)    6 (11.8%)    7 (12.5%)    7 (14.0%)    8 (13.1%)    10 (14.7%)
#   A                          2 (2.9%)     1 (2.0%)     3 (5.4%)     3 (6.0%)     1 (1.6%)     5 (7.4%) 
#     Mean                      34.00        45.00        29.33        33.33        35.00        32.80   
#   B                          4 (5.7%)     3 (5.9%)     1 (1.8%)     4 (8.0%)     3 (4.9%)     1 (1.5%) 
#     Mean                      37.00        43.67        48.00        36.75        34.33        36.00   
#   C                          2 (2.9%)     2 (3.9%)     3 (5.4%)     0 (0.0%)     4 (6.6%)     4 (5.9%) 
#     Mean                      35.50        44.00        44.67          NA         38.50        35.00   
# BLACK OR AFRICAN AMERICAN   18 (25.7%)   10 (19.6%)   12 (21.4%)   12 (24.0%)   13 (21.3%)   14 (20.6%)
#   A                          5 (7.1%)     1 (2.0%)     5 (8.9%)     2 (4.0%)     4 (6.6%)     4 (5.9%) 
#     Mean                      31.20        33.00        28.00        30.00        30.75        36.50   
#   B                         7 (10.0%)     3 (5.9%)     3 (5.4%)     3 (6.0%)     6 (9.8%)     6 (8.8%) 
#     Mean                      36.14        34.33        29.67        32.00        36.33        31.00   
#   C                          6 (8.6%)    6 (11.8%)     4 (7.1%)    7 (14.0%)     3 (4.9%)     4 (5.9%) 
#     Mean                      31.33        39.67        34.50        34.00        33.00        36.50   
# ASIAN                       44 (62.9%)   35 (68.6%)   37 (66.1%)   31 (62.0%)   40 (65.6%)   44 (64.7%)
#   A                         15 (21.4%)   12 (23.5%)   14 (25.0%)   6 (12.0%)    15 (24.6%)   16 (23.5%)
#     Mean                      30.40        34.42        35.43        30.33        37.40        36.25   
#   B                         16 (22.9%)   8 (15.7%)    13 (23.2%)   16 (32.0%)   10 (16.4%)   12 (17.6%)
#     Mean                      33.75        34.88        32.46        30.94        33.30        35.92   
#   C                         13 (18.6%)   15 (29.4%)   10 (17.9%)   9 (18.0%)    15 (24.6%)   16 (23.5%)
#     Mean                      36.92        35.60        34.00        31.89        33.47        31.38
```

Within each ethnicity separately, sort the strata by number of females
in arm C (i.e. column position `5`):

``` r

sort_at_path(pruned, path = c("RACE", "*", "STRATA1"), cont_n_onecol(5))
#                                    A: Drug X                B: Placebo              C: Combination     
#                                 F            M            F            M            F            M     
# ———————————————————————————————————————————————————————————————————————————————————————————————————————
# ASIAN                       44 (62.9%)   35 (68.6%)   37 (66.1%)   31 (62.0%)   40 (65.6%)   44 (64.7%)
#   A                         15 (21.4%)   12 (23.5%)   14 (25.0%)   6 (12.0%)    15 (24.6%)   16 (23.5%)
#     Mean                      30.40        34.42        35.43        30.33        37.40        36.25   
#   C                         13 (18.6%)   15 (29.4%)   10 (17.9%)   9 (18.0%)    15 (24.6%)   16 (23.5%)
#     Mean                      36.92        35.60        34.00        31.89        33.47        31.38   
#   B                         16 (22.9%)   8 (15.7%)    13 (23.2%)   16 (32.0%)   10 (16.4%)   12 (17.6%)
#     Mean                      33.75        34.88        32.46        30.94        33.30        35.92   
# BLACK OR AFRICAN AMERICAN   18 (25.7%)   10 (19.6%)   12 (21.4%)   12 (24.0%)   13 (21.3%)   14 (20.6%)
#   B                         7 (10.0%)     3 (5.9%)     3 (5.4%)     3 (6.0%)     6 (9.8%)     6 (8.8%) 
#     Mean                      36.14        34.33        29.67        32.00        36.33        31.00   
#   A                          5 (7.1%)     1 (2.0%)     5 (8.9%)     2 (4.0%)     4 (6.6%)     4 (5.9%) 
#     Mean                      31.20        33.00        28.00        30.00        30.75        36.50   
#   C                          6 (8.6%)    6 (11.8%)     4 (7.1%)    7 (14.0%)     3 (4.9%)     4 (5.9%) 
#     Mean                      31.33        39.67        34.50        34.00        33.00        36.50   
# WHITE                       8 (11.4%)    6 (11.8%)    7 (12.5%)    7 (14.0%)    8 (13.1%)    10 (14.7%)
#   C                          2 (2.9%)     2 (3.9%)     3 (5.4%)     0 (0.0%)     4 (6.6%)     4 (5.9%) 
#     Mean                      35.50        44.00        44.67          NA         38.50        35.00   
#   B                          4 (5.7%)     3 (5.9%)     1 (1.8%)     4 (8.0%)     3 (4.9%)     1 (1.5%) 
#     Mean                      37.00        43.67        48.00        36.75        34.33        36.00   
#   A                          2 (2.9%)     1 (2.0%)     3 (5.4%)     3 (6.0%)     1 (1.6%)     5 (7.4%) 
#     Mean                      34.00        45.00        29.33        33.33        35.00        32.80
```

#### Sorting Within an Analysis Subtable

When sorting within an analysis subtable (e.g., the subtable generated
when your analysis function generates more than one row per group of
data), the name of that subtable (generally the name of the variable
being analyzed) must appear in the path, ***even if the variable label
is not displayed when the table is printed***.

To show the differences between sorting an analysis subtable
(`DataRow`), and a content subtable (`ContentRow`), we modify and prune
(as before) a similar raw table as before:

``` r

more_analysis_fnc <- function(x) {
  in_rows(
    "median" = median(x),
    "mean" = mean(x),
    .formats = "xx.x"
  )
}

raw_lyt <- basic_table() |>
  split_cols_by("ARM") |>
  split_rows_by(
    "RACE",
    split_fun = drop_and_remove_levels("WHITE") # dropping WHITE levels
  ) |>
  summarize_row_groups() |>
  split_rows_by("STRATA1") |>
  summarize_row_groups() |>
  analyze("AGE", afun = more_analysis_fnc)

tbl <- build_table(raw_lyt, DM) |>
  prune_table() |>
  print()
#                             A: Drug X    B: Placebo   C: Combination
# ————————————————————————————————————————————————————————————————————
# ASIAN                       79 (65.3%)   68 (64.2%)     84 (65.1%)  
#   A                         27 (22.3%)   20 (18.9%)     31 (24.0%)  
#     median                     30.0         33.0           36.0     
#     mean                       32.2         33.9           36.8     
#   B                         24 (19.8%)   29 (27.4%)     22 (17.1%)  
#     median                     32.5         32.0           34.0     
#     mean                       34.1         31.6           34.7     
#   C                         28 (23.1%)   19 (17.9%)     31 (24.0%)  
#     median                     36.5         34.0           33.0     
#     mean                       36.2         33.0           32.4     
# BLACK OR AFRICAN AMERICAN   28 (23.1%)   24 (22.6%)     27 (20.9%)  
#   A                          6 (5.0%)     7 (6.6%)       8 (6.2%)   
#     median                     32.0         29.0           32.5     
#     mean                       31.5         28.6           33.6     
#   B                         10 (8.3%)     6 (5.7%)      12 (9.3%)   
#     median                     33.0         30.0           33.5     
#     mean                       35.6         30.8           33.7     
#   C                         12 (9.9%)    11 (10.4%)      7 (5.4%)   
#     median                     33.0         36.0           32.0     
#     mean                       35.5         34.2           35.0
```

What should we do now if we want to sort each median and mean in each of
the strata variables? We need to write a custom score function as the
ready-made ones at the moment work only with content nodes
([`content_table()`](https://pharmaverse.github.io/rtables/reference/content_table.md)
access function for
[`cont_n_allcols()`](https://pharmaverse.github.io/rtables/reference/score_funs.md)
and
[`cont_n_onecol()`](https://pharmaverse.github.io/rtables/reference/score_funs.md),
of which we will talk in a moment). But before that, we need to think
about what are we ordering, i.e. we need to specify the right path. We
suggest looking at the structure first with
[`table_structure()`](https://pharmaverse.github.io/rtables/reference/table_structure.md)
or
[`row_paths_summary()`](https://pharmaverse.github.io/rtables/reference/row_paths_summary.md).

``` r

table_structure(tbl) # Direct inspection into the tree-like structure of rtables
# [TableTree] RACE
#  [TableTree] ASIAN [cont: 1 x 3]
#   [TableTree] STRATA1
#    [TableTree] A [cont: 1 x 3]
#     [ElementaryTable] AGE (2 x 3)
#    [TableTree] B [cont: 1 x 3]
#     [ElementaryTable] AGE (2 x 3)
#    [TableTree] C [cont: 1 x 3]
#     [ElementaryTable] AGE (2 x 3)
#  [TableTree] BLACK OR AFRICAN AMERICAN [cont: 1 x 3]
#   [TableTree] STRATA1
#    [TableTree] A [cont: 1 x 3]
#     [ElementaryTable] AGE (2 x 3)
#    [TableTree] B [cont: 1 x 3]
#     [ElementaryTable] AGE (2 x 3)
#    [TableTree] C [cont: 1 x 3]
#     [ElementaryTable] AGE (2 x 3)
```

We see that to order all of the `AGE` nodes we need to get there with
something like this: `RACE, ASIAN, STRATA1, A, AGE` and no more as the
next level is what we need to sort. But we see now that this path would
sort only the first group. We need wildcards:
`RACE, *, STRATA1, *, AGE`.

Now, we have found a way to select relevant paths that we want to sort.
We want to construct a scoring function that works on the median and
mean and sort them. To do so, we may want to enter our scoring function
with [`browser()`](https://rdrr.io/r/base/browser.html) to see what is
fed to it and try to retrieve the single value that is to be returned to
do the sorting. We allow the user to experiment with this, while here we
show a possible solution that considers summing all the column values
that are retrieved with `row_values(tt)` from the subtable that is fed
to the function itself. Note that any score function should be defined
as having a subtable `tt` as a unique input parameter and a single
numeric value as output.

``` r

scorefun <- function(tt) {
  # Here we could use browser()
  sum(unlist(row_values(tt)))
}
sort_at_path(tbl, c("RACE", "*", "STRATA1", "*", "AGE"), scorefun)
#                             A: Drug X    B: Placebo   C: Combination
# ————————————————————————————————————————————————————————————————————
# ASIAN                       79 (65.3%)   68 (64.2%)     84 (65.1%)  
#   A                         27 (22.3%)   20 (18.9%)     31 (24.0%)  
#     mean                       32.2         33.9           36.8     
#     median                     30.0         33.0           36.0     
#   B                         24 (19.8%)   29 (27.4%)     22 (17.1%)  
#     mean                       34.1         31.6           34.7     
#     median                     32.5         32.0           34.0     
#   C                         28 (23.1%)   19 (17.9%)     31 (24.0%)  
#     median                     36.5         34.0           33.0     
#     mean                       36.2         33.0           32.4     
# BLACK OR AFRICAN AMERICAN   28 (23.1%)   24 (22.6%)     27 (20.9%)  
#   A                          6 (5.0%)     7 (6.6%)       8 (6.2%)   
#     mean                       31.5         28.6           33.6     
#     median                     32.0         29.0           32.5     
#   B                         10 (8.3%)     6 (5.7%)      12 (9.3%)   
#     mean                       35.6         30.8           33.7     
#     median                     33.0         30.0           33.5     
#   C                         12 (9.9%)    11 (10.4%)      7 (5.4%)   
#     mean                       35.5         34.2           35.0     
#     median                     33.0         36.0           32.0
```

To help the user visualize what is happening in the score function we
show here an example of its exploration from the debugging:

    > sort_at_path(tbl, c("RACE", "*", "STRATA1", "*", "AGE"), scorefun)
    Called from: scorefun(x)
    Browse[1]> tt ### THIS IS THE LEAF LEVEL -> DataRow ###
    [DataRow indent_mod 0]: median   30.0   33.0   36.0
    Browse[1]> row_values(tt) ### Extraction of values -> It will be a named list! ###
    $`A: Drug X`
    [1] 30

    $`B: Placebo`
    [1] 33

    $`C: Combination`
    [1] 36

    Browse[1]> sum(unlist(row_values(tt))) ### Final value we want to give back to sort_at_path ###
    [1] 99

We can see how powerful and pragmatic it might be to change the sorting
principles from within the custom scoring function. We show this by
selecting a specific column to sort. Looking at the pre-defined function
[`cont_n_onecol()`](https://pharmaverse.github.io/rtables/reference/score_funs.md)
gives us an insight into how to proceed.

``` r

cont_n_onecol
# function (j) 
# {
#     function(tt) {
#         ctab <- content_table(tt)
#         if (NROW(ctab) == 0) {
#             stop("cont_n_allcols score function used at subtable [", 
#                 obj_name(tt), "] that has no content table.")
#         }
#         row_values(tree_children(ctab)[[1]])[[j]][1]
#     }
# }
# <bytecode: 0x5630bef4dd50>
# <environment: namespace:rtables>
```

We see that a similar function to
[`cont_n_allcols()`](https://pharmaverse.github.io/rtables/reference/score_funs.md)
is wrapped by one that allows a parameter `j` to be used to select a
specific column. We will do the same here for selecting which column we
want to sort.

``` r

scorefun_onecol <- function(colpath) {
  function(tt) {
    # Here we could use browser()
    unlist(cell_values(tt, colpath = colpath), use.names = FALSE)[1] # Modified to lose the list names
  }
}
sort_at_path(tbl, c("RACE", "*", "STRATA1", "*", "AGE"), scorefun_onecol(colpath = c("ARM", "A: Drug X")))
#                             A: Drug X    B: Placebo   C: Combination
# ————————————————————————————————————————————————————————————————————
# ASIAN                       79 (65.3%)   68 (64.2%)     84 (65.1%)  
#   A                         27 (22.3%)   20 (18.9%)     31 (24.0%)  
#     mean                       32.2         33.9           36.8     
#     median                     30.0         33.0           36.0     
#   B                         24 (19.8%)   29 (27.4%)     22 (17.1%)  
#     mean                       34.1         31.6           34.7     
#     median                     32.5         32.0           34.0     
#   C                         28 (23.1%)   19 (17.9%)     31 (24.0%)  
#     median                     36.5         34.0           33.0     
#     mean                       36.2         33.0           32.4     
# BLACK OR AFRICAN AMERICAN   28 (23.1%)   24 (22.6%)     27 (20.9%)  
#   A                          6 (5.0%)     7 (6.6%)       8 (6.2%)   
#     median                     32.0         29.0           32.5     
#     mean                       31.5         28.6           33.6     
#   B                         10 (8.3%)     6 (5.7%)      12 (9.3%)   
#     mean                       35.6         30.8           33.7     
#     median                     33.0         30.0           33.5     
#   C                         12 (9.9%)    11 (10.4%)      7 (5.4%)   
#     mean                       35.5         34.2           35.0     
#     median                     33.0         36.0           32.0
```

In the above table we see that the mean and median rows are reordered by
their values in the first column, compared to the raw table, as desired.

With this function we can also do the same for columns that are nested
within larger splits:

``` r

# Simpler table
tbl <- basic_table() |>
  split_cols_by("ARM") |>
  split_cols_by("SEX",
    split_fun = drop_and_remove_levels(c("U", "UNDIFFERENTIATED"))
  ) |>
  analyze("AGE", afun = more_analysis_fnc) |>
  build_table(DM) |>
  prune_table() |>
  print()
#           A: Drug X      B: Placebo      C: Combination  
#            F      M       F       M        F         M   
# —————————————————————————————————————————————————————————
# median   32.0    35.0   33.0    31.0     35.0      32.0  
# mean     33.7    36.5   33.8    32.1     34.9      34.3

sort_at_path(tbl, c("AGE"), scorefun_onecol(colpath = c("ARM", "B: Placebo", "SEX", "F")))
#           A: Drug X      B: Placebo      C: Combination  
#            F      M       F       M        F         M   
# —————————————————————————————————————————————————————————
# mean     33.7    36.5   33.8    32.1     34.9      34.3  
# median   32.0    35.0   33.0    31.0     35.0      32.0
```

## Writing Custom Pruning Criteria and Scoring Functions

Pruning criteria and scoring functions map `TableTree` or `TableRow`
objects to a Boolean value (for pruning criteria) or a sortable scalar
value (scoring functions). To do this we currently need to interact with
the structure of the objects more than usual. Indeed, we showed already
how sorting can be very complicated if the concept of tree-like
structure and pathing is not well understood. It is important though to
have in mind the following functions that can be used in each pruning or
sorting function to retrieve the relevant information from the table.

### Useful Functions and Accessors

- [`cell_values()`](https://pharmaverse.github.io/rtables/reference/cell_values.md) -
  Retrieves a named list of a `TableRow` or `TableTree` object’s values
  - accepts both `rowpath` and `colpath` to restrict which cell values
    are returned
- [`obj_name()`](https://rdrr.io/pkg/formatters/man/lab_name.html) -
  Retrieves the name of an object. Note this can differ from the label
  that is displayed (if any is) when printing. This will match the
  element in the path.
- [`obj_label()`](https://rdrr.io/pkg/formatters/man/lab_name.html) -
  Retrieves the display label of an object. Note this can differ from
  the name that appears in the path.
- [`content_table()`](https://pharmaverse.github.io/rtables/reference/content_table.md) -
  Retrieves a `TableTree` object’s content table (which contains its
  summary rows).
- [`tree_children()`](https://pharmaverse.github.io/rtables/reference/tree_children.md) -
  Retrieves a `TableTree` object’s direct children (either subtables,
  rows or possibly a mix thereof, though that should not happen in
  practice)

### Example Custom Scoring Functions

#### Sort by a character “score”

In this case, for convenience/simplicity, we use the name of the table
element but any logic which returns a single string could be used here.

We sort the ethnicity by alphabetical order (in practice undoing our
previous sorting by ethnicity above).

``` r

silly_name_scorer <- function(tt) {
  nm <- obj_name(tt)
  print(nm)
  nm
}

sort_at_path(ethsort, "RACE", silly_name_scorer) # Now, it is sorted alphabetically!
# [1] "WHITE"
# [1] "BLACK OR AFRICAN AMERICAN"
# [1] "ASIAN"
#                                    A: Drug X                B: Placebo              C: Combination     
#                                 F            M            F            M            F            M     
# ———————————————————————————————————————————————————————————————————————————————————————————————————————
# ASIAN                       44 (62.9%)   35 (68.6%)   37 (66.1%)   31 (62.0%)   40 (65.6%)   44 (64.7%)
#   A                         15 (21.4%)   12 (23.5%)   14 (25.0%)   6 (12.0%)    15 (24.6%)   16 (23.5%)
#     Mean                      30.40        34.42        35.43        30.33        37.40        36.25   
#   B                         16 (22.9%)   8 (15.7%)    13 (23.2%)   16 (32.0%)   10 (16.4%)   12 (17.6%)
#     Mean                      33.75        34.88        32.46        30.94        33.30        35.92   
#   C                         13 (18.6%)   15 (29.4%)   10 (17.9%)   9 (18.0%)    15 (24.6%)   16 (23.5%)
#     Mean                      36.92        35.60        34.00        31.89        33.47        31.38   
# BLACK OR AFRICAN AMERICAN   18 (25.7%)   10 (19.6%)   12 (21.4%)   12 (24.0%)   13 (21.3%)   14 (20.6%)
#   A                          5 (7.1%)     1 (2.0%)     5 (8.9%)     2 (4.0%)     4 (6.6%)     4 (5.9%) 
#     Mean                      31.20        33.00        28.00        30.00        30.75        36.50   
#   B                         7 (10.0%)     3 (5.9%)     3 (5.4%)     3 (6.0%)     6 (9.8%)     6 (8.8%) 
#     Mean                      36.14        34.33        29.67        32.00        36.33        31.00   
#   C                          6 (8.6%)    6 (11.8%)     4 (7.1%)    7 (14.0%)     3 (4.9%)     4 (5.9%) 
#     Mean                      31.33        39.67        34.50        34.00        33.00        36.50   
# WHITE                       8 (11.4%)    6 (11.8%)    7 (12.5%)    7 (14.0%)    8 (13.1%)    10 (14.7%)
#   A                          2 (2.9%)     1 (2.0%)     3 (5.4%)     3 (6.0%)     1 (1.6%)     5 (7.4%) 
#     Mean                      34.00        45.00        29.33        33.33        35.00        32.80   
#   B                          4 (5.7%)     3 (5.9%)     1 (1.8%)     4 (8.0%)     3 (4.9%)     1 (1.5%) 
#     Mean                      37.00        43.67        48.00        36.75        34.33        36.00   
#   C                          2 (2.9%)     2 (3.9%)     3 (5.4%)     0 (0.0%)     4 (6.6%)     4 (5.9%) 
#     Mean                      35.50        44.00        44.67          NA         38.50        35.00
```

**NOTE**: Generally this would be more appropriately done using the
[`reorder_split_levels()`](https://pharmaverse.github.io/rtables/reference/split_funcs.md)
function within the layout rather than as a sort post-processing step,
but other character scorers may or may not map as easily to layouting
directives.

#### Sort by the Percent Difference in Counts Between Genders in Arm C

We need the F and M percents, only for Arm C (i.e. columns 5 and 6),
differenced.

We will sort ***the strata within each ethnicity*** by the percent
difference in counts between males and females in arm C.

Note: this is not statistically meaningful at all, and is in fact a
terrible idea because it reorders the strata seemingly (but not) at
random within each race, but illustrates the various things we need to
do inside custom sorting functions.

``` r

silly_gender_diffcount <- function(tt) {
  ## (1st) content row has same name as object (STRATA1 level)
  rpath <- c(obj_name(tt), "@content", obj_name(tt))
  ## the [1] below is cause these are count (pct%) cells
  ## and we only want the count part!
  mcount <- unlist(cell_values(
    tt,
    rowpath = rpath,
    colpath = c("ARM", "C: Combination", "SEX", "M")
  ))[1]
  fcount <- unlist(cell_values(
    tt,
    rowpath = rpath,
    colpath = c("ARM", "C: Combination", "SEX", "F")
  ))[1]
  (mcount - fcount) / fcount
}

sort_at_path(pruned, c("RACE", "*", "STRATA1"), silly_gender_diffcount)
#                                    A: Drug X                B: Placebo              C: Combination     
#                                 F            M            F            M            F            M     
# ———————————————————————————————————————————————————————————————————————————————————————————————————————
# ASIAN                       44 (62.9%)   35 (68.6%)   37 (66.1%)   31 (62.0%)   40 (65.6%)   44 (64.7%)
#   B                         16 (22.9%)   8 (15.7%)    13 (23.2%)   16 (32.0%)   10 (16.4%)   12 (17.6%)
#     Mean                      33.75        34.88        32.46        30.94        33.30        35.92   
#   A                         15 (21.4%)   12 (23.5%)   14 (25.0%)   6 (12.0%)    15 (24.6%)   16 (23.5%)
#     Mean                      30.40        34.42        35.43        30.33        37.40        36.25   
#   C                         13 (18.6%)   15 (29.4%)   10 (17.9%)   9 (18.0%)    15 (24.6%)   16 (23.5%)
#     Mean                      36.92        35.60        34.00        31.89        33.47        31.38   
# BLACK OR AFRICAN AMERICAN   18 (25.7%)   10 (19.6%)   12 (21.4%)   12 (24.0%)   13 (21.3%)   14 (20.6%)
#   C                          6 (8.6%)    6 (11.8%)     4 (7.1%)    7 (14.0%)     3 (4.9%)     4 (5.9%) 
#     Mean                      31.33        39.67        34.50        34.00        33.00        36.50   
#   A                          5 (7.1%)     1 (2.0%)     5 (8.9%)     2 (4.0%)     4 (6.6%)     4 (5.9%) 
#     Mean                      31.20        33.00        28.00        30.00        30.75        36.50   
#   B                         7 (10.0%)     3 (5.9%)     3 (5.4%)     3 (6.0%)     6 (9.8%)     6 (8.8%) 
#     Mean                      36.14        34.33        29.67        32.00        36.33        31.00   
# WHITE                       8 (11.4%)    6 (11.8%)    7 (12.5%)    7 (14.0%)    8 (13.1%)    10 (14.7%)
#   A                          2 (2.9%)     1 (2.0%)     3 (5.4%)     3 (6.0%)     1 (1.6%)     5 (7.4%) 
#     Mean                      34.00        45.00        29.33        33.33        35.00        32.80   
#   C                          2 (2.9%)     2 (3.9%)     3 (5.4%)     0 (0.0%)     4 (6.6%)     4 (5.9%) 
#     Mean                      35.50        44.00        44.67          NA         38.50        35.00   
#   B                          4 (5.7%)     3 (5.9%)     1 (1.8%)     4 (8.0%)     3 (4.9%)     1 (1.5%) 
#     Mean                      37.00        43.67        48.00        36.75        34.33        36.00
```
