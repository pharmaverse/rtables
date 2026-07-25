# Default tabulation

This function is used when
[`analyze()`](https://pharmaverse.github.io/rtables/reference/analyze.md)
is invoked.

## Usage

``` r
simple_analysis(x, ...)

# S4 method for class 'numeric'
simple_analysis(x, ...)

# S4 method for class 'logical'
simple_analysis(x, ...)

# S4 method for class 'factor'
simple_analysis(x, ...)

# S4 method for class 'ANY'
simple_analysis(x, ...)
```

## Arguments

- x:

  (`vector`)\
  the *already split* data being tabulated for a particular cell/set of
  cells.

- ...:

  additional parameters to pass on.

## Value

A `RowsVerticalSection` object (or `NULL`). The details of this object
should be considered an internal implementation detail.

## Details

This function has the following behavior given particular types of
inputs:

- numeric:

  calls [`mean()`](https://rdrr.io/r/base/mean.html) on `x`.

- logical:

  calls [`sum()`](https://rdrr.io/r/base/sum.html) on `x`.

- factor:

  calls [`length()`](https://rdrr.io/r/base/length.html) on `x`.

The
[`in_rows()`](https://pharmaverse.github.io/rtables/reference/in_rows.md)
function is called on the resulting value(s). All other classes of input
currently lead to an error.

## Author

Gabriel Becker and Adrian Waddell

## Examples

``` r
simple_analysis(1:3)
#> RowsVerticalSection (in_rows) object print method:
#> ----------------------------
#>   row_name formatted_cell indent_mod row_label
#> 1     Mean           2.00          0      Mean
simple_analysis(iris$Species)
#> RowsVerticalSection (in_rows) object print method:
#> ----------------------------
#>     row_name formatted_cell indent_mod  row_label
#> 1     setosa             50          0     setosa
#> 2 versicolor             50          0 versicolor
#> 3  virginica             50          0  virginica
simple_analysis(iris$Species == "setosa")
#> RowsVerticalSection (in_rows) object print method:
#> ----------------------------
#>   row_name formatted_cell indent_mod row_label
#> 1    Count             50          0     Count
```
