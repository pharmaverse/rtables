# Find degenerate (sub)structures within a table

**\[experimental\]**

This function returns a list with the row-paths to all structural
subtables which contain no data rows (even if they have associated
content rows).

## Usage

``` r
find_degen_struct(tt)
```

## Arguments

- tt:

  (`TableTree`)\
  a `TableTree` object.

## Value

A list of character vectors representing the row paths, if any, to
degenerate substructures within the table.

## See also

Other table structure validation functions:
[`sanitize_table_struct()`](https://pharmaverse.github.io/rtables/reference/sanitize_table_struct.md),
[`validate_table_struct()`](https://pharmaverse.github.io/rtables/reference/validate_table_struct.md)

## Examples

``` r
find_degen_struct(rtable("hi"))
#> [[1]]
#> [1] ""
#> 
```
