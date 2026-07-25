# Tabulation Concepts

## Introduction

In this vignette we will introduce some theory behind using layouts for
table creation. Much of the theory also holds true when using other
table packages. For this vignette we will use the following packages:

``` r

library(dplyr)
library(tibble)
library(rtables)
```

The data we use is the following, created with random number generators:

``` r

add_subgroup <- function(x) paste0(tolower(x), sample(1:3, length(x), TRUE))

set.seed(1)

df <- tibble(
  x = rnorm(100),
  c1 = factor(sample(c("A", "B", "C"), 100, replace = TRUE), levels = c("A", "B", "C")),
  r1 = factor(sample(c("U", "V", "W"), 100, replace = TRUE), levels = c("U", "V", "W"))
) |>
  mutate(
    c2 = add_subgroup(c1),
    r2 = add_subgroup(r1),
    y = as.numeric(2 * as.numeric(c1) - 3 * as.numeric(r1))
  ) |>
  select(c1, c2, r1, r2, x, y)

df
# # A tibble: 100 × 6
#    c1    c2    r1    r2         x     y
#    <fct> <chr> <fct> <chr>  <dbl> <dbl>
#  1 B     b2    U     u3    -0.626     1
#  2 A     a3    V     v2     0.184    -4
#  3 B     b1    V     v2    -0.836    -2
#  4 B     b3    V     v2     1.60     -2
#  5 B     b1    U     u1     0.330     1
#  6 C     c1    U     u3    -0.820     3
#  7 A     a3    U     u3     0.487    -1
#  8 B     b1    U     u3     0.738     1
#  9 C     c3    V     v2     0.576     0
# 10 C     c3    U     u2    -0.305     3
# # ℹ 90 more rows
```

## Building A Table Row By Row

Let’s look at a table that has 3 columns and 3 rows. Each row represents
a different analysis (functions `foo`, `bar`, `zoo` that return an
[`rcell()`](https://pharmaverse.github.io/rtables/reference/rcell.md)
object):

                         A         B         C
    ------------------------------------------------
    foo_label        foo(df_A)  foo(df_B)  foo(df_C)
    bar_label        bar(df_A)  bar(df_B)  bar(df_C)
    zoo_label        zoo(df_A)  zoo(df_B)  zoo(df_C)

The data passed to the analysis functions are a subset defined by the
respective column and:

``` r

df_A <- df |> filter(c1 == "A")
df_B <- df |> filter(c1 == "B")
df_C <- df |> filter(c1 == "C")
```

Let’s do this on the concrete data with
[`analyze()`](https://pharmaverse.github.io/rtables/reference/analyze.md):

``` r

foo <- prod
bar <- sum
zoo <- mean

lyt <- basic_table() |>
  split_cols_by("c1") |>
  analyze("x", function(df) foo(df$x), var_labels = "foo label", format = "xx.xx") |>
  analyze("x", function(df) bar(df$x), var_labels = "bar label", format = "xx.xx") |>
  analyze("x", function(df) zoo(df$x), var_labels = "zoo label", format = "xx.xx")

tbl <- build_table(lyt, df)
# Warning: Non-unique sibling analysis table names. Using Labels instead. Use the table_names argument to analyze to avoid this when analyzing the same variable multiple times.
#   occured at (row) path: root
tbl
#                A       B       C  
# ——————————————————————————————————
# foo label                         
#   foo label   0.00   -0.00   -0.00
# bar label                         
#   bar label   1.87   4.37    4.64 
# zoo label                         
#   zoo label   0.05   0.13    0.18
```

or if we wanted the `x` variable instead of the data frame:

                         A         B         C
    ------------------------------------------------
    foo_label        foo(x_A)  foo(x_B)  foo(x_C)
    bar_label        bar(x_A)  bar(x_B)  bar(x_C)
    zoo_label        zoo(x_A)  zoo(x_B)  zoo(x_C)

where:

``` r

x_A <- df_A$x
x_B <- df_B$x
x_C <- df_C$x
```

The function passed to `afun` is evaluated using argument matching. If
`afun` has an argument `x` the analysis variable specified in `vars` in
[`analyze()`](https://pharmaverse.github.io/rtables/reference/analyze.md)
is passed to the function, and if `afun` has an argument `df` then a
subset of the dataset is passed to `afun`:

``` r

lyt2 <- basic_table() |>
  split_cols_by("c1") |>
  analyze("x", foo, var_labels = "foo label", format = "xx.xx") |>
  analyze("x", bar, var_labels = "bar label", format = "xx.xx") |>
  analyze("x", zoo, var_labels = "zoo label", format = "xx.xx")

tbl2 <- build_table(lyt2, df)
# Warning: Non-unique sibling analysis table names. Using Labels instead. Use the table_names argument to analyze to avoid this when analyzing the same variable multiple times.
#   occured at (row) path: root
tbl2
#              A       B       C  
# ————————————————————————————————
# foo label                       
#   foo       0.00   -0.00   -0.00
# bar label                       
#   bar       1.87   4.37    4.64 
# zoo label                       
#   zoo       0.05   0.13    0.18
```

Note that it is also possible that a function returns multiple rows with
[`in_rows()`](https://pharmaverse.github.io/rtables/reference/in_rows.md):

``` r

lyt3 <- basic_table() |>
  split_cols_by("c1") |>
  analyze("x", function(x) {
    in_rows(
      "row 1" = rcell(mean(x), format = "xx.xx"),
      "row 2" = rcell(sd(x), format = "xx.xxx")
    )
  }, var_labels = "foo label") |>
  analyze("x", function(x) {
    in_rows(
      "more rows 1" = rcell(median(x), format = "xx.x"),
      "even more rows 1" = rcell(IQR(x), format = "xx.xx")
    )
  }, var_labels = "bar label", format = "xx.xx")

tbl3 <- build_table(lyt3, df)
# Warning: Non-unique sibling analysis table names. Using Labels instead. Use the table_names argument to analyze to avoid this when analyzing the same variable multiple times.
#   occured at (row) path: root
tbl3
#                        A       B       C  
# ——————————————————————————————————————————
# foo label                                 
#   row 1              0.05    0.13    0.18 
#   row 2              0.985   0.815   0.890
# bar label                                 
#   more rows 1        -0.0     0.2     0.3 
#   even more rows 1   1.20    1.15    1.16
```

This is how we recommend you specify the row names explicitly.

## Tabulation With Row Structure

Let’s say we would like to create the following table:

                A         B         C
    --------------------------------------
    U        foo(df_UA)  foo(df_UB)  foo(df_UC)
    V        foo(df_VA)  foo(df_VB)  foo(df_VC)
    W        foo(df_WA)  foo(df_WB)  foo(df_WC)

where `df_*` are subsets of `df` as follows:

``` r

df_UA <- df |> filter(r1 == "U", c1 == "A")
df_VA <- df |> filter(r1 == "V", c1 == "A")
df_WA <- df |> filter(r1 == "W", c1 == "A")
df_UB <- df |> filter(r1 == "U", c1 == "B")
df_VB <- df |> filter(r1 == "V", c1 == "B")
df_WB <- df |> filter(r1 == "W", c1 == "C")
df_UC <- df |> filter(r1 == "U", c1 == "C")
df_VC <- df |> filter(r1 == "V", c1 == "C")
df_WC <- df |> filter(r1 == "W", c1 == "C")
```

further note that `df_*` are of the same class as `df`, i.e. `tibble`s.
Hence `foo` aggregates the subset of our data to a cell value.

Given a function `foo` (ignore the `...` for now):

``` r

foo <- function(df, labelstr = "", ...) {
  paste(dim(df), collapse = " x ")
}
```

we can start calculating the cell values individually:

``` r

foo(df_UA)
# [1] "17 x 6"
foo(df_VA)
# [1] "9 x 6"
foo(df_WA)
# [1] "14 x 6"
foo(df_UB)
# [1] "13 x 6"
foo(df_VB)
# [1] "15 x 6"
foo(df_WB)
# [1] "11 x 6"
foo(df_UC)
# [1] "10 x 6"
foo(df_VC)
# [1] "5 x 6"
foo(df_WC)
# [1] "11 x 6"
```

Now we are still missing the table structure:

``` r

matrix(
  list(
    foo(df_UA),
    foo(df_VA),
    foo(df_WA),
    foo(df_UB),
    foo(df_VB),
    foo(df_WB),
    foo(df_UC),
    foo(df_VC),
    foo(df_WC)
  ),
  byrow = FALSE, ncol = 3
)
#      [,1]     [,2]     [,3]    
# [1,] "17 x 6" "13 x 6" "10 x 6"
# [2,] "9 x 6"  "15 x 6" "5 x 6" 
# [3,] "14 x 6" "11 x 6" "11 x 6"
```

In `rtables` this type of tabulation is done with `layouts`:

``` r

lyt4 <- basic_table() |>
  split_cols_by("c1") |>
  split_rows_by("r1") |>
  analyze("x", foo)

tbl4 <- build_table(lyt4, df)
tbl4
#           A        B        C   
# ————————————————————————————————
# U                               
#   foo   17 x 6   13 x 6   10 x 6
# V                               
#   foo   9 x 6    15 x 6   5 x 6 
# W                               
#   foo   14 x 6   6 x 6    11 x 6
```

or if we would not want to see the `foo` label we would have to use:

``` r

lyt5 <- basic_table() |>
  split_cols_by("c1") |>
  split_rows_by("r1") |>
  summarize_row_groups(cfun = foo, format = "xx")

tbl5 <- build_table(lyt5, df)
tbl5
#      A        B        C   
# ———————————————————————————
#    17 x 6   13 x 6   10 x 6
#    9 x 6    15 x 6   5 x 6 
#    14 x 6   6 x 6    11 x 6
```

but now the row labels have disappeared. This is because `cfun` needs to
define its row label. So let’s redefine `foo`:

``` r

foo <- function(df, labelstr) {
  rcell(paste(dim(df), collapse = " x "), format = "xx", label = labelstr)
}

lyt6 <- basic_table() |>
  split_cols_by("c1") |>
  split_rows_by("r1") |>
  summarize_row_groups(cfun = foo)

tbl6 <- build_table(lyt6, df)
tbl6
#       A        B        C   
# ————————————————————————————
# U   17 x 6   13 x 6   10 x 6
# V   9 x 6    15 x 6   5 x 6 
# W   14 x 6   6 x 6    11 x 6
```

### Calculating the Mean

Now let’s calculate the mean of `df$y` for pattern I:

``` r

foo <- function(df, labelstr) {
  rcell(mean(df$y), label = labelstr, format = "xx.xx")
}

lyt7 <- basic_table() |>
  split_cols_by("c1") |>
  split_rows_by("r1") |>
  summarize_row_groups(cfun = foo)

tbl7 <- build_table(lyt7, df)
tbl7
#       A       B       C  
# —————————————————————————
# U   -1.00   1.00    3.00 
# V   -4.00   -2.00   0.00 
# W   -7.00   -5.00   -3.00
```

Note that `foo` has the variable information hard-encoded in the
function body. Let’s try some alternatives returning to
[`analyze()`](https://pharmaverse.github.io/rtables/reference/analyze.md):

``` r

lyt8 <- basic_table() |>
  split_cols_by("c1") |>
  split_rows_by("r1") |>
  analyze("y", afun = mean)

tbl8 <- build_table(lyt8, df)
tbl8
#          A    B    C 
# —————————————————————
# U                    
#   mean   -1   1    3 
# V                    
#   mean   -4   -2   0 
# W                    
#   mean   -7   -5   -3
```

Note that the subset of the `y` variable is passed as the `x` argument
to [`mean()`](https://rdrr.io/r/base/mean.html). We could also get the
`data.frame` instead of the variable:

``` r

lyt9 <- basic_table() |>
  split_cols_by("c1") |>
  split_rows_by("r1") |>
  analyze("y", afun = function(df) mean(df$y))

tbl9 <- build_table(lyt9, df)
tbl9
#       A    B    C 
# ——————————————————
# U                 
#   y   -1   1    3 
# V                 
#   y   -4   -2   0 
# W                 
#   y   -7   -5   -3
```

which is in contrast to:

``` r

lyt10 <- basic_table() |>
  split_cols_by("c1") |>
  split_rows_by("r1") |>
  analyze("y", afun = function(x) mean(x))

tbl10 <- build_table(lyt10, df)
tbl10
#       A    B    C 
# ——————————————————
# U                 
#   y   -1   1    3 
# V                 
#   y   -4   -2   0 
# W                 
#   y   -7   -5   -3
```

where the function receives the subset of `y`.

### Group Summaries

Pattern I is an interesting one as we can add more row structure (with
further splits). Consider the following table:

                A         B         C
    --------------------------------------
    U
      u1     foo(<>)  foo(<>)  foo(<>)
      u2     foo(<>)  foo(<>)  foo(<>)
      u3     foo(<>)  foo(<>)  foo(<>)
    V
      v1     foo(<>)  foo(<>)  foo(<>)
      v2     foo(<>)  foo(<>)  foo(<>)
      v3     foo(<>)  foo(<>)  foo(<>)
    W
      w1     foo(<>)  foo(<>)  foo(<>)
      w2     foo(<>)  foo(<>)  foo(<>)
      w3     foo(<>)  foo(<>)  foo(<>)

where `<>` represents the data that is represented by the cell. So for
the cell `U > u1, A` we would have the subset:

``` r

df |>
  filter(r1 == "U", r2 == "u1", c1 == "A")
# # A tibble: 2 × 6
#   c1    c2    r1    r2        x     y
#   <fct> <chr> <fct> <chr> <dbl> <dbl>
# 1 A     a2    U     u1    1.12     -1
# 2 A     a1    U     u1    0.594    -1
```

and so on. We can get this table as follows:

``` r

lyt11 <- basic_table() |>
  split_cols_by("c1") |>
  split_rows_by("r1") |>
  split_rows_by("r2") |>
  summarize_row_groups(cfun = function(df, labelstr) {
    rcell(mean(df$x), format = "xx.xx", label = paste("mean x for", labelstr))
  })

tbl11 <- build_table(lyt11, df)
tbl11
#                     A       B       C  
# ———————————————————————————————————————
# U                                      
#   mean x for u3   -0.04   0.36    -0.25
#   mean x for u1   0.86    0.32     NA  
#   mean x for u2   -0.28   0.38    0.08 
# V                                      
#   mean x for v2   0.01    0.55    0.60 
#   mean x for v3   -0.03   -0.30   1.06 
#   mean x for v1   0.56    -0.27   -0.54
# W                                      
#   mean x for w1   -0.58   0.42    0.67 
#   mean x for w3   0.56    0.69    -0.39
#   mean x for w2   -1.99   -0.10   0.53
```

or, if we wanted to calculate two summaries per row split:

``` r

s_mean_sd <- function(x) {
  in_rows("mean (sd)" = rcell(c(mean(x), sd(x)), format = "xx.xx (xx.xx)"))
}

s_range <- function(x) {
  in_rows("range" = rcell(range(x), format = "xx.xx - xx.xx"))
}

lyt12 <- basic_table() |>
  split_cols_by("c1") |>
  split_rows_by("r1") |>
  split_rows_by("r2") |>
  analyze("x", s_mean_sd, show_labels = "hidden") |>
  analyze("x", s_range, show_labels = "hidden")

tbl12 <- build_table(lyt12, df)
# Warning: Non-unique sibling analysis table names. Using Labels instead. Use the table_names argument to analyze to avoid this when analyzing the same variable multiple times.
#   occured at (row) path: r1[U]->r2[u3]
# Modifying subtable (or row) names to ensure uniqueness among direct siblings
# [x  -> { x, x[2] }]
#   To control table names use split_rows_by*(, parent_name =.) or  analyze(., table_names = .) when analyzing a single variable, or analyze(., parent_name = .) when analyzing multiple variables in a single call.FALSE
# Warning in min(x): no non-missing arguments to min; returning Inf
# Warning in max(x): no non-missing arguments to max; returning -Inf
# Warning: Non-unique sibling analysis table names. Using Labels instead. Use the table_names argument to analyze to avoid this when analyzing the same variable multiple times.
#   occured at (row) path: r1[U]->r2[u1]
# Modifying subtable (or row) names to ensure uniqueness among direct siblings
# [x  -> { x, x[2] }]
#   To control table names use split_rows_by*(, parent_name =.) or  analyze(., table_names = .) when analyzing a single variable, or analyze(., parent_name = .) when analyzing multiple variables in a single call.FALSE
# Warning: Non-unique sibling analysis table names. Using Labels instead. Use the table_names argument to analyze to avoid this when analyzing the same variable multiple times.
#   occured at (row) path: r1[U]->r2[u2]
# Modifying subtable (or row) names to ensure uniqueness among direct siblings
# [x  -> { x, x[2] }]
#   To control table names use split_rows_by*(, parent_name =.) or  analyze(., table_names = .) when analyzing a single variable, or analyze(., parent_name = .) when analyzing multiple variables in a single call.FALSE
# Warning: Non-unique sibling analysis table names. Using Labels instead. Use the table_names argument to analyze to avoid this when analyzing the same variable multiple times.
#   occured at (row) path: r1[V]->r2[v2]
# Modifying subtable (or row) names to ensure uniqueness among direct siblings
# [x  -> { x, x[2] }]
#   To control table names use split_rows_by*(, parent_name =.) or  analyze(., table_names = .) when analyzing a single variable, or analyze(., parent_name = .) when analyzing multiple variables in a single call.FALSE
# Warning: Non-unique sibling analysis table names. Using Labels instead. Use the table_names argument to analyze to avoid this when analyzing the same variable multiple times.
#   occured at (row) path: r1[V]->r2[v3]
# Modifying subtable (or row) names to ensure uniqueness among direct siblings
# [x  -> { x, x[2] }]
#   To control table names use split_rows_by*(, parent_name =.) or  analyze(., table_names = .) when analyzing a single variable, or analyze(., parent_name = .) when analyzing multiple variables in a single call.FALSE
# Warning: Non-unique sibling analysis table names. Using Labels instead. Use the table_names argument to analyze to avoid this when analyzing the same variable multiple times.
#   occured at (row) path: r1[V]->r2[v1]
# Modifying subtable (or row) names to ensure uniqueness among direct siblings
# [x  -> { x, x[2] }]
#   To control table names use split_rows_by*(, parent_name =.) or  analyze(., table_names = .) when analyzing a single variable, or analyze(., parent_name = .) when analyzing multiple variables in a single call.FALSE
# Warning: Non-unique sibling analysis table names. Using Labels instead. Use the table_names argument to analyze to avoid this when analyzing the same variable multiple times.
#   occured at (row) path: r1[W]->r2[w1]
# Modifying subtable (or row) names to ensure uniqueness among direct siblings
# [x  -> { x, x[2] }]
#   To control table names use split_rows_by*(, parent_name =.) or  analyze(., table_names = .) when analyzing a single variable, or analyze(., parent_name = .) when analyzing multiple variables in a single call.FALSE
# Warning: Non-unique sibling analysis table names. Using Labels instead. Use the table_names argument to analyze to avoid this when analyzing the same variable multiple times.
#   occured at (row) path: r1[W]->r2[w3]
# Modifying subtable (or row) names to ensure uniqueness among direct siblings
# [x  -> { x, x[2] }]
#   To control table names use split_rows_by*(, parent_name =.) or  analyze(., table_names = .) when analyzing a single variable, or analyze(., parent_name = .) when analyzing multiple variables in a single call.FALSE
# Warning: Non-unique sibling analysis table names. Using Labels instead. Use the table_names argument to analyze to avoid this when analyzing the same variable multiple times.
#   occured at (row) path: r1[W]->r2[w2]
# Modifying subtable (or row) names to ensure uniqueness among direct siblings
# [x  -> { x, x[2] }]
#   To control table names use split_rows_by*(, parent_name =.) or  analyze(., table_names = .) when analyzing a single variable, or analyze(., parent_name = .) when analyzing multiple variables in a single call.FALSE
tbl12
#                       A              B              C      
# ———————————————————————————————————————————————————————————
# U                                                          
#   u3                                                       
#     mean (sd)   -0.04 (1.18)    0.36 (1.41)    -0.25 (0.72)
#     range       -1.80 - 1.47    -1.28 - 2.40   -0.82 - 0.56
#   u1                                                       
#     mean (sd)    0.86 (0.38)    0.32 (0.51)         NA     
#     range        0.59 - 1.12    -0.48 - 0.94    Inf - -Inf 
#   u2                                                       
#     mean (sd)   -0.28 (0.96)    0.38 (0.67)    0.08 (0.91) 
#     range       -1.52 - 1.43    -0.39 - 0.82   -0.93 - 1.51
# V                                                          
#   v2                                                       
#     mean (sd)    0.01 (0.25)    0.55 (1.14)    0.60 (0.03) 
#     range       -0.16 - 0.18    -0.84 - 1.60   0.58 - 0.62 
#   v3                                                       
#     mean (sd)   -0.03 (0.37)    -0.30 (0.36)    1.06 (NA)  
#     range       -0.41 - 0.33    -0.62 - 0.03   1.06 - 1.06 
#   v1                                                       
#     mean (sd)    0.56 (1.10)    -0.27 (0.73)   -0.54 (1.18)
#     range       -0.16 - 2.17    -1.22 - 0.59   -1.38 - 0.29
# W                                                          
#   w1                                                       
#     mean (sd)   -0.58 (0.85)     0.42 (NA)     0.67 (0.39) 
#     range       -1.25 - 0.61    0.42 - 0.42    0.37 - 1.21 
#   w3                                                       
#     mean (sd)    0.56 (0.85)     0.69 (NA)     -0.39 (1.68)
#     range       -0.71 - 1.98    0.69 - 0.69    -2.21 - 1.10
#   w2                                                       
#     mean (sd)    -1.99 (NA)     -0.10 (0.47)   0.53 (0.60) 
#     range       -1.99 - -1.99   -0.61 - 0.39   -0.10 - 1.16
```

Which has the following structure:

                       A              B              C
    ---------------------------------------------------------
    U
      u1
         mean_sd  s_mean_sd(<>)  s_mean_sd(<>)  s_mean_sd(<>)
         range    s_range(<>)    s_range(<>)    s_range(<>)
      u2
         mean_sd  s_mean_sd(<>)  s_mean_sd(<>)  s_mean_sd(<>)
         range    s_range(<>)    s_range(<>)    s_range(<>)
      u3
         mean_sd  s_mean_sd(<>)  s_mean_sd(<>)  s_mean_sd(<>)
         range    s_range(<>)    s_range(<>)    s_range(<>)
    V
      v1
         mean_sd  s_mean_sd(<>)  s_mean_sd(<>)  s_mean_sd(<>)
         range    s_range(<>)    s_range(<>)    s_range(<>)
      v2
         mean_sd  s_mean_sd(<>)  s_mean_sd(<>)  s_mean_sd(<>)
         range    s_range(<>)    s_range(<>)    s_range(<>)
      v3
         mean_sd  s_mean_sd(<>)  s_mean_sd(<>)  s_mean_sd(<>)
         range    s_range(<>)    s_range(<>)    s_range(<>)
    W
      w1
         mean_sd  s_mean_sd(<>)  s_mean_sd(<>)  s_mean_sd(<>)
         range    s_range(<>)    s_range(<>)    s_range(<>)
      w2
         mean_sd  s_mean_sd(<>)  s_mean_sd(<>)  s_mean_sd(<>)
         range    s_range(<>)    s_range(<>)    s_range(<>)
      w3
         mean_sd  s_mean_sd(<>)  s_mean_sd(<>)  s_mean_sd(<>)
         range    s_range(<>)    s_range(<>)    s_range(<>)

The rows `U`, `u1`, `u2`, …, `W`, `w1`, `w2`, `w3` are label rows and
the other rows (with `mean_sd` and `range`) are data rows. Currently we
do not have content rows in the table. Content rows summarize the data
defined by their splitting (i.e. `V > v1, B`). So if we wanted to add
content rows at the `r2` split level then we would get:

                       A              B              C
    ---------------------------------------------------------
    U
      u1          s_cfun_2(<>)   s_cfun_2(<>)   s_cfun_2(<>)
         mean_sd  s_mean_sd(<>)  s_mean_sd(<>)  s_mean_sd(<>)
         range    s_range(<>)    s_range(<>)    s_range(<>)
      u2          s_cfun_2(<>)   s_cfun_2(<>)   s_cfun_2(<>)
         mean_sd  s_mean_sd(<>)  s_mean_sd(<>)  s_mean_sd(<>)
         range    s_range(<>)    s_range(<>)    s_range(<>)
      u3          s_cfun_2(<>)   s_cfun_2(<>)   s_cfun_2(<>)
         mean_sd  s_mean_sd(<>)  s_mean_sd(<>)  s_mean_sd(<>)
         range    s_range(<>)    s_range(<>)    s_range(<>)
    V
      v1          s_cfun_2(<>)   s_cfun_2(<>)   s_cfun_2(<>)
         mean_sd  s_mean_sd(<>)  s_mean_sd(<>)  s_mean_sd(<>)
         range    s_range(<>)    s_range(<>)    s_range(<>)
      v2          s_cfun_2(<>)   s_cfun_2(<>)   s_cfun_2(<>)
         mean_sd  s_mean_sd(<>)  s_mean_sd(<>)  s_mean_sd(<>)
         range    s_range(<>)    s_range(<>)    s_range(<>)
      v3          s_cfun_2(<>)   s_cfun_2(<>)   s_cfun_2(<>)
         mean_sd  s_mean_sd(<>)  s_mean_sd(<>)  s_mean_sd(<>)
         range    s_range(<>)    s_range(<>)    s_range(<>)
    W
      w1          s_cfun_2(<>)   s_cfun_2(<>)   s_cfun_2(<>)
         mean_sd  s_mean_sd(<>)  s_mean_sd(<>)  s_mean_sd(<>)
         range    s_range(<>)    s_range(<>)    s_range(<>)
      w2          s_cfun_2(<>)   s_cfun_2(<>)   s_cfun_2(<>)
         mean_sd  s_mean_sd(<>)  s_mean_sd(<>)  s_mean_sd(<>)
         range    s_range(<>)    s_range(<>)    s_range(<>)
      w3          s_cfun_2(<>)   s_cfun_2(<>)   s_cfun_2(<>)
         mean_sd  s_mean_sd(<>)  s_mean_sd(<>)  s_mean_sd(<>)
         range    s_range(<>)    s_range(<>)    s_range(<>)

where `s_cfun_2` is the content function and either returns one row via
[`rcell()`](https://pharmaverse.github.io/rtables/reference/rcell.md) or
multiple rows via
[`in_rows()`](https://pharmaverse.github.io/rtables/reference/in_rows.md).
The data represented by `<>` for the content rows is same data as for
it’s descendant, i.e. for the `U > u1, A` content row cell it is
`df |> filter(r1 == "U", r2 == "u1", c1 == "A")`. Note that content
functions `cfun` operate only on data frames and not on
vectors/variables so they must take the `df` argument. Further, a `cfun`
must also have the `labelstr` argument which is the split level. This
way, the `cfun` can define its own row name. In order to get the table
above we can use the layout framework as follows:

``` r

s_mean_sd <- function(x) {
  in_rows("mean (sd)" = rcell(c(mean(x), sd(x)), format = "xx.xx (xx.xx)"))
}

s_range <- function(x) {
  in_rows("range" = rcell(range(x), format = "xx.xx - xx.xx"))
}

s_cfun_2 <- function(df, labelstr) {
  rcell(nrow(df), format = "xx", label = paste(labelstr, "(n)"))
}

lyt13 <- basic_table() |>
  split_cols_by("c1") |>
  split_rows_by("r1") |>
  split_rows_by("r2") |>
  summarize_row_groups(cfun = s_cfun_2) |>
  analyze("x", s_mean_sd, show_labels = "hidden") |>
  analyze("x", s_range, show_labels = "hidden")

tbl13 <- build_table(lyt13, df)
# Warning: Non-unique sibling analysis table names. Using Labels instead. Use the table_names argument to analyze to avoid this when analyzing the same variable multiple times.
#   occured at (row) path: r1[U]->r2[u3]
# Modifying subtable (or row) names to ensure uniqueness among direct siblings
# [x  -> { x, x[2] }]
#   To control table names use split_rows_by*(, parent_name =.) or  analyze(., table_names = .) when analyzing a single variable, or analyze(., parent_name = .) when analyzing multiple variables in a single call.FALSE
# Warning in min(x): no non-missing arguments to min; returning Inf
# Warning in max(x): no non-missing arguments to max; returning -Inf
# Warning: Non-unique sibling analysis table names. Using Labels instead. Use the table_names argument to analyze to avoid this when analyzing the same variable multiple times.
#   occured at (row) path: r1[U]->r2[u1]
# Modifying subtable (or row) names to ensure uniqueness among direct siblings
# [x  -> { x, x[2] }]
#   To control table names use split_rows_by*(, parent_name =.) or  analyze(., table_names = .) when analyzing a single variable, or analyze(., parent_name = .) when analyzing multiple variables in a single call.FALSE
# Warning: Non-unique sibling analysis table names. Using Labels instead. Use the table_names argument to analyze to avoid this when analyzing the same variable multiple times.
#   occured at (row) path: r1[U]->r2[u2]
# Modifying subtable (or row) names to ensure uniqueness among direct siblings
# [x  -> { x, x[2] }]
#   To control table names use split_rows_by*(, parent_name =.) or  analyze(., table_names = .) when analyzing a single variable, or analyze(., parent_name = .) when analyzing multiple variables in a single call.FALSE
# Warning: Non-unique sibling analysis table names. Using Labels instead. Use the table_names argument to analyze to avoid this when analyzing the same variable multiple times.
#   occured at (row) path: r1[V]->r2[v2]
# Modifying subtable (or row) names to ensure uniqueness among direct siblings
# [x  -> { x, x[2] }]
#   To control table names use split_rows_by*(, parent_name =.) or  analyze(., table_names = .) when analyzing a single variable, or analyze(., parent_name = .) when analyzing multiple variables in a single call.FALSE
# Warning: Non-unique sibling analysis table names. Using Labels instead. Use the table_names argument to analyze to avoid this when analyzing the same variable multiple times.
#   occured at (row) path: r1[V]->r2[v3]
# Modifying subtable (or row) names to ensure uniqueness among direct siblings
# [x  -> { x, x[2] }]
#   To control table names use split_rows_by*(, parent_name =.) or  analyze(., table_names = .) when analyzing a single variable, or analyze(., parent_name = .) when analyzing multiple variables in a single call.FALSE
# Warning: Non-unique sibling analysis table names. Using Labels instead. Use the table_names argument to analyze to avoid this when analyzing the same variable multiple times.
#   occured at (row) path: r1[V]->r2[v1]
# Modifying subtable (or row) names to ensure uniqueness among direct siblings
# [x  -> { x, x[2] }]
#   To control table names use split_rows_by*(, parent_name =.) or  analyze(., table_names = .) when analyzing a single variable, or analyze(., parent_name = .) when analyzing multiple variables in a single call.FALSE
# Warning: Non-unique sibling analysis table names. Using Labels instead. Use the table_names argument to analyze to avoid this when analyzing the same variable multiple times.
#   occured at (row) path: r1[W]->r2[w1]
# Modifying subtable (or row) names to ensure uniqueness among direct siblings
# [x  -> { x, x[2] }]
#   To control table names use split_rows_by*(, parent_name =.) or  analyze(., table_names = .) when analyzing a single variable, or analyze(., parent_name = .) when analyzing multiple variables in a single call.FALSE
# Warning: Non-unique sibling analysis table names. Using Labels instead. Use the table_names argument to analyze to avoid this when analyzing the same variable multiple times.
#   occured at (row) path: r1[W]->r2[w3]
# Modifying subtable (or row) names to ensure uniqueness among direct siblings
# [x  -> { x, x[2] }]
#   To control table names use split_rows_by*(, parent_name =.) or  analyze(., table_names = .) when analyzing a single variable, or analyze(., parent_name = .) when analyzing multiple variables in a single call.FALSE
# Warning: Non-unique sibling analysis table names. Using Labels instead. Use the table_names argument to analyze to avoid this when analyzing the same variable multiple times.
#   occured at (row) path: r1[W]->r2[w2]
# Modifying subtable (or row) names to ensure uniqueness among direct siblings
# [x  -> { x, x[2] }]
#   To control table names use split_rows_by*(, parent_name =.) or  analyze(., table_names = .) when analyzing a single variable, or analyze(., parent_name = .) when analyzing multiple variables in a single call.FALSE
tbl13
#                       A              B              C      
# ———————————————————————————————————————————————————————————
# U                                                          
#   u3 (n)              6              5              3      
#     mean (sd)   -0.04 (1.18)    0.36 (1.41)    -0.25 (0.72)
#     range       -1.80 - 1.47    -1.28 - 2.40   -0.82 - 0.56
#   u1 (n)              2              5              0      
#     mean (sd)    0.86 (0.38)    0.32 (0.51)         NA     
#     range        0.59 - 1.12    -0.48 - 0.94    Inf - -Inf 
#   u2 (n)              9              3              7      
#     mean (sd)   -0.28 (0.96)    0.38 (0.67)    0.08 (0.91) 
#     range       -1.52 - 1.43    -0.39 - 0.82   -0.93 - 1.51
# V                                                          
#   v2 (n)              2              4              2      
#     mean (sd)    0.01 (0.25)    0.55 (1.14)    0.60 (0.03) 
#     range       -0.16 - 0.18    -0.84 - 1.60   0.58 - 0.62 
#   v3 (n)              3              4              1      
#     mean (sd)   -0.03 (0.37)    -0.30 (0.36)    1.06 (NA)  
#     range       -0.41 - 0.33    -0.62 - 0.03   1.06 - 1.06 
#   v1 (n)              4              7              2      
#     mean (sd)    0.56 (1.10)    -0.27 (0.73)   -0.54 (1.18)
#     range       -0.16 - 2.17    -1.22 - 0.59   -1.38 - 0.29
# W                                                          
#   w1 (n)              4              1              4      
#     mean (sd)   -0.58 (0.85)     0.42 (NA)     0.67 (0.39) 
#     range       -1.25 - 0.61    0.42 - 0.42    0.37 - 1.21 
#   w3 (n)              9              1              3      
#     mean (sd)    0.56 (0.85)     0.69 (NA)     -0.39 (1.68)
#     range       -0.71 - 1.98    0.69 - 0.69    -2.21 - 1.10
#   w2 (n)              1              4              4      
#     mean (sd)    -1.99 (NA)     -0.10 (0.47)   0.53 (0.60) 
#     range       -1.99 - -1.99   -0.61 - 0.39   -0.10 - 1.16
```

In the same manner, if we want content rows for the `r1` split we can do
it at as follows:

``` r

lyt14 <- basic_table() |>
  split_cols_by("c1") |>
  split_rows_by("r1") |>
  summarize_row_groups(cfun = s_cfun_2) |>
  split_rows_by("r2") |>
  summarize_row_groups(cfun = s_cfun_2) |>
  analyze("x", s_mean_sd, show_labels = "hidden") |>
  analyze("x", s_range, show_labels = "hidden")

tbl14 <- build_table(lyt14, df)
# Warning: Non-unique sibling analysis table names. Using Labels instead. Use the table_names argument to analyze to avoid this when analyzing the same variable multiple times.
#   occured at (row) path: r1[U]->r2[u3]
# Modifying subtable (or row) names to ensure uniqueness among direct siblings
# [x  -> { x, x[2] }]
#   To control table names use split_rows_by*(, parent_name =.) or  analyze(., table_names = .) when analyzing a single variable, or analyze(., parent_name = .) when analyzing multiple variables in a single call.FALSE
# Warning in min(x): no non-missing arguments to min; returning Inf
# Warning in max(x): no non-missing arguments to max; returning -Inf
# Warning: Non-unique sibling analysis table names. Using Labels instead. Use the table_names argument to analyze to avoid this when analyzing the same variable multiple times.
#   occured at (row) path: r1[U]->r2[u1]
# Modifying subtable (or row) names to ensure uniqueness among direct siblings
# [x  -> { x, x[2] }]
#   To control table names use split_rows_by*(, parent_name =.) or  analyze(., table_names = .) when analyzing a single variable, or analyze(., parent_name = .) when analyzing multiple variables in a single call.FALSE
# Warning: Non-unique sibling analysis table names. Using Labels instead. Use the table_names argument to analyze to avoid this when analyzing the same variable multiple times.
#   occured at (row) path: r1[U]->r2[u2]
# Modifying subtable (or row) names to ensure uniqueness among direct siblings
# [x  -> { x, x[2] }]
#   To control table names use split_rows_by*(, parent_name =.) or  analyze(., table_names = .) when analyzing a single variable, or analyze(., parent_name = .) when analyzing multiple variables in a single call.FALSE
# Warning: Non-unique sibling analysis table names. Using Labels instead. Use the table_names argument to analyze to avoid this when analyzing the same variable multiple times.
#   occured at (row) path: r1[V]->r2[v2]
# Modifying subtable (or row) names to ensure uniqueness among direct siblings
# [x  -> { x, x[2] }]
#   To control table names use split_rows_by*(, parent_name =.) or  analyze(., table_names = .) when analyzing a single variable, or analyze(., parent_name = .) when analyzing multiple variables in a single call.FALSE
# Warning: Non-unique sibling analysis table names. Using Labels instead. Use the table_names argument to analyze to avoid this when analyzing the same variable multiple times.
#   occured at (row) path: r1[V]->r2[v3]
# Modifying subtable (or row) names to ensure uniqueness among direct siblings
# [x  -> { x, x[2] }]
#   To control table names use split_rows_by*(, parent_name =.) or  analyze(., table_names = .) when analyzing a single variable, or analyze(., parent_name = .) when analyzing multiple variables in a single call.FALSE
# Warning: Non-unique sibling analysis table names. Using Labels instead. Use the table_names argument to analyze to avoid this when analyzing the same variable multiple times.
#   occured at (row) path: r1[V]->r2[v1]
# Modifying subtable (or row) names to ensure uniqueness among direct siblings
# [x  -> { x, x[2] }]
#   To control table names use split_rows_by*(, parent_name =.) or  analyze(., table_names = .) when analyzing a single variable, or analyze(., parent_name = .) when analyzing multiple variables in a single call.FALSE
# Warning: Non-unique sibling analysis table names. Using Labels instead. Use the table_names argument to analyze to avoid this when analyzing the same variable multiple times.
#   occured at (row) path: r1[W]->r2[w1]
# Modifying subtable (or row) names to ensure uniqueness among direct siblings
# [x  -> { x, x[2] }]
#   To control table names use split_rows_by*(, parent_name =.) or  analyze(., table_names = .) when analyzing a single variable, or analyze(., parent_name = .) when analyzing multiple variables in a single call.FALSE
# Warning: Non-unique sibling analysis table names. Using Labels instead. Use the table_names argument to analyze to avoid this when analyzing the same variable multiple times.
#   occured at (row) path: r1[W]->r2[w3]
# Modifying subtable (or row) names to ensure uniqueness among direct siblings
# [x  -> { x, x[2] }]
#   To control table names use split_rows_by*(, parent_name =.) or  analyze(., table_names = .) when analyzing a single variable, or analyze(., parent_name = .) when analyzing multiple variables in a single call.FALSE
# Warning: Non-unique sibling analysis table names. Using Labels instead. Use the table_names argument to analyze to avoid this when analyzing the same variable multiple times.
#   occured at (row) path: r1[W]->r2[w2]
# Modifying subtable (or row) names to ensure uniqueness among direct siblings
# [x  -> { x, x[2] }]
#   To control table names use split_rows_by*(, parent_name =.) or  analyze(., table_names = .) when analyzing a single variable, or analyze(., parent_name = .) when analyzing multiple variables in a single call.FALSE
tbl14
#                       A              B              C      
# ———————————————————————————————————————————————————————————
# U (n)                17              13             10     
#   u3 (n)              6              5              3      
#     mean (sd)   -0.04 (1.18)    0.36 (1.41)    -0.25 (0.72)
#     range       -1.80 - 1.47    -1.28 - 2.40   -0.82 - 0.56
#   u1 (n)              2              5              0      
#     mean (sd)    0.86 (0.38)    0.32 (0.51)         NA     
#     range        0.59 - 1.12    -0.48 - 0.94    Inf - -Inf 
#   u2 (n)              9              3              7      
#     mean (sd)   -0.28 (0.96)    0.38 (0.67)    0.08 (0.91) 
#     range       -1.52 - 1.43    -0.39 - 0.82   -0.93 - 1.51
# V (n)                 9              15             5      
#   v2 (n)              2              4              2      
#     mean (sd)    0.01 (0.25)    0.55 (1.14)    0.60 (0.03) 
#     range       -0.16 - 0.18    -0.84 - 1.60   0.58 - 0.62 
#   v3 (n)              3              4              1      
#     mean (sd)   -0.03 (0.37)    -0.30 (0.36)    1.06 (NA)  
#     range       -0.41 - 0.33    -0.62 - 0.03   1.06 - 1.06 
#   v1 (n)              4              7              2      
#     mean (sd)    0.56 (1.10)    -0.27 (0.73)   -0.54 (1.18)
#     range       -0.16 - 2.17    -1.22 - 0.59   -1.38 - 0.29
# W (n)                14              6              11     
#   w1 (n)              4              1              4      
#     mean (sd)   -0.58 (0.85)     0.42 (NA)     0.67 (0.39) 
#     range       -1.25 - 0.61    0.42 - 0.42    0.37 - 1.21 
#   w3 (n)              9              1              3      
#     mean (sd)    0.56 (0.85)     0.69 (NA)     -0.39 (1.68)
#     range       -0.71 - 1.98    0.69 - 0.69    -2.21 - 1.10
#   w2 (n)              1              4              4      
#     mean (sd)    -1.99 (NA)     -0.10 (0.47)   0.53 (0.60) 
#     range       -1.99 - -1.99   -0.61 - 0.39   -0.10 - 1.16
```

In pagination, content rows and label rows get repeated if a page is
split in a descendant of a content row. So, for example, if we were to
split the following table at `***`:

                       A              B              C
    ---------------------------------------------------------
    U
      u1 (n)      s_cfun_2(<>)   s_cfun_2(<>)   s_cfun_2(<>)
         mean_sd  s_mean_sd(<>)  s_mean_sd(<>)  s_mean_sd(<>)
    ***
         range    s_range(<>)    s_range(<>)    s_range(<>)
      u2 (n)      s_cfun_2(<>)   s_cfun_2(<>)   s_cfun_2(<>)
         mean_sd  s_mean_sd(<>)  s_mean_sd(<>)  s_mean_sd(<>)
         range    s_range(<>)    s_range(<>)    s_range(<>)

Then we would get the following two tables:

                       A              B              C
    ---------------------------------------------------------
    U
      u1 (n)      s_cfun_2(<>)   s_cfun_2(<>)   s_cfun_2(<>)
         mean_sd  s_mean_sd(<>)  s_mean_sd(<>)  s_mean_sd(<>)

and

                       A              B              C
    ---------------------------------------------------------
    U
      u1 (n)      s_cfun_2(<>)   s_cfun_2(<>)   s_cfun_2(<>)
         range    s_range(<>)    s_range(<>)    s_range(<>)
      u2 (n)      s_cfun_2(<>)   s_cfun_2(<>)   s_cfun_2(<>)
         mean_sd  s_mean_sd(<>)  s_mean_sd(<>)  s_mean_sd(<>)
         range    s_range(<>)    s_range(<>)    s_range(<>)

### Pattern III

Let’s consider the following tabulation pattern:

                         A         B         C
    ------------------------------------------------
    label 1        foo(x_A)  bar(x_B)  zoo(x_C)
    label 2        foo(x_A)  bar(x_B)  zoo(x_C)
    label 3        foo(x_A)  bar(x_B)  zoo(x_C)

We will discuss that in a future release of `rtables`.
