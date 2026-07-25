# Create multiple rows in analysis or summary functions

Define the cells that get placed into multiple rows in `afun`.

## Usage

``` r
in_rows(
  ...,
  .list = NULL,
  .names = NULL,
  .labels = NULL,
  .formats = NULL,
  .indent_mods = NULL,
  .cell_footnotes = list(NULL),
  .row_footnotes = list(NULL),
  .aligns = NULL,
  .format_na_strs = NULL,
  .stat_names = list(NULL)
)
```

## Arguments

- ...:

  single row defining expressions.

- .list:

  (`list`)\
  list cell content (usually `rcells`). The `.list` is concatenated to
  `...`.

- .names:

  (`character` or `NULL`)\
  names of the returned list/structure.

- .labels:

  (`character` or `NULL`)\
  labels for the defined rows.

- .formats:

  (`character` or `NULL`)\
  formats for the values.

- .indent_mods:

  (`integer` or `NULL`)\
  indent modifications for the defined rows.

- .cell_footnotes:

  (`list`)\
  referential footnote messages to be associated by name with *cells*.

- .row_footnotes:

  (`list`)\
  referential footnotes messages to be associated by name with *rows*.

- .aligns:

  (`character` or `NULL`)\
  alignments for the cells. Standard for `NULL` is `"center"`. See
  [`formatters::list_valid_aligns()`](https://rdrr.io/pkg/formatters/man/list_formats.html)
  for currently supported alignments.

- .format_na_strs:

  (`character` or `NULL`)\
  NA strings for the cells.

- .stat_names:

  (`list`)\
  names for the statistics in the cells. It can be a vector of values.
  If `list(NULL)`, statistic names are not specified and will appear as
  `NA`.

## Value

A `RowsVerticalSection` object (or `NULL`). The details of this object
should be considered an internal implementation detail.

## Note

In post-processing, referential footnotes can also be added using row
and column paths with `fnotes_at_path<-`.

## See also

[`analyze()`](https://pharmaverse.github.io/rtables/reference/analyze.md)

## Examples

``` r
in_rows(1, 2, 3, .names = c("a", "b", "c"))
#> RowsVerticalSection (in_rows) object print method:
#> ----------------------------
#>   row_name formatted_cell indent_mod row_label
#> 1        a              1          0         a
#> 2        b              2          0         b
#> 3        c              3          0         c
in_rows(1, 2, 3, .labels = c("a", "b", "c"))
#> RowsVerticalSection (in_rows) object print method:
#> ----------------------------
#>   row_name formatted_cell indent_mod row_label
#> 1        a              1          0         a
#> 2        b              2          0         b
#> 3        c              3          0         c
in_rows(1, 2, 3, .names = c("a", "b", "c"), .labels = c("AAA", "BBB", "CCC"))
#> RowsVerticalSection (in_rows) object print method:
#> ----------------------------
#>   row_name formatted_cell indent_mod row_label
#> 1        a              1          0       AAA
#> 2        b              2          0       BBB
#> 3        c              3          0       CCC
in_rows(
  .list = list(a = c(NA, NA)),
  .formats = "xx - xx",
  .format_na_strs = list(c("asda", "lkjklj"))
)
#> RowsVerticalSection (in_rows) object print method:
#> ----------------------------
#>   row_name formatted_cell indent_mod row_label
#> 1        a  asda - lkjklj          0         a
in_rows(.list = list(a = c(NA, NA)), .format_na_strs = c("asda", "lkjklj"))
#> RowsVerticalSection (in_rows) object print method:
#> ----------------------------
#>   row_name formatted_cell indent_mod row_label
#> 1        a           asda          0         a
#> 2        a         lkjklj          0      <NA>

in_rows(.list = list(a = 1, b = 2, c = 3))
#> RowsVerticalSection (in_rows) object print method:
#> ----------------------------
#>   row_name formatted_cell indent_mod row_label
#> 1        a              1          0         a
#> 2        b              2          0         b
#> 3        c              3          0         c
in_rows(1, 2, .list = list(3), .names = c("a", "b", "c"))
#> RowsVerticalSection (in_rows) object print method:
#> ----------------------------
#>   row_name formatted_cell indent_mod row_label
#> 1        a              1          0         a
#> 2        b              2          0         b
#> 3        c              3          0         c

lyt <- basic_table() |>
  split_cols_by("ARM") |>
  analyze("AGE", afun = function(x) {
    in_rows(
      "Mean (sd)" = rcell(c(mean(x), sd(x)), format = "xx.xx (xx.xx)"),
      "Range" = rcell(range(x), format = "xx.xx - xx.xx")
    )
  })

tbl <- build_table(lyt, ex_adsl)
tbl
#>               A: Drug X      B: Placebo     C: Combination
#> ——————————————————————————————————————————————————————————
#> Mean (sd)   33.77 (6.55)    35.43 (7.90)     35.43 (7.72) 
#> Range       21.00 - 50.00   21.00 - 62.00   20.00 - 69.00 
```
