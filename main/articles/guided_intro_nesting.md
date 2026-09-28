# Introductory \`rtables\` - Facet And Analysis Nesting

## Introduction

`rtables` models data-summarizing tables as *faceted data
visualizations*, analogous to a `ggplot2` plot using `facet_grid` or a
`lattice` plot conditioned on multiple factors.

We saw in the previous section that we use:

- `split_cols_by` to declare *columns*,
- `split_rows_by` to declare *groups of individual rows*,
- `summarize_row_groups` to declare *marginal summary rows* for groups
  of individual rows, and
- `analyze` to declare (sets of) *individual rows*.

Combining a single call each to `split_cols_by`, `split_rows_by` and
`analyze` creates a rectangular table, while adding
`summarize_row_groups` after the `split_rows_by` adds marginal summary
rows for each group.

Often we need tables with more complex structure, whether it is multiple
top-level sections of the table; tables which analyze multiple variables
simultaneously; nested faceting in row structure, column structure, or
both; or combinations of all three of these.

We achieve all of these by leveraging *nesting* of layout instructions.

Throughout this vignette we will use a custom split function
(`keep_2_levels`) for table brevity, defined as follows:

\
`keep_2_levels`` ``<-`` ``function``(``varnm``, ``dat`` ``=`` ``ex_adsl``)`` ``{`\
`  `[`keep_split_levels`](https://pharmaverse.github.io/rtables/reference/split_funcs.md)`(`[`levels`](https://rdrr.io/r/base/levels.html)`(``dat``[[``varnm``]``]``)``[``1``:``2``]``)`\
`}`

## Nesting

*Nesting* is how we talk about *where* a layout instruction fits with
respect to the existing state of the layout. We say an instruction is
*nested within* a preceding faceting instruction (`split_rows_by` or
`split_cols_by`) if the new instruction \*should be applied separately
within each facet generated during tabulation from the previous
instruction. This is analogous to what we see with `facet_*` in
`ggplot2` when we give multiple variables for a single faceting
dimension.

By default, each layout instruction is nested within the directly
preceding layout instruction - if any - in its dimension (row or
column), with a couple caveats we discuss later. We see this default
behavior below:

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`rtables`](https://github.com/pharmaverse/rtables)`)`

    ## Loading required package: formatters

    ## 
    ## Attaching package: 'formatters'

    ## The following object is masked from 'package:base':
    ## 
    ##     %||%

    ## 
    ## Attaching package: 'rtables'

    ## The following object is masked from 'package:utils':
    ## 
    ##     str

\
`lyt`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`\
`  `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"ARM"``)`` ``|>`\
`  `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"STRATA1"``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"SEX"``, split_fun ``=`` ``keep_2_levels``(``"SEX"``)``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"BMRKR2"``, split_fun ``=`` ``keep_2_levels``(``"BMRKR2"``)``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``)`\
[`table_structure`](https://pharmaverse.github.io/rtables/reference/table_structure.md)`(`[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt``, ``ex_adsl``)``)`

    ## [TableTree] SEX
    ##  [TableTree] F
    ##   [TableTree] BMRKR2
    ##    [TableTree] LOW
    ##     [ElementaryTable] AGE (1 x 9)
    ##    [TableTree] MEDIUM
    ##     [ElementaryTable] AGE (1 x 9)
    ##  [TableTree] M
    ##   [TableTree] BMRKR2
    ##    [TableTree] LOW
    ##     [ElementaryTable] AGE (1 x 9)
    ##    [TableTree] MEDIUM
    ##     [ElementaryTable] AGE (1 x 9)

When `analyze` instructions are ‘nested within’ another `analyze`, the
analyses are bundled into a ‘multi-analysis’ parent structure. This
parent structure as a whole, then, has the nesting behavior that a
single `analyze` call would have in its place.

\
`lyt2`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`\
`  `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"ARM"``)`` ``|>`\
`  `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"STRATA1"``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"SEX"``, split_fun ``=`` ``keep_2_levels``(``"SEX"``)``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"BMRKR2"``, split_fun ``=`` ``keep_2_levels``(``"BMRKR2"``)``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"BMRKR1"``)`\
[`table_structure`](https://pharmaverse.github.io/rtables/reference/table_structure.md)`(`[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt2``, ``ex_adsl``)``)`

    ## [TableTree] SEX
    ##  [TableTree] F
    ##   [TableTree] BMRKR2
    ##    [TableTree] LOW
    ##     [ElementaryTable] AGE (1 x 9)
    ##     [ElementaryTable] BMRKR1 (1 x 9)
    ##    [TableTree] MEDIUM
    ##     [ElementaryTable] AGE (1 x 9)
    ##     [ElementaryTable] BMRKR1 (1 x 9)
    ##  [TableTree] M
    ##   [TableTree] BMRKR2
    ##    [TableTree] LOW
    ##     [ElementaryTable] AGE (1 x 9)
    ##     [ElementaryTable] BMRKR1 (1 x 9)
    ##    [TableTree] MEDIUM
    ##     [ElementaryTable] AGE (1 x 9)
    ##     [ElementaryTable] BMRKR1 (1 x 9)

By default:

- `analyze` calls nest within the most recently preceding
  `split_rows_by` or instruction
  - multiple `analyze` calls that nest within the

### Creating ‘Multi-Section’ Tables With `nested = FALSE`

We often want to create tables with rows grouped into two or more
logical or analytical sections. For example we might want to analyze
`AGE` overall, then separately by `SEX` and by `RACE`. We can do this
by:

1.  `analyze`ing `AGE`, then
2.  splitting by `SEX` and `analyze`ing `AGE`, and finally
3.  splitting by `RACE` and `analyze`ing `AGE` again.

We will start each section after the first with `nested = FALSE` to
delineate it from the previous portion of the layout.

NOTE: while we will do it explicitly for illustration purposes, any
`split_rows_by` layout instruction that follows an `analyze` defaults to
`nested = FALSE`.

Thus we can create our table with the code below:

Note: we set a top level section divider to make our different sections
concrete; section dividers will be covered in a later part of this guide
and can be taken as is for now.

\
`trim_adsl`` ``<-`` `[`subset`](https://rdrr.io/r/base/subset.html)`(``ex_adsl``, ``RACE`` `[`%in%`](https://rdrr.io/r/base/match.html)` `[`levels`](https://rdrr.io/r/base/levels.html)`(``ex_adsl``$``RACE``)``[``1``:``3``]`` ``&`` ``SEX`` `[`%in%`](https://rdrr.io/r/base/match.html)` `[`c`](https://rdrr.io/r/base/c.html)`(``"F"``, ``"M"``)``)`\
`trim_adsl``$``RACE`` ``<-`` `[`factor`](https://rdrr.io/r/base/factor.html)`(``trim_adsl``$``RACE``)`\
`trim_adsl``$``SEX`` ``<-`` `[`factor`](https://rdrr.io/r/base/factor.html)`(``trim_adsl``$``SEX``)`\
\
`nice_mean`` ``<-`` ``function``(``x``)`` ``{`\
`  `[`in_rows`](https://pharmaverse.github.io/rtables/reference/in_rows.md)`(``"Average Age"`` ``=`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``x``)``, .formats ``=`` `[`list`](https://rdrr.io/r/base/list.html)`(``"Average Age"`` ``=`` ``"xx.x"``)``)`\
`}`\
\
`lyt3`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``top_level_section_div ``=`` ``"-"``)`` ``|>`\
`  `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"ARM"``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``, afun ``=`` ``nice_mean``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"SEX"``, nested ``=`` ``FALSE``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``, afun ``=`` ``nice_mean``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"RACE"``, nested ``=`` ``FALSE``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``, afun ``=`` ``nice_mean``)`\
\
`tbl3`` ``<-`` `[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt3``, ``trim_adsl``)`\
`tbl3`

    ##                             A: Drug X   B: Placebo   C: Combination
    ## ———————————————————————————————————————————————————————————————————
    ## Average Age                   33.7         35.5           35.3     
    ## -------------------------------------------------------------------
    ## F                                                                  
    ##   Average Age                 32.5         34.1           35.1     
    ## M                                                                  
    ##   Average Age                 35.7         37.4           35.6     
    ## -------------------------------------------------------------------
    ## ASIAN                                                              
    ##   Average Age                 32.5         36.7           37.0     
    ## BLACK OR AFRICAN AMERICAN                                          
    ##   Average Age                 34.3         34.9           33.7     
    ## WHITE                                                              
    ##   Average Age                 36.2         33.1           32.0

We see three clear top-level ‘sections’ of our table in row-space, as
desired. Contrast this with our result without `nested = FALSE` (and
with the first two `analyze` calls replaced with `summarize_row_groups`:

\
`nice_mean_cfun`` ``<-`` ``function``(``x``, ``labelstr``)`` ``{`\
`  ``lbl`` ``<-`` `[`paste0`](https://rdrr.io/r/base/paste.html)`(``labelstr``, ``" (Ave. Age)"``)`\
`  `[`in_rows`](https://pharmaverse.github.io/rtables/reference/in_rows.md)`(`[`mean`](https://rdrr.io/r/base/mean.html)`(``x``)``, .labels ``=`` ``lbl``, .formats ``=`` ``"xx.x"``)`\
`}`\
\
`lyt3b`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``top_level_section_div ``=`` ``"-"``)`` ``|>`\
`  `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"ARM"``)`` ``|>`\
`  `[`summarize_row_groups`](https://pharmaverse.github.io/rtables/reference/summarize_row_groups.md)`(``"AGE"``, cfun ``=`` ``nice_mean_cfun``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"SEX"``, split_fun ``=`` ``keep_2_levels``(``"SEX"``)``)`` ``|>`\
`  `[`summarize_row_groups`](https://pharmaverse.github.io/rtables/reference/summarize_row_groups.md)`(``"AGE"``, cfun ``=`` ``nice_mean_cfun``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"RACE"``, split_fun ``=`` ``keep_2_levels``(``"RACE"``)``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``, afun ``=`` ``nice_mean``)`\
\
`tbl3b`` ``<-`` `[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt3b``, ``trim_adsl``)`\
[`head`](https://pharmaverse.github.io/rtables/reference/head_tail.md)`(``tbl3b``)`

    ##                                 A: Drug X   B: Placebo   C: Combination
    ## ———————————————————————————————————————————————————————————————————————
    ##  (Ave. Age)                       33.7         35.5           35.3     
    ##   F (Ave. Age)                    32.5         34.1           35.1     
    ##     ASIAN                                                              
    ##       Average Age                 31.2         35.1           36.4     
    ##     BLACK OR AFRICAN AMERICAN                                          
    ##       Average Age                 34.1         33.9           33.2

Here the faceting on `RACE` occurs *nested within* the faceting on
`SEX`, whereas above it occurs *alongside* it.

#### A Brief Note On Removing Sections

Sometimes we will receive a template script that does more than we want,
but is close to meeting our needs. For example, imagine we wanted the
above table (non-nested version) but only wanted the overall and race
portions, removing the age within gender analysis.

We do this by simply identifying all of the layout instructions
corresponding to that portion of the table and removing them. Our top
level section dividers can help us reason about this, and can be added
to the template if they were not there originally.

In our case, the instructions for our section to remove are the
`split_rows_by("SEX", nested = FALSE)`, and directly following
`analyze("AGE")` calls. By starting with our code above and removing
those, we would get our desired table:

\
`lyt3c`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``top_level_section_div ``=`` ``"-"``)`` ``|>`\
`  `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"ARM"``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``, afun ``=`` ``nice_mean``)`` ``|>`\
`  ``## split_rows_by("SEX", nested = FALSE) |>`\
`  ``## analyze("AGE", afun = nice_mean) |>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"RACE"``, nested ``=`` ``FALSE``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``, afun ``=`` ``nice_mean``)`\
\
`tbl3c`` ``<-`` `[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt3c``, ``trim_adsl``)`\
`tbl3c`

    ##                             A: Drug X   B: Placebo   C: Combination
    ## ———————————————————————————————————————————————————————————————————
    ## Average Age                   33.7         35.5           35.3     
    ## -------------------------------------------------------------------
    ## ASIAN                                                              
    ##   Average Age                 32.5         36.7           37.0     
    ## BLACK OR AFRICAN AMERICAN                                          
    ##   Average Age                 34.3         34.9           33.7     
    ## WHITE                                                              
    ##   Average Age                 36.2         33.1           32.0

When performing this kind of layout pruning in the wild, it is important
to remember that `split_rows_by` calls that follow `analyze` calls
default to `nested = FALSE`, even if that is not made explicit in the
template script you are starting from.

It is also important to not remove all `analyze` call(s) nested within
any series of row faceting (`split_rows_by*` calls), as this will result
in an degenerate (invalidly structured) table which could have undefined
behavior when passed to some other aspects of the `rtables` and
`formatters` APIs.

### Intermediate Nesting

As of `rtables` `0.7.0`, we can declare *intermediate* nesting, rather
than simply full – the previous and now default behavior when
`nested = TRUE` – and no – the `nested = FALSE` behavior – nesting.

We do this via the new `at_sibling` parameter the `split_rows_by*` and
`analyze*` families of layout functions now accept. `at_sibling` allows
us to specify the *nesting anchor* for a row split or analyze directive;
when we do so, the table resulting from our new directive will appear
*as a direct sibling* to that resulting from our anchor in the created
table.

Consider where our `BMRKR2` analysis is placed in when using the
following layouts to build tables:

The default behavior:

\
`lyt4`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`\
`  `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"ARM"``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"STRATA1"``, split_fun ``=`` ``keep_2_levels``(``"STRATA1"``)``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"SEX"``, split_fun ``=`` ``keep_2_levels``(``"SEX"``)``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"BMRKR2"``)`\
\
[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt4``, ``ex_adsl``)`

    ##                A: Drug X   B: Placebo   C: Combination
    ## ——————————————————————————————————————————————————————
    ## A                                                     
    ##   F                                                   
    ##     AGE                                               
    ##       Mean       31.14       32.08          34.22     
    ##     BMRKR2                                            
    ##       LOW          9           7              10      
    ##       MEDIUM       5           11             3       
    ##       HIGH         7           6              5       
    ##   M                                                   
    ##     AGE                                               
    ##       Mean       35.62       39.37          33.55     
    ##     BMRKR2                                            
    ##       LOW          3           8              3       
    ##       MEDIUM       4           6              10      
    ##       HIGH         9           5              7       
    ## B                                                     
    ##   F                                                   
    ##     AGE                                               
    ##       Mean       32.84       35.33          36.57     
    ##     BMRKR2                                            
    ##       LOW          7           6              6       
    ##       MEDIUM       8           16             9       
    ##       HIGH        10           5              6       
    ##   M                                                   
    ##     AGE                                               
    ##       Mean       35.33       37.12          36.05     
    ##     BMRKR2                                            
    ##       LOW         11           7              3       
    ##       MEDIUM       5           6              7       
    ##       HIGH         5           4              11

Anchoring the analysis on `"SEX"`:

\
`lyt4a`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`\
`  `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"ARM"``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"STRATA1"``, split_fun ``=`` ``keep_2_levels``(``"STRATA1"``)``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"SEX"``, split_fun ``=`` ``keep_2_levels``(``"SEX"``)``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"BMRKR2"``, at_sibling ``=`` ``"SEX"``, show_labels ``=`` ``"visible"``)`\
\
[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt4a``, ``ex_adsl``)`

    ##              A: Drug X   B: Placebo   C: Combination
    ## ————————————————————————————————————————————————————
    ## A                                                   
    ##   SEX                                               
    ##     F                                               
    ##       Mean     31.14       32.08          34.22     
    ##     M                                               
    ##       Mean     35.62       39.37          33.55     
    ##   BMRKR2                                            
    ##     LOW         12           16             14      
    ##     MEDIUM      10           17             13      
    ##     HIGH        16           11             13      
    ## B                                                   
    ##   SEX                                               
    ##     F                                               
    ##       Mean     32.84       35.33          36.57     
    ##     M                                               
    ##       Mean     35.33       37.12          36.05     
    ##   BMRKR2                                            
    ##     LOW         19           13             10      
    ##     MEDIUM      13           22             16      
    ##     HIGH        15           10             17

Anchoring the analysis on `"STRATA1"`

\
`lyt4b`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`\
`  `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"ARM"``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"STRATA1"``, split_fun ``=`` ``keep_2_levels``(``"STRATA1"``)``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"SEX"``, split_fun ``=`` ``keep_2_levels``(``"SEX"``)``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"BMRKR2"``, at_sibling ``=`` ``"STRATA1"``, show_labels ``=`` ``"visible"``)`\
\
[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt4b``, ``ex_adsl``)`

    ##            A: Drug X   B: Placebo   C: Combination
    ## ——————————————————————————————————————————————————
    ## A                                                 
    ##   F                                               
    ##     Mean     31.14       32.08          34.22     
    ##   M                                               
    ##     Mean     35.62       39.37          33.55     
    ## B                                                 
    ##   F                                               
    ##     Mean     32.84       35.33          36.57     
    ##   M                                               
    ##     Mean     35.33       37.12          36.05     
    ## BMRKR2                                            
    ##   LOW         50           45             40      
    ##   MEDIUM      37           56             42      
    ##   HIGH        47           33             50

Analysis is fully non-nested:

\
`lyt4c`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`\
`  `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"ARM"``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"STRATA1"``, split_fun ``=`` ``keep_2_levels``(``"STRATA1"``)``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"SEX"``, split_fun ``=`` ``keep_2_levels``(``"SEX"``)``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"BMRKR2"``, nested ``=`` ``FALSE``, show_labels ``=`` ``"visible"``)`\
\
[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt4c``, ``ex_adsl``)`

    ##            A: Drug X   B: Placebo   C: Combination
    ## ——————————————————————————————————————————————————
    ## A                                                 
    ##   F                                               
    ##     Mean     31.14       32.08          34.22     
    ##   M                                               
    ##     Mean     35.62       39.37          33.55     
    ## B                                                 
    ##   F                                               
    ##     Mean     32.84       35.33          36.57     
    ##   M                                               
    ##     Mean     35.33       37.12          36.05     
    ## BMRKR2                                            
    ##   LOW         50           45             40      
    ##   MEDIUM      37           56             42      
    ##   HIGH        47           33             50

Note that because our `STRATA` split is a top-level split, anchoring our
analysis to it is equivalent to simply using `nested = FALSE`. While
these result in identically-rendering tables, they will not if our
current layout is placed under a new split, such as when we want the
same table structure both globally and split by subgroups or parameters:

Anchoring the analysis on `"STRATA1"`

\
`lyt4d`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`\
`  `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"ARM"``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"RACE"``, split_fun ``=`` ``keep_2_levels``(``"RACE"``)``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"STRATA1"``, split_fun ``=`` ``keep_2_levels``(``"STRATA1"``)``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"SEX"``, split_fun ``=`` ``keep_2_levels``(``"SEX"``)``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"BMRKR2"``, at_sibling ``=`` ``"STRATA1"``, show_labels ``=`` ``"visible"``)`\
\
[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt4d``, ``ex_adsl``)`

    ##                             A: Drug X   B: Placebo   C: Combination
    ## ———————————————————————————————————————————————————————————————————
    ## ASIAN                                                              
    ##   STRATA1                                                          
    ##     A                                                              
    ##       F                                                            
    ##         Mean                  29.00       31.07          33.73     
    ##       M                                                            
    ##         Mean                  35.00       40.90          37.00     
    ##     B                                                              
    ##       F                                                            
    ##         Mean                  29.55       38.73          41.45     
    ##       M                                                            
    ##         Mean                  35.33       37.57          36.07     
    ##   BMRKR2                                                           
    ##     LOW                        22           21             18      
    ##     MEDIUM                     17           28             21      
    ##     HIGH                       29           18             34      
    ## BLACK OR AFRICAN AMERICAN                                          
    ##   STRATA1                                                          
    ##     A                                                              
    ##       F                                                            
    ##         Mean                  32.60       32.80          39.33     
    ##       M                                                            
    ##         Mean                  34.00       37.17          30.14     
    ##     B                                                              
    ##       F                                                            
    ##         Mean                  34.33       25.67          27.25     
    ##       M                                                            
    ##         Mean                  34.00       36.50          41.00     
    ##   BMRKR2                                                           
    ##     LOW                        12           9              14      
    ##     MEDIUM                      8           13             10      
    ##     HIGH                       11           6              8

Analysis is fully non-nested:

\
`lyt4c`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`\
`  `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"ARM"``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"RACE"``, split_fun ``=`` ``keep_2_levels``(``"RACE"``)``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"STRATA1"``, split_fun ``=`` ``keep_2_levels``(``"STRATA1"``)``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"SEX"``, split_fun ``=`` ``keep_2_levels``(``"SEX"``)``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"BMRKR2"``, nested ``=`` ``FALSE``, show_labels ``=`` ``"visible"``)`\
\
[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt4c``, ``ex_adsl``)`

    ##                             A: Drug X   B: Placebo   C: Combination
    ## ———————————————————————————————————————————————————————————————————
    ## ASIAN                                                              
    ##   A                                                                
    ##     F                                                              
    ##       Mean                    29.00       31.07          33.73     
    ##     M                                                              
    ##       Mean                    35.00       40.90          37.00     
    ##   B                                                                
    ##     F                                                              
    ##       Mean                    29.55       38.73          41.45     
    ##     M                                                              
    ##       Mean                    35.33       37.57          36.07     
    ## BLACK OR AFRICAN AMERICAN                                          
    ##   A                                                                
    ##     F                                                              
    ##       Mean                    32.60       32.80          39.33     
    ##     M                                                              
    ##       Mean                    34.00       37.17          30.14     
    ##   B                                                                
    ##     F                                                              
    ##       Mean                    34.33       25.67          27.25     
    ##     M                                                              
    ##       Mean                    34.00       36.50          41.00     
    ## BMRKR2                                                             
    ##   LOW                          50           45             40      
    ##   MEDIUM                       37           56             42      
    ##   HIGH                         47           33             50

Thus whether to use explicit anchoring to generate top-level sections is
a trade-off between explicit clarity (`nested = FALSE`) and robustness
to this sort of slotting the described structure into a larger table
(`at_sibling =`).

#### Anchor Resolution

Given a pre-existing layout, only certain elements are eligible to act
as nesting anchors. For clarity, we will use *element* to refer to any
individual layout instruction that effect the resulting table
row-structure (i.e., `split_rows_by*` and `analyze`); furthermore we
will refer to an element named by `at_sibling` as the *anchor point* and
an element placed via `at_sibling` as the *anchored element*. For
convenience we will refer to elements which do not act as anchor points
nor anchored elements as *standard elements*.

Using this terminology, the general rules are as follows:

1.  Elements nested within previous top-level elements are *not
    eligible*,
2.  Elements nested within previous anchor points are *not eligible*,
3.  For each previous anchor point, elements nested within anchored
    elements other than the most recently placed one are *not eligible*.

We can re-frame this into an algorithm to determine the list of eligible
elements like so:

1.  All previous top-level elements,
2.  the current top-level element and all standard elements nested
    directly within it until the first anchor point,
3.  the anchor point and all of its anchored elements,
4.  all standard elements nested within the most recent of this anchor
    point’s anchored elements, until the next anchor point,
5.  repeat (3)-(4) until no more anchor points along the path exist.

Viewed a certain way, this algorithm defines a horizon along the edge of
the branching structure defined by a layout.

To illustrate these rules, and this concept of a horizon, consider the
following illustrative - if analytically nonsensical - complex row
layout:

\
`complex_lyt`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"STRATA1"``, split_fun ``=`` ``keep_2_levels``(``"RACE"``)``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"STRATA2"``, split_fun ``=`` ``keep_2_levels``(``"STRATA2"``)``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"ARM"``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"SEX"``, split_fun ``=`` ``keep_2_levels``(``"SEX"``)``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"RACE"``, split_fun ``=`` ``keep_2_levels``(``"RACE"``)``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"STRATA1"``, split_fun ``=`` ``keep_2_levels``(``"STRATA1"``)``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"BMRKR1"``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"BMRKR2"``, split_fun ``=`` ``keep_2_levels``(``"BMRKR2"``)``, at_sibling ``=`` ``"RACE"``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"COUNTRY"``, split_fun ``=`` ``keep_2_levels``(``"COUNTRY"``)``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"SITEID"``, split_fun ``=`` ``drop_split_levels``, at_sibling ``=`` ``"RACE"``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"BEP01FL"``, split_fun ``=`` ``keep_2_levels``(``"BEP01FL"``)``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``)`

We can get the list of eligible anchor points via `get_anchor_list`:

\
[`get_row_anchor_list`](https://pharmaverse.github.io/rtables/reference/get_anchor_df.md)`(``complex_lyt``)`

    ## [[1]]
    ## [1] "STRATA1"
    ## 
    ## [[2]]
    ## [1] "SEX"
    ## 
    ## [[3]]
    ## [1] "RACE"   "BMRKR2" "SITEID"
    ## 
    ## [[4]]
    ## [1] "BEP01FL"
    ## 
    ## [[5]]
    ## [1] "AGE"

We can see that our first `STRATA1` split is eligible, but the `STRATA2`
split nested within it and the `ARM` analysis nested within that are
not. Then, for the current top-level structure, `SEX`(std element)
`RACE`(anchor pt), `BMRKR2` (anchored element), `SITEID` (anchored
element), `BEP01FL` (std element), and `AGE` (std element) are eligible.

#### Order Of Intermediate Nesting Placement

The rules above imply a particular order required to place
intermediately nested elements anchored to different points within the
same top-level structure:

*When you intend to anchor multiple points to different elements in a
sequence of splits, place them in order from most deeply nested anchor
point to least deeply nested anchor point.*

We can see this in practice, consider the following sequence of
splitting layout instructions (ending, as always, with an `analyze`):

\
`lyt_stack`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"STRATA1"``, split_fun ``=`` ``keep_2_levels``(``"STRATA1"``)``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"STRATA2"``, split_fun ``=`` ``keep_2_levels``(``"STRATA2"``)``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"RACE"``, split_fun ``=`` ``keep_2_levels``(``"RACE"``)``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"SEX"``, split_fun ``=`` ``keep_2_levels``(``"SEX"``)``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``)`

Now suppose we want to place additional `analyze`’s as siblings to the
`STRATA2` and `RACE` splits.

If we do so in that order, our first placement will work:

\
`lyt_stack2`` ``<-`` ``lyt_stack`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"BMRKR1"``, at_sibling ``=`` ``"STRATA2"``)`

But we will get an error when attempting to anchor another `analyze`
onto `RACE`:

\
`lyt_stack2`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"BMRKR2"``, at_sibling ``=`` ``"RACE"``)`

    ## Error in `find_branch_pos_df()`:
    ## ! Unable to find structural element 'RACE' to add siblings for.
    ## Eligible elements: 'STRATA1', 'STRATA2', 'BMRKR1'

If, however, we anchor our `BMRKR2` analyze to `RACE` *first*, and then
place our `BMRKR1` analyze to `STRATA2`, we can achieve both placements:

\
`lyt_stack3`` ``<-`` ``lyt_stack`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"BMRKR2"``, at_sibling ``=`` ``"RACE"``, show_labels ``=`` ``"visible"``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"BMRKR1"``, at_sibling ``=`` ``"STRATA2"``, show_labels ``=`` ``"visible"``)`

Thus we can build the (somewhat lengthy) desired table:

\
[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt_stack3``, ``ex_adsl``)`

    ##                                     all obs
    ## ———————————————————————————————————————————
    ## A                                          
    ##   STRATA2                                  
    ##     S1                                     
    ##       RACE                                 
    ##         ASIAN                              
    ##           F                                
    ##             Mean                     31.48 
    ##           M                                
    ##             Mean                     39.38 
    ##         BLACK OR AFRICAN AMERICAN          
    ##           F                                
    ##             Mean                     38.50 
    ##           M                                
    ##             Mean                     33.00 
    ##       BMRKR2                               
    ##         LOW                           23   
    ##         MEDIUM                        19   
    ##         HIGH                          12   
    ##     S2                                     
    ##       RACE                                 
    ##         ASIAN                              
    ##           F                                
    ##             Mean                     30.73 
    ##           M                                
    ##             Mean                     36.14 
    ##         BLACK OR AFRICAN AMERICAN          
    ##           F                                
    ##             Mean                     33.45 
    ##           M                                
    ##             Mean                     33.70 
    ##       BMRKR2                               
    ##         LOW                           19   
    ##         MEDIUM                        21   
    ##         HIGH                          28   
    ##   BMRKR1                                   
    ##     Mean                             5.44  
    ## B                                          
    ##   STRATA2                                  
    ##     S1                                     
    ##       RACE                                 
    ##         ASIAN                              
    ##           F                                
    ##             Mean                     35.61 
    ##           M                                
    ##             Mean                     35.92 
    ##         BLACK OR AFRICAN AMERICAN          
    ##           F                                
    ##             Mean                     32.80 
    ##           M                                
    ##             Mean                     36.50 
    ##       BMRKR2                               
    ##         LOW                           23   
    ##         MEDIUM                        21   
    ##         HIGH                          21   
    ##     S2                                     
    ##       RACE                                 
    ##         ASIAN                              
    ##           F                                
    ##             Mean                     37.95 
    ##           M                                
    ##             Mean                     36.39 
    ##         BLACK OR AFRICAN AMERICAN          
    ##           F                                
    ##             Mean                     28.50 
    ##           M                                
    ##             Mean                     37.60 
    ##       BMRKR2                               
    ##         LOW                           19   
    ##         MEDIUM                        30   
    ##         HIGH                          21   
    ##   BMRKR1                                   
    ##     Mean                             5.85

Phrased a different way, placing an anchored element at an anchor point
diverts the stream of eligible nested elements after that point from
those nested within the anchor point, or previously placed anchored
elements, to those nested within the newly placed anchored element.

We can consider the current state to help us visualize the eligible
anchor points by printing our current layout:

\
`lyt_stack`

    ## A Pre-data Table Layout
    ## 
    ## Column-Split Structure:
    ## <implicit> (all obs)
    ## 
    ## Row-Split Structure:
    ## STRATA1 (lvls) -> STRATA2 (lvls) -> RACE (lvls) -> SEX (lvls) -> AGE (** var **)
    ## 
    ## '->' indicates nesting, vertical stacks of '|' indicate anchoring/siblings.
    ## '(<type>)' indicates split type, while '(** <type> **)' indicates an analyze instruction.

## Designing Multi-Section Row-Layouts To Support Subgroup Variants

In setting with standardized table outputs, we commonly want both
all-patient and split-by-subgroups variants of a given core table
structure. Intermediate nesting allows us to develop layouts with this
in mind as we will see in this section.

Consider a table layout with multiple sections in row space, e.g., an
overall analysis, an analysis split by `RACE` and the same analysis
split by `SEX`:

\
`lyt`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`\
`  `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"ARM"``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"RACE"``, split_fun ``=`` ``keep_2_levels``(``"RACE"``)``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"SEX"``, split_fun ``=`` ``keep_2_levels``(``"SEX"``)``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``)`\
\
[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt``, ``ex_adsl``)`

    ##                             A: Drug X   B: Placebo   C: Combination
    ## ———————————————————————————————————————————————————————————————————
    ## Mean                          33.77       35.43          35.43     
    ## ASIAN                                                              
    ##   Mean                        32.53       36.66          36.92     
    ## BLACK OR AFRICAN AMERICAN                                          
    ##   Mean                        34.06       34.93          34.56     
    ## F                                                                  
    ##   Mean                        32.76       34.12          35.20     
    ## M                                                                  
    ##   Mean                        35.57       37.44          35.38

Now supposing we want the same structure for each strata in our sample,
if we apply `split_rows_by("STRATA1")` as the first row instruction, we
do not get the desired table, because each `split_rows_by` that follows
an `analyze` is `nested = FALSE` by default, bringing it all the way to
the top level, ie.e, outside of our new strata splitting:

\
`lyt2`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`\
`  `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"ARM"``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"STRATA1"``, split_fun ``=`` ``keep_2_levels``(``"STRATA1"``)``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"RACE"``, split_fun ``=`` ``keep_2_levels``(``"RACE"``)``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"SEX"``, split_fun ``=`` ``keep_2_levels``(``"SEX"``)``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``)`\
\
[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt2``, ``ex_adsl``)`

    ##                             A: Drug X   B: Placebo   C: Combination
    ## ———————————————————————————————————————————————————————————————————
    ## A                                                                  
    ##   Mean                        33.08       35.11          34.23     
    ## B                                                                  
    ##   Mean                        33.85       36.00          36.33     
    ## ASIAN                                                              
    ##   Mean                        32.53       36.66          36.92     
    ## BLACK OR AFRICAN AMERICAN                                          
    ##   Mean                        34.06       34.93          34.56     
    ## F                                                                  
    ##   Mean                        32.76       34.12          35.20     
    ## M                                                                  
    ##   Mean                        35.57       37.44          35.38

This is not a subgroup variant of our table.

If we anchor those `split_rows_by` (each of which essentially starts a
new section of the layout in row space) to our overall `AGE` analyze
call, we will get the same table for the full variant:

\
`lyt_good`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`\
`  `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"ARM"``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"RACE"``,`\
`    split_fun ``=`` ``keep_2_levels``(``"RACE"``)``,`\
`    at_sibling ``=`` ``"AGE"`\
`  ``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"SEX"``,`\
`    split_fun ``=`` ``keep_2_levels``(``"SEX"``)``,`\
`    at_sibling ``=`` ``"AGE"`\
`  ``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``)`\
\
[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt_good``, ``ex_adsl``)`

    ##                               A: Drug X   B: Placebo   C: Combination
    ## —————————————————————————————————————————————————————————————————————
    ## Mean                            33.77       35.43          35.43     
    ## RACE                                                                 
    ##   ASIAN                                                              
    ##     Mean                        32.53       36.66          36.92     
    ##   BLACK OR AFRICAN AMERICAN                                          
    ##     Mean                        34.06       34.93          34.56     
    ## SEX                                                                  
    ##   F                                                                  
    ##     Mean                        32.76       34.12          35.20     
    ##   M                                                                  
    ##     Mean                        35.57       37.44          35.38

Crucially, however, when we prepend a new row splitting instruction to
the sequence of row layout instructions, we immediately get our desired
subgroup variant with no extra effort required:

\
`lyt_good_subgrp`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`\
`  `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"ARM"``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"STRATA1"``, split_fun ``=`` ``keep_2_levels``(``"STRATA1"``)``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"RACE"``,`\
`    split_fun ``=`` ``keep_2_levels``(``"RACE"``)``,`\
`    at_sibling ``=`` ``"AGE"`\
`  ``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``)`` ``|>`\
`  `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"SEX"``,`\
`    split_fun ``=`` ``keep_2_levels``(``"SEX"``)``,`\
`    at_sibling ``=`` ``"AGE"`\
`  ``)`` ``|>`\
`  `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``)`\
\
[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt_good``, ``ex_adsl``)`

    ##                               A: Drug X   B: Placebo   C: Combination
    ## —————————————————————————————————————————————————————————————————————
    ## Mean                            33.77       35.43          35.43     
    ## RACE                                                                 
    ##   ASIAN                                                              
    ##     Mean                        32.53       36.66          36.92     
    ##   BLACK OR AFRICAN AMERICAN                                          
    ##     Mean                        34.06       34.93          34.56     
    ## SEX                                                                  
    ##   F                                                                  
    ##     Mean                        32.76       34.12          35.20     
    ##   M                                                                  
    ##     Mean                        35.57       37.44          35.38

Note can use either standard splitting or splitting with
`page_by = TRUE` when injecting our subgroups, depending on the desired
behavior, with no other changes.

Thus, it is good practice to anchor all top level (seemingly non-nested)
row instructions after the first to that first instruction to make our
layouts easily support the creation of subgroup variants.
