# Create enriched flat value table with paths

This function creates a flat tabular file of cell values and
corresponding paths via
[`path_enriched_df()`](https://pharmaverse.github.io/rtables/reference/data.frame_export.md).
It then writes that data frame out as a `tsv` file.

## Usage

``` r
export_as_tsv(
  tt,
  file = NULL,
  path_fun = collapse_path,
  value_fun = collapse_values,
  sep = "\t",
  ...
)

import_from_tsv(file)
```

## Arguments

- tt:

  (`TableTree` or related class)\
  a `TableTree` object representing a populated table.

- file:

  (`string`)\
  the path of the file to written to or read from.

- path_fun:

  (`function`)\
  function to transform paths into single-string row/column names.

- value_fun:

  (`function`)\
  function to transform cell values into cells of a `data.frame`.
  Defaults to `collapse_values`, which creates strings where
  multi-valued cells are collapsed together, separated by `|`.

- sep:

  (`string`)\
  defaults to `\t`. See
  [`utils::write.table()`](https://rdrr.io/r/utils/write.table.html) for
  more details.

- ...:

  (`any`)\
  additional arguments to be passed to
  [`utils::write.table()`](https://rdrr.io/r/utils/write.table.html).

## Value

- `export_as_tsv` returns `NULL` silently.

- `import_from_tsv` returns a `data.frame` with re-constituted list
  values.

## Details

By default (i.e. when `value_func` is not specified, list columns where
at least one value has length \> 1 are collapsed to character vectors by
collapsing the list element with `"|"`.

## Note

There is currently no round-trip capability for this type of export. You
can read values exported this way back in via `import_from_tsv` but you
will receive only the `data.frame` version back, NOT a `TableTree`.

## See also

[`path_enriched_df()`](https://pharmaverse.github.io/rtables/reference/data.frame_export.md)
for the underlying function that does the work.
