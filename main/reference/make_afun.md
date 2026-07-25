# Create a custom analysis function wrapping an existing function

Create a custom analysis function wrapping an existing function

## Usage

``` r
make_afun(
  fun,
  .stats = NULL,
  .formats = NULL,
  .labels = NULL,
  .indent_mods = NULL,
  .ungroup_stats = NULL,
  .format_na_strs = NULL,
  ...,
  .null_ref_cells = ".in_ref_col" %in% names(formals(fun))
)
```

## Arguments

- fun:

  (`function`)\
  the function to be wrapped in a new customized analysis function.
  `fun` should return a named `list`.

- .stats:

  (`character`)\
  names of elements to keep from `fun`'s full output.

- .formats:

  (`ANY`)\
  vector or list of formats to override any defaults applied by `fun`.

- .labels:

  (`character`)\
  vector of labels to override defaults returned by `fun`.

- .indent_mods:

  (`integer`)\
  named vector of indent modifiers for the generated rows.

- .ungroup_stats:

  (`character`)\
  vector of names, which must match elements of `.stats`.

- .format_na_strs:

  (`ANY`)\
  vector/list of `NA` strings to override any defaults applied by `fun`.

- ...:

  additional arguments to `fun` which effectively become new defaults.
  These can still be overridden by `extra_args` within a split.

- .null_ref_cells:

  (`flag`)\
  whether cells for the reference column should be `NULL`-ed by the
  returned analysis function. Defaults to `TRUE` if `fun` accepts
  `.in_ref_col` as a formal argument. Note this argument occurs after
  `...` so it must be *fully* specified by name when set.

## Value

A function suitable for use in
[`analyze()`](https://pharmaverse.github.io/rtables/reference/analyze.md)
with element selection, reformatting, and relabeling performed
automatically.

## Note

Setting `.ungroup_stats` to non-`NULL` changes the *structure* of the
value(s) returned by `fun`, rather than just labeling (`.labels`),
formatting (`.formats`), and selecting amongst (`.stats`) them. This
means that subsequent `make_afun` calls to customize the output further
both can and must operate on the new structure, *not* the original
structure returned by `fun`. See the final pair of examples below.

## See also

[`analyze()`](https://pharmaverse.github.io/rtables/reference/analyze.md)

## Examples

``` r
s_summary <- function(x) {
  stopifnot(is.numeric(x))

  list(
    n = sum(!is.na(x)),
    mean_sd = c(mean = mean(x), sd = sd(x)),
    min_max = range(x)
  )
}

s_summary(iris$Sepal.Length)
#> $n
#> [1] 150
#> 
#> $mean_sd
#>      mean        sd 
#> 5.8433333 0.8280661 
#> 
#> $min_max
#> [1] 4.3 7.9
#> 

a_summary <- make_afun(
  fun = s_summary,
  .formats = c(n = "xx", mean_sd = "xx.xx (xx.xx)", min_max = "xx.xx - xx.xx"),
  .labels = c(n = "n", mean_sd = "Mean (sd)", min_max = "min - max")
)

a_summary(x = iris$Sepal.Length)
#> RowsVerticalSection (in_rows) object print method:
#> ----------------------------
#>   row_name formatted_cell indent_mod row_label
#> 1        n            150          0         n
#> 2  mean_sd    5.84 (0.83)          0 Mean (sd)
#> 3  min_max    4.30 - 7.90          0 min - max

a_summary2 <- make_afun(a_summary, .stats = c("n", "mean_sd"))

a_summary2(x = iris$Sepal.Length)
#> RowsVerticalSection (in_rows) object print method:
#> ----------------------------
#>   row_name formatted_cell indent_mod row_label
#> 1        n            150          0         n
#> 2  mean_sd    5.84 (0.83)          0 Mean (sd)

a_summary3 <- make_afun(a_summary, .formats = c(mean_sd = "(xx.xxx, xx.xxx)"))

s_foo <- function(df, .N_col, a = 1, b = 2) {
  list(
    nrow_df = nrow(df),
    .N_col = .N_col,
    a = a,
    b = b
  )
}

s_foo(iris, 40)
#> $nrow_df
#> [1] 150
#> 
#> $.N_col
#> [1] 40
#> 
#> $a
#> [1] 1
#> 
#> $b
#> [1] 2
#> 

a_foo <- make_afun(s_foo,
  b = 4,
  .formats = c(nrow_df = "xx.xx", ".N_col" = "xx.", a = "xx", b = "xx.x"),
  .labels = c(
    nrow_df = "Nrow df",
    ".N_col" = "n in cols", a = "a value", b = "b value"
  ),
  .indent_mods = c(nrow_df = 2L, a = 1L)
)

a_foo(iris, .N_col = 40)
#> RowsVerticalSection (in_rows) object print method:
#> ----------------------------
#>   row_name formatted_cell indent_mod row_label
#> 1  nrow_df         150.00          2   Nrow df
#> 2   .N_col             40          0 n in cols
#> 3        a              1          1   a value
#> 4        b            4.0          0   b value
a_foo2 <- make_afun(a_foo, .labels = c(nrow_df = "Number of Rows"))
a_foo2(iris, .N_col = 40)
#> RowsVerticalSection (in_rows) object print method:
#> ----------------------------
#>   row_name formatted_cell indent_mod      row_label
#> 1  nrow_df         150.00          2 Number of Rows
#> 2   .N_col             40          0      n in cols
#> 3        a              1          1        a value
#> 4        b            4.0          0        b value

# grouping and further customization
s_grp <- function(df, .N_col, a = 1, b = 2) {
  list(
    nrow_df = nrow(df),
    .N_col = .N_col,
    letters = list(
      a = a,
      b = b
    )
  )
}
a_grp <- make_afun(s_grp,
  b = 3,
  .labels = c(
    nrow_df = "row count",
    .N_col = "count in column"
  ),
  .formats = c(nrow_df = "xx.", .N_col = "xx."),
  .indent_mods = c(letters = 1L),
  .ungroup_stats = "letters"
)
a_grp(iris, 40)
#> RowsVerticalSection (in_rows) object print method:
#> ----------------------------
#>   row_name formatted_cell indent_mod       row_label
#> 1  nrow_df            150          0       row count
#> 2   .N_col             40          0 count in column
#> 3        a              1          1               a
#> 4        b              3          1               b
a_aftergrp <- make_afun(a_grp,
  .stats = c("nrow_df", "b"),
  .formats = c(b = "xx.")
)
a_aftergrp(iris, 40)
#> RowsVerticalSection (in_rows) object print method:
#> ----------------------------
#>   row_name formatted_cell indent_mod row_label
#> 1  nrow_df            150          0 row count
#> 2        b              3          0         b

s_ref <- function(x, .in_ref_col, .ref_group) {
  list(
    mean_diff = mean(x) - mean(.ref_group)
  )
}

a_ref <- make_afun(s_ref,
  .labels = c(mean_diff = "Mean Difference from Ref")
)
a_ref(iris$Sepal.Length, .in_ref_col = TRUE, 1:10)
#> RowsVerticalSection (in_rows) object print method:
#> ----------------------------
#>    row_name formatted_cell indent_mod                row_label
#> 1 mean_diff                         0 Mean Difference from Ref
a_ref(iris$Sepal.Length, .in_ref_col = FALSE, 1:10)
#> RowsVerticalSection (in_rows) object print method:
#> ----------------------------
#>    row_name    formatted_cell indent_mod                row_label
#> 1 mean_diff 0.343333333333334          0 Mean Difference from Ref
```
