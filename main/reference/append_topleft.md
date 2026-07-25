# Append a description to the 'top-left' materials for the layout

This function *adds* `newlines` to the current set of "top-left
materials".

## Usage

``` r
append_topleft(lyt, newlines)
```

## Arguments

- lyt:

  (`PreDataTableLayouts`)\
  layout object pre-data used for tabulation.

- newlines:

  (`character`)\
  the new line(s) to be added to the materials.

## Value

A `PreDataTableLayouts` object suitable for passing to further layouting
functions, and to
[`build_table()`](https://pharmaverse.github.io/rtables/reference/build_table.md).

## Details

Adds `newlines` to the set of strings representing the 'top-left'
materials declared in the layout (the content displayed to the left of
the column labels when the resulting tables are printed).

Top-left material strings are stored and then displayed *exactly as is*,
no structure or indenting is applied to them either when they are added
or when they are displayed.

## Note

Currently, where in the construction of the layout this is called makes
no difference, as it is independent of the actual splitting keywords.
This may change in the future.

This function is experimental, its name and the details of its behavior
are subject to change in future versions.

## See also

[`top_left()`](https://pharmaverse.github.io/rtables/reference/top_left.md)

## Examples

``` r
library(dplyr)

DM2 <- DM |> mutate(RACE = factor(RACE), SEX = factor(SEX))

lyt <- basic_table() |>
  split_cols_by("ARM") |>
  split_cols_by("SEX") |>
  split_rows_by("RACE") |>
  append_topleft("Ethnicity") |>
  analyze("AGE") |>
  append_topleft("  Age")

tbl <- build_table(lyt, DM2)
tbl
#> Ethnicity                     A: Drug X      B: Placebo      C: Combination  
#>   Age                         F       M       F       M        F         M   
#> —————————————————————————————————————————————————————————————————————————————
#> ASIAN                                                                        
#>   Mean                      33.55   35.03   34.00   31.10    34.90     34.39 
#> BLACK OR AFRICAN AMERICAN                                                    
#>   Mean                      33.17   37.40   30.58   32.83    33.85     34.14 
#> WHITE                                                                        
#>   Mean                      35.88   44.00   38.57   35.29    36.50     34.00 
```
