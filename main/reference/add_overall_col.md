# Add overall column

This function will *only* add an overall column at the *top* level of
splitting, NOT within existing column splits. See
[`add_overall_level()`](https://pharmaverse.github.io/rtables/reference/add_overall_level.md)
for the recommended way to add overall columns more generally within
existing splits.

## Usage

``` r
add_overall_col(lyt, label)
```

## Arguments

- lyt:

  (`PreDataTableLayouts`)\
  layout object pre-data used for tabulation.

- label:

  (`string`)\
  a label (not to be confused with the name) for the object/structure.

## Value

A `PreDataTableLayouts` object suitable for passing to further layouting
functions, and to
[`build_table()`](https://pharmaverse.github.io/rtables/reference/build_table.md).

## See also

[`add_overall_level()`](https://pharmaverse.github.io/rtables/reference/add_overall_level.md)

## Examples

``` r
lyt <- basic_table() |>
  split_cols_by("ARM") |>
  add_overall_col("All Patients") |>
  analyze("AGE")
lyt
#> A Pre-data Table Layout
#> 
#> Column-Split Structure:
#> ARM (lvls) 
#>  (all obs) 
#> 
#> Row-Split Structure:
#> AGE (** analysis **) 
#> 

tbl <- build_table(lyt, DM)
tbl
#>        A: Drug X   B: Placebo   C: Combination   All Patients
#> —————————————————————————————————————————————————————————————
#> Mean     34.91       33.02          34.57           34.22    
```
