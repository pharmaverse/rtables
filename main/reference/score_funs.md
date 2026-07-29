# Score functions for sorting `TableTrees`

Score functions for sorting `TableTrees`

## Usage

``` r
cont_n_allcols(tt)

cont_n_onecol(j)
```

## Arguments

- tt:

  (`TableTree` or related class)\
  a `TableTree` object representing a populated table.

- j:

  (`numeric(1)`)\
  index of column used for scoring.

## Value

A single numeric value indicating score according to the relevant metric
for `tt`, to be used when sorting.

## See also

For examples and details, please read the documentation for
[`sort_at_path()`](https://pharmaverse.github.io/rtables/reference/sort_at_path.md)
and the [Sorting and
Pruning](https://pharmaverse.github.io/rtables/latest-tag/articles/sorting_pruning.html)
vignette.
