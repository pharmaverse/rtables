# Table shells

A table shell is a rendering of the table which maintains the structure,
but does not display the values, rather displaying the formatting
instructions for each cell.

## Usage

``` r
table_shell(
  tt,
  widths = NULL,
  col_gap = 3,
  hsep = default_hsep(),
  tf_wrap = FALSE,
  max_width = NULL
)

table_shell_str(
  tt,
  widths = NULL,
  col_gap = 3,
  hsep = default_hsep(),
  tf_wrap = FALSE,
  max_width = NULL
)
```

## Arguments

- tt:

  (`TableTree` or related class)\
  a `TableTree` object representing a populated table.

- widths:

  (`numeric` or `NULL`)\
  Proposed widths for the columns of `x`. The expected length of this
  numeric vector can be retrieved with `ncol(x) + 1` as the column of
  row names must also be considered.

- col_gap:

  (`numeric(1)`)\
  space (in characters) between columns.

- hsep:

  (`string`)\
  character to repeat to create header/body separator line. If `NULL`,
  the object value will be used. If `" "`, an empty separator will be
  printed. See
  [`default_hsep()`](https://rdrr.io/pkg/formatters/man/default_horizontal_sep.html)
  for more information.

- tf_wrap:

  (`flag`)\
  whether the text for title, subtitles, and footnotes should be
  wrapped.

- max_width:

  (`integer(1)`, `string` or `NULL`)\
  width that title and footer (including footnotes) materials should be
  word-wrapped to. If `NULL`, it is set to the current print width of
  the session (`getOption("width")`). If set to `"auto"`, the width of
  the table (plus any table inset) is used. Parameter is ignored if
  `tf_wrap = FALSE`.

## Value

- `table_shell` returns `NULL`, as the function is called for the side
  effect of printing the shell to the console.

- `table_shell_str` returns the string representing the table shell.

## See also

[`value_formats()`](https://pharmaverse.github.io/rtables/reference/value_formats.md)
for a matrix of formats for each cell in a table.

## Examples

``` r
library(dplyr)

iris2 <- iris |>
  group_by(Species) |>
  mutate(group = as.factor(rep_len(c("a", "b"), length.out = n()))) |>
  ungroup()

lyt <- basic_table() |>
  split_cols_by("Species") |>
  split_cols_by("group") |>
  analyze(c("Sepal.Length", "Petal.Width"), afun = list_wrap_x(summary), format = "xx.xx")

tbl <- build_table(lyt, iris2)
table_shell(tbl)
#>                   setosa        versicolor       virginica  
#>                  a       b       a       b       a       b  
#> ————————————————————————————————————————————————————————————
#> Sepal.Length     -       -       -       -       -       -  
#>   Min.         xx.xx   xx.xx   xx.xx   xx.xx   xx.xx   xx.xx
#>   1st Qu.      xx.xx   xx.xx   xx.xx   xx.xx   xx.xx   xx.xx
#>   Median       xx.xx   xx.xx   xx.xx   xx.xx   xx.xx   xx.xx
#>   Mean         xx.xx   xx.xx   xx.xx   xx.xx   xx.xx   xx.xx
#>   3rd Qu.      xx.xx   xx.xx   xx.xx   xx.xx   xx.xx   xx.xx
#>   Max.         xx.xx   xx.xx   xx.xx   xx.xx   xx.xx   xx.xx
#> Petal.Width      -       -       -       -       -       -  
#>   Min.         xx.xx   xx.xx   xx.xx   xx.xx   xx.xx   xx.xx
#>   1st Qu.      xx.xx   xx.xx   xx.xx   xx.xx   xx.xx   xx.xx
#>   Median       xx.xx   xx.xx   xx.xx   xx.xx   xx.xx   xx.xx
#>   Mean         xx.xx   xx.xx   xx.xx   xx.xx   xx.xx   xx.xx
#>   3rd Qu.      xx.xx   xx.xx   xx.xx   xx.xx   xx.xx   xx.xx
#>   Max.         xx.xx   xx.xx   xx.xx   xx.xx   xx.xx   xx.xx
```
