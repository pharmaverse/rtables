# Trim levels to map

This split function constructor creates a split function which trims
levels of a variable to reflect restrictions on the possible
combinations of two or more variables which the data is split by (along
the same axis) within a layout.

## Usage

``` r
trim_levels_to_map(map = NULL)
```

## Arguments

- map:

  data.frame. A data.frame defining allowed combinations of variables.
  Any combination at the level of this split not present in the map will
  be removed from the data, both for the variable being split and those
  present in the data but not associated with this split or any parents
  of it.

## Value

A function that can be used as a split function.

## Details

When splitting occurs, the map is subset to the values of all previously
performed splits. The levels of the variable being split are then pruned
to only those still present within this subset of the map representing
the current hierarchical splitting context.

Splitting is then performed via the
[`keep_split_levels()`](https://pharmaverse.github.io/rtables/reference/split_funcs.md)
split function.

Each resulting element of the partition is then further trimmed by
pruning values of any remaining variables specified in the map to those
values allowed under the combination of the previous and current split.

## See also

[`trim_levels_in_group()`](https://pharmaverse.github.io/rtables/reference/split_funcs.md).

## Examples

``` r
map <- data.frame(
  LBCAT = c("CHEMISTRY", "CHEMISTRY", "CHEMISTRY", "IMMUNOLOGY"),
  PARAMCD = c("ALT", "CRP", "CRP", "IGA"),
  ANRIND = c("LOW", "LOW", "HIGH", "HIGH"),
  stringsAsFactors = FALSE
)

lyt <- basic_table() |>
  split_rows_by("LBCAT") |>
  split_rows_by("PARAMCD", split_fun = trim_levels_to_map(map = map)) |>
  analyze("ANRIND")
tbl <- build_table(lyt, ex_adlb)
```
