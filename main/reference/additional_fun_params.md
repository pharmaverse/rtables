# Additional parameters within analysis and content functions (`afun`/`cfun`)

It is possible to add specific parameters to `afun` and `cfun`, in
[`analyze()`](https://pharmaverse.github.io/rtables/reference/analyze.md)
and
[`summarize_row_groups()`](https://pharmaverse.github.io/rtables/reference/summarize_row_groups.md),
respectively. These parameters grant access to relevant information like
the row split structure (see
[spl_context](https://pharmaverse.github.io/rtables/reference/spl_context.md))
and the predefined baseline (`.ref_group`).

## Details

We list and describe all the parameters that can be added to a custom
analysis function below:

- .N_col:

  Column-wise N (column count) for the full column being tabulated
  within.

- .N_total:

  Overall N (all observation count, defined as sum of column counts) for
  the tabulation.

- .N_row:

  Row-wise N (row group count) for the group of observations being
  analyzed (i.e. with no column-based subsetting).

- .df_row:

  `data.frame` for observations in the row group being analyzed (i.e.
  with no column-based subsetting).

- .var:

  Variable being analyzed.

- .ref_group:

  `data.frame` or vector of subset corresponding to the `ref_group`
  column including subsetting defined by row-splitting. Only
  required/meaningful if a `ref_group` column has been defined.

- .ref_full:

  `data.frame` or vector of subset corresponding to the `ref_group`
  column without subsetting defined by row-splitting. Only
  required/meaningful if a `ref_group` column has been defined.

- .in_ref_col:

  Boolean indicating if calculation is done for cells within the
  reference column.

- .spl_context:

  `data.frame` where each row gives information about a previous
  'ancestor' split state. See
  [spl_context](https://pharmaverse.github.io/rtables/reference/spl_context.md).

- .alt_df_row:

  `data.frame`, i.e. the `alt_counts_df` after row splitting. It can be
  used with `.all_col_exprs` and `.spl_context` information to retrieve
  current faceting, but for `alt_count_df`. It can be an empty table if
  all the entries are filtered out.

- .alt_df:

  `data.frame`, `.alt_df_row` but filtered by columns expression. This
  data present the same faceting of main data `df`. This also filters
  `NA`s out if related parameters are set to do so (e.g. `inclNAs` in
  [`analyze()`](https://pharmaverse.github.io/rtables/reference/analyze.md)).
  Similarly to `.alt_df_row`, it can be an empty data.frame if all the
  entries are filtered out.

- .alt_df_full:

  `data.frame`, the full `alt_counts_df` as passed into `build_table`.
  Unlike `.alt_df` and `.alt_df_row`, this parameter can be used in
  cases where the variables required for row splitting are not present
  in `alt_counts_df`.

- .all_col_exprs:

  List of expressions. Each of them represents a different column
  splitting.

- .all_col_counts:

  Vector of integers. Each of them represents the global count for each
  column. It differs if `alt_counts_df` is used (see
  [`build_table()`](https://pharmaverse.github.io/rtables/reference/build_table.md)).

## Note

If any of these formals is specified incorrectly or not present in the
tabulation machinery, it will be treated as if missing. For example,
`.ref_group` will be missing if no baseline is previously defined during
data splitting (via `ref_group` parameters in, e.g.,
[`split_rows_by()`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)).
Similarly, if no `alt_counts_df` is provided to
[`build_table()`](https://pharmaverse.github.io/rtables/reference/build_table.md),
`.alt_df_row` and `.alt_df` will not be present.
