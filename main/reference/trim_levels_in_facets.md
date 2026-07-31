# Trim levels of another variable from each facet (post-processing split step)

Trim levels of another variable from each facet (post-processing split
step)

## Usage

``` r
trim_levels_in_facets(innervar)
```

## Arguments

- innervar:

  (`character`)\
  the variable(s) to trim (remove unobserved levels) independently
  within each facet.

## Value

A function suitable for use in the `post` (list) argument of
`make_split_fun`.

## See also

[`make_split_fun()`](https://pharmaverse.github.io/rtables/reference/make_split_fun.md)

Other make_custom_split:
[`add_combo_facet()`](https://pharmaverse.github.io/rtables/reference/add_combo_facet.md),
[`drop_facet_levels()`](https://pharmaverse.github.io/rtables/reference/drop_facet_levels.md),
[`make_split_fun()`](https://pharmaverse.github.io/rtables/reference/make_split_fun.md),
[`make_split_result()`](https://pharmaverse.github.io/rtables/reference/make_split_result.md),
[`restrict_facets()`](https://pharmaverse.github.io/rtables/reference/restrict_facets.md)
