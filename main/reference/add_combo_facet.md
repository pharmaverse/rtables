# Add a combination facet in post-processing

Add a combination facet during the post-processing stage in a custom
split fun.

## Usage

``` r
add_combo_facet(name, label = name, levels, extra = list())

add_overall_facet(name, label, extra = list())
```

## Arguments

- name:

  (`string`)\
  name for the resulting facet (for use in pathing, etc.).

- label:

  (`string`)\
  label for the resulting facet.

- levels:

  (`character`)\
  vector of levels to combine within the resulting facet.

- extra:

  (`list`)\
  extra arguments to be passed to analysis functions applied within the
  resulting facet.

## Value

A function which can be used within the `post` argument in
[`make_split_fun()`](https://pharmaverse.github.io/rtables/reference/make_split_fun.md).

## Details

For `add_combo_facet`, the data associated with the resulting facet will
be the data associated with the facets for each level in `levels`,
row-bound together. In particular, this means that if those levels are
overlapping, data that appears in both will be duplicated.

## See also

[`make_split_fun()`](https://pharmaverse.github.io/rtables/reference/make_split_fun.md)

Other make_custom_split:
[`drop_facet_levels()`](https://pharmaverse.github.io/rtables/reference/drop_facet_levels.md),
[`make_split_fun()`](https://pharmaverse.github.io/rtables/reference/make_split_fun.md),
[`make_split_result()`](https://pharmaverse.github.io/rtables/reference/make_split_result.md),
[`restrict_facets()`](https://pharmaverse.github.io/rtables/reference/restrict_facets.md),
[`trim_levels_in_facets()`](https://pharmaverse.github.io/rtables/reference/trim_levels_in_facets.md)

## Examples

``` r
mysplfun <- make_split_fun(post = list(
  add_combo_facet("A_B",
    label = "Arms A+B",
    levels = c("A: Drug X", "B: Placebo")
  ),
  add_overall_facet("ALL", label = "All Arms")
))

lyt <- basic_table(show_colcounts = TRUE) |>
  split_cols_by("ARM", split_fun = mysplfun) |>
  analyze("AGE")

tbl <- build_table(lyt, DM)
```
