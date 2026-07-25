# Get formatted cells

Get formatted cells

## Usage

``` r
get_formatted_cells(obj, shell = FALSE, round_type = obj_round_type(obj))

# S4 method for class 'TableTree'
get_formatted_cells(obj, shell = FALSE, round_type = obj_round_type(obj))

# S4 method for class 'ElementaryTable'
get_formatted_cells(obj, shell = FALSE, round_type = obj_round_type(obj))

# S4 method for class 'TableRow'
get_formatted_cells(obj, shell = FALSE, round_type = obj_round_type(obj))

# S4 method for class 'LabelRow'
get_formatted_cells(obj, shell = FALSE, round_type = obj_round_type(obj))

get_cell_aligns(obj)

# S4 method for class 'TableTree'
get_cell_aligns(obj)

# S4 method for class 'ElementaryTable'
get_cell_aligns(obj)

# S4 method for class 'TableRow'
get_cell_aligns(obj)

# S4 method for class 'LabelRow'
get_cell_aligns(obj)
```

## Arguments

- obj:

  (`ANY`)\
  the object for the accessor to access or modify.

- shell:

  (`flag`)\
  whether the formats themselves should be returned instead of the
  values with formats applied. Defaults to `FALSE`.

- round_type:

  (`"iec"` (default), `"iec_mod"` or `"sas"`)\
  the type of rounding to perform. See
  [`formatters::format_value()`](https://rdrr.io/pkg/formatters/man/format_value.html)
  for details.

## Value

The formatted print-strings for all (body) cells in `obj`.

## Examples

``` r
library(dplyr)

iris2 <- iris |>
  group_by(Species) |>
  mutate(group = as.factor(rep_len(c("a", "b"), length.out = n()))) |>
  ungroup()

tbl <- basic_table() |>
  split_cols_by("Species") |>
  split_cols_by("group") |>
  analyze(c("Sepal.Length", "Petal.Width"), afun = list_wrap_x(summary), format = "xx.xx") |>
  build_table(iris2)

get_formatted_cells(tbl)
#>       [,1]   [,2]   [,3]   [,4]   [,5]   [,6]  
#>  [1,] ""     ""     ""     ""     ""     ""    
#>  [2,] "4.40" "4.30" "5.00" "4.90" "4.90" "5.60"
#>  [3,] "4.80" "4.80" "5.60" "5.60" "6.20" "6.30"
#>  [4,] "5.00" "5.00" "5.90" "5.90" "6.50" "6.50"
#>  [5,] "5.02" "4.99" "5.99" "5.88" "6.50" "6.67"
#>  [6,] "5.30" "5.10" "6.40" "6.10" "6.70" "7.20"
#>  [7,] "5.80" "5.70" "7.00" "6.70" "7.70" "7.90"
#>  [8,] ""     ""     ""     ""     ""     ""    
#>  [9,] "0.10" "0.10" "1.00" "1.00" "1.40" "1.50"
#> [10,] "0.20" "0.20" "1.20" "1.20" "1.90" "1.80"
#> [11,] "0.20" "0.20" "1.30" "1.30" "2.10" "2.00"
#> [12,] "0.23" "0.26" "1.35" "1.30" "2.08" "1.98"
#> [13,] "0.20" "0.30" "1.50" "1.40" "2.30" "2.20"
#> [14,] "0.40" "0.60" "1.80" "1.70" "2.50" "2.50"
```
