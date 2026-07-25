# Compatibility argument conventions

Compatibility argument conventions

## Usage

``` r
compat_args(.lst, row.name, format, indent, label, inset)
```

## Arguments

- .lst:

  (`list`)\
  an already-collected list of arguments to be used instead of the
  elements of `...`. Arguments passed via `...` will be ignored if this
  is specified.

- row.name:

  (`string` or `NULL`)\
  row name. If `NULL`, an empty string is used as `row.name` of the
  [`rrow()`](https://pharmaverse.github.io/rtables/reference/rrow.md).

- format:

  (`string`, `function`, or `list`)\
  the format label (string) or formatter function to apply to the cell
  values passed via `...`. See
  [`formatters::list_valid_format_labels()`](https://rdrr.io/pkg/formatters/man/list_formats.html)
  for currently supported format labels.

- indent:

  **\[deprecated\]**

- label:

  (`string`)\
  a label (not to be confused with the name) for the object/structure.

- inset:

  (`integer(1)`)\
  the table inset for the row or table being constructed. See
  [`formatters::table_inset()`](https://rdrr.io/pkg/formatters/man/table_inset.html)
  for details.

## Value

No return value.

## See also

Other conventions:
[`constr_args()`](https://pharmaverse.github.io/rtables/reference/constr_args.md),
[`gen_args()`](https://pharmaverse.github.io/rtables/reference/gen_args.md),
[`lyt_args()`](https://pharmaverse.github.io/rtables/reference/lyt_args.md),
[`sf_args()`](https://pharmaverse.github.io/rtables/reference/sf_args.md)
