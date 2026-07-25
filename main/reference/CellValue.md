# Constructor for Cell Value

Constructor for Cell Value

## Usage

``` r
CellValue(
  val,
  format = NULL,
  colspan = 1L,
  label = NULL,
  indent_mod = NULL,
  footnotes = NULL,
  align = NULL,
  format_na_str = NULL,
  stat_names = NA_character_,
  round_type = valid_round_type
)
```

## Arguments

- val:

  (`ANY`)\
  value in the cell exactly as it should be passed to a formatter or
  returned when extracted.

- format:

  (`string`, `function`, or `list`)\
  format associated with this split. Formats can be declared via strings
  (`"xx.x"`) or function. In cases such as `analyze` calls, they can be
  character vectors or lists of functions. See
  [`formatters::list_valid_format_labels()`](https://rdrr.io/pkg/formatters/man/list_formats.html)
  for a list of all available format strings.

- colspan:

  (`integer(1)`)\
  column span value.

- label:

  (`string`)\
  a label (not to be confused with the name) for the object/structure.

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

## Value

An object representing the value within a single cell within a populated
table. The underlying structure of this object is an implementation
detail and should not be relied upon beyond calling accessors for the
class.
