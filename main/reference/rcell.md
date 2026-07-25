# Cell value constructors

Construct a cell value and associate formatting, labeling, indenting,
and column spanning information with it.

## Usage

``` r
rcell(
  x,
  format = NULL,
  colspan = 1L,
  label = NULL,
  indent_mod = NULL,
  footnotes = NULL,
  align = NULL,
  format_na_str = NULL,
  stat_names = NULL,
  round_type = valid_round_type
)

non_ref_rcell(
  x,
  is_ref,
  format = NULL,
  colspan = 1L,
  label = NULL,
  indent_mod = NULL,
  refval = NULL,
  align = "center",
  format_na_str = NULL
)
```

## Arguments

- x:

  (`ANY`)\
  cell value.

- format:

  (`string` or `function`)\
  the format label (string) or `formatters` function to apply to `x`.
  See
  [`formatters::list_valid_format_labels()`](https://rdrr.io/pkg/formatters/man/list_formats.html)
  for currently supported format labels.

- colspan:

  (`integer(1)`)\
  column span value.

- label:

  (`string` or `NULL`)\
  label. If non-`NULL`, it will be looked at when determining row
  labels.

- indent_mod:

  (`numeric`)\
  modifier for the default indent position for the structure created by
  this function (subtable, content table, or row) *and all of that
  structure's children*. Defaults to 0, which corresponds to the
  unmodified default behavior.

- footnotes:

  (`list` or `NULL`)\
  referential footnote messages for the cell.

- align:

  (`string` or `NULL`)\
  alignment the value should be rendered with. Defaults to `"center"` if
  `NULL` is used. See
  [`formatters::list_valid_aligns()`](https://rdrr.io/pkg/formatters/man/list_formats.html)
  for all currently supported alignments.

- format_na_str:

  (`string`)\
  string which should be displayed when formatted if this cell's
  value(s) are all `NA`.

- stat_names:

  (`character` or `NA`)\
  names for the statistics in the cell. It can be a vector of strings.
  If `NA`, statistic names are not specified.

- round_type:

  (`"iec"` (default), `"iec_mod"` or `"sas"`)\
  the type of rounding to perform. See
  [`formatters::format_value()`](https://rdrr.io/pkg/formatters/man/format_value.html)
  for details.

- is_ref:

  (`flag`)\
  whether function is being used in the reference column (i.e.
  `.in_ref_col` should be passed to this argument).

- refval:

  (`ANY`)\
  value to use when in the reference column. Defaults to `NULL`.

## Value

An object representing the value within a single cell within a populated
table. The underlying structure of this object is an implementation
detail and should not be relied upon beyond calling accessors for the
class.

## Details

`non_ref_rcell` provides the common *blank for cells in the reference
column, this value otherwise*, and should be passed the value of
`.in_ref_col` when it is used.

## Note

Currently column spanning is only supported for defining header
structure.

## Examples

``` r
rcell(1, format = "xx.x")
#> rcell: 1.0 
rcell(c(1, 2), format = c("xx - xx"))
#> rcell: 1 - 2 
rcell(c(1, 2), stat_names = c("Rand1", "Rand2"))
#> rcell: 1, 2 
```
