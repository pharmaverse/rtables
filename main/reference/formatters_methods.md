# Methods for generics in the `formatters` package

See the `formatters` documentation for descriptions of these generics.

These are internal methods that are documented only to satisfy
`R CMD check`. End users should pay no attention to this documentation,
except for the few exported methods.

## Usage

``` r
# S4 method for class 'VNodeInfo'
obj_name(obj)

# S4 method for class 'Split'
obj_name(obj)

# S4 method for class 'VNodeInfo'
obj_name(obj) <- value

# S4 method for class 'Split'
obj_name(obj) <- value

# S4 method for class 'Split'
obj_label(obj)

# S4 method for class 'TableRow'
obj_label(obj)

# S4 method for class 'VTableTree'
obj_label(obj)

# S4 method for class 'ValueWrapper'
obj_label(obj)

# S4 method for class 'Split'
obj_label(obj) <- value

# S4 method for class 'TableRow'
obj_label(obj) <- value

# S4 method for class 'ValueWrapper'
obj_label(obj) <- value

# S4 method for class 'VTableTree'
obj_label(obj) <- value

# S4 method for class 'VTableNodeInfo'
obj_format(obj)

# S4 method for class 'CellValue'
obj_format(obj)

# S4 method for class 'Split'
obj_format(obj)

# S4 method for class 'RowsVerticalSection'
obj_format(obj)

# S4 method for class 'VTableNodeInfo'
obj_format(obj) <- value

# S4 method for class 'Split'
obj_format(obj) <- value

# S4 method for class 'CellValue'
obj_format(obj) <- value

# S4 method for class 'RowsVerticalSection'
obj_format(obj) <- value

# S4 method for class 'Split'
obj_na_str(obj)

# S4 method for class 'VTitleFooter'
main_title(obj)

# S4 method for class 'VTitleFooter'
main_title(obj) <- value

# S4 method for class 'TableRow'
main_title(obj)

# S4 method for class 'VTitleFooter'
subtitles(obj)

# S4 method for class 'VTitleFooter'
subtitles(obj) <- value

# S4 method for class 'TableRow'
subtitles(obj)

# S4 method for class 'VTitleFooter'
main_footer(obj)

# S4 method for class 'VTitleFooter'
main_footer(obj) <- value

# S4 method for class 'TableRow'
main_footer(obj)

# S4 method for class 'VTitleFooter'
prov_footer(obj)

# S4 method for class 'VTitleFooter'
prov_footer(obj) <- value

# S4 method for class 'TableRow'
prov_footer(obj)

# S4 method for class 'VTableNodeInfo'
table_inset(obj)

# S4 method for class 'PreDataTableLayouts'
table_inset(obj)

# S4 method for class 'VTableNodeInfo'
table_inset(obj) <- value

# S4 method for class 'PreDataTableLayouts'
table_inset(obj) <- value

# S4 method for class 'InstantiatedColumnInfo'
table_inset(obj) <- value

# S4 method for class 'ANY'
obj_round_type(obj)

# S4 method for class 'PreDataTableLayouts'
obj_round_type(obj)

# S4 method for class 'VTableTree'
obj_round_type(obj)

# S4 method for class 'TableRow'
obj_round_type(obj)

# S4 method for class 'CellValue'
obj_round_type(obj)

# S4 method for class 'VTableTree'
obj_round_type(obj) <- value

# S4 method for class 'TableRow'
obj_round_type(obj) <- value

# S4 method for class 'LabelRow'
obj_round_type(obj) <- value

# S4 method for class 'CellValue'
obj_round_type(obj) <- value

# S4 method for class 'TableRow'
nlines(x, colwidths = NULL, max_width = NULL, fontspec, col_gap = 3)

# S4 method for class 'LabelRow'
nlines(
  x,
  colwidths = NULL,
  max_width = NULL,
  fontspec = fontspec,
  col_gap = NULL
)

# S4 method for class 'RefFootnote'
nlines(x, colwidths = NULL, max_width = NULL, fontspec, col_gap = NULL)

# S4 method for class 'InstantiatedColumnInfo'
nlines(x, colwidths = NULL, max_width = NULL, fontspec, col_gap = 3)

# S4 method for class 'VTableTree'
make_row_df(
  tt,
  colwidths = NULL,
  visible_only = TRUE,
  rownum = 0,
  indent = 0L,
  path = character(),
  incontent = FALSE,
  repr_ext = 0L,
  repr_inds = integer(),
  sibpos = NA_integer_,
  nsibs = NA_integer_,
  max_width = NULL,
  fontspec = NULL,
  col_gap = 3
)

# S4 method for class 'TableRow'
make_row_df(
  tt,
  colwidths = NULL,
  visible_only = TRUE,
  rownum = 0,
  indent = 0L,
  path = "root",
  incontent = FALSE,
  repr_ext = 0L,
  repr_inds = integer(),
  sibpos = NA_integer_,
  nsibs = NA_integer_,
  max_width = NULL,
  fontspec,
  col_gap = 3
)

# S4 method for class 'LabelRow'
make_row_df(
  tt,
  colwidths = NULL,
  visible_only = TRUE,
  rownum = 0,
  indent = 0L,
  path = "root",
  incontent = FALSE,
  repr_ext = 0L,
  repr_inds = integer(),
  sibpos = NA_integer_,
  nsibs = NA_integer_,
  max_width = NULL,
  fontspec,
  col_gap = 3
)
```

## Arguments

- obj:

  (`ANY`)\
  the object for the accessor to access or modify.

- value:

  (`ANY`)\
  the new value.

- x:

  (`ANY`)\
  an object.

- colwidths:

  (`numeric`)\
  a vector of column widths for use in vertical pagination.

- max_width:

  (`numeric(1)`)\
  width that strings should be wrapped to when determining how many
  lines they require.

- fontspec:

  (`font_spec`)\
  a font_spec object specifying the font information to use for
  calculating string widths and heights, as returned by
  [`font_spec()`](https://rdrr.io/pkg/formatters/man/font_spec.html).

- col_gap:

  (`numeric(1)`)\
  width of gap between columns in number of spaces. Only used by methods
  which must calculate span widths after wrapping.

- tt:

  (`TableTree` or related class)\
  a `TableTree` object representing a populated table.

- visible_only:

  (`flag`)\
  should only visible aspects of the table structure be reflected in
  this summary. Defaults to `TRUE`. May not be supported by all methods.

- rownum:

  (`numeric(1)`)\
  internal detail, do not set manually.

- indent:

  (`integer(1)`)\
  internal detail, do not set manually.

- path:

  (`character`)\
  a vector path for a position within the structure of a `TableTree`.
  Each element represents a subsequent choice amongst the children of
  the previous choice.

- incontent:

  (`flag`)\
  internal detail, do not set manually.

- repr_ext:

  (`integer(1)`)\
  internal detail, do not set manually.

- repr_inds:

  (`integer`)\
  internal detail, do not set manually.

- sibpos:

  (`integer(1)`)\
  internal detail, do not set manually.

- nsibs:

  (`integer(1)`)\
  internal detail, do not set manually.

## Value

- Accessor functions return the current value of the component being
  accessed of `obj`

- Setter functions return a modified copy of `obj` with the new value.

## Details

When `visible_only` is `TRUE` (the default), methods should return a
`data.frame` with exactly one row per visible row in the table-like
object. This is useful when reasoning about how a table will print, but
does not reflect the full pathing space of the structure (though the
paths which are given will all work as is).

If supported, when `visible_only` is `FALSE`, every structural element
of the table (in row-space) will be reflected in the returned
`data.frame`, meaning the full pathing-space will be represented but
some rows in the layout summary will not represent printed rows in the
table as it is displayed.

Most arguments beyond `tt` and `visible_only` are present so that
`make_row_df` methods can call `make_row_df` recursively and retain
information, and should not be set during a top-level call.

## Note

The technically present root tree node is excluded from the summary
returned by both `make_row_df` and `make_col_df` (see relevant functions
in`rtables`), as it is the row/column structure of `tt` and thus not
useful for pathing or pagination.

## Examples

``` r
# Expected error with matrix_form. For real case examples consult {rtables} documentation
mf <- basic_matrix_form(iris)
# make_row_df(mf) # Use table obj instead
```
