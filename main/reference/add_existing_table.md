# Add an already calculated table to the layout

Add an already calculated table to the layout

## Usage

``` r
add_existing_table(lyt, tt, indent_mod = 0)
```

## Arguments

- lyt:

  (`PreDataTableLayouts`)\
  layout object pre-data used for tabulation.

- tt:

  (`TableTree` or related class)\
  a `TableTree` object representing a populated table.

- indent_mod:

  (`numeric`)\
  modifier for the default indent position for the structure created by
  this function (subtable, content table, or row) *and all of that
  structure's children*. Defaults to 0, which corresponds to the
  unmodified default behavior.

## Value

A `PreDataTableLayouts` object suitable for passing to further layouting
functions, and to
[`build_table()`](https://pharmaverse.github.io/rtables/reference/build_table.md).

## Author

Gabriel Becker

## Examples

``` r
lyt1 <- basic_table() |>
  split_cols_by("ARM") |>
  analyze("AGE", afun = mean, format = "xx.xx")

tbl1 <- build_table(lyt1, DM)
tbl1
#>        A: Drug X   B: Placebo   C: Combination
#> ——————————————————————————————————————————————
#> mean     34.91       33.02          34.57     

lyt2 <- basic_table() |>
  split_cols_by("ARM") |>
  analyze("AGE", afun = sd, format = "xx.xx") |>
  add_existing_table(tbl1)

tbl2 <- build_table(lyt2, DM)
#> Modifying subtable (or row) names to ensure uniqueness among direct siblings
#> [AGE  -> { AGE, AGE[2] }]
#>   To control table names use split_rows_by*(, parent_name =.) or  analyze(., table_names = .) when analyzing a single variable, or analyze(., parent_name = .) when analyzing multiple variables in a single call.FALSE
tbl2
#>        A: Drug X   B: Placebo   C: Combination
#> ——————————————————————————————————————————————
#> sd       7.79         6.34           6.50     
#> mean     34.91       33.02          34.57     

table_structure(tbl2)
#> [TableTree] root
#>  [ElementaryTable] AGE (1 x 3)
#>  [ElementaryTable] AGE[2] (1 x 3)
row_paths_summary(tbl2)
#> rowname    node_class    path              
#> ———————————————————————————————————————————
#> sd         DataRow       root, AGE, sd     
#> mean       DataRow       root, AGE[2], mean
```
