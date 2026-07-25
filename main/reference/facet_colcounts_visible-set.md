# Set visibility of column counts for a group of sibling facets

Set visibility of column counts for a group of sibling facets

## Usage

``` r
facet_colcounts_visible(obj, path) <- value
```

## Arguments

- obj:

  (`ANY`)\
  the object for the accessor to access or modify.

- path:

  (`character`)\
  the path *to the parent of the desired siblings*. The last element in
  the path should be a split name.

- value:

  (`ANY`)\
  the new value.

## Value

obj, modified with the desired column count. display behavior

## See also

[`colcount_visible()`](https://pharmaverse.github.io/rtables/reference/colcount_visible.md)
