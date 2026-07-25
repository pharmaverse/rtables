# Insert row at path

Insert a row into an existing table directly before or directly after an
existing data (i.e., non-content and non-label) row, specified by its
path.

## Usage

``` r
insert_row_at_path(tt, path, value, after = FALSE)

# S4 method for class 'VTableTree,DataRow'
insert_row_at_path(tt, path, value, after = FALSE)

# S4 method for class 'VTableTree,ANY'
insert_row_at_path(tt, path, value)
```

## Arguments

- tt:

  (`TableTree` or related class)\
  a `TableTree` object representing a populated table.

- path:

  (`character`)\
  a vector path for a position within the structure of a `TableTree`.
  Each element represents a subsequent choice amongst the children of
  the previous choice.

- value:

  (`ANY`)\
  the new value.

- after:

  (`flag`)\
  whether `value` should be added as a row directly before (`FALSE`, the
  default) or after (`TRUE`) the row specified by `path`.

## See also

[`DataRow()`](https://pharmaverse.github.io/rtables/reference/rowclasses.md),
[`rrow()`](https://pharmaverse.github.io/rtables/reference/rrow.md)

## Examples

``` r
lyt <- basic_table() |>
  split_rows_by("COUNTRY", split_fun = keep_split_levels(c("CHN", "USA"))) |>
  analyze("AGE")

tbl <- build_table(lyt, DM)

tbl2 <- insert_row_at_path(
  tbl, c("COUNTRY", "CHN", "AGE", "Mean"),
  rrow("new row", 555)
)
tbl2
#>             all obs
#> ———————————————————
#> CHN                
#>   new row     555  
#>   Mean       34.64 
#> USA                
#>   Mean       35.30 

tbl3 <- insert_row_at_path(tbl2, c("COUNTRY", "CHN", "AGE", "Mean"),
  rrow("new row redux", 888),
  after = TRUE
)
tbl3
#>                   all obs
#> —————————————————————————
#> CHN                      
#>   new row           555  
#>   Mean             34.64 
#>   new row redux     888  
#> USA                      
#>   Mean             35.30 
```
