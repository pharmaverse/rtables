# Format `rcell` objects

This is a wrapper for
[`formatters::format_value()`](https://rdrr.io/pkg/formatters/man/format_value.html)
for use with `CellValue` objects

## Usage

``` r
format_rcell(
  x,
  format,
  output = c("ascii", "html"),
  na_str = obj_na_str(x) %||% "NA",
  pr_row_format = NULL,
  pr_row_na_str = NULL,
  round_type,
  shell = FALSE
)
```

## Arguments

- x:

  (`CellValue` or `ANY`)\
  an object of class `CellValue`, or a raw value.

- format:

  (`string` or `function`)\
  the format label or formatter function to apply to `x`.

- output:

  (`string`)\
  output type.

- na_str:

  (`string`)\
  string that should be displayed when the value of `x` is missing.
  Defaults to `"NA"`.

- pr_row_format:

  (`list`)\
  list of default formats coming from the general row.

- pr_row_na_str:

  (`list`)\
  list of default `"NA"` strings coming from the general row.

- round_type:

  (`"iec"` (default), `"iec_mod"` or `"sas"`)\
  the type of rounding to perform. See
  [`formatters::format_value()`](https://rdrr.io/pkg/formatters/man/format_value.html)
  for details.

- shell:

  (`flag`)\
  whether the formats themselves should be returned instead of the
  values with formats applied. Defaults to `FALSE`.

## Value

Formatted text.

## Examples

``` r
cll <- CellValue(pi, format = "xx.xxx")
format_rcell(cll)
#> [1] "3.142"

# Cell values precedes the row values
cll <- CellValue(pi, format = "xx.xxx")
format_rcell(cll, pr_row_format = "xx.x")
#> [1] "3.142"

# Similarly for NA values
cll <- CellValue(NA, format = "xx.xxx", format_na_str = "This is THE NA")
format_rcell(cll, pr_row_na_str = "This is NA")
#> [1] "This is THE NA"
```
