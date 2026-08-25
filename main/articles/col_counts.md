# Column Counts and Formats

## The Old Way

Many tables call for column counts to be displayed in the header
material of a table (i.e., interspersed with the column labels).

Historically, `rtables` supported this only for so-called leaf or
individual columns.

### Setting column counts to visible at Layout time

Display of column counts (off by default) was primarily achieved via
passing `show_colcounts = TRUE` to `basic_table` , e.g.

[`library`](https://rdrr.io/r/base/library.html)`(`[`dplyr`](https://dplyr.tidyverse.org)`)`` ``# `` ``# Attaching package: 'dplyr'`` ``# The following objects are masked from 'package:stats':`` ``# `` ``# filter, lag`` ``# The following objects are masked from 'package:base':`` ``# `` ``# intersect, setdiff, setequal, union`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`rtables`](https://github.com/pharmaverse/rtables)`)`` ``# Loading required package: formatters`` ``# `` ``# Attaching package: 'formatters'`` ``# The following object is masked from 'package:base':`` ``# `` ``# %||%`` ``# `` ``# Attaching package: 'rtables'`` ``# The following object is masked from 'package:utils':`` ``# `` ``# str`` ``lyt`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``show_colcounts ``=`` ``TRUE``)`` ``|>`` `` `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"ARM"``)`` ``|>`` `` `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"SEX"``, split_fun ``=`` `[`keep_split_levels`](https://pharmaverse.github.io/rtables/reference/split_funcs.md)`(`[`c`](https://rdrr.io/r/base/c.html)`(``"F"``, ``"M"``)``)``)`` ``|>`` `` `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``)`` `` ``tbl`` ``<-`` `[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt``, ``ex_adsl``)`` ``tbl`` ``# A: Drug X B: Placebo C: Combination `` ``# F M F M F M `` ``# (N=79) (N=51) (N=77) (N=55) (N=66) (N=60) `` ``# ————————————————————————————————————————————————————————————`` ``# Mean 32.76 35.57 34.12 37.44 35.20 35.38`

The format of the counts could also be controlled by the
`colcount_format` argument to `basic_table`.

We had no way of displaying (or, in fact, even easily calculating) the
`ARM` facet counts.

### Modifying counts on an existing table

(Leaf-)column counts could be altered after the fact via the
`col_counts<-` getter:

[`col_counts`](https://pharmaverse.github.io/rtables/reference/col_accessors.md)`(``tbl``)`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``17``, ``18``, ``19``, ``17``, ``18``, ``19``)`` ``tbl`` ``# A: Drug X B: Placebo C: Combination `` ``# F M F M F M `` ``# (N=17) (N=18) (N=19) (N=17) (N=18) (N=19) `` ``# ————————————————————————————————————————————————————————————`` ``# Mean 32.76 35.57 34.12 37.44 35.20 35.38`

**NB** doing this has never updated percentages that appear within the
table as they are calculated at table-creation time, so this can lead to
misleading results when not used with care.

### Hiding counts

We did not provide a user-visible way to toggle column count display
after table creation, though we did support showing a blank space for
particular counts by setting them to `NA`:

[`col_counts`](https://pharmaverse.github.io/rtables/reference/col_accessors.md)`(``tbl``)`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``17``, ``18``, ``NA``, ``17``, ``18``, ``19``)`` ``tbl`` ``# A: Drug X B: Placebo C: Combination `` ``# F M F M F M `` ``# (N=17) (N=18) (N=17) (N=18) (N=19) `` ``# ———————————————————————————————————————————————————————————`` ``# Mean 32.76 35.57 34.12 37.44 35.20 35.38`

These mechanisms will all continue to work for the forseeable future,
though new code is advised use the new API discussed below.

## Higher Level Column Counts

Starting in `rtables` version `6.8.0`, the concept of column counts is
modeled and handled with much more granularity than previously. Each
facet in column space now has a column count (whether or not it is
displayed), which will appear directly under the corresponding column
label (spanning the same number of rows) when set to be visible.

### Setting Column Counts to Visible at Layout Time

The primary way for users to create tables which displays these
“high-level” column counts is to create a layout that specifies they
should be visible.

We do this with the new `show_colcounts` argument now accepted by all
`split_cols_by*` layout functions.

`lyt2`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`` `` `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"ARM"``)`` ``|>`` `` `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"SEX"``,`` `` split_fun ``=`` `[`keep_split_levels`](https://pharmaverse.github.io/rtables/reference/split_funcs.md)`(`[`c`](https://rdrr.io/r/base/c.html)`(``"F"``, ``"M"``)``)``,`` `` show_colcounts ``=`` ``TRUE`` `` ``)`` ``|>`` `` `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``)`` `` ``tbl2`` ``<-`` `[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt2``, ``ex_adsl``)`` ``tbl2`` ``# A: Drug X B: Placebo C: Combination `` ``# F M F M F M `` ``# (N=79) (N=51) (N=77) (N=55) (N=66) (N=60) `` ``# ————————————————————————————————————————————————————————————`` ``# Mean 32.76 35.57 34.12 37.44 35.20 35.38`

`lyt3`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`` `` `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"ARM"``, show_colcounts ``=`` ``TRUE``)`` ``|>`` `` `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"SEX"``, split_fun ``=`` `[`keep_split_levels`](https://pharmaverse.github.io/rtables/reference/split_funcs.md)`(`[`c`](https://rdrr.io/r/base/c.html)`(``"F"``, ``"M"``)``)``)`` ``|>`` `` `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``)`` `` ``tbl3`` ``<-`` `[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt3``, ``ex_adsl``)`` ``tbl3`` ``# A: Drug X B: Placebo C: Combination `` ``# (N=134) (N=134) (N=132) `` ``# F M F M F M `` ``# ————————————————————————————————————————————————————————`` ``# Mean 32.76 35.57 34.12 37.44 35.20 35.38`

As before, these column counts are calculated at table creation time,
using `alt_counts_df` if it is provided (or simply `df` otherwise).

Column formats are set at layout time via the `colcount_format` argument
*of the specific `split_cols_by` call*.

### Manipulating Column Counts In An Existing Table

Manipulation of column counts (beyond the old setters provided for
backwards compatibility) is path based. In other words, when we set a
column count (e.g., to NA so it displays as a blank) or set the
visibilty of a set of column counts, we do so by indicating them via
column paths. The ability to alter column count formats on an existing
table is currently not offered by any exported functions.

Column paths can be obtained via `col_paths` for the leaf columns, or
via `make_col_df(tbl, visible_only = FALSE)$path` for all addressable
facets.

#### Setting individual column counts

The `facet_colcount` getter and setter queries and sets the column count
for a facet in column space (note it needs not be a leaf facet). E.g.,

[`facet_colcount`](https://pharmaverse.github.io/rtables/reference/facet_colcount.md)`(``tbl3``, `[`c`](https://rdrr.io/r/base/c.html)`(``"ARM"``, ``"C: Combination"``)``)`` ``# [1] 132`

[`facet_colcount`](https://pharmaverse.github.io/rtables/reference/facet_colcount.md)`(``tbl3``, `[`c`](https://rdrr.io/r/base/c.html)`(``"ARM"``, ``"C: Combination"``)``)`` ``<-`` ``75`` ``tbl3`` ``# A: Drug X B: Placebo C: Combination `` ``# (N=134) (N=134) (N=75) `` ``# F M F M F M `` ``# ————————————————————————————————————————————————————————`` ``# Mean 32.76 35.57 34.12 37.44 35.20 35.38`

For convenience (primarily because it was needed internally), we also
provide `rm_all_colcounts` which sets *all* column counts for a
particular table to `NA` at all levels of nesting. We do not expect this
to be particularly useful to end-users.

#### Setting Col Count Visibility

Typically we do not set column count visibility individually. \*This is
due to a constraint where direct leaf siblings (e.g. F and M under one
of the arms in our layout) must have the same visibility for their
column counts in order for the rendering machinery to work.

Instead, we can reset the column count visibility of groups of siblings
via the `facet_colcounts_visible` (note the ‘s’) setter. This function
accepts a path which ends in the name associated with a splitting
instruction in the layout (e.g., `c("ARM")`,
`c("ARM", "B: Placebo", "SEX")`, etc) and *resets the visibility of all
direct children of that path*.

`facet_colcounts_visible``(``tbl3``, `[`c`](https://rdrr.io/r/base/c.html)`(``"ARM"``, ``"A: Drug X"``, ``"SEX"``)``)`` ``<-`` ``TRUE`` ``tbl3`` ``# A: Drug X `` ``# (N=134) B: Placebo C: Combination `` ``# F M (N=134) (N=75) `` ``# (N=79) (N=51) F M F M `` ``# ——————————————————————————————————————————————————————————`` ``# Mean 32.76 35.57 34.12 37.44 35.20 35.38`

**NOTE** as we can see here, the visibility of column counts can have an
“unbalanced design”, provided the direct-siblings agreeing constraint is
met. This leads to things not lining up directly as one might expect (it
does not generate any blank spaces the way setting a visible column
count to `NA` does).

Currently paths with `"*"` in them do not work within
`facet_colcounts_visible`, but that capability is likely to be added in
future releases.

`colcount_visible` getters and setters do also exist which retrieve and
set individual column counts’ visibilities, but these are largely an
internal detail and in virtually all cases end users should avoid
calling them directly.

`## BEWARE, the following is expected to show error`` ``tbl4`` ``<-`` ``tbl3`` `[`colcount_visible`](https://pharmaverse.github.io/rtables/reference/colcount_visible.md)`(``tbl4``, `[`c`](https://rdrr.io/r/base/c.html)`(``"ARM"``, ``"A: Drug X"``, ``"SEX"``, ``"F"``)``)`` ``<-`` ``FALSE`` ``tbl4`` `` ``# Expected Error message`` ``# Error in h(simpleError(msg, call)) :`` ``# error in evaluating the argument 'x' in selecting a method for function 'toString':`` ``# Detected different colcount visibility among sibling facets (those arising from the`` ``# same split_cols_by* layout instruction). This is not supported.`` ``# Set count values to NA if you want a blank space to appear as the displayed count for particular facets.`` ``# First disagreement occured at paths:`` ``# ARM[A: Drug X]->SEX[F]`` ``# ARM[A: Drug X]->SEX[M]`

Note currently this restriction is currently only enforced for leaf
columns due to technical implementation details but how a table renders
should be considered undefined behavior when it contains a group of
sibling column facets arising from the same layout instruction whose
column count visibilities disagree. That may become an error in future
versions without warning.

#### Advanced Settings

By using
[`make_col_df()`](https://pharmaverse.github.io/rtables/reference/make_col_df.md)
we can see the full path to any column count. One example application is
to add a `NA` value that would print to the default value is `""`, that
will show nothing. To change (for now uniformly only) the output string
in case of missing values in the column counts you can use
`colcount_na_str`:

`coldf`` ``<-`` `[`make_col_df`](https://pharmaverse.github.io/rtables/reference/make_col_df.md)`(``tbl3``)`` `[`facet_colcount`](https://pharmaverse.github.io/rtables/reference/facet_colcount.md)`(``tbl3``, ``coldf``$``path``[[``1``]``]``[`[`c`](https://rdrr.io/r/base/c.html)`(``1``, ``2``)``]``)`` ``<-`` ``NA_integer_`` `[`print`](https://rdrr.io/r/base/print.html)`(``tbl3``)`` ``# Keeps the missing space`` ``# A: Drug X `` ``# B: Placebo C: Combination `` ``# F M (N=134) (N=75) `` ``# (N=79) (N=51) F M F M `` ``# ——————————————————————————————————————————————————————————`` ``# Mean 32.76 35.57 34.12 37.44 35.20 35.38`` `[`colcount_na_str`](https://pharmaverse.github.io/rtables/reference/int_methods.md)`(``tbl3``)`` ``<-`` ``"NaN"`` ``tbl3`` ``# Shows NaN`` ``# A: Drug X `` ``# NaN B: Placebo C: Combination `` ``# F M (N=134) (N=75) `` ``# (N=79) (N=51) F M F M `` ``# ——————————————————————————————————————————————————————————`` ``# Mean 32.76 35.57 34.12 37.44 35.20 35.38`
