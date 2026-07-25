# Construct a `SplitValue` object

Creates a `SplitValue` object representing a single facet value produced
by a splitting operation, optionally carrying a custom subsetting
expression and child-specific extra arguments.

## Usage

``` r
SplitValue(val, extr = list(), label = val, sub_expr = NULL)
```

## Arguments

- val:

  (`ANY`)\
  the raw value for this split facet.

- extr:

  (`list`)\
  named list of child-specific extra arguments to forward to the
  analysis or content function for this facet.

- label:

  (`character(1)`)\
  display label. Defaults to `val`.

- sub_expr:

  (`expression` or `NULL`)\
  optional subsetting expression. When `NULL` (default) the expression
  is derived automatically from `val` during tabulation.

## Value

A `SplitValue` object.

## See also

[`splv_extra()`](https://pharmaverse.github.io/rtables/reference/splv_extra.md),
[`value_expr()`](https://pharmaverse.github.io/rtables/reference/value_expr.md)

## Examples

``` r
sv <- SplitValue("A", sub_expr = expression(ARM == "A"))
value_expr(sv)
#> expression(ARM == "A")
splv_extra(sv)
#> list()
```
