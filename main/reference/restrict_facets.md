# Postprocessing split function behavior to generally restrict facets

Postprocessing split function behavior to generally restrict facets

## Usage

``` r
restrict_facets(
  facets,
  op = c("keep", "exclude"),
  reorder = TRUE,
  quiet = FALSE
)
```

## Arguments

- facets:

  `(character)`\
  Vector of facet names

- op:

  `("keep", or "exclude")`\
  Whether `facets` names facets to be (exclusively) kept (the default)
  or removed.

- reorder:

  `(flag)`\
  For `op == "keep"`, should the resulting facets be reordered to the
  order they appear in `facets`. Defaults to `TRUE`. Ignored if
  `op == "exclude"`.

- quiet:

  `(logical(1))`\
  Whether warnings should be given or not (the default) when facets
  named in `facets` are not found in the split result.

## Value

a function suitable for use within the `post` argument of
[`make_split_fun()`](https://pharmaverse.github.io/rtables/reference/make_split_fun.md).

## Details

This is a function factory which creates a post-process behavioral
building block for use in
[`make_split_fun()`](https://pharmaverse.github.io/rtables/reference/make_split_fun.md).

This factory provides the equivalent of both `keep_split_levels` and
`remove_split_levels` in a form suitable for use in
[`make_split_fun()`](https://pharmaverse.github.io/rtables/reference/make_split_fun.md).

When `op` is `"keep"` (the default), resulting facets are restricted to
only those named in `facets` when the generated function is applied to a
split result; in the case of `"exclude"`, facets named in `facets` are
removed so that only those not named remain.

The generated function will throw a warning if any of `facets` are not
found in the split result it receives during splitting, unless it was
created with `quiet = FALSE`.

## See also

[`make_split_fun()`](https://pharmaverse.github.io/rtables/reference/make_split_fun.md)

Other make_custom_split:
[`add_combo_facet()`](https://pharmaverse.github.io/rtables/reference/add_combo_facet.md),
[`drop_facet_levels()`](https://pharmaverse.github.io/rtables/reference/drop_facet_levels.md),
[`make_split_fun()`](https://pharmaverse.github.io/rtables/reference/make_split_fun.md),
[`make_split_result()`](https://pharmaverse.github.io/rtables/reference/make_split_result.md),
[`trim_levels_in_facets()`](https://pharmaverse.github.io/rtables/reference/trim_levels_in_facets.md)

## Examples

``` r

keep_spl <- make_split_fun(post = list(restrict_facets(c("M", "F"), op = "keep")))

lyt <- basic_table() |>
  split_cols_by("SEX", split_fun = keep_spl) |>
  analyze("AGE")

build_table(lyt, ex_adsl)
#>          M       F  
#> ————————————————————
#> Mean   36.12   33.95


excl_undiff <- restrict_facets("UNDIFFERENTIATED", op = "exclude")
excl_spl <- make_split_fun(post = list(excl_undiff))

lyt <- basic_table() |>
  split_cols_by("SEX", split_fun = excl_spl) |>
  analyze("AGE")

build_table(lyt, ex_adsl)
#>          F       M       U  
#> ————————————————————————————
#> Mean   33.95   36.12   33.11
```
