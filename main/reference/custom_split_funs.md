# Custom split functions

Split functions provide the work-horse for `rtables`'s generalized
partitioning. These functions accept a (sub)set of incoming data and a
split object, and return "splits" of that data.

## Custom Splitting Function Details

User-defined custom split functions can perform any type of computation
on the incoming data provided that they meet the requirements for
generating "splits" of the incoming data based on the split object.

Split functions are functions that accept:

- df:

  a `data.frame` of incoming data to be split.

- spl:

  a Split object. This is largely an internal detail custom functions
  will not need to worry about, but `obj_name(spl)`, for example, will
  give the name of the split as it will appear in paths in the resulting
  table.

- vals:

  any pre-calculated values. If given non-`NULL` values, the values
  returned should match these. Should be `NULL` in most cases and can
  usually be ignored.

- labels:

  any pre-calculated value labels. Same as above for `values`.

- trim:

  if `TRUE`, resulting splits that are empty are removed.

- (optional) .spl_context:

  a `data.frame` describing previously performed splits which
  collectively arrived at `df`.

The function must then output a named `list` with the following
elements:

- values:

  the vector of all values corresponding to the splits of `df`.

- datasplit:

  a list of `data.frame`s representing the groupings of the actual
  observations from `df`.

- labels:

  a character vector giving a string label for each value listed in the
  `values` element above.

- (optional) extras:

  if present, extra arguments are to be passed to summary and analysis
  functions whenever they are executed on the corresponding element of
  `datasplit` or a subset thereof.

One way to generate custom splitting functions is to wrap existing split
functions and modify either the incoming data before they are called or
their outputs.

## See also

[`make_split_fun()`](https://pharmaverse.github.io/rtables/reference/make_split_fun.md)
for the API for creating custom split functions, and
[split_funcs](https://pharmaverse.github.io/rtables/reference/split_funcs.md)
for a variety of pre-defined split functions.

## Examples

``` r
# Example of a picky split function. The number of values in the column variable
# var decrees if we are going to print also the column with all observation
# or not.

picky_splitter <- function(var) {
  # Main layout function
  function(df, spl, vals, labels, trim) {
    orig_vals <- vals

    # Check for number of levels if all are selected
    if (is.null(vals)) {
      vec <- df[[var]]
      vals <- unique(vec)
    }

    # Do a split with or without All obs
    if (length(vals) == 1) {
      do_base_split(spl = spl, df = df, vals = vals, labels = labels, trim = trim)
    } else {
      fnc_tmp <- add_overall_level("Overall", label = "All Obs", first = FALSE)
      fnc_tmp(df = df, spl = spl, vals = orig_vals, trim = trim)
    }
  }
}

# Data sub-set
d1 <- subset(ex_adsl, ARM == "A: Drug X" | (ARM == "B: Placebo" & SEX == "F"))
d1 <- subset(d1, SEX %in% c("M", "F"))
d1$SEX <- factor(d1$SEX)

# This table uses the number of values in the SEX column to add the overall col or not
lyt <- basic_table() |>
  split_cols_by("ARM", split_fun = drop_split_levels) |>
  split_cols_by("SEX", split_fun = picky_splitter("SEX")) |>
  analyze("AGE", show_labels = "visible")
tbl <- build_table(lyt, d1)
tbl
#>                 A: Drug X          B: Placebo
#>            F       M     All Obs       F     
#> —————————————————————————————————————————————
#> AGE                                          
#>   Mean   32.76   35.57    33.86      34.12   
```
