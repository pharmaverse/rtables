# Value formats

Returns a matrix of formats for the cells in a table.

## Usage

``` r
value_formats(obj, default = obj_format(obj))

# S4 method for class 'ANY'
value_formats(obj, default = obj_format(obj))

# S4 method for class 'TableRow'
value_formats(obj, default = obj_format(obj))

# S4 method for class 'LabelRow'
value_formats(obj, default = obj_format(obj))

# S4 method for class 'VTableTree'
value_formats(obj, default = obj_format(obj))
```

## Arguments

- obj:

  (`VTableTree` or `TableRow`)\
  a table or row object.

- default:

  (`string`, `function`, or `list`)\
  default format.

## Value

Matrix (storage mode list) containing the effective format for each cell
position in the table (including 'virtual' cells implied by label rows,
whose formats are always `NULL`).

## See also

[`table_shell()`](https://pharmaverse.github.io/rtables/reference/table_shell.md)
and
[`table_shell_str()`](https://pharmaverse.github.io/rtables/reference/table_shell.md)
for information on the table format structure.

## Examples

``` r
lyt <- basic_table() |>
  split_rows_by("RACE", split_fun = keep_split_levels(c("ASIAN", "WHITE"))) |>
  analyze("AGE")

tbl <- build_table(lyt, DM)
value_formats(tbl)
#>       all obs
#> ASIAN NULL   
#> Mean  "xx.xx"
#> WHITE NULL   
#> Mean  "xx.xx"
```
