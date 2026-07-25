# .spl_context within analysis and split functions

`.spl_context` is an optional parameter for any of rtables' special
functions, i.e. `afun` (analysis function in
[`analyze()`](https://pharmaverse.github.io/rtables/reference/analyze.md)),
`cfun` (content or label function in
[`summarize_row_groups()`](https://pharmaverse.github.io/rtables/reference/summarize_row_groups.md)),
or `split_fun` (e.g. for
[`split_rows_by()`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)).

## Details

The `.spl_context` `data.frame` gives information about the subsets of
data corresponding to the splits within which the current `analyze`
action is nested. Taken together, these correspond to the path that the
resulting (set of) rows the analysis function is creating, although the
information is in a slightly different form. Each split (which
correspond to groups of rows in the resulting table), as well as the
initial 'root' "split", is represented via the following columns:

- split:

  The name of the split (often the variable being split).

- value:

  The string representation of the value at that split (`split`).

- full_parent_df:

  A `data.frame` containing the full data (i.e. across all columns)
  corresponding to the path defined by the combination of `split` and
  `value` of this row *and all rows above this row*.

- all_cols_n:

  The number of observations corresponding to the row grouping (union of
  all columns).

- column for each column in the table structure (*row-split and analyze
  contexts only*):

  These list columns (named the same as `names(col_exprs(tab))`) contain
  logical vectors corresponding to the subset of this row's
  `full_parent_df` corresponding to the column.

- cur_col_id:

  Identifier of the current column. This may be an internal name,
  constructed by pasting the column path together.

- cur_col_subset:

  List column containing logical vectors indicating the subset of this
  row's `full_parent_df` for the column currently being created by the
  analysis function.

- cur_col_expr:

  List of current column expression. This may be used to filter
  `.alt_df_row`, or any external data, by column. Filtering
  `.alt_df_row` by columns produces `.alt_df`.

- cur_col_n:

  Integer column containing the observation counts for that split.

- cur_col_split:

  Current column split names. This is recovered from the current column
  path.

- cur_col_split_val:

  Current column split values. This is recovered from the current column
  path.

## Note

Within analysis functions that accept `.spl_context`, the `all_cols_n`
and `cur_col_n` columns of the data frame will contain the 'true'
observation counts corresponding to the row-group and row-group x column
subsets of the data. These numbers will not, and currently cannot,
reflect alternate column observation counts provided by the
`alt_counts_df`, `col_counts` or `col_total` arguments to
[`build_table()`](https://pharmaverse.github.io/rtables/reference/build_table.md).
