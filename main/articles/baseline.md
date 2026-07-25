# Comparing Against Baselines or Control

## Introduction

Often the data from one column is considered the
reference/baseline/comparison group and is compared to the data from the
other columns.

For example, lets calculate the average age:

``` r

library(rtables)

lyt <- basic_table() |>
  split_cols_by("ARM") |>
  analyze("AGE")

tbl <- build_table(lyt, DM)
tbl
```

    #        A: Drug X   B: Placebo   C: Combination
    # ——————————————————————————————————————————————
    # Mean     34.91       33.02          34.57

and then the difference of the average `AGE` between the placebo arm and
the other arms:

``` r

lyt2 <- basic_table() |>
  split_cols_by("ARM", ref_group = "B: Placebo") |>
  analyze("AGE", afun = function(x, .ref_group) {
    in_rows(
      "Difference of Averages" = rcell(mean(x) - mean(.ref_group), format = "xx.xx")
    )
  })

tbl2 <- build_table(lyt2, DM)
tbl2
```

    #                          A: Drug X   B: Placebo   C: Combination
    # ————————————————————————————————————————————————————————————————
    # Difference of Averages     1.89         0.00           1.55

Note that the column order has changed and the reference group is
displayed in the first column.

In cases where we want cells to be blank in the reference column, (e.g.,
“B: Placebo”) we use
[`non_ref_rcell()`](https://pharmaverse.github.io/rtables/reference/rcell.md)
instead of
[`rcell()`](https://pharmaverse.github.io/rtables/reference/rcell.md),
and pass `.in_ref_col` as the second argument:

``` r

lyt3 <- basic_table() |>
  split_cols_by("ARM", ref_group = "B: Placebo") |>
  analyze(
    "AGE",
    afun = function(x, .ref_group, .in_ref_col) {
      in_rows(
        "Difference of Averages" = non_ref_rcell(mean(x) - mean(.ref_group), is_ref = .in_ref_col, format = "xx.xx")
      )
    }
  )

tbl3 <- build_table(lyt3, DM)
tbl3
```

    #                          A: Drug X   B: Placebo   C: Combination
    # ————————————————————————————————————————————————————————————————
    # Difference of Averages     1.89                        1.55

``` r

lyt4 <- basic_table() |>
  split_cols_by("ARM", ref_group = "B: Placebo") |>
  analyze(
    "AGE",
    afun = function(x, .ref_group, .in_ref_col) {
      in_rows(
        "Difference of Averages" = non_ref_rcell(mean(x) - mean(.ref_group), is_ref = .in_ref_col, format = "xx.xx"),
        "another row" = non_ref_rcell("aaa", .in_ref_col)
      )
    }
  )

tbl4 <- build_table(lyt4, DM)
tbl4
```

    #                          A: Drug X   B: Placebo   C: Combination
    # ————————————————————————————————————————————————————————————————
    # Difference of Averages     1.89                        1.55     
    # another row                 aaa                        aaa

You can see which arguments are available for `afun` in the manual for
[`analyze()`](https://pharmaverse.github.io/rtables/reference/analyze.md).

## Row Splitting

When adding row-splitting the reference data may be represented by the
column with or without row splitting. For example:

``` r

lyt5 <- basic_table(show_colcounts = TRUE) |>
  split_cols_by("ARM", ref_group = "B: Placebo") |>
  split_rows_by("SEX", split_fun = drop_split_levels) |>
  analyze("AGE", afun = function(x, .ref_group, .ref_full, .in_ref_col) {
    in_rows(
      "is reference (.in_ref_col)" = rcell(.in_ref_col),
      "ref cell N (.ref_group)" = rcell(length(.ref_group)),
      "ref column N (.ref_full)" = rcell(length(.ref_full))
    )
  })

tbl5 <- build_table(lyt5, subset(DM, SEX %in% c("M", "F")))
tbl5
```

    #                                A: Drug X   B: Placebo   C: Combination
    #                                 (N=121)     (N=106)        (N=129)    
    # ——————————————————————————————————————————————————————————————————————
    # F                                                                     
    #   is reference (.in_ref_col)     FALSE        TRUE          FALSE     
    #   ref cell N (.ref_group)         56           56             56      
    #   ref column N (.ref_full)        106         106            106      
    # M                                                                     
    #   is reference (.in_ref_col)     FALSE        TRUE          FALSE     
    #   ref cell N (.ref_group)         50           50             50      
    #   ref column N (.ref_full)        106         106            106

The data assigned to `.ref_full` is the full data of the reference
column whereas the data assigned to `.ref_group` respects the subsetting
defined by row-splitting and hence is from the same subset as the
argument `x` or `df` to `afun`.
