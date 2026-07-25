# Add the column population counts to the header

Add the data derived column counts.

## Usage

``` r
add_colcounts(lyt, format = "(N=xx)")
```

## Arguments

- lyt:

  (`PreDataTableLayouts`)\
  layout object pre-data used for tabulation.

- format:

  (`string`, `function`, or `list`)\
  format associated with this split. Formats can be declared via strings
  (`"xx.x"`) or function. In cases such as `analyze` calls, they can be
  character vectors or lists of functions. See
  [`formatters::list_valid_format_labels()`](https://rdrr.io/pkg/formatters/man/list_formats.html)
  for a list of all available format strings.

## Value

A `PreDataTableLayouts` object suitable for passing to further layouting
functions, and to
[`build_table()`](https://pharmaverse.github.io/rtables/reference/build_table.md).

## Details

It is often the case that the the column counts derived from the input
data to
[`build_table()`](https://pharmaverse.github.io/rtables/reference/build_table.md)
is not representative of the population counts. For example, if events
are counted in the table and the header should display the number of
subjects and not the total number of events.

## Author

Gabriel Becker

## Examples

``` r
lyt <- basic_table() |>
  split_cols_by("ARM") |>
  add_colcounts() |>
  split_rows_by("RACE", split_fun = drop_split_levels) |>
  analyze("AGE", afun = function(x) list(min = min(x), max = max(x)))
lyt
#> A Pre-data Table Layout
#> 
#> Column-Split Structure:
#> ARM (lvls) 
#> 
#> Row-Split Structure:
#> RACE (lvls) -> AGE (** analysis **) 
#> 

tbl <- build_table(lyt, DM)
tbl
#>                             A: Drug X   B: Placebo   C: Combination
#>                              (N=121)     (N=106)        (N=129)    
#> ———————————————————————————————————————————————————————————————————
#> ASIAN                                                              
#>   min                          20           21             22      
#>   max                          58           55             53      
#> BLACK OR AFRICAN AMERICAN                                          
#>   min                          23           21             24      
#>   max                          60           42             51      
#> WHITE                                                              
#>   min                          30           25             28      
#>   max                          47           55             47      
```
