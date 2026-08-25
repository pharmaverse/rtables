# Comparison with dplyr Tabulation

## Introduction

In this vignette, we would like to discuss the similarities and
differences between `dplyr` and `rtable`.

Much of the `rtables` framework focuses on tabulation/summarizing of
data and then the visualization of the table. In this vignette, we focus
on summarizing data using `dplyr` and contrast it to `rtables`. We won’t
pay attention to the table visualization/markup and just derive the cell
content.

Using `dplyr` to summarize data and `gt` to visualize the table is a
good way if the tabulation is of a certain nature or complexity.
However, there are tables such as the table created in the
[`introduction`](https://pharmaverse.github.io/rtables/latest-release/articles/rtables.html)
vignette that take some effort to create with `dplyr`. Part of the
effort is due to fact that when using `dplyr` the table data is stored
in `data.frame`s or `tibble`s which is not the most natural way to
represent a table as we will show in this vignette.

If you know a more elegant way of deriving the table content with
`dplyr` please let us know and we will update the vignette.

[`library`](https://rdrr.io/r/base/library.html)`(`[`rtables`](https://github.com/pharmaverse/rtables)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`dplyr`](https://dplyr.tidyverse.org)`)`

Here is the table and data used in the
[`introduction`](https://pharmaverse.github.io/rtables/latest-release/articles/rtables.html)
vignette:

`n`` ``<-`` ``400`` `` `[`set.seed`](https://rdrr.io/r/base/Random.html)`(``1``)`` `` ``df`` ``<-`` `[`tibble`](https://tibble.tidyverse.org/reference/tibble.html)`(`` `` arm ``=`` `[`factor`](https://rdrr.io/r/base/factor.html)`(`[`sample`](https://rdrr.io/r/base/sample.html)`(`[`c`](https://rdrr.io/r/base/c.html)`(``"Arm A"``, ``"Arm B"``)``, ``n``, replace ``=`` ``TRUE``)``, levels ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Arm A"``, ``"Arm B"``)``)``,`` `` country ``=`` `[`factor`](https://rdrr.io/r/base/factor.html)`(`[`sample`](https://rdrr.io/r/base/sample.html)`(`[`c`](https://rdrr.io/r/base/c.html)`(``"CAN"``, ``"USA"``)``, ``n``, replace ``=`` ``TRUE``, prob ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``.55``, ``.45``)``)``, levels ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"CAN"``, ``"USA"``)``)``,`` `` gender ``=`` `[`factor`](https://rdrr.io/r/base/factor.html)`(`[`sample`](https://rdrr.io/r/base/sample.html)`(`[`c`](https://rdrr.io/r/base/c.html)`(``"Female"``, ``"Male"``)``, ``n``, replace ``=`` ``TRUE``)``, levels ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Female"``, ``"Male"``)``)``,`` `` handed ``=`` `[`factor`](https://rdrr.io/r/base/factor.html)`(`[`sample`](https://rdrr.io/r/base/sample.html)`(`[`c`](https://rdrr.io/r/base/c.html)`(``"Left"``, ``"Right"``)``, ``n``, prob ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``.6``, ``.4``)``, replace ``=`` ``TRUE``)``, levels ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Left"``, ``"Right"``)``)``,`` `` age ``=`` `[`rchisq`](https://rdrr.io/r/stats/Chisquare.html)`(``n``, ``30``)`` ``+`` ``10`` ``)`` ``|>`` `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(`` `` weight ``=`` ``35`` ``*`` `[`rnorm`](https://rdrr.io/r/stats/Normal.html)`(``n``, sd ``=`` ``.5``)`` ``+`` `[`ifelse`](https://rdrr.io/r/base/ifelse.html)`(``gender`` ``==`` ``"Female"``, ``140``, ``180``)`` ``)`` `` ``lyt`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``show_colcounts ``=`` ``TRUE``)`` ``|>`` `` `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"arm"``)`` ``|>`` `` `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"gender"``)`` ``|>`` `` `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"country"``)`` ``|>`` `` `[`summarize_row_groups`](https://pharmaverse.github.io/rtables/reference/summarize_row_groups.md)`(``)`` ``|>`` `` `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"handed"``)`` ``|>`` `` `[`summarize_row_groups`](https://pharmaverse.github.io/rtables/reference/summarize_row_groups.md)`(``)`` ``|>`` `` `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"age"``, afun ``=`` ``mean``, format ``=`` ``"xx.x"``)`` `` ``tbl`` ``<-`` `[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt``, ``df``)`` ``tbl`` ``# Arm A Arm B `` ``# Female Male Female Male `` ``# (N=96) (N=105) (N=92) (N=107) `` ``# ————————————————————————————————————————————————————————————`` ``# CAN 45 (46.9%) 64 (61.0%) 46 (50.0%) 62 (57.9%)`` ``# Left 32 (33.3%) 42 (40.0%) 26 (28.3%) 37 (34.6%)`` ``# mean 38.9 40.4 40.3 37.7 `` ``# Right 13 (13.5%) 22 (21.0%) 20 (21.7%) 25 (23.4%)`` ``# mean 36.6 40.2 40.2 40.6 `` ``# USA 51 (53.1%) 41 (39.0%) 46 (50.0%) 45 (42.1%)`` ``# Left 34 (35.4%) 19 (18.1%) 25 (27.2%) 25 (23.4%)`` ``# mean 40.4 39.7 39.2 40.1 `` ``# Right 17 (17.7%) 22 (21.0%) 21 (22.8%) 20 (18.7%)`` ``# mean 36.9 39.8 38.5 39.0`

## Getting Started

We will start by deriving the first data cell on row 3 (note, row 1 and
2 have content cells, see the
[`introduction`](https://pharmaverse.github.io/rtables/latest-release/articles/rtables.html)
vignette). Cell 3,1 contains the mean age for left handed & female
Canadians in “Arm A”:

[`mean`](https://rdrr.io/r/base/mean.html)`(``df``$``age``[``df``$``country`` ``==`` ``"CAN"`` ``&`` ``df``$``arm`` ``==`` ``"Arm A"`` ``&`` ``df``$``gender`` ``==`` ``"Female"`` ``&`` ``df``$``handed`` ``==`` ``"Left"``]``)`` ``# [1] 38.86979`

or with `dplyr`:

`df`` ``|>`` `` `[`filter`](https://dplyr.tidyverse.org/reference/filter.html)`(``country`` ``==`` ``"CAN"``, ``arm`` ``==`` ``"Arm A"``, ``gender`` ``==`` ``"Female"``, ``handed`` ``==`` ``"Left"``)`` ``|>`` `` `[`summarise`](https://dplyr.tidyverse.org/reference/summarise.html)`(``mean_age ``=`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``age``)``)`` ``# ``# A tibble: 1 × 1`` ``# mean_age`` ``# ``<dbl>`` ``# ``1`` 38.9`

Further, `dplyr` gives us other verbs to easily get the average age of
left handed Canadians for each group defined by the 4 columns:

`df`` ``|>`` `` `[`group_by`](https://dplyr.tidyverse.org/reference/group_by.html)`(``arm``, ``gender``)`` ``|>`` `` `[`filter`](https://dplyr.tidyverse.org/reference/filter.html)`(``country`` ``==`` ``"CAN"``, ``handed`` ``==`` ``"Left"``)`` ``|>`` `` `[`summarise`](https://dplyr.tidyverse.org/reference/summarise.html)`(``mean_age ``=`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``age``)``)`` ``` # `summarise()` has regrouped the output. ``` ``# ``ℹ`` Summaries were computed grouped by ``arm`` and ``gender``.`` ``# ``ℹ`` Output is grouped by ``arm``.`` ``# ``ℹ```  Use `summarise(.groups = "drop_last")` to silence this message. ``` ``# ``ℹ```  Use `summarise(.by = c(arm, gender))` for per-operation grouping ``` ``` # (`?dplyr::dplyr_by`) instead. ``` ``# ``# A tibble: 4 × 3`` ``# ``# Groups: arm [2]`` ``# arm gender mean_age`` ``# ``<fct>`` ``<fct>`` ``<dbl>`` ``# ``1`` Arm A Female 38.9`` ``# ``2`` Arm A Male 40.4`` ``# ``3`` Arm B Female 40.3`` ``# ``4`` Arm B Male 37.7`

We can further get to all the average age cell values with:

`average_age`` ``<-`` ``df`` ``|>`` `` `[`group_by`](https://dplyr.tidyverse.org/reference/group_by.html)`(``arm``, ``gender``, ``country``, ``handed``)`` ``|>`` `` `[`summarise`](https://dplyr.tidyverse.org/reference/summarise.html)`(``mean_age ``=`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``age``)``)`` ``` # `summarise()` has regrouped the output. ``` ``# ``ℹ`` Summaries were computed grouped by ``arm``, ``gender``, ``country``, and ``handed``.`` ``# ``ℹ`` Output is grouped by ``arm``, ``gender``, and ``country``.`` ``# ``ℹ```  Use `summarise(.groups = "drop_last")` to silence this message. ``` ``# ``ℹ```  Use `summarise(.by = c(arm, gender, country, handed))` for per-operation ``` ``` # grouping (`?dplyr::dplyr_by`) instead. ``` `` ``average_age`` ``# ``# A tibble: 16 × 5`` ``# ``# Groups: arm, gender, country [8]`` ``# arm gender country handed mean_age`` ``# ``<fct>`` ``<fct>`` ``<fct>`` ``<fct>`` ``<dbl>`` ``# `` 1`` Arm A Female CAN Left 38.9`` ``# `` 2`` Arm A Female CAN Right 36.6`` ``# `` 3`` Arm A Female USA Left 40.4`` ``# `` 4`` Arm A Female USA Right 36.9`` ``# `` 5`` Arm A Male CAN Left 40.4`` ``# `` 6`` Arm A Male CAN Right 40.2`` ``# `` 7`` Arm A Male USA Left 39.7`` ``# `` 8`` Arm A Male USA Right 39.8`` ``# `` 9`` Arm B Female CAN Left 40.3`` ``# ``10`` Arm B Female CAN Right 40.2`` ``# ``11`` Arm B Female USA Left 39.2`` ``# ``12`` Arm B Female USA Right 38.5`` ``# ``13`` Arm B Male CAN Left 37.7`` ``# ``14`` Arm B Male CAN Right 40.6`` ``# ``15`` Arm B Male USA Left 40.1`` ``# ``16`` Arm B Male USA Right 39.0`

In `rtable` syntax, we need the following code to get to the same
content:

`lyt`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`` `` `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"arm"``)`` ``|>`` `` `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"gender"``)`` ``|>`` `` `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"country"``)`` ``|>`` `` `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"handed"``)`` ``|>`` `` `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"age"``, afun ``=`` ``mean``, format ``=`` ``"xx.x"``)`` `` ``tbl`` ``<-`` `[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt``, ``df``)`` ``tbl`` ``# Arm A Arm B `` ``# Female Male Female Male`` ``# ————————————————————————————————————————`` ``# CAN `` ``# Left `` ``# mean 38.9 40.4 40.3 37.7`` ``# Right `` ``# mean 36.6 40.2 40.2 40.6`` ``# USA `` ``# Left `` ``# mean 40.4 39.7 39.2 40.1`` ``# Right `` ``# mean 36.9 39.8 38.5 39.0`

As mentioned in the introduction to this vignette, please ignore the
difference in arranging and formatting the data: it’s possible to
condense the `rtable` more and it is possible to make the `tibble` look
more like the reference table using the `gt` R package.

In terms of tabulation for this example there was arguably not much
added by `rtables` over `dplyr`.

## Content Information

Unlike in `rtables` the different levels of summarization are discrete
computations in `dplyr` which we will then need to combine

We first focus on the count and percentage information for handedness
within each country (for each arm-gender pair), along with the analysis
row mean values:

`c_h_df`` ``<-`` ``df`` ``|>`` `` `[`group_by`](https://dplyr.tidyverse.org/reference/group_by.html)`(``arm``, ``gender``, ``country``, ``handed``)`` ``|>`` `` `[`summarize`](https://dplyr.tidyverse.org/reference/summarise.html)`(``mean ``=`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``age``)``, c_h_count ``=`` `[`n`](https://dplyr.tidyverse.org/reference/context.html)`(``)``)`` ``|>`` `` ``## we need the sum below to *not* be by country, so that we're dividing by the column counts`` `` `[`ungroup`](https://dplyr.tidyverse.org/reference/group_by.html)`(``country``)`` ``|>`` `` ``` # now the `handed` grouping has been removed, therefore we can calculate percent now: ``` `` `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(``n_col ``=`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``c_h_count``)``, c_h_percent ``=`` ``c_h_count`` ``/`` ``n_col``)`` ``` # `summarise()` has regrouped the output. ``` ``# ``ℹ`` Summaries were computed grouped by ``arm``, ``gender``, ``country``, and ``handed``.`` ``# ``ℹ`` Output is grouped by ``arm``, ``gender``, and ``country``.`` ``# ``ℹ```  Use `summarise(.groups = "drop_last")` to silence this message. ``` ``# ``ℹ```  Use `summarise(.by = c(arm, gender, country, handed))` for per-operation ``` ``` # grouping (`?dplyr::dplyr_by`) instead. ``` ``c_h_df`` ``# ``# A tibble: 16 × 8`` ``# ``# Groups: arm, gender [4]`` ``# arm gender country handed mean c_h_count n_col c_h_percent`` ``# ``<fct>`` ``<fct>`` ``<fct>`` ``<fct>`` ``<dbl>`` ``<int>`` ``<int>`` ``<dbl>`` ``# `` 1`` Arm A Female CAN Left 38.9 32 96 0.333`` ``# `` 2`` Arm A Female CAN Right 36.6 13 96 0.135`` ``# `` 3`` Arm A Female USA Left 40.4 34 96 0.354`` ``# `` 4`` Arm A Female USA Right 36.9 17 96 0.177`` ``# `` 5`` Arm A Male CAN Left 40.4 42 105 0.4 `` ``# `` 6`` Arm A Male CAN Right 40.2 22 105 0.210`` ``# `` 7`` Arm A Male USA Left 39.7 19 105 0.181`` ``# `` 8`` Arm A Male USA Right 39.8 22 105 0.210`` ``# `` 9`` Arm B Female CAN Left 40.3 26 92 0.283`` ``# ``10`` Arm B Female CAN Right 40.2 20 92 0.217`` ``# ``11`` Arm B Female USA Left 39.2 25 92 0.272`` ``# ``12`` Arm B Female USA Right 38.5 21 92 0.228`` ``# ``13`` Arm B Male CAN Left 37.7 37 107 0.346`` ``# ``14`` Arm B Male CAN Right 40.6 25 107 0.234`` ``# ``15`` Arm B Male USA Left 40.1 25 107 0.234`` ``# ``16`` Arm B Male USA Right 39.0 20 107 0.187`

which has 16 rows (cells) like the `average_age` data frame defined
above. Next, we will derive the group information for countries:

`c_df`` ``<-`` ``df`` ``|>`` `` `[`group_by`](https://dplyr.tidyverse.org/reference/group_by.html)`(``arm``, ``gender``, ``country``)`` ``|>`` `` `[`summarize`](https://dplyr.tidyverse.org/reference/summarise.html)`(``c_count ``=`` `[`n`](https://dplyr.tidyverse.org/reference/context.html)`(``)``)`` ``|>`` `` ``` # now the `handed` grouping has been removed, therefore we can calculate percent now: ``` `` `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(``n_col ``=`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``c_count``)``, c_percent ``=`` ``c_count`` ``/`` ``n_col``)`` ``` # `summarise()` has regrouped the output. ``` ``# ``ℹ`` Summaries were computed grouped by ``arm``, ``gender``, and ``country``.`` ``# ``ℹ`` Output is grouped by ``arm`` and ``gender``.`` ``# ``ℹ```  Use `summarise(.groups = "drop_last")` to silence this message. ``` ``# ``ℹ```  Use `summarise(.by = c(arm, gender, country))` for per-operation grouping ``` ``` # (`?dplyr::dplyr_by`) instead. ``` ``c_df`` ``# ``# A tibble: 8 × 6`` ``# ``# Groups: arm, gender [4]`` ``# arm gender country c_count n_col c_percent`` ``# ``<fct>`` ``<fct>`` ``<fct>`` ``<int>`` ``<int>`` ``<dbl>`` ``# ``1`` Arm A Female CAN 45 96 0.469`` ``# ``2`` Arm A Female USA 51 96 0.531`` ``# ``3`` Arm A Male CAN 64 105 0.610`` ``# ``4`` Arm A Male USA 41 105 0.390`` ``# ``5`` Arm B Female CAN 46 92 0.5 `` ``# ``6`` Arm B Female USA 46 92 0.5 `` ``# ``7`` Arm B Male CAN 62 107 0.579`` ``# ``8`` Arm B Male USA 45 107 0.421`

Finally, we
[`left_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html)
the two levels of summary to get a data.frame containing the full set of
values which make up the body of our table (note, however, they are not
in the same order):

`full_dplyr`` ``<-`` `[`left_join`](https://dplyr.tidyverse.org/reference/mutate-joins.html)`(``c_h_df``, ``c_df``)`` ``|>`` `[`ungroup`](https://dplyr.tidyverse.org/reference/group_by.html)`(``)`` ``` # Joining with `by = join_by(arm, gender, country, n_col)` ``

Alternatively, we could calculate only the counts in `c_h_df`, and use
[`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html) after
the
[`left_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html)
to divide the counts by the `n_col` values which are more naturally
calculated within `c_df`. This would simplify `c_h_df`’s creation
somewhat by not requiring the explicit
[`ungroup()`](https://dplyr.tidyverse.org/reference/group_by.html), but
it prevents each level of summarization from being a self-contained set
of computations.

The `rtables` call in contrast is:

`lyt`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``show_colcounts ``=`` ``TRUE``)`` ``|>`` `` `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"arm"``)`` ``|>`` `` `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"gender"``)`` ``|>`` `` `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"country"``)`` ``|>`` `` `[`summarize_row_groups`](https://pharmaverse.github.io/rtables/reference/summarize_row_groups.md)`(``)`` ``|>`` `` `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"handed"``)`` ``|>`` `` `[`summarize_row_groups`](https://pharmaverse.github.io/rtables/reference/summarize_row_groups.md)`(``)`` ``|>`` `` `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"age"``, afun ``=`` ``mean``, format ``=`` ``"xx.x"``)`` `` ``tbl`` ``<-`` `[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt``, ``df``)`` ``tbl`` ``# Arm A Arm B `` ``# Female Male Female Male `` ``# (N=96) (N=105) (N=92) (N=107) `` ``# ————————————————————————————————————————————————————————————`` ``# CAN 45 (46.9%) 64 (61.0%) 46 (50.0%) 62 (57.9%)`` ``# Left 32 (33.3%) 42 (40.0%) 26 (28.3%) 37 (34.6%)`` ``# mean 38.9 40.4 40.3 37.7 `` ``# Right 13 (13.5%) 22 (21.0%) 20 (21.7%) 25 (23.4%)`` ``# mean 36.6 40.2 40.2 40.6 `` ``# USA 51 (53.1%) 41 (39.0%) 46 (50.0%) 45 (42.1%)`` ``# Left 34 (35.4%) 19 (18.1%) 25 (27.2%) 25 (23.4%)`` ``# mean 40.4 39.7 39.2 40.1 `` ``# Right 17 (17.7%) 22 (21.0%) 21 (22.8%) 20 (18.7%)`` ``# mean 36.9 39.8 38.5 39.0`

We can now spot check that the values are the same

`frm_rtables_h`` ``<-`` `[`cell_values`](https://pharmaverse.github.io/rtables/reference/cell_values.md)`(`` `` ``tbl``,`` `` rowpath ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"country"``, ``"CAN"``, ``"handed"``, ``"Right"``, ``"@content"``)``,`` `` colpath ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"arm"``, ``"Arm B"``, ``"gender"``, ``"Female"``)`` ``)``[[``1``]``]`` ``frm_rtables_h`` ``# [1] 20.0000000 0.2173913`` `` ``frm_dplyr_h`` ``<-`` ``full_dplyr`` ``|>`` `` `[`filter`](https://dplyr.tidyverse.org/reference/filter.html)`(``country`` ``==`` ``"CAN"`` ``&`` ``handed`` ``==`` ``"Right"`` ``&`` ``arm`` ``==`` ``"Arm B"`` ``&`` ``gender`` ``==`` ``"Female"``)`` ``|>`` `` `[`select`](https://dplyr.tidyverse.org/reference/select.html)`(``c_h_count``, ``c_h_percent``)`` `` ``frm_dplyr_h`` ``# ``# A tibble: 1 × 2`` ``# c_h_count c_h_percent`` ``# ``<int>`` ``<dbl>`` ``# ``1`` 20 0.217`` `` `` ``frm_rtables_c`` ``<-`` `[`cell_values`](https://pharmaverse.github.io/rtables/reference/cell_values.md)`(`` `` ``tbl``,`` `` rowpath ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"country"``, ``"CAN"``, ``"@content"``)``,`` `` colpath ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"arm"``, ``"Arm A"``, ``"gender"``, ``"Male"``)`` ``)``[[``1``]``]`` `` ``frm_rtables_c`` ``# [1] 64.0000000 0.6095238`` `` ``frm_dplyr_c`` ``<-`` ``full_dplyr`` ``|>`` `` `[`filter`](https://dplyr.tidyverse.org/reference/filter.html)`(``country`` ``==`` ``"CAN"`` ``&`` ``arm`` ``==`` ``"Arm A"`` ``&`` ``gender`` ``==`` ``"Male"``)`` ``|>`` `` `[`select`](https://dplyr.tidyverse.org/reference/select.html)`(``c_count``, ``c_percent``)`` `` ``frm_dplyr_c`` ``# ``# A tibble: 2 × 2`` ``# c_count c_percent`` ``# ``<int>`` ``<dbl>`` ``# ``1`` 64 0.610`` ``# ``2`` 64 0.610`

Further, the `rtable` syntax has hopefully also become a bit more
straightforward to derive the cell values than with `dplyr` for this
particular table.

## Summary

In this vignette learned that:

- many tables are quite easily created with `dplyr` and `data.frame` or
  `tibble` as data structure
  - `dplyr` keeps simple things simple
- if tables have group summaries then repeating of information is
  required
- `rtables` streamlines the construction of complex tables

We recommend that you continue reading the
[`clinical_trials`](https://pharmaverse.github.io/rtables/latest-tag/articles/clinical_trials.html)
vignette where we create a number of more advanced tables using layouts.
