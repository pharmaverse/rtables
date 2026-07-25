# Convert an `rtable` object to a string

Transform a complex object into a string representation ready to be
printed or written to a plain-text file.

All objects that are printed to console pass via `toString`. This
function allows fundamental formatting specifications to be applied to
final output, like column widths and relative wrapping (`width`), title
and footer wrapping (`tf_wrap = TRUE` and `max_width`), and horizontal
separator character (e.g. `hsep = "+"`).

## Usage

``` r
# S4 method for class 'VTableTree'
toString(
  x,
  widths = NULL,
  col_gap = 3,
  hsep = horizontal_sep(x),
  indent_size = 2,
  tf_wrap = FALSE,
  max_width = NULL,
  fontspec = font_spec(),
  ttype_ok = FALSE,
  round_type = obj_round_type(x)
)
```

## Arguments

- x:

  (`ANY`)\
  object to be prepared for rendering.

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

- indent_size:

  (`numeric(1)`)\
  number of spaces to use per indent level. Defaults to 2.

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

- fontspec:

  (`font_spec`)\
  a font_spec object specifying the font information to use for
  calculating string widths and heights, as returned by
  [`font_spec()`](https://rdrr.io/pkg/formatters/man/font_spec.html).

- ttype_ok:

  (`logical(1)`)\
  should truetype (non-monospace) fonts be allowed via `fontspec`.
  Defaults to `FALSE`. This parameter is primarily for internal testing
  and generally should not be set by end users.

- round_type:

  (`string`)\
  The type of rounding to perform. Allowed values: (`"iec"`, `"iec_mod"`
  or `"sas"`) See
  [`round_fmt()`](https://rdrr.io/pkg/formatters/man/round_fmt.html) for
  details.

## Value

A string representation of `x` as it appears when printed.

## Details

Manual insertion of newlines is not supported when `tf_wrap = TRUE` and
will result in a warning and undefined wrapping behavior. Passing
vectors of already split strings remains supported, however in this case
each string is word-wrapped separately with the behavior described
above.

## See also

[`wrap_string()`](https://rdrr.io/pkg/formatters/man/wrap_string.html)

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

cat(toString(tbl, col_gap = 3))
#>                  setosa       versicolor      virginica  
#>                 a      b       a       b       a      b  
#> —————————————————————————————————————————————————————————
#> Sepal.Length                                             
#>   Min.         4.40   4.30   5.00    4.90    4.90    5.60
#>   1st Qu.      4.80   4.80   5.60    5.60    6.20    6.30
#>   Median       5.00   5.00   5.90    5.90    6.50    6.50
#>   Mean         5.02   4.99   5.99    5.88    6.50    6.67
#>   3rd Qu.      5.30   5.10   6.40    6.10    6.70    7.20
#>   Max.         5.80   5.70   7.00    6.70    7.70    7.90
#> Petal.Width                                              
#>   Min.         0.10   0.10   1.00    1.00    1.40    1.50
#>   1st Qu.      0.20   0.20   1.20    1.20    1.90    1.80
#>   Median       0.20   0.20   1.30    1.30    2.10    2.00
#>   Mean         0.23   0.26   1.35    1.30    2.08    1.98
#>   3rd Qu.      0.20   0.30   1.50    1.40    2.30    2.20
#>   Max.         0.40   0.60   1.80    1.70    2.50    2.50
```
