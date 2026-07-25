# Referential footnote accessors

Access and set the referential footnotes aspects of a built table.

## Usage

``` r
row_footnotes(obj)

row_footnotes(obj) <- value

cell_footnotes(obj)

cell_footnotes(obj) <- value

col_fnotes_here(obj)

# S4 method for class 'ANY'
col_fnotes_here(obj)

col_fnotes_here(obj) <- value

col_footnotes(obj)

col_footnotes(obj) <- value

ref_index(obj)

ref_index(obj) <- value

ref_symbol(obj)

ref_symbol(obj) <- value

ref_msg(obj)

fnotes_at_path(obj, rowpath = NULL, colpath = NULL, reset_idx = TRUE) <- value
```

## Arguments

- obj:

  (`ANY`)\
  the object for the accessor to access or modify.

- value:

  (`ANY`)\
  the new value.

- rowpath:

  (`character` or `NULL`)\
  path within row structure. `NULL` indicates the footnote should go on
  the column rather than cell.

- colpath:

  (`character` or `NULL`)\
  path within column structure. `NULL` indicates footnote should go on
  the row rather than cell.

- reset_idx:

  (`flag`)\
  whether the numbering for referential footnotes should be immediately
  recalculated. Defaults to `TRUE`.

## See also

[`row_paths()`](https://pharmaverse.github.io/rtables/reference/make_col_row_df.md),
[`col_paths()`](https://pharmaverse.github.io/rtables/reference/make_col_row_df.md),
[`row_paths_summary()`](https://pharmaverse.github.io/rtables/reference/row_paths_summary.md),
[`col_paths_summary()`](https://pharmaverse.github.io/rtables/reference/row_paths_summary.md)

## Examples

``` r
# How to add referencial footnotes after having created a table
lyt <- basic_table() |>
  split_rows_by("SEX", page_by = TRUE) |>
  analyze("AGE")

tbl <- build_table(lyt, DM)
tbl <- trim_rows(tbl)
# Check the row and col structure to add precise references
# row_paths(tbl)
# col_paths(t)
# row_paths_summary(tbl)
# col_paths_summary(tbl)

# Add the citation numbers on the table and relative references in the footnotes
fnotes_at_path(tbl, rowpath = c("SEX", "F", "AGE", "Mean")) <- "Famous paper 1"
fnotes_at_path(tbl, rowpath = c("SEX", "UNDIFFERENTIATED")) <- "Unfamous paper 2"
# tbl
```
