# Insert `rrow`s at (before) a specific location

**\[deprecated\]**

## Usage

``` r
insert_rrow(tbl, rrow, at = 1, ascontent = FALSE)
```

## Arguments

- tbl:

  (`VTableTree`)\
  a `rtable` object.

- rrow:

  (`TableRow`)\
  an `rrow` to append to `tbl`.

- at:

  (`integer(1)`)\
  position into which to put the `rrow`, defaults to beginning (i.e. row
  1).

- ascontent:

  (`flag`)\
  currently ignored.

## Value

A `TableTree` of the same specific class as `tbl`.

## Details

This function is deprecated and will be removed in a future release of
`rtables`. Please use
[`insert_row_at_path()`](https://pharmaverse.github.io/rtables/reference/insert_row_at_path.md)
or
[`label_at_path()`](https://pharmaverse.github.io/rtables/reference/label_at_path.md)
instead.

## Note

Label rows (i.e. a row with no data values, only a `row.name`) can only
be inserted at positions which do not already contain a label row when
there is a non-trivial nested row structure in `tbl`.

## Examples

``` r
o <- options(warn = 0)
lyt <- basic_table() |>
  split_cols_by("Species") |>
  analyze("Sepal.Length")

tbl <- build_table(lyt, iris)

insert_rrow(tbl, rrow("Hello World"))
#> Warning: `insert_rrow()` was deprecated in rtables 0.4.0.
#> ℹ Please use insert_row_at_path() or label_at_path() instead.
#>               setosa   versicolor   virginica
#> —————————————————————————————————————————————
#> Hello World                                  
#> Mean           5.01       5.94        6.59   
insert_rrow(tbl, rrow("Hello World"), at = 2)
#>               setosa   versicolor   virginica
#> —————————————————————————————————————————————
#> Mean           5.01       5.94        6.59   
#> Hello World                                  

lyt2 <- basic_table() |>
  split_cols_by("Species") |>
  split_rows_by("Species") |>
  analyze("Sepal.Length")

tbl2 <- build_table(lyt2, iris)

insert_rrow(tbl2, rrow("Hello World"))
#>               setosa   versicolor   virginica
#> —————————————————————————————————————————————
#> Hello World                                  
#> setosa                                       
#>   Mean         5.01        NA          NA    
#> versicolor                                   
#>   Mean          NA        5.94         NA    
#> virginica                                    
#>   Mean          NA         NA         6.59   
insert_rrow(tbl2, rrow("Hello World"), at = 2)
#>                 setosa   versicolor   virginica
#> ———————————————————————————————————————————————
#> setosa                                         
#>   Hello World                                  
#>     Mean         5.01        NA          NA    
#> versicolor                                     
#>   Mean            NA        5.94         NA    
#> virginica                                      
#>   Mean            NA         NA         6.59   
insert_rrow(tbl2, rrow("Hello World"), at = 4)
#>                 setosa   versicolor   virginica
#> ———————————————————————————————————————————————
#> setosa                                         
#>   Mean           5.01        NA          NA    
#> versicolor                                     
#>   Hello World                                  
#>     Mean          NA        5.94         NA    
#> virginica                                      
#>   Mean            NA         NA         6.59   

insert_rrow(tbl2, rrow("new row", 5, 6, 7))
#>              setosa   versicolor   virginica
#> ————————————————————————————————————————————
#> new row        5          6            7    
#> setosa                                      
#>   Mean        5.01        NA          NA    
#> versicolor                                  
#>   Mean         NA        5.94         NA    
#> virginica                                   
#>   Mean         NA         NA         6.59   

insert_rrow(tbl2, rrow("new row", 5, 6, 7), at = 3)
#>              setosa   versicolor   virginica
#> ————————————————————————————————————————————
#> setosa                                      
#>   Mean        5.01        NA          NA    
#>   new row      5          6            7    
#> versicolor                                  
#>   Mean         NA        5.94         NA    
#> virginica                                   
#>   Mean         NA         NA         6.59   

options(o)
```
