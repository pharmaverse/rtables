# Sanitize degenerate table structures

**\[experimental\]**

Experimental function to correct structure of degenerate tables by
adding messaging rows to empty sub-structures.

## Usage

``` r
sanitize_table_struct(tt, empty_msg = "-- This Section Contains No Data --")
```

## Arguments

- tt:

  (`TableTree`)\
  a `TableTree` object.

- empty_msg:

  (`string`)\
  the string which should be spanned across the inserted empty rows.

## Value

If `tt` is already valid, it is returned unmodified. If `tt` is
degenerate, a modified, non-degenerate version of the table is returned.

## Details

This function locates degenerate portions of the table (including the
table overall in the case of a table with no data rows) and inserts a
row which spans all columns with the message `empty_msg` at each one,
generating a table guaranteed to be non-degenerate.

## See also

Other table structure validation functions:
[`find_degen_struct()`](https://pharmaverse.github.io/rtables/reference/find_degen_struct.md),
[`validate_table_struct()`](https://pharmaverse.github.io/rtables/reference/validate_table_struct.md)

## Examples

``` r
sanitize_table_struct(rtable("cool beans"))
#>                cool beans             
#> ——————————————————————————————————————
#>    -- This Section Contains No Data --

lyt <- basic_table() |>
  split_cols_by("ARM") |>
  split_rows_by("SEX") |>
  summarize_row_groups()

## Degenerate because it doesn't have any analyze calls -> no data rows
badtab <- build_table(lyt, DM)
sanitize_table_struct(badtab)
#>                     A: Drug X    B: Placebo   C: Combination
#> ————————————————————————————————————————————————————————————
#> F                  70 (57.9%)    56 (52.8%)     61 (47.3%)  
#>                       -- This Section Contains No Data --   
#> M                  51 (42.1%)    50 (47.2%)     68 (52.7%)  
#>                       -- This Section Contains No Data --   
#> U                   0 (0.0%)      0 (0.0%)       0 (0.0%)   
#>                       -- This Section Contains No Data --   
#> UNDIFFERENTIATED    0 (0.0%)      0 (0.0%)       0 (0.0%)   
#>                       -- This Section Contains No Data --   
```
