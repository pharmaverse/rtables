# Retrieve the subset expression from a split value

Returns the subsetting expression associated with a `SplitValue` (or
`ValueWrapper`) object, or `NULL` for objects without one. This
expression is used internally to subset data when tabulating.

## Usage

``` r
value_expr(obj)

# S4 method for class 'ValueWrapper'
value_expr(obj)

# S4 method for class 'ANY'
value_expr(obj)
```

## Arguments

- obj:

  (`ValueWrapper` or `ANY`)\
  a split value object, typically a `SplitValue` constructed by
  [`SplitValue()`](https://pharmaverse.github.io/rtables/reference/SplitValue.md).
  Any other object returns `NULL`.

## Value

An `expression` object, or `NULL`.

## Examples

``` r
sv <- SplitValue("A", sub_expr = expression(ARM == "A"))
value_expr(sv)
#> expression(ARM == "A")

value_expr("not a SplitValue") # NULL
#> NULL
```
