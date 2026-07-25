# Row-bind `TableTree` and related objects

Row-bind `TableTree` and related objects

## Usage

``` r
rbindl_rtables(
  x,
  gap = lifecycle::deprecated(),
  check_headers = lifecycle::deprecated()
)

# S4 method for class 'VTableNodeInfo'
rbind(..., deparse.level = 1)

# S4 method for class 'VTableNodeInfo,ANY'
rbind2(x, y)
```

## Arguments

- x:

  (`VTableNodeInfo`)\
  `TableTree`, `ElementaryTable`, or `TableRow` object.

- gap:

  **\[deprecated\]** ignored.

- check_headers:

  **\[deprecated\]** ignored.

- ...:

  (`ANY`)\
  elements to be stacked.

- deparse.level:

  (`numeric(1)`)\
  currently ignored.

- y:

  (`VTableNodeInfo`)\
  `TableTree`, `ElementaryTable`, or `TableRow` object.

## Value

A formal table object.

## Note

When objects are row-bound, titles and footer information is retained
from the first object (if any exists) if all other objects have no
titles/footers or have identical titles/footers. Otherwise, all
titles/footers are removed and must be set for the bound table via the
[`formatters::main_title()`](https://rdrr.io/pkg/formatters/man/title_footer.html),
[`formatters::subtitles()`](https://rdrr.io/pkg/formatters/man/title_footer.html),
[`formatters::main_footer()`](https://rdrr.io/pkg/formatters/man/title_footer.html),
and
[`formatters::prov_footer()`](https://rdrr.io/pkg/formatters/man/title_footer.html)
functions.

## Examples

``` r
mtbl <- rtable(
  header = rheader(
    rrow(row.name = NULL, rcell("Sepal.Length", colspan = 2), rcell("Petal.Length", colspan = 2)),
    rrow(NULL, "mean", "median", "mean", "median")
  ),
  rrow(
    row.name = "All Species",
    mean(iris$Sepal.Length), median(iris$Sepal.Length),
    mean(iris$Petal.Length), median(iris$Petal.Length),
    format = "xx.xx"
  )
)

mtbl2 <- with(subset(iris, Species == "setosa"), rtable(
  header = rheader(
    rrow(row.name = NULL, rcell("Sepal.Length", colspan = 2), rcell("Petal.Length", colspan = 2)),
    rrow(NULL, "mean", "median", "mean", "median")
  ),
  rrow(
    row.name = "Setosa",
    mean(Sepal.Length), median(Sepal.Length),
    mean(Petal.Length), median(Petal.Length),
    format = "xx.xx"
  )
))

rbind(mtbl, mtbl2)
#>                Sepal.Length      Petal.Length  
#>               mean    median    mean    median 
#> ———————————————————————————————————————————————
#> All Species   5.84     5.80     3.76     4.35  
#> Setosa        5.01     5.00     1.46     1.50  
rbind(mtbl, rrow(), mtbl2)
#>                Sepal.Length      Petal.Length  
#>               mean    median    mean    median 
#> ———————————————————————————————————————————————
#> All Species   5.84     5.80     3.76     4.35  
#>                                                
#> Setosa        5.01     5.00     1.46     1.50  
rbind(mtbl, rrow("aaa"), indent(mtbl2))
#>                Sepal.Length      Petal.Length  
#>               mean    median    mean    median 
#> ———————————————————————————————————————————————
#> All Species   5.84     5.80     3.76     4.35  
#> aaa                                            
#>   Setosa      5.01     5.00     1.46     1.50  
```
