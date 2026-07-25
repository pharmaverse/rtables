# General argument conventions

General argument conventions

## Usage

``` r
gen_args(
  df,
  alt_counts_df,
  spl,
  pos,
  tt,
  tr,
  verbose,
  colwidths,
  obj,
  x,
  value,
  object,
  path,
  label,
  label_pos,
  cvar,
  topleft,
  page_prefix,
  hsep,
  indent_size,
  section_div,
  na_str,
  inset,
  table_inset,
  tt_type = c("any", "row", "table", "elemtable"),
  round_type = valid_round_type,
  ...
)
```

## Arguments

- df:

  (`data.frame` or `tibble`)\
  dataset.

- alt_counts_df:

  (`data.frame` or `tibble`)\
  alternative full dataset the rtables framework will use *only* when
  calculating column counts.

- spl:

  (`Split`)\
  a `Split` object defining a partitioning or analysis/tabulation of the
  data.

- pos:

  (`numeric`)\
  which top-level set of nested splits should the new layout feature be
  added to. Defaults to the current split.

- tt:

  (`TableTree` or related class)\
  a `TableTree` object representing a populated table.

- tr:

  (`TableRow` or related class)\
  a `TableRow` object representing a single row within a populated
  table.

- verbose:

  (`flag`)\
  whether additional information should be displayed to the user.
  Defaults to `FALSE`.

- colwidths:

  (`numeric`)\
  a vector of column widths for use in vertical pagination.

- obj:

  (`ANY`)\
  the object for the accessor to access or modify.

- x:

  (`ANY`)\
  an object.

- value:

  (`ANY`)\
  the new value.

- object:

  (`ANY`)\
  the object to modify in place.

- path:

  (`character`)\
  a vector path for a position within the structure of a `TableTree`.
  Each element represents a subsequent choice amongst the children of
  the previous choice.

- label:

  (`string`)\
  a label (not to be confused with the name) for the object/structure.

- label_pos:

  (`string`)\
  location where the variable label should be displayed. Accepts
  `"hidden"` (default for non-analyze row splits), `"visible"`,
  `"topleft"`, and `"default"` (for analyze splits only). For `analyze`
  calls, `"default"` indicates that the variable should be visible if
  and only if multiple variables are analyzed at the same level of
  nesting.

- cvar:

  (`string`)\
  the variable, if any, that the content function should accept.
  Defaults to `NA`.

- topleft:

  (`character`)\
  override values for the "top left" material to be displayed during
  printing.

- page_prefix:

  (`string`)\
  prefix to be appended with the split value when forcing pagination
  between the children of a split/table.

- hsep:

  (`string`)\
  set of characters to be repeated as the separator between the header
  and body of the table when rendered as text. Defaults to a connected
  horizontal line (unicode 2014) in locals that use a UTF charset, and
  to `-` elsewhere (with a once per session warning). See
  [`formatters::set_default_hsep()`](https://rdrr.io/pkg/formatters/man/default_horizontal_sep.html)
  for further information.

- indent_size:

  (`numeric(1)`)\
  number of spaces to use per indent level. Defaults to 2.

- section_div:

  (`string`)\
  string which should be repeated as a section divider after each group
  defined by this split instruction, or `NA_character_` (the default)
  for no section divider.

- na_str:

  (`string`)\
  string that should be displayed when the value of `x` is missing.
  Defaults to `"NA"`.

- inset:

  (`numeric(1)`)\
  number of spaces to inset the table header, table body, referential
  footnotes, and main_footer, as compared to alignment of title,
  subtitle, and provenance footer. Defaults to 0 (no inset).

- table_inset:

  (`numeric(1)`)\
  number of spaces to inset the table header, table body, referential
  footnotes, and main footer, as compared to alignment of title,
  subtitles, and provenance footer. Defaults to 0 (no inset).

- tt_type:

  (`character(1)`)\
  One of "any", "row", "table", "elemtable"; when testing existence or
  resolving a path with "\*" wildcards, this indicates a restriction on
  *the final element the path resolves to*. E.g., for "table", possible
  paths which match the structure of the wild-card path but resolve to
  an individual row will not be considered matching. The value
  "elemtable" indicates an Elementary table, i.e., one representing a
  single variable within an `analyze` call.

- round_type:

  (`"iec"` (default), `"iec_mod"` or `"sas"`)\
  the type of rounding to perform. See
  [`formatters::format_value()`](https://rdrr.io/pkg/formatters/man/format_value.html)
  for details.

- ...:

  additional parameters passed to methods or tabulation functions.

## Value

No return value.

## See also

Other conventions:
[`compat_args()`](https://pharmaverse.github.io/rtables/reference/compat_args.md),
[`constr_args()`](https://pharmaverse.github.io/rtables/reference/constr_args.md),
[`lyt_args()`](https://pharmaverse.github.io/rtables/reference/lyt_args.md),
[`sf_args()`](https://pharmaverse.github.io/rtables/reference/sf_args.md)
