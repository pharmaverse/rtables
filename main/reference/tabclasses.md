# `TableTree` classes

`TableTree` classes

Table constructors and classes

## Usage

``` r
ElementaryTable(
  kids = list(),
  name = "",
  lev = 1L,
  label = "",
  labelrow = LabelRow(lev = lev, label = label, vis = !isTRUE(iscontent) && !is.na(label)
    && nzchar(label)),
  rspans = data.frame(),
  cinfo = NULL,
  iscontent = NA,
  var = NA_character_,
  format = NULL,
  na_str = NA_character_,
  indent_mod = 0L,
  title = "",
  subtitles = character(),
  main_footer = character(),
  prov_footer = character(),
  header_section_div = NA_character_,
  hsep = default_hsep(),
  trailing_section_div = NA_character_,
  inset = 0L,
  round_type = valid_round_type
)

TableTree(
  kids = list(),
  name = if (!is.na(var)) var else "",
  cont = EmptyElTable,
  lev = 1L,
  label = name,
  labelrow = LabelRow(lev = lev, label = label, vis = nrow(cont) == 0 && !is.na(label) &&
    nzchar(label)),
  rspans = data.frame(),
  iscontent = NA,
  var = NA_character_,
  cinfo = NULL,
  format = NULL,
  na_str = NA_character_,
  indent_mod = 0L,
  title = "",
  subtitles = character(),
  main_footer = character(),
  prov_footer = character(),
  page_title = NA_character_,
  hsep = default_hsep(),
  header_section_div = NA_character_,
  trailing_section_div = NA_character_,
  inset = 0L,
  round_type = NULL
)
```

## Arguments

- kids:

  (`list`)\
  list of direct children.

- name:

  (`string`)\
  name of the split/table/row being created. Defaults to the value of
  the corresponding label, but is not required to be.

- lev:

  (`integer(1)`)\
  nesting level (roughly, indentation level in practical terms).

- label:

  (`string`)\
  a label (not to be confused with the name) for the object/structure.

- labelrow:

  (`LabelRow`)\
  the `LabelRow` object to assign to the table. Constructed from `label`
  by default if not specified.

- rspans:

  (`data.frame`)\
  currently stored but otherwise ignored.

- cinfo:

  (`InstantiatedColumnInfo` or `NULL`)\
  column structure for the object being created.

- iscontent:

  (`flag`)\
  whether the `TableTree`/`ElementaryTable` is being constructed as the
  content table for another `TableTree`.

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

- indent_mod:

  (`numeric`)\
  modifier for the default indent position for the structure created by
  this function (subtable, content table, or row) *and all of that
  structure's children*. Defaults to 0, which corresponds to the
  unmodified default behavior.

- title:

  (`string`)\
  single string to use as main title
  ([`formatters::main_title()`](https://rdrr.io/pkg/formatters/man/title_footer.html)).
  Ignored for subtables.

- subtitles:

  (`character`)\
  a vector of strings to use as subtitles
  ([`formatters::subtitles()`](https://rdrr.io/pkg/formatters/man/title_footer.html)),
  where every element is printed on a separate line. Ignored for
  subtables.

- main_footer:

  (`character`)\
  a vector of strings to use as main global (non-referential) footer
  materials
  ([`formatters::main_footer()`](https://rdrr.io/pkg/formatters/man/title_footer.html)),
  where every element is printed on a separate line.

- prov_footer:

  (`character`)\
  a vector of strings to use as provenance-related global footer
  materials
  ([`formatters::prov_footer()`](https://rdrr.io/pkg/formatters/man/title_footer.html)),
  where every element is printed on a separate line.

- header_section_div:

  (`string`)\
  string which will be used to divide the header from the table. See
  [`header_section_div()`](https://pharmaverse.github.io/rtables/reference/section_div.md)
  for the associated getter and setter. Please consider changing last
  element of
  [`section_div()`](https://pharmaverse.github.io/rtables/reference/section_div.md)
  when concatenating tables that require a divider between them.

- hsep:

  (`string`)\
  set of characters to be repeated as the separator between the header
  and body of the table when rendered as text. Defaults to a connected
  horizontal line (unicode 2014) in locals that use a UTF charset, and
  to `-` elsewhere (with a once per session warning). See
  [`formatters::set_default_hsep()`](https://rdrr.io/pkg/formatters/man/default_horizontal_sep.html)
  for further information.

- trailing_section_div:

  (`string`)\
  string which will be used as a section divider after the printing of
  the last row contained in this (sub)table, unless that row is also the
  last table row to be printed overall, or `NA_character_` for none (the
  default). When generated via layouting, this would correspond to the
  `section_div` of the split under which this table represents a single
  facet.

- inset:

  (`numeric(1)`)\
  number of spaces to inset the table header, table body, referential
  footnotes, and main_footer, as compared to alignment of title,
  subtitle, and provenance footer. Defaults to 0 (no inset).

- round_type:

  (`"iec"` (default), `"iec_mod"` or `"sas"`)\
  the type of rounding to perform. See
  [`formatters::format_value()`](https://rdrr.io/pkg/formatters/man/format_value.html)
  for details.

- cont:

  (`ElementaryTable`)\
  content table.

- page_title:

  (`character`)\
  page-specific title(s).

## Value

A formal object representing a populated table.

## Author

Gabriel Becker
