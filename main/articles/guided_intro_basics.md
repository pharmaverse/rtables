# Introductory rtables - Basic Table Layout Instructions

## Introduction

To create a table using `rtables`, we first declare its structure using
the layout engine. We do this by defining four aspects of the table we
intend to create:

1.  Individual Row and Cell Contents,
2.  Column Structure,
3.  Row Faceting Structure, and
4.  Marginal (/Summary) Cell Contents

Each of these aspects corresponds with a set of layout functions which
we will go through now.

## Declaring Rows And Cell Contents With `analyze()`

### Core Idea

We declare rows and cell values by
[`analyze()`](https://pharmaverse.github.io/rtables/reference/analyze.md)ing
variables with *analysis functions*.

Analysis functions: - are applied to data by `rtables` to calculate cell
values at table construction time - can generate multiple rows - *do
not* handle subsetting data into relevant subsets for each cell

### Basic Usage

In `rtables` we declare individual rows and the cell contents for those
rows by setting an *analysis function* via an
[`analyze()`](https://pharmaverse.github.io/rtables/reference/analyze.md)
call. By default,
[`analyze()`](https://pharmaverse.github.io/rtables/reference/analyze.md)
declares the
[`simple_analysis()`](https://pharmaverse.github.io/rtables/reference/rtinner.md)
analysis, which will create a single row with the man value(s) for a
numeric variable and a row per level with counts for a factor (or
character) variable. For this introductory portion of the tour we will
simply use this default analysis function, as it suffices to illustrate
the core behaviors we are discussing.

Consider a trivial table, with a single column representing all of our
data. We can analyze `AGE` (a numeric variable) to declare a single row
displaying the mean of patient ages in our data:

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

`lyt`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`` `` `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``)`` `` `[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt``, ``ex_adsl``)`

    ##        all obs
    ## ——————————————
    ## Mean    34.88

Alternatively, if we `analyze` `BMRKR2`, a simulated categorical
biomarker, we get rows with counts for each level:

`lyt2`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`` `` `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"BMRKR2"``)`` `` `[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt2``, ``ex_adsl``)`

    ##          all obs
    ## ————————————————
    ## LOW        135  
    ## MEDIUM     135  
    ## HIGH       130

Note: in production tables we will typically not use the default
analysis function; we are using it here to separate the discussion of
what
[`analyze()`](https://pharmaverse.github.io/rtables/reference/analyze.md)
does from discussion of any particular analysis function. See the
intermediate guided tour, specifically [Identifying Required Analysis
Behavior](https://pharmaverse.github.io/rtables/articles/guided_intermediate_afun_reqs.md)
for more details on how we select analysis functions in more realistic
scenarios.

## Declaring Columns With `split_cols_by()`

### Core Idea

Individual columns are typically defined via
[`split_cols_by()`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md),
which defines *column faceting*. This can be nested which is discussed
in detail in the [next
portion](https://pharmaverse.github.io/rtables/articles/guided_intro_nesting.md)
of this guide.

Column faceting: - defines individual columns - defines subsetting for
each column which applies to all rows - typically a partition on
categorical variable - *can* be overlapping or non-exhaustive as needed

### Basic Usage

By default, faceting (which we also call *splitting*) partitions the
data; in the case of `split_cols_by`, declaring columns.

For example, we can define a column for each trial arm in our simulated
data by splitting on `ARM`:

`lyt3`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`` `` `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"ARM"``)`` ``|>`` `` `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"BMRKR2"``)`` `` `[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt3``, ``ex_adsl``)`

    ##          A: Drug X   B: Placebo   C: Combination
    ## ————————————————————————————————————————————————
    ## LOW         50           45             40      
    ## MEDIUM      37           56             42      
    ## HIGH        47           33             50

Here we combine our column splitting with the analysis of `BMRKR2` to
illustrate how splitting interacts with analysis functions that generate
more than one row.

We can see that we now have three columns - one for each arm - and each
column has three cells - one for each `BMRKR2` level.

Note: our analysis function is only called here three times - once for
each column - as there is no additional row faceting and each call
generates three values.

## Declaring Row-Grouping With `split_rows_by()`

### Core Idea

We declare *structural groups* of rows via row faceting. This defines
what data our analysis function is passed *from the row structure
perspective* to (repeatedly) create our cells and individual rows during
tabulation.

Row faceting defines groups that:

- will contain one or more individual rows, and
- are eligible for marginal summaries (see next section)

### Basic Usage

Row facets represent subsets of our data which should be analyzed. For
example, we might want to analyze patient `BMRKR2` status for each
gender:

`lyt4`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`` `` `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"SEX"``)`` ``|>`` `` `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"BMRKR2"``)`` `` `[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt4``, ``ex_adsl``)`

    ##                    all obs
    ## ——————————————————————————
    ## F                         
    ##   LOW                73   
    ##   MEDIUM             76   
    ##   HIGH               73   
    ## M                         
    ##   LOW                55   
    ##   MEDIUM             56   
    ##   HIGH               55   
    ## U                         
    ##   LOW                 4   
    ##   MEDIUM              3   
    ##   HIGH                2   
    ## UNDIFFERENTIATED          
    ##   LOW                 3   
    ##   MEDIUM              0   
    ##   HIGH                0

## Adding Marginal Summaries With `summarize_row_groups`

### Core Idea

Marginal row-group summaries generate cells that provide context for
cells underneath them in the row structure; they *typically* replace
label a facet’s row with more informative row(s).

We declare marginal summaries by declaring a *content function* via
[`summarize_row_groups()`](https://pharmaverse.github.io/rtables/reference/summarize_row_groups.md),
which modifies the the currently active (most recent) row split such
that:

- the content function will be called for each facet generated by the
  split, and
- the label row for each facet will be replaced with the row(s)
  generated by the content function

### Basic Usage

We might want an overall count for each gender in addition to those of
each `BMRKR2` level within those genders:

`lyt5`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`` `` `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"SEX"``)`` ``|>`` `` `[`summarize_row_groups`](https://pharmaverse.github.io/rtables/reference/summarize_row_groups.md)`(``"SEX"``)`` ``|>`` `` `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"BMRKR2"``)`` `` `[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt5``, ``ex_adsl``)`

    ##                      all obs  
    ## ——————————————————————————————
    ## F                  222 (55.5%)
    ##   LOW                  73     
    ##   MEDIUM               76     
    ##   HIGH                 73     
    ## M                  166 (41.5%)
    ##   LOW                  55     
    ##   MEDIUM               56     
    ##   HIGH                 55     
    ## U                   9 (2.2%)  
    ##   LOW                   4     
    ##   MEDIUM                3     
    ##   HIGH                  2     
    ## UNDIFFERENTIATED    3 (0.8%)  
    ##   LOW                   3     
    ##   MEDIUM                0     
    ##   HIGH                  0

### Some Relevant Details

- By default label rows are hidden when a marginal summary is present
  - this can be disabled via `child_labels = 'visible'` in the
    `split_rows_by` call

## All Together - A Basic Rectangular Table

We combine our column splitting, row splitting, group summary, and
analysis instructions to create a full table layout, like so:

`lyt_basic`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`` `` `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"ARM"``)`` ``|>`` `` `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"SEX"``)`` ``|>`` `` `[`summarize_row_groups`](https://pharmaverse.github.io/rtables/reference/summarize_row_groups.md)`(``"SEX"``)`` ``|>`` `` `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"BMRKR2"``)`` `` `[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt_basic``, ``ex_adsl``)`

    ##                    A: Drug X    B: Placebo   C: Combination
    ## ———————————————————————————————————————————————————————————
    ## F                  79 (59.0%)   77 (57.5%)     66 (50.0%)  
    ##   LOW                  26           21             26      
    ##   MEDIUM               21           38             17      
    ##   HIGH                 32           18             23      
    ## M                  51 (38.1%)   55 (41.0%)     60 (45.5%)  
    ##   LOW                  21           23             11      
    ##   MEDIUM               15           18             23      
    ##   HIGH                 15           14             26      
    ## U                   3 (2.2%)     2 (1.5%)       4 (3.0%)   
    ##   LOW                  2            1              1       
    ##   MEDIUM               1            0              2       
    ##   HIGH                 0            1              1       
    ## UNDIFFERENTIATED    1 (0.7%)     0 (0.0%)       2 (1.5%)   
    ##   LOW                  1            0              2       
    ##   MEDIUM               0            0              0       
    ##   HIGH                 0            0              0

Thus we have created a basic table. In practice, our table structures
are generally significantly more complex than this; rtables supports
these myriad structures by allowing us to control the *nesting* behavior
of both splitting and analysis instructions. We cover this in detail in
the [next
section](https://pharmaverse.github.io/rtables/articles/guided_intro.nesting.md)
of this guide.
