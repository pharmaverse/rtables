# Row classes and constructors

Row classes and constructors

Row constructors and classes

## Usage

``` r
LabelRow(
  lev = 1L,
  label = "",
  name = label,
  vis = !is.na(label) && nzchar(label),
  cinfo = EmptyColInfo,
  indent_mod = 0L,
  table_inset = 0L,
  trailing_section_div = NA_character_,
  round_type = valid_round_type
)

.tablerow(
  vals = list(),
  name = "",
  lev = 1L,
  label = name,
  cspan = rep(1L, length(vals)),
  cinfo = EmptyColInfo,
  var = NA_character_,
  format = NULL,
  na_str = NA_character_,
  klass,
  indent_mod = 0L,
  footnotes = list(),
  table_inset = 0L,
  trailing_section_div = NA_character_,
  round_type = valid_round_type
)

DataRow(...)

ContentRow(...)
```

## Arguments

- lev:

  (`integer(1)`)\
  nesting level (roughly, indentation level in practical terms).

- label:

  (`string`)\
  a label (not to be confused with the name) for the object/structure.

- name:

  (`string`)\
  name of the split/table/row being created. Defaults to the value of
  the corresponding label, but is not required to be.

- vis:

  (`flag`)\
  whether the row should be visible (`LabelRow` only).

- cinfo:

  (`InstantiatedColumnInfo` or `NULL`)\
  column structure for the object being created.

- indent_mod:

  (`numeric`)\
  modifier for the default indent position for the structure created by
  this function (subtable, content table, or row) *and all of that
  structure's children*. Defaults to 0, which corresponds to the
  unmodified default behavior.

- table_inset:

  (`numeric(1)`)\
  number of spaces to inset the table header, table body, referential
  footnotes, and main footer, as compared to alignment of title,
  subtitles, and provenance footer. Defaults to 0 (no inset).

- trailing_section_div:

  (`string`)\
  string which will be used as a section divider after the printing of
  the last row contained in this (sub)table, unless that row is also the
  last table row to be printed overall, or `NA_character_` for none (the
  default). When generated via layouting, this would correspond to the
  `section_div` of the split under which this table represents a single
  facet.

- round_type:

  (`"iec"`, `"iec_mod"` or `"sas"`)\
  the type of rounding to perform. See
  [`round_fmt()`](https://rdrr.io/pkg/formatters/man/round_fmt.html) for
  details.

- vals:

  (`list`)\
  cell values for the row.

- cspan:

  (`integer`)\
  column span. `1` indicates no spanning.

- var:

  (`string`)\
  variable name.

- format:

  (`string`, `function`, or `list`)\
  format associated with this split. Formats can be declared via strings
  (`"xx.x"`) or function. In cases such as `analyze` calls, they can be
  character vectors or lists of functions. See
  [`formatters::list_valid_format_labels()`](https://rdrr.io/pkg/formatters/man/list_formats.html)
  for a list of all available format strings.

- na_str:

  (`string`)\
  string that should be displayed when the value of `x` is missing.
  Defaults to `"NA"`.

- klass:

  (`character`)\
  internal detail.

- footnotes:

  (`list` or `NULL`)\
  referential footnotes to be applied at current level. In
  post-processing, this can be achieved with `fnotes_at_path<-`.

- ...:

  additional parameters passed to shared constructor (`.tablerow`).

## Value

A formal object representing a table row of the constructed type.

## Author

Gabriel Becker
