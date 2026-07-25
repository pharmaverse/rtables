# Pre-processing function for use in `make_split_fun`

This function is intended for use as a pre-processing component in
`make_split_fun`, and should not be called directly by end users.

## Usage

``` r
drop_facet_levels(df, spl, ...)
```

## Arguments

- df:

  (`data.frame`)\
  the incoming data corresponding with the parent facet.

- spl:

  (`VarLevelSplit`)\
  the split.

- ...:

  additional parameters passed internally.

## See also

[`make_split_fun()`](https://pharmaverse.github.io/rtables/reference/make_split_fun.md)

Other make_custom_split:
[`add_combo_facet()`](https://pharmaverse.github.io/rtables/reference/add_combo_facet.md),
[`make_split_fun()`](https://pharmaverse.github.io/rtables/reference/make_split_fun.md),
[`make_split_result()`](https://pharmaverse.github.io/rtables/reference/make_split_result.md),
[`restrict_facets()`](https://pharmaverse.github.io/rtables/reference/restrict_facets.md),
[`trim_levels_in_facets()`](https://pharmaverse.github.io/rtables/reference/trim_levels_in_facets.md)
