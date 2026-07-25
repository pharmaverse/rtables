# Constructing rtables Manually

## Overview

The main functions currently associated with `rtable`s are

Tables in `rtables` can be constructed via the layout or `rtabulate`
tabulation frameworks or also manually. Currently manual table
construction is the only way to define column spans. The main functions
for manual table constructions are:

- [`rtable()`](https://pharmaverse.github.io/rtables/reference/rtable.md):
  collection of
  [`rrow()`](https://pharmaverse.github.io/rtables/reference/rrow.md)
  objects, column header and default format
- [`rrow()`](https://pharmaverse.github.io/rtables/reference/rrow.md):
  collection of
  [`rcell()`](https://pharmaverse.github.io/rtables/reference/rcell.md)
  objects and default format
- [`rcell()`](https://pharmaverse.github.io/rtables/reference/rcell.md):
  collection of data objects and cell format

## Simple Example

``` r

library(rtables)
```

``` r

tbl <- rtable(
  header = c("Treatement\nN=100", "Comparison\nN=300"),
  format = "xx (xx.xx%)",
  rrow("A", c(104, .2), c(100, .4)),
  rrow("B", c(23, .4), c(43, .5)),
  rrow(),
  rrow("this is a very long section header"),
  rrow("estimate", rcell(55.23, "xx.xx", colspan = 2)),
  rrow("95% CI", indent = 1, rcell(c(44.8, 67.4), format = "(xx.x, xx.x)", colspan = 2))
)
```

Before we go into explaining the individual components used to create
this table we continue with the html conversion of the
[`rtable()`](https://pharmaverse.github.io/rtables/reference/rtable.md)
object:

``` r

as_html(tbl, width = "80%")
```
