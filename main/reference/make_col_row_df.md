# Get a list of table row/column paths

Get a list of table row/column paths

## Usage

``` r
row_paths(x)

col_paths(x)
```

## Arguments

- x:

  (`VTableTree`)\
  an `rtable` object.

## Value

A list of paths to each row/column within `x`.

## See also

[`cell_values()`](https://pharmaverse.github.io/rtables/reference/cell_values.md),
`fnotes_at_path<-`,
[`row_paths_summary()`](https://pharmaverse.github.io/rtables/reference/row_paths_summary.md),
[`col_paths_summary()`](https://pharmaverse.github.io/rtables/reference/row_paths_summary.md)

## Examples

``` r
lyt <- basic_table() |>
  split_cols_by("ARM") |>
  analyze(c("SEX", "AGE"))

tbl <- build_table(lyt, ex_adsl)
tbl
#>                      A: Drug X   B: Placebo   C: Combination
#> ————————————————————————————————————————————————————————————
#> SEX                                                         
#>   F                     79           77             66      
#>   M                     51           55             60      
#>   U                      3           2              4       
#>   UNDIFFERENTIATED       1           0              2       
#> AGE                                                         
#>   Mean                 33.77       35.43          35.43     

row_paths(tbl)
#> [[1]]
#> [1] "ma_SEX_AGE" "SEX"       
#> 
#> [[2]]
#> [1] "ma_SEX_AGE" "SEX"        "F"         
#> 
#> [[3]]
#> [1] "ma_SEX_AGE" "SEX"        "M"         
#> 
#> [[4]]
#> [1] "ma_SEX_AGE" "SEX"        "U"         
#> 
#> [[5]]
#> [1] "ma_SEX_AGE"       "SEX"              "UNDIFFERENTIATED"
#> 
#> [[6]]
#> [1] "ma_SEX_AGE" "AGE"       
#> 
#> [[7]]
#> [1] "ma_SEX_AGE" "AGE"        "Mean"      
#> 
col_paths(tbl)
#> [[1]]
#> [1] "ARM"       "A: Drug X"
#> 
#> [[2]]
#> [1] "ARM"        "B: Placebo"
#> 
#> [[3]]
#> [1] "ARM"            "C: Combination"
#> 

cell_values(tbl, c("AGE", "Mean"), c("ARM", "B: Placebo"))
#> $`B: Placebo`
#> [1] 35.43284
#> 
```
