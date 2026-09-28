# List variables required by a pre-data table layout

List variables required by a pre-data table layout

## Usage

``` r
vars_in_layout(lyt)

# S4 method for class 'PreDataTableLayouts'
vars_in_layout(lyt)

# S4 method for class 'PreDataAxisLayout'
vars_in_layout(lyt)

# S4 method for class 'SplitVectorTree'
vars_in_layout(lyt)

# S4 method for class 'SplitVector'
vars_in_layout(lyt)

# S4 method for class 'Split'
vars_in_layout(lyt)

# S4 method for class 'CompoundSplit'
vars_in_layout(lyt)

# S4 method for class 'ManualSplit'
vars_in_layout(lyt)
```

## Arguments

- lyt:

  (`PreDataTableLayouts`)\
  the layout (or a component thereof).

## Value

A character vector containing the unique variables explicitly used in
the layout (see the notes below).

## Details

This will walk the layout declaration and return a vector of the names
of the unique variables that are used in any of the following ways:

- Variable being split on (directly or via cuts)

- Element of a Multi-variable column split

- Content variable

- Value-label variable

## Note

- This function will not detect dependencies implicit in analysis or
  summary functions which accept `x` or `df` and then rely on the
  existence of particular variables not being split on/analyzed.

- The order these variable names appear within the return vector is
  undefined and should not be relied upon.

## Examples

``` r
lyt <- basic_table() |>
  split_cols_by("ARM") |>
  split_cols_by("SEX") |>
  summarize_row_groups(label_fstr = "Overall (N)") |>
  split_rows_by("RACE",
    split_label = "Ethnicity", labels_var = "ethn_lab",
    split_fun = drop_split_levels
  ) |>
  summarize_row_groups("RACE", label_fstr = "%s (n)") |>
  analyze("AGE", var_labels = "Age", afun = mean, format = "xx.xx")

vars_in_layout(lyt)
#> [1] "ARM"      "SEX"      "RACE"     "ethn_lab" "AGE"     
```
