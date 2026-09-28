# Manual column declaration

Manual column declaration

## Usage

``` r
manual_cols(..., .lst = list(...), ccount_format = NULL)
```

## Arguments

- ...:

  one or more vectors of levels to appear in the column space. If more
  than one set of levels is given, the values of the second are nested
  within each value of the first, and so on.

- .lst:

  (`list`)\
  a list of sets of levels, by default populated via `list(...)`.

- ccount_format:

  (`FormatSpec`)\
  the format to use when counts are displayed.

## Value

An `InstantiatedColumnInfo` object, suitable for declaring the column
structure for a manually constructed table.

## Author

Gabriel Becker

## Examples

``` r
# simple one level column space
rows <- lapply(1:5, function(i) {
  DataRow(rep(i, times = 3))
})
tbl <- TableTree(kids = rows, cinfo = manual_cols(split = c("a", "b", "c")))
#> Modifying subtable (or row) names to ensure uniqueness among direct siblings
#> [  -> { , [2], [3], [4], [5] }]
#>   To control table names use split_rows_by*(, parent_name =.) or  analyze(., table_names = .) when analyzing a single variable, or analyze(., parent_name = .) when analyzing multiple variables in a single call.
tbl
#>    a   b   c
#> ————————————
#>    1   1   1
#>    2   2   2
#>    3   3   3
#>    4   4   4
#>    5   5   5

# manually declared nesting
tbl2 <- TableTree(
  kids = list(DataRow(as.list(1:4))),
  cinfo = manual_cols(
    Arm = c("Arm A", "Arm B"),
    Gender = c("M", "F")
  )
)
tbl2
#>     Arm A      Arm B  
#>     M    F     M    F 
#> ——————————————————————
#>     1    2     3    4 
```
