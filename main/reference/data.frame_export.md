# Generate a result data frame

Collection of utilities to extract `data.frame` objects from `TableTree`
objects.

## Usage

``` r
as_result_df(
  tt,
  spec = NULL,
  data_format = c("full_precision", "strings", "numeric"),
  make_ard = FALSE,
  expand_colnames = FALSE,
  keep_label_rows = FALSE,
  add_tbl_name_split = FALSE,
  simplify = FALSE,
  verbose = FALSE,
  round_type = obj_round_type(tt),
  ...
)

path_enriched_df(tt, path_fun = collapse_path, value_fun = collapse_values)
```

## Arguments

- tt:

  (`TableTree` or related class)\
  a `TableTree` object representing a populated table.

- spec:

  (`function`)\
  function that generates the result data frame from a table
  (`TableTree`). It defaults to `NULL`, for standard processing.

- data_format:

  (`string`)\
  the format of the data in the result data frame. It can be one value
  between `"full_precision"` (default), `"strings"`, and `"numeric"`.
  The last two values show the numeric data with the visible precision.

- make_ard:

  (`flag`)\
  when `TRUE`, the result data frame will have only one statistic per
  row.

- expand_colnames:

  (`flag`)\
  when `TRUE`, the result data frame will have expanded column names
  above the usual output. This is useful when the result data frame is
  used for further processing.

- keep_label_rows:

  (`flag`)\
  when `TRUE`, the result data frame will have all labels as they appear
  in the final table.

- add_tbl_name_split:

  (`flag`)\
  when `TRUE` and when the table has more than one
  `analyze(table_names = "<diff_names>")`, the table names will be
  present as a group split named `"<analysis_spl_tbl_name>"`.

- simplify:

  (`flag`)\
  when `TRUE`, the result data frame will have only visible labels and
  result columns. Consider showing also label rows with
  `keep_label_rows = TRUE`. This output can be used again to create a
  `TableTree` object with
  [`df_to_tt()`](https://pharmaverse.github.io/rtables/reference/df_to_tt.md).

- verbose:

  (`flag`)\
  when `TRUE`, the function will print additional information for
  `data_format != "full_precision"`.

- round_type:

  (`"iec"` (default), `"iec_mod"` or `"sas"`)\
  the type of rounding to perform. See
  [`formatters::format_value()`](https://rdrr.io/pkg/formatters/man/format_value.html)
  for details.

- ...:

  additional arguments passed to spec-specific result data frame
  function (`spec`). When using `make_ard = TRUE`, it is possible to
  turn off the extraction of the exact string decimals printed by the
  table with `add_tbl_str_decimals = FALSE`.

- path_fun:

  (`function`)\
  function to transform paths into single-string row/column names.

- value_fun:

  (`function`)\
  function to transform cell values into cells of a `data.frame`.
  Defaults to `collapse_values`, which creates strings where
  multi-valued cells are collapsed together, separated by `|`.

## Value

- `as_result_df` returns a result `data.frame`.

&nbsp;

- `path_enriched_df()` returns a `data.frame` of `tt`'s cell values
  (processed by `value_fun`, with columns named by the full column paths
  (processed by `path_fun` and an additional `row_path` column with the
  row paths (processed by `path_fun`).

## Functions

- `path_enriched_df()`: Transform a `TableTree` object to a
  path-enriched `data.frame`.

## Note

When `parent_name` is used when constructing a layout to directly
control the name of subtables in a table, that will be reflected in the
'group' values returned in the result dataframe/ard. When automatic
de-duplication of sibling names is performed by `rtables`, that is
automatically undone during the result df creation process, so the group
values will be as if the relevant siblings had identical names.

## See also

[`df_to_tt()`](https://pharmaverse.github.io/rtables/reference/df_to_tt.md)
when using `simplify = TRUE` and
[`formatters::make_row_df()`](https://rdrr.io/pkg/formatters/man/make_row_df.html)
to have a comprehensive view of the hierarchical structure of the rows.

## Examples

``` r
lyt <- basic_table() |>
  split_cols_by("ARM") |>
  split_rows_by("STRATA1") |>
  analyze(c("AGE", "BMRKR2"))

tbl <- build_table(lyt, ex_adsl)
as_result_df(tbl, simplify = TRUE)
#>    label_name A: Drug X B: Placebo C: Combination
#> 1        Mean  33.07895   35.11364         34.225
#> 2         LOW        12         16             14
#> 3      MEDIUM        10         17             13
#> 4        HIGH        16         11             13
#> 5        Mean  33.85106         36       36.32558
#> 6         LOW        19         13             10
#> 7      MEDIUM        13         22             16
#> 8        HIGH        15         10             17
#> 9        Mean  34.22449   35.17778       35.63265
#> 10        LOW        19         16             16
#> 11     MEDIUM        14         17             13
#> 12       HIGH        16         12             20

lyt <- basic_table() |>
  split_cols_by("ARM") |>
  analyze(c("AGE", "BMRKR2"))

tbl <- build_table(lyt, ex_adsl)
path_enriched_df(tbl)
#>                      row_path ARM|A: Drug X ARM|B: Placebo ARM|C: Combination
#> 1      ma_AGE_BMRKR2|AGE|Mean      33.76866       35.43284           35.43182
#> 2    ma_AGE_BMRKR2|BMRKR2|LOW      50.00000       45.00000           40.00000
#> 3 ma_AGE_BMRKR2|BMRKR2|MEDIUM      37.00000       56.00000           42.00000
#> 4   ma_AGE_BMRKR2|BMRKR2|HIGH      47.00000       33.00000           50.00000
```
