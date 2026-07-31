# Exploratory Analysis

## Introduction

In this vignette, we would like to introduce how
[`qtable()`](https://pharmaverse.github.io/rtables/reference/qtable_layout.md)
can be used to easily create cross tabulations for exploratory data
analysis.
[`qtable()`](https://pharmaverse.github.io/rtables/reference/qtable_layout.md)
is an extension of [`table()`](https://rdrr.io/r/base/table.html) from
base R and can do much beyond creating two-way contingency tables. The
function has a simple to use interface while internally it builds
layouts using the `rtables` framework.

## Getting Started

Load packages used in this vignette:

``` r

library(rtables)
library(dplyr)
```

Let’s start by seeing what
[`table()`](https://rdrr.io/r/base/table.html) can do:

``` r

table(ex_adsl$ARM)
# 
#      A: Drug X     B: Placebo C: Combination 
#            134            134            132
table(ex_adsl$SEX, ex_adsl$ARM)
#                   
#                    A: Drug X B: Placebo C: Combination
#   F                       79         77             66
#   M                       51         55             60
#   U                        3          2              4
#   UNDIFFERENTIATED         1          0              2
```

We can easily recreate the cross-tables above with
[`qtable()`](https://pharmaverse.github.io/rtables/reference/qtable_layout.md)
by specifying a data.frame with variable(s) to tabulate. The `col_vars`
and `row_vars` arguments control how to split the data across columns
and rows respectively.

``` r

qtable(ex_adsl, col_vars = "ARM")
#         A: Drug X   B: Placebo   C: Combination
#          (N=134)     (N=134)        (N=132)    
# ———————————————————————————————————————————————
# count      134         134            132
qtable(ex_adsl, col_vars = "ARM", row_vars = "SEX")
#                    A: Drug X   B: Placebo   C: Combination
# count               (N=134)     (N=134)        (N=132)    
# ——————————————————————————————————————————————————————————
# F                     79           77             66      
# M                     51           55             60      
# U                      3           2              4       
# UNDIFFERENTIATED       1           0              2
```

Aside from the display style, the main difference is that
[`qtable()`](https://pharmaverse.github.io/rtables/reference/qtable_layout.md)
will add (N=xx) in the table header by default. This can be removed with
`show_colcounts`.

``` r

qtable(ex_adsl, "ARM", show_colcounts = FALSE)
# count            all obs
# ————————————————————————
# A: Drug X          134  
# B: Placebo         134  
# C: Combination     132
```

Any variables used as the row or column facets should not have any empty
strings (““). This is because non empty values are required as labels
when generating the table. The code below will generate an error.

``` r

tmp_adsl <- ex_adsl
tmp_adsl$new <- rep_len(c("", "A", "B"), nrow(tmp_adsl))

qtable(tmp_adsl, row_vars = "new")
```

## Nested Tables

Providing more than one variable name for the row or column structure in
[`qtable()`](https://pharmaverse.github.io/rtables/reference/qtable_layout.md)
will create a nested table. Arbitrary nesting is supported in each
dimension.

``` r

qtable(ex_adsl, row_vars = c("SEX", "STRATA1"), col_vars = c("ARM", "STRATA2"))
#                       A: Drug X        B: Placebo       C: Combination  
#                      S1       S2       S1       S2       S1        S2   
# count              (N=73)   (N=61)   (N=67)   (N=67)   (N=56)    (N=76) 
# ————————————————————————————————————————————————————————————————————————
# F                                                                       
#   A                  12       9        11       13        7        11   
#   B                  14       11       12       15        9        12   
#   C                  17       16       13       13       14        13   
# M                                                                       
#   A                  5        11       10       9         6        14   
#   B                  13       8        7        10        9        12   
#   C                  8        6        13       6         8        11   
# U                                                                       
#   A                  1        0        1        0         1         0   
#   B                  1        0        0        1         0         1   
#   C                  1        0        0        0         1         1   
# UNDIFFERENTIATED                                                        
#   A                  0        0        0        0         0         1   
#   C                  1        0        0        0         1         0
```

Note that by default, unobserved factor levels within a facet are not
included in the table. This can be modified with `drop_levels`. The code
below adds a row of 0s for `STRATA1` level “B” nested under the `SEX`
level “UNDIFFERENTIATED”.

``` r

qtable(
  ex_adsl,
  row_vars = c("SEX", "STRATA1"),
  col_vars = c("ARM", "STRATA2"),
  drop_levels = FALSE
)
#                       A: Drug X        B: Placebo       C: Combination  
#                      S1       S2       S1       S2       S1        S2   
# count              (N=73)   (N=61)   (N=67)   (N=67)   (N=56)    (N=76) 
# ————————————————————————————————————————————————————————————————————————
# F                                                                       
#   A                  12       9        11       13        7        11   
#   B                  14       11       12       15        9        12   
#   C                  17       16       13       13       14        13   
# M                                                                       
#   A                  5        11       10       9         6        14   
#   B                  13       8        7        10        9        12   
#   C                  8        6        13       6         8        11   
# U                                                                       
#   A                  1        0        1        0         1         0   
#   B                  1        0        0        1         0         1   
#   C                  1        0        0        0         1         1   
# UNDIFFERENTIATED                                                        
#   A                  0        0        0        0         0         1   
#   B                  0        0        0        0         0         0   
#   C                  1        0        0        0         1         0
```

In contrast, [`table()`](https://rdrr.io/r/base/table.html) cannot
return a nested table. Rather it produces a list of contingency tables
when more than two variables are used as inputs.

``` r

table(ex_adsl$SEX, ex_adsl$STRATA1, ex_adsl$ARM, ex_adsl$STRATA2)
# , ,  = A: Drug X,  = S1
# 
#                   
#                     A  B  C
#   F                12 14 17
#   M                 5 13  8
#   U                 1  1  1
#   UNDIFFERENTIATED  0  0  1
# 
# , ,  = B: Placebo,  = S1
# 
#                   
#                     A  B  C
#   F                11 12 13
#   M                10  7 13
#   U                 1  0  0
#   UNDIFFERENTIATED  0  0  0
# 
# , ,  = C: Combination,  = S1
# 
#                   
#                     A  B  C
#   F                 7  9 14
#   M                 6  9  8
#   U                 1  0  1
#   UNDIFFERENTIATED  0  0  1
# 
# , ,  = A: Drug X,  = S2
# 
#                   
#                     A  B  C
#   F                 9 11 16
#   M                11  8  6
#   U                 0  0  0
#   UNDIFFERENTIATED  0  0  0
# 
# , ,  = B: Placebo,  = S2
# 
#                   
#                     A  B  C
#   F                13 15 13
#   M                 9 10  6
#   U                 0  1  0
#   UNDIFFERENTIATED  0  0  0
# 
# , ,  = C: Combination,  = S2
# 
#                   
#                     A  B  C
#   F                11 12 13
#   M                14 12 11
#   U                 0  1  1
#   UNDIFFERENTIATED  1  0  0
```

With some help from
[`stats::ftable()`](https://rdrr.io/r/stats/ftable.html) the nested
structure can be achieved in two steps.

``` r

t1 <- ftable(ex_adsl[, c("SEX", "STRATA1", "ARM", "STRATA2")])
ftable(t1, row.vars = c("SEX", "STRATA1"))
#                          ARM     A: Drug X    B: Placebo    C: Combination   
#                          STRATA2        S1 S2         S1 S2             S1 S2
# SEX              STRATA1                                                     
# F                A                      12  9         11 13              7 11
#                  B                      14 11         12 15              9 12
#                  C                      17 16         13 13             14 13
# M                A                       5 11         10  9              6 14
#                  B                      13  8          7 10              9 12
#                  C                       8  6         13  6              8 11
# U                A                       1  0          1  0              1  0
#                  B                       1  0          0  1              0  1
#                  C                       1  0          0  0              1  1
# UNDIFFERENTIATED A                       0  0          0  0              0  1
#                  B                       0  0          0  0              0  0
#                  C                       1  0          0  0              1  0
```

## NA Values

So far in all the examples we have seen, we used counts to summarize the
data in each table cell as this is the default analysis used by
[`qtable()`](https://pharmaverse.github.io/rtables/reference/qtable_layout.md).
Internally, a single analysis variable specified by `avar` is used to
generate the counts in the table. The default analysis variable is the
first variable in `data`. In the case of `ex_adsl` this is “STUDYID”.

Let’s see what happens when we introduce some `NA` values into the
analysis variable:

``` r

tmp_adsl <- ex_adsl
tmp_adsl[[1]] <- NA_character_

qtable(tmp_adsl, row_vars = "ARM", col_vars = "SEX")
#                     F         M        U     UNDIFFERENTIATED
# count            (N=222)   (N=166)   (N=9)        (N=3)      
# —————————————————————————————————————————————————————————————
# A: Drug X           0         0        0            0        
# B: Placebo          0         0        0            0        
# C: Combination      0         0        0            0
```

The resulting table is showing 0’s across all cells because all the
values of the analysis variable are `NA`.

Keep this behavior in mind when doing quick exploratory analysis using
the default counts aggregate function of `qtable`.

If this does not suit your purpose, you can either pre-process your data
to re-code the `NA` values or use another analysis function. We will see
how the latter is done in the [Custom Aggregation](#custom-aggregation)
section.

``` r

# Recode NA values
tmp_adsl[[1]] <- addNA(tmp_adsl[[1]])

qtable(tmp_adsl, row_vars = "ARM", col_vars = "SEX")
#                     F         M        U     UNDIFFERENTIATED
# count            (N=222)   (N=166)   (N=9)        (N=3)      
# —————————————————————————————————————————————————————————————
# A: Drug X          79        51        3            1        
# B: Placebo         77        55        2            0        
# C: Combination     66        60        4            2
```

In addition, row and column variables should have `NA` levels explicitly
labelled as above. If this is not done, the columns and/or rows will not
reflect the full data.

``` r

tmp_adsl$new1 <- factor(NA_character_, levels = c("X", "Y", "Z"))
qtable(tmp_adsl, row_vars = "ARM", col_vars = "new1")
#                    X       Y       Z  
# count            (N=0)   (N=0)   (N=0)
# ——————————————————————————————————————
# A: Drug X          0       0       0  
# B: Placebo         0       0       0  
# C: Combination     0       0       0
```

Explicitly labeling the `NA` levels in the column facet adds a column to
the table:

``` r

tmp_adsl$new2 <- addNA(tmp_adsl$new1)
levels(tmp_adsl$new2)[4] <- "<NA>" # NA needs to be a recognizible string
qtable(tmp_adsl, row_vars = "ARM", col_vars = "new2")
#                    X       Y       Z      <NA>  
# count            (N=0)   (N=0)   (N=0)   (N=400)
# ————————————————————————————————————————————————
# A: Drug X          0       0       0       134  
# B: Placebo         0       0       0       134  
# C: Combination     0       0       0       132
```

## Custom Aggregation

A powerful feature of
[`qtable()`](https://pharmaverse.github.io/rtables/reference/qtable_layout.md)
is that the user can define the type of function used to summarize the
data in each facet. We can specify the type of analysis summary using
the `afun` argument:

``` r

qtable(ex_adsl, row_vars = "STRATA2", col_vars = "ARM", avar = "AGE", afun = mean)
#              A: Drug X   B: Placebo   C: Combination
# AGE - mean    (N=134)     (N=134)        (N=132)    
# ————————————————————————————————————————————————————
# S1             34.10       36.46          35.70     
# S2             33.38       34.40          35.24
```

Note that the analysis variable `AGE` and analysis function name are
included in the top right header of the table.

If the analysis function returns a vector of 2 or 3 elements, the result
is displayed in multi-valued single cells.

``` r

qtable(ex_adsl, row_vars = "STRATA2", col_vars = "ARM", avar = "AGE", afun = range)
#                A: Drug X    B: Placebo    C: Combination
# AGE - range     (N=134)       (N=134)        (N=132)    
# ————————————————————————————————————————————————————————
# S1            23.0 / 48.0   24.0 / 62.0    20.0 / 69.0  
# S2            21.0 / 50.0   21.0 / 58.0    23.0 / 64.0
```

If you want to use an analysis function with more than 3 summary
elements, you can use a list. In this case, the values are displayed in
the table as multiple stacked cells within each facet. If the list
elements are named, the names are used as row labels.

``` r

fivenum2 <- function(x) {
  setNames(as.list(fivenum(x)), c("min", "Q1", "MED", "Q3", "max"))
}
qtable(ex_adsl, row_vars = "STRATA2", col_vars = "ARM", avar = "AGE", afun = fivenum2)
#                  A: Drug X   B: Placebo   C: Combination
# AGE - fivenum2    (N=134)     (N=134)        (N=132)    
# ————————————————————————————————————————————————————————
# S1                                                      
#   min              23.00       24.00          20.00     
#   Q1               28.00       30.00          30.50     
#   MED              34.00       36.00          35.00     
#   Q3               39.00       40.50          40.00     
#   max              48.00       62.00          69.00     
# S2                                                      
#   min              21.00       21.00          23.00     
#   Q1               29.00       29.50          30.00     
#   MED              32.00       32.00          34.50     
#   Q3               38.00       39.50          38.00     
#   max              50.00       58.00          64.00
```

More advanced formatting can be controlled with
[`in_rows()`](https://pharmaverse.github.io/rtables/reference/in_rows.md).
See function documentation for more details.

``` r

meansd_range <- function(x) {
  in_rows(
    "Mean (sd)" = rcell(c(mean(x), sd(x)), format = "xx.xx (xx.xx)"),
    "Range" = rcell(range(x), format = "xx - xx")
  )
}

qtable(ex_adsl, row_vars = "STRATA2", col_vars = "ARM", avar = "AGE", afun = meansd_range)
#                       A: Drug X      B: Placebo    C: Combination
# AGE - meansd_range     (N=134)        (N=134)         (N=132)    
# —————————————————————————————————————————————————————————————————
# S1                                                               
#   Mean (sd)          34.10 (6.71)   36.46 (7.72)    35.70 (8.22) 
#   Range                23 - 48        24 - 62         20 - 69    
# S2                                                               
#   Mean (sd)          33.38 (6.40)   34.40 (7.99)    35.24 (7.39) 
#   Range                21 - 50        21 - 58         23 - 64
```

## Marginal Summaries

Another feature of
[`qtable()`](https://pharmaverse.github.io/rtables/reference/qtable_layout.md)
is the ability to quickly add marginal summary rows with the
`summarize_groups` argument. This summary will add to the table the
count of non-NA records of the analysis variable at each level of
nesting. For example, compare these two tables:

``` r

qtable(
  ex_adsl,
  row_vars = c("STRATA1", "STRATA2"), col_vars = "ARM",
  avar = "AGE", afun = mean
)
#              A: Drug X   B: Placebo   C: Combination
# AGE - mean    (N=134)     (N=134)        (N=132)    
# ————————————————————————————————————————————————————
# A                                                   
#   S1           31.61       36.68          34.00     
#   S2           34.40       33.55          34.35     
# B                                                   
#   S1           34.57       37.68          35.83     
#   S2           32.79       34.77          36.68     
# C                                                   
#   S1           35.26       35.38          36.58     
#   S2           32.95       34.89          34.72

qtable(
  ex_adsl,
  row_vars = c("STRATA1", "STRATA2"), col_vars = "ARM",
  summarize_groups = TRUE, avar = "AGE", afun = mean
)
#                  A: Drug X    B: Placebo   C: Combination
# AGE - mean        (N=134)      (N=134)        (N=132)    
# —————————————————————————————————————————————————————————
# A                38 (28.4%)   44 (32.8%)     40 (30.3%)  
#   S1             18 (13.4%)   22 (16.4%)     14 (10.6%)  
#     AGE - mean     31.61        36.68          34.00     
#   S2             20 (14.9%)   22 (16.4%)     26 (19.7%)  
#     AGE - mean     34.40        33.55          34.35     
# B                47 (35.1%)   45 (33.6%)     43 (32.6%)  
#   S1             28 (20.9%)   19 (14.2%)     18 (13.6%)  
#     AGE - mean     34.57        37.68          35.83     
#   S2             19 (14.2%)   26 (19.4%)     25 (18.9%)  
#     AGE - mean     32.79        34.77          36.68     
# C                49 (36.6%)   45 (33.6%)     49 (37.1%)  
#   S1             27 (20.1%)   26 (19.4%)     24 (18.2%)  
#     AGE - mean     35.26        35.38          36.58     
#   S2             22 (16.4%)   19 (14.2%)     25 (18.9%)  
#     AGE - mean     32.95        34.89          34.72
```

In the second table, there are marginal summary rows for each level of
the two row facet variables: `STRATA1` and `STRATA2`. The number 18 in
the second row gives the count of observations part of `ARM` level “A:
Drug X”, `STRATA1` level “A”, and `STRATA2` level “S1”. The percent is
calculated as the cell count divided by the column count given in the
table header. So we can see that the mean `AGE` of 31.61 in that
subgroup is based on 18 subjects which correspond to 13.4% of the
subjects in arm “A: Drug X”.

See
[`?summarize_row_groups`](https://pharmaverse.github.io/rtables/reference/summarize_row_groups.md)
for how to add marginal summary rows when using the core `rtables`
framework.

## Table Decorations

Tables generated with
[`qtable()`](https://pharmaverse.github.io/rtables/reference/qtable_layout.md)
can include annotations such as titles, subtitles and footnotes like so:

``` r

qtable(
  ex_adsl,
  row_vars = "STRATA2", col_vars = "ARM",
  title = "Strata 2 Summary",
  subtitle = paste0("STUDY ", ex_adsl$STUDYID[1]),
  main_footer = paste0("Date: ", as.character(Sys.Date()))
)
# Strata 2 Summary
# STUDY AB12345
# 
# ———————————————————————————————————————————————
#         A: Drug X   B: Placebo   C: Combination
# count    (N=134)     (N=134)        (N=132)    
# ———————————————————————————————————————————————
# S1         73           67             56      
# S2         61           67             76      
# ———————————————————————————————————————————————
# 
# Date: 2026-07-31
```

## Summary

Here is what we have learned in this vignette:

- [`qtable()`](https://pharmaverse.github.io/rtables/reference/qtable_layout.md)
  can replace and extend uses of
  [`table()`](https://rdrr.io/r/base/table.html) and
  [`stats::ftable()`](https://rdrr.io/r/stats/ftable.html)

- [`qtable()`](https://pharmaverse.github.io/rtables/reference/qtable_layout.md)
  is useful for exploratory data analysis

As the intended use of
[`qtable()`](https://pharmaverse.github.io/rtables/reference/qtable_layout.md)
is for exploratory data analysis, there is limited functionality for
building very complex tables. For details on how to get started with the
core `rtables` layout functionality see the
[`introduction`](https://pharmaverse.github.io/rtables/latest-release/articles/rtables.html)
vignette.
