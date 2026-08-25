# Subsetting and Manipulating Table Contents

## Introduction

`TableTree` objects are based on a tree data structure as the name
indicates. The package is written such that the user does not need to
walk trees for many basic table manipulations. Walking trees will still
be necessary for certain manipulation and will be the subject of a
different vignette.

In this vignette we show some methods to subset tables and to extract
cell values.

We will use the following table for illustrative purposes:

[`library`](https://rdrr.io/r/base/library.html)`(`[`rtables`](https://github.com/pharmaverse/rtables)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`dplyr`](https://dplyr.tidyverse.org)`)`` `` ``lyt`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`` `` `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"ARM"``)`` ``|>`` `` `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"SEX"``, split_fun ``=`` ``drop_split_levels``)`` ``|>`` `` `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(`[`c`](https://rdrr.io/r/base/c.html)`(``"AGE"``, ``"STRATA1"``)``)`` `` ``tbl`` ``<-`` `[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt``, ``ex_adsl`` ``|>`` `[`filter`](https://dplyr.tidyverse.org/reference/filter.html)`(``SEX`` `[`%in%`](https://rdrr.io/r/base/match.html)` `[`c`](https://rdrr.io/r/base/c.html)`(``"M"``, ``"F"``)``)``)`` ``tbl`` ``# A: Drug X B: Placebo C: Combination`` ``# ———————————————————————————————————————————————————`` ``# F `` ``# AGE `` ``# Mean 32.76 34.12 35.20 `` ``# STRATA1 `` ``# A 21 24 18 `` ``# B 25 27 21 `` ``# C 33 26 27 `` ``# M `` ``# AGE `` ``# Mean 35.57 37.44 35.38 `` ``# STRATA1 `` ``# A 16 19 20 `` ``# B 21 17 21 `` ``# C 14 19 19`

## Traditional Subsetting and modification with `[`

The `[` and `[<-` accessor functions operate largely the same as their
`data.frame` cousins:

- `[` and `[<-` both treat Tables as rectangular objects (rather than
  trees)
  - In particular this means label rows are treated as rows with empty
    cell values, rather than rows without cells
- `[` accepts both column and row absolute position, and missing
  arguments mean “all indexes in that dimension”
  - multiple values can be specified in both row and column position
  - negative numeric positions are supported, though like `[.data.frame`
    they cannot be mixed with positive ones
- `[` always returns the same class as the object being subset unless
  `drop = TRUE`
- `[ , drop = TRUE` returns the raw (possibly multi-element) value
  associated with the cell.

**Known Differences from `[.data.frame`** - absolute position cannot
currently be used to reorder columns or rows. Note in general the result
of such an ordering is unlikely to be structurally valid. To change the
order of values, please read [sorting and
pruning](https://pharmaverse.github.io/rtables/latest-tag/articles/sorting_pruning.html)
vignette or relevant function
([`sort_at_path()`](https://pharmaverse.github.io/rtables/reference/sort_at_path.md)). -
`character` indices are treated as paths, not vectors of names in both
`[` and `[<-`

The `[` accessor function always returns an `TableTree` object if
`drop=TRUE` is not set. The first argument are the row indices and the
second argument the column indices. Alternatively logical subsetting can
be used. The indices are based on visible rows and not on the tree
structure. So:

`tbl``[``1``, ``1``]`` ``# A: Drug X`` ``# —————————————`` ``# F`

is a table with an empty cell because the first row is a label row. We
need to access a cell with actual cell data:

`tbl``[``3``, ``1``]`` ``# A: Drug X`` ``# ————————————————`` ``# Mean 32.76`

To retrieve the value, we use `drop = TRUE`:

`tbl``[``3``, ``1``, drop ``=`` ``TRUE``]`` ``# [1] 32.75949`

One can access multiple rows and columns:

`tbl``[``1``:``3``, ``1``:``2``]`` ``# A: Drug X B: Placebo`` ``# —————————————————————————————————`` ``# F `` ``# AGE `` ``# Mean 32.76 34.12`

Note that we do not repeat label rows for descending children, e.g.

`tbl``[``2``:``4``, ``]`` ``# A: Drug X B: Placebo C: Combination`` ``# —————————————————————————————————————————————————`` ``# AGE `` ``# Mean 32.76 34.12 35.20 `` ``# STRATA1`

does not show that the first row is derived from `AGE`. In order to
repeat content/label information, one should use the pagination feature.
Please read the related vignette.

Character indices are interpreted as paths (see below), NOT elements to
be matched against `names(tbl)`:

`tbl``[``, `[`c`](https://rdrr.io/r/base/c.html)`(``"ARM"``, ``"A: Drug X"``)``]`` ``# Note: method with signature 'VTableTree#missing#ANY' chosen for function '[',`` ``# target signature 'TableTree#missing#character'.`` ``# "VTableTree#ANY#character" would also be valid`` ``# A: Drug X`` ``# —————————————————————`` ``# F `` ``# AGE `` ``# Mean 32.76 `` ``# STRATA1 `` ``# A 21 `` ``# B 25 `` ``# C 33 `` ``# M `` ``# AGE `` ``# Mean 35.57 `` ``# STRATA1 `` ``# A 16 `` ``# B 21 `` ``# C 14`

### Dealing with titles, foot notes, and top left information

As standard no additional information is kept after subsetting. Here, we
show with a more complete table how it is still possible to keep the
(possibly) relevant information.

[`top_left`](https://pharmaverse.github.io/rtables/reference/top_left.md)`(``tbl``)`` ``<-`` ``"SEX"`` `[`main_title`](https://rdrr.io/pkg/formatters/man/title_footer.html)`(``tbl``)`` ``<-`` ``"Table 1"`` `[`subtitles`](https://rdrr.io/pkg/formatters/man/title_footer.html)`(``tbl``)`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Authors:"``, ``" - Abcd Zabcd"``, ``" - Cde Zbcd"``)`` `` `[`main_footer`](https://rdrr.io/pkg/formatters/man/title_footer.html)`(``tbl``)`` ``<-`` ``"Please regard this table as an example of smart subsetting"`` `[`prov_footer`](https://rdrr.io/pkg/formatters/man/title_footer.html)`(``tbl``)`` ``<-`` ``"Do remember where you read this though"`` `` ``fnotes_at_path``(``tbl``, rowpath ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"M"``, ``"AGE"``, ``"Mean"``)``, colpath ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"ARM"``, ``"A: Drug X"``)``)`` ``<-`` ``"Very important mean"`

Normal subsetting loses all the information showed above.

`tbl``[``3``, ``3``]`` ``# C: Combination`` ``# —————————————————————`` ``# Mean 35.20`

If all the rows are kept, top left information is also kept. This can be
also imposed by adding `keep_topleft = TRUE` to the subsetting as
follows:

`tbl``[``, ``2``:``3``]`` ``# SEX B: Placebo C: Combination`` ``# ———————————————————————————————————————`` ``# F `` ``# AGE `` ``# Mean 34.12 35.20 `` ``# STRATA1 `` ``# A 24 18 `` ``# B 27 21 `` ``# C 26 27 `` ``# M `` ``# AGE `` ``# Mean 37.44 35.38 `` ``# STRATA1 `` ``# A 19 20 `` ``# B 17 21 `` ``# C 19 19`` ``tbl``[``1``:``3``, ``3``, keep_topleft ``=`` ``TRUE``]`` ``# SEX C: Combination`` ``# —————————————————————————`` ``# F `` ``# AGE `` ``# Mean 35.20`

If the referenced entry is present in the subsetting, also the
referential footnote will appear. Please consider reading relevant
vignette about [referential
footnotes](https://pharmaverse.github.io/rtables/latest-tag/articles/title_footer.html#referential-footnotes).
In case of subsetting, the referential footnotes are by default indexed
again, as if the produced table is a new one.

`tbl``[``10``, ``1``]`` ``# A: Drug X`` ``# ————————————————`` ``# Mean 35.57 {1}`` ``# ————————————————`` ``# `` ``# {1} - Very important mean`` ``# ————————————————`` `[`col_paths_summary`](https://pharmaverse.github.io/rtables/reference/row_paths_summary.md)`(``tbl``)`` ``# Use these to find the right path to value or label`` ``# label path `` ``# —————————————————————————————————————`` ``# A: Drug X ARM, A: Drug X `` ``# B: Placebo ARM, B: Placebo `` ``# C: Combination ARM, C: Combination`` `[`row_paths_summary`](https://pharmaverse.github.io/rtables/reference/row_paths_summary.md)`(``tbl``)`` ``#`` ``# rowname node_class path `` ``# —————————————————————————————————————————————`` ``# F LabelRow SEX, F `` ``# AGE LabelRow SEX, F, AGE `` ``# Mean DataRow SEX, F, AGE, Mean `` ``# STRATA1 LabelRow SEX, F, STRATA1 `` ``# A DataRow SEX, F, STRATA1, A`` ``# B DataRow SEX, F, STRATA1, B`` ``# C DataRow SEX, F, STRATA1, C`` ``# M LabelRow SEX, M `` ``# AGE LabelRow SEX, M, AGE `` ``# Mean DataRow SEX, M, AGE, Mean `` ``# STRATA1 LabelRow SEX, M, STRATA1 `` ``# A DataRow SEX, M, STRATA1, A`` ``# B DataRow SEX, M, STRATA1, B`` ``# C DataRow SEX, M, STRATA1, C`` `` ``` # To select column value, use `NULL` for `rowpath` ``` ``fnotes_at_path``(``tbl``, rowpath ``=`` ``NULL``, colpath ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"ARM"``, ``"A: Drug X"``)``)`` ``<-`` ``"Interesting"`` ``tbl``[``3``, ``1``]`` ``# A: Drug X {1}`` ``# ————————————————————`` ``# Mean 32.76 `` ``# ————————————————————`` ``# `` ``# {1} - Interesting`` ``# ————————————————————`` `` ``# reindexing of {2} as {1}`` ``fnotes_at_path``(``tbl``, rowpath ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"M"``, ``"AGE"``, ``"Mean"``)``, colpath ``=`` ``NULL``)`` ``<-`` ``"THIS mean"`` ``tbl`` ``# {1}, {2}, and {3} are present`` ``# Table 1`` ``# Authors:`` ``# - Abcd Zabcd`` ``# - Cde Zbcd`` ``# `` ``# ——————————————————————————————————————————————————————————`` ``# SEX A: Drug X {1} B: Placebo C: Combination`` ``# ——————————————————————————————————————————————————————————`` ``# F `` ``# AGE `` ``# Mean 32.76 34.12 35.20 `` ``# STRATA1 `` ``# A 21 24 18 `` ``# B 25 27 21 `` ``# C 33 26 27 `` ``# M `` ``# AGE `` ``# Mean {2} 35.57 {3} 37.44 35.38 `` ``# STRATA1 `` ``# A 16 19 20 `` ``# B 21 17 21 `` ``# C 14 19 19 `` ``# ——————————————————————————————————————————————————————————`` ``# `` ``# {1} - Interesting`` ``# {2} - THIS mean`` ``# {3} - Very important mean`` ``# ——————————————————————————————————————————————————————————`` ``# `` ``# Please regard this table as an example of smart subsetting`` ``# `` ``# Do remember where you read this though`` ``tbl``[``10``, ``2``]`` ``# only {1} which was previously {2}`` ``# B: Placebo`` ``# —————————————————————`` ``# Mean {1} 37.44 `` ``# —————————————————————`` ``# `` ``# {1} - THIS mean`` ``# —————————————————————`

Similar to what we have used to keep top left information, we can
specify to keep more information from the original table. As a standard
the foot notes are always present if the titles are kept.

`tbl``[``1``:``3``, ``2``:``3``, keep_titles ``=`` ``TRUE``]`` ``# Table 1`` ``# Authors:`` ``# - Abcd Zabcd`` ``# - Cde Zbcd`` ``# `` ``# ——————————————————————————————————————`` ``# B: Placebo C: Combination`` ``# ——————————————————————————————————————`` ``# F `` ``# AGE `` ``# Mean 34.12 35.20 `` ``# ——————————————————————————————————————`` ``# `` ``# Please regard this table as an example of smart subsetting`` ``# `` ``# Do remember where you read this though`` ``tbl``[``1``:``3``, ``2``:``3``, keep_titles ``=`` ``FALSE``, keep_footers ``=`` ``TRUE``]`` ``# B: Placebo C: Combination`` ``# ——————————————————————————————————————`` ``# F `` ``# AGE `` ``# Mean 34.12 35.20 `` ``# ——————————————————————————————————————`` ``# `` ``# Please regard this table as an example of smart subsetting`` ``# `` ``# Do remember where you read this though`` `` ``` # Referential footnotes are not influenced by `keep_footers = FALSE` ``` ``tbl``[``1``:``3``, keep_titles ``=`` ``TRUE``, keep_footers ``=`` ``FALSE``]`` ``# Table 1`` ``# Authors:`` ``# - Abcd Zabcd`` ``# - Cde Zbcd`` ``# `` ``# ——————————————————————————————————————————————————————`` ``# A: Drug X {1} B: Placebo C: Combination`` ``# ——————————————————————————————————————————————————————`` ``# F `` ``# AGE `` ``# Mean 32.76 34.12 35.20 `` ``# ——————————————————————————————————————————————————————`` ``# `` ``# {1} - Interesting`` ``# ——————————————————————————————————————————————————————`

## Path Based Cell Value Accessing:

Tables can be subset or modified in a structurally aware manner via
*pathing*. See the [pathing
vignette](https://pharmaverse.github.io/rtables/articles/pathing.md) for
a more expansive discussion of pathing, though we reiterate the basics
below.

Paths define semantically meaningful positions within a constructed
table that correspond to the logic of the layout used to create it.

A path is an ordered set of split names, the names of subgroups
generated by the split, and the `@content` directive, which steps into a
position’s content (or row group summary) table.

We can see the row and column paths of an existing table via the
[`row_paths()`](https://pharmaverse.github.io/rtables/reference/make_col_row_df.md),
[`col_paths()`](https://pharmaverse.github.io/rtables/reference/make_col_row_df.md),
[`row_paths_summary()`](https://pharmaverse.github.io/rtables/reference/row_paths_summary.md),
and
[`col_paths_summary()`](https://pharmaverse.github.io/rtables/reference/row_paths_summary.md),
functions, or as a portion of the more general
[`make_row_df()`](https://rdrr.io/pkg/formatters/man/make_row_df.html)
function output.

`lyt2`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`` `` `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"ARM"``)`` ``|>`` `` `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"SEX"``, split_fun ``=`` ``drop_split_levels``)`` ``|>`` `` `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"RACE"``, split_fun ``=`` ``drop_split_levels``)`` ``|>`` `` `[`summarize_row_groups`](https://pharmaverse.github.io/rtables/reference/summarize_row_groups.md)`(``)`` ``|>`` `` `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(`[`c`](https://rdrr.io/r/base/c.html)`(``"AGE"``, ``"STRATA1"``)``)`` `` ``tbl2`` ``<-`` `[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt2``, ``ex_adsl`` ``|>`` `[`filter`](https://dplyr.tidyverse.org/reference/filter.html)`(``SEX`` `[`%in%`](https://rdrr.io/r/base/match.html)` `[`c`](https://rdrr.io/r/base/c.html)`(``"M"``, ``"F"``)`` ``&`` ``RACE`` `[`%in%`](https://rdrr.io/r/base/match.html)` ``(`[`levels`](https://rdrr.io/r/base/levels.html)`(``RACE``)``[``1``:``3``]``)``)``)`` ``tbl2`` ``# A: Drug X B: Placebo C: Combination `` ``# F M F M F M `` ``# ———————————————————————————————————————————————————————————————————————————————————————————————————————`` ``# ASIAN 41 (53.9%) 25 (54.3%) 36 (52.2%) 30 (60.0%) 39 (60.9%) 32 (57.1%)`` ``# AGE `` ``# Mean 31.22 34.60 35.06 38.63 36.44 37.66 `` ``# STRATA1 `` ``# A 11 10 14 10 11 7 `` ``# B 11 9 15 7 11 14 `` ``# C 19 6 7 13 17 11 `` ``# BLACK OR AFRICAN AMERICAN 18 (23.7%) 12 (26.1%) 16 (23.2%) 12 (24.0%) 14 (21.9%) 14 (25.0%)`` ``# AGE `` ``# Mean 34.06 34.58 33.88 36.33 33.21 34.21 `` ``# STRATA1 `` ``# A 5 2 5 6 3 7 `` ``# B 6 5 3 4 4 4 `` ``# C 7 5 8 2 7 3 `` ``# WHITE 17 (22.4%) 9 (19.6%) 17 (24.6%) 8 (16.0%) 11 (17.2%) 10 (17.9%)`` ``# AGE `` ``# Mean 34.12 40.00 32.41 34.62 33.00 30.80 `` ``# STRATA1 `` ``# A 5 3 3 3 3 5 `` ``# B 5 4 8 4 5 2 `` ``# C 7 2 6 1 3 3`

So the column paths are as follows:

[`col_paths_summary`](https://pharmaverse.github.io/rtables/reference/row_paths_summary.md)`(``tbl2``)`` ``# label path `` ``# —————————————————————————————————————————————`` ``# A: Drug X ARM, A: Drug X `` ``# F ARM, A: Drug X, SEX, F `` ``# M ARM, A: Drug X, SEX, M `` ``# B: Placebo ARM, B: Placebo `` ``# F ARM, B: Placebo, SEX, F `` ``# M ARM, B: Placebo, SEX, M `` ``# C: Combination ARM, C: Combination `` ``# F ARM, C: Combination, SEX, F`` ``# M ARM, C: Combination, SEX, M`

and the row paths are as follows:

[`row_paths_summary`](https://pharmaverse.github.io/rtables/reference/row_paths_summary.md)`(``tbl2``)`` ``# rowname node_class path `` ``# ———————————————————————————————————————————————————————————————————————————————————————————————————————————————`` ``# ASIAN ContentRow RACE, ASIAN, @content, ASIAN `` ``# AGE LabelRow RACE, ASIAN, AGE `` ``# Mean DataRow RACE, ASIAN, AGE, Mean `` ``# STRATA1 LabelRow RACE, ASIAN, STRATA1 `` ``# A DataRow RACE, ASIAN, STRATA1, A `` ``# B DataRow RACE, ASIAN, STRATA1, B `` ``# C DataRow RACE, ASIAN, STRATA1, C `` ``# BLACK OR AFRICAN AMERICAN ContentRow RACE, BLACK OR AFRICAN AMERICAN, @content, BLACK OR AFRICAN AMERICAN`` ``# AGE LabelRow RACE, BLACK OR AFRICAN AMERICAN, AGE `` ``# Mean DataRow RACE, BLACK OR AFRICAN AMERICAN, AGE, Mean `` ``# STRATA1 LabelRow RACE, BLACK OR AFRICAN AMERICAN, STRATA1 `` ``# A DataRow RACE, BLACK OR AFRICAN AMERICAN, STRATA1, A `` ``# B DataRow RACE, BLACK OR AFRICAN AMERICAN, STRATA1, B `` ``# C DataRow RACE, BLACK OR AFRICAN AMERICAN, STRATA1, C `` ``# WHITE ContentRow RACE, WHITE, @content, WHITE `` ``# AGE LabelRow RACE, WHITE, AGE `` ``# Mean DataRow RACE, WHITE, AGE, Mean `` ``# STRATA1 LabelRow RACE, WHITE, STRATA1 `` ``# A DataRow RACE, WHITE, STRATA1, A `` ``# B DataRow RACE, WHITE, STRATA1, B `` ``# C DataRow RACE, WHITE, STRATA1, C`

To get a semantically meaningful subset of our table, then, we can use
`[` (or
[`tt_at_path()`](https://pharmaverse.github.io/rtables/reference/ttap.md)
which underlies it)

`tbl2``[`[`c`](https://rdrr.io/r/base/c.html)`(``"RACE"``, ``"ASIAN"``)``, `[`c`](https://rdrr.io/r/base/c.html)`(``"ARM"``, ``"C: Combination"``)``]`` ``# C: Combination `` ``# F M `` ``# ———————————————————————————————————`` ``# ASIAN 39 (60.9%) 32 (57.1%)`` ``# AGE `` ``# Mean 36.44 37.66 `` ``# STRATA1 `` ``# A 11 7 `` ``# B 11 14 `` ``# C 17 11`

We can also retrieve individual cell-values via the
[`value_at()`](https://pharmaverse.github.io/rtables/reference/cell_values.md)
convenience function, which takes a pair of row and column paths which
resolve together to an individual cell, e.g. average age for Asian
female patients in arm A:

[`value_at`](https://pharmaverse.github.io/rtables/reference/cell_values.md)`(``tbl2``, `[`c`](https://rdrr.io/r/base/c.html)`(``"RACE"``, ``"ASIAN"``, ``"AGE"``, ``"Mean"``)``, `[`c`](https://rdrr.io/r/base/c.html)`(``"ARM"``, ``"A: Drug X"``, ``"SEX"``, ``"F"``)``)`` ``# [1] 31.21951`

You can also request information from non-cell specific paths with the
[`cell_values()`](https://pharmaverse.github.io/rtables/reference/cell_values.md)
function:

[`cell_values`](https://pharmaverse.github.io/rtables/reference/cell_values.md)`(``tbl2``, `[`c`](https://rdrr.io/r/base/c.html)`(``"RACE"``, ``"ASIAN"``, ``"AGE"``, ``"Mean"``)``, `[`c`](https://rdrr.io/r/base/c.html)`(``"ARM"``, ``"A: Drug X"``)``)`` ``` # $`A: Drug X.F` ``` ``# [1] 31.21951`` ``# `` ``` # $`A: Drug X.M` ``` ``# [1] 34.6`

Note the return value of
[`cell_values()`](https://pharmaverse.github.io/rtables/reference/cell_values.md)
is always a list even if you specify a path to a cell:

[`cell_values`](https://pharmaverse.github.io/rtables/reference/cell_values.md)`(``tbl2``, `[`c`](https://rdrr.io/r/base/c.html)`(``"RACE"``, ``"ASIAN"``, ``"AGE"``, ``"Mean"``)``, `[`c`](https://rdrr.io/r/base/c.html)`(``"ARM"``, ``"A: Drug X"``, ``"SEX"``, ``"F"``)``)`` ``` # $`A: Drug X.F` ``` ``# [1] 31.21951`
