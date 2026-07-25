# Returns a function that coerces the return values of a function to a list

Returns a function that coerces the return values of a function to a
list

## Usage

``` r
list_wrap_x(f)

list_wrap_df(f)
```

## Arguments

- f:

  (`function`)\
  the function to wrap.

## Value

A function that returns a list of `CellValue` objects.

## Details

`list_wrap_x` generates a wrapper which takes `x` as its first argument,
while `list_wrap_df` generates an otherwise identical wrapper function
whose first argument is named `df`.

We provide both because when using the functions as tabulation in
[`analyze()`](https://pharmaverse.github.io/rtables/reference/analyze.md),
functions which take `df` as their first argument are passed the full
subset data frame, while those which accept anything else notably
including `x` are passed only the relevant subset of the variable being
analyzed.

## Author

Gabriel Becker

## Examples

``` r
summary(iris$Sepal.Length)
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#>   4.300   5.100   5.800   5.843   6.400   7.900 

f <- list_wrap_x(summary)
f(x = iris$Sepal.Length)
#> $Min.
#> [1] 4.3
#> 
#> $`1st Qu.`
#> [1] 5.1
#> 
#> $Median
#> [1] 5.8
#> 
#> $Mean
#> [1] 5.843333
#> 
#> $`3rd Qu.`
#> [1] 6.4
#> 
#> $Max.
#> [1] 7.9
#> 

f2 <- list_wrap_df(summary)
f2(df = iris$Sepal.Length)
#> $Min.
#> [1] 4.3
#> 
#> $`1st Qu.`
#> [1] 5.1
#> 
#> $Median
#> [1] 5.8
#> 
#> $Mean
#> [1] 5.843333
#> 
#> $`3rd Qu.`
#> [1] 6.4
#> 
#> $Max.
#> [1] 7.9
#> 
```
