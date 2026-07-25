# Create an `rtable` row

Create an `rtable` row

## Usage

``` r
rrow(
  row.name = "",
  ...,
  format = NULL,
  indent = 0,
  inset = 0L,
  round_type = valid_round_type
)
```

## Arguments

- row.name:

  (`string` or `NULL`)\
  row name. If `NULL`, an empty string is used as `row.name` of the
  `rrow()`.

- ...:

  cell values.

- format:

  (`string`, `function`, or `list`)\
  the format label (string) or formatter function to apply to the cell
  values passed via `...`. See
  [`formatters::list_valid_format_labels()`](https://rdrr.io/pkg/formatters/man/list_formats.html)
  for currently supported format labels.

- indent:

  **\[deprecated\]**

- inset:

  (`integer(1)`)\
  the table inset for the row or table being constructed. See
  [`formatters::table_inset()`](https://rdrr.io/pkg/formatters/man/table_inset.html)
  for details.

- round_type:

  (`"iec"`, `"iec_mod"` or `"sas"`)\
  the type of rounding to perform. See
  [`round_fmt()`](https://rdrr.io/pkg/formatters/man/round_fmt.html) for
  details.

## Value

A row object of the context-appropriate type (label or data).

## See also

Other compatibility:
[`rheader()`](https://pharmaverse.github.io/rtables/reference/rheader.md),
[`rrowl()`](https://pharmaverse.github.io/rtables/reference/rrowl.md),
[`rtable()`](https://pharmaverse.github.io/rtables/reference/rtable.md)

## Examples

``` r
rrow("ABC", c(1, 2), c(3, 2), format = "xx (xx.%)")
#> [DataRow indent_mod 0]: ABC   1 (200%)   3 (200%)
rrow("")
#> [LabelRow indent_mod 0]:    
```
