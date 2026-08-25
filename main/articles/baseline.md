# Comparing Against Baselines or Control

## Introduction

Often the data from one column is considered the
reference/baseline/comparison group and is compared to the data from the
other columns.

For example, lets calculate the average age:

[`library`](https://rdrr.io/r/base/library.html)`(`[`rtables`](https://github.com/pharmaverse/rtables)`)`` `` ``lyt`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`` `` `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"ARM"``)`` ``|>`` `` `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``)`` `` ``tbl`` ``<-`` `[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt``, ``DM``)`` ``tbl`

    #        A: Drug X   B: Placebo   C: Combination
    # ——————————————————————————————————————————————
    # Mean     34.91       33.02          34.57

and then the difference of the average `AGE` between the placebo arm and
the other arms:

`lyt2`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`` `` `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"ARM"``, ref_group ``=`` ``"B: Placebo"``)`` ``|>`` `` `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``, afun ``=`` ``function``(``x``, ``.ref_group``)`` ``{`` `` `[`in_rows`](https://pharmaverse.github.io/rtables/reference/in_rows.md)`(`` `` ``"Difference of Averages"`` ``=`` `[`rcell`](https://pharmaverse.github.io/rtables/reference/rcell.md)`(`[`mean`](https://rdrr.io/r/base/mean.html)`(``x``)`` ``-`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``.ref_group``)``, format ``=`` ``"xx.xx"``)`` `` ``)`` `` ``}``)`` `` ``tbl2`` ``<-`` `[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt2``, ``DM``)`` ``tbl2`

    #                          A: Drug X   B: Placebo   C: Combination
    # ————————————————————————————————————————————————————————————————
    # Difference of Averages     1.89         0.00           1.55

Note that the column order has changed and the reference group is
displayed in the first column.

In cases where we want cells to be blank in the reference column, (e.g.,
“B: Placebo”) we use
[`non_ref_rcell()`](https://pharmaverse.github.io/rtables/reference/rcell.md)
instead of
[`rcell()`](https://pharmaverse.github.io/rtables/reference/rcell.md),
and pass `.in_ref_col` as the second argument:

`lyt3`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`` `` `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"ARM"``, ref_group ``=`` ``"B: Placebo"``)`` ``|>`` `` `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(`` `` ``"AGE"``,`` `` afun ``=`` ``function``(``x``, ``.ref_group``, ``.in_ref_col``)`` ``{`` `` `[`in_rows`](https://pharmaverse.github.io/rtables/reference/in_rows.md)`(`` `` ``"Difference of Averages"`` ``=`` `[`non_ref_rcell`](https://pharmaverse.github.io/rtables/reference/rcell.md)`(`[`mean`](https://rdrr.io/r/base/mean.html)`(``x``)`` ``-`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``.ref_group``)``, is_ref ``=`` ``.in_ref_col``, format ``=`` ``"xx.xx"``)`` `` ``)`` `` ``}`` `` ``)`` `` ``tbl3`` ``<-`` `[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt3``, ``DM``)`` ``tbl3`

    #                          A: Drug X   B: Placebo   C: Combination
    # ————————————————————————————————————————————————————————————————
    # Difference of Averages     1.89                        1.55

`lyt4`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`` `` `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"ARM"``, ref_group ``=`` ``"B: Placebo"``)`` ``|>`` `` `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(`` `` ``"AGE"``,`` `` afun ``=`` ``function``(``x``, ``.ref_group``, ``.in_ref_col``)`` ``{`` `` `[`in_rows`](https://pharmaverse.github.io/rtables/reference/in_rows.md)`(`` `` ``"Difference of Averages"`` ``=`` `[`non_ref_rcell`](https://pharmaverse.github.io/rtables/reference/rcell.md)`(`[`mean`](https://rdrr.io/r/base/mean.html)`(``x``)`` ``-`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``.ref_group``)``, is_ref ``=`` ``.in_ref_col``, format ``=`` ``"xx.xx"``)``,`` `` ``"another row"`` ``=`` `[`non_ref_rcell`](https://pharmaverse.github.io/rtables/reference/rcell.md)`(``"aaa"``, ``.in_ref_col``)`` `` ``)`` `` ``}`` `` ``)`` `` ``tbl4`` ``<-`` `[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt4``, ``DM``)`` ``tbl4`

    #                          A: Drug X   B: Placebo   C: Combination
    # ————————————————————————————————————————————————————————————————
    # Difference of Averages     1.89                        1.55     
    # another row                 aaa                        aaa

You can see which arguments are available for `afun` in the manual for
[`analyze()`](https://pharmaverse.github.io/rtables/reference/analyze.md).

## Row Splitting

When adding row-splitting the reference data may be represented by the
column with or without row splitting. For example:

`lyt5`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``show_colcounts ``=`` ``TRUE``)`` ``|>`` `` `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"ARM"``, ref_group ``=`` ``"B: Placebo"``)`` ``|>`` `` `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"SEX"``, split_fun ``=`` ``drop_split_levels``)`` ``|>`` `` `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``, afun ``=`` ``function``(``x``, ``.ref_group``, ``.ref_full``, ``.in_ref_col``)`` ``{`` `` `[`in_rows`](https://pharmaverse.github.io/rtables/reference/in_rows.md)`(`` `` ``"is reference (.in_ref_col)"`` ``=`` `[`rcell`](https://pharmaverse.github.io/rtables/reference/rcell.md)`(``.in_ref_col``)``,`` `` ``"ref cell N (.ref_group)"`` ``=`` `[`rcell`](https://pharmaverse.github.io/rtables/reference/rcell.md)`(`[`length`](https://rdrr.io/r/base/length.html)`(``.ref_group``)``)``,`` `` ``"ref column N (.ref_full)"`` ``=`` `[`rcell`](https://pharmaverse.github.io/rtables/reference/rcell.md)`(`[`length`](https://rdrr.io/r/base/length.html)`(``.ref_full``)``)`` `` ``)`` `` ``}``)`` `` ``tbl5`` ``<-`` `[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt5``, `[`subset`](https://rdrr.io/r/base/subset.html)`(``DM``, ``SEX`` `[`%in%`](https://rdrr.io/r/base/match.html)` `[`c`](https://rdrr.io/r/base/c.html)`(``"M"``, ``"F"``)``)``)`` ``tbl5`

    #                                A: Drug X   B: Placebo   C: Combination
    #                                 (N=121)     (N=106)        (N=129)    
    # ——————————————————————————————————————————————————————————————————————
    # F                                                                     
    #   is reference (.in_ref_col)     FALSE        TRUE          FALSE     
    #   ref cell N (.ref_group)         56           56             56      
    #   ref column N (.ref_full)        106         106            106      
    # M                                                                     
    #   is reference (.in_ref_col)     FALSE        TRUE          FALSE     
    #   ref cell N (.ref_group)         50           50             50      
    #   ref column N (.ref_full)        106         106            106

The data assigned to `.ref_full` is the full data of the reference
column whereas the data assigned to `.ref_group` respects the subsetting
defined by row-splitting and hence is from the same subset as the
argument `x` or `df` to `afun`.
