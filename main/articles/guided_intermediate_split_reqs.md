# Intermediate rtables - Identifying Required Faceting Behavior

## Introduction

`rtables` supports *generalized* faceting when declaring row and column
structure. In particular it, allows faceting behavior to deviate from
that seen in e.g., `ggplot2` faceting support in four crucial ways often
required for tables:

1.  Facets need not be mutually exclusive,
2.  Facets need not be exhaustive,
3.  Nested faceting behavior can depend on the parent facet it occurs
    within, and
4.  Facets can be created that do not reflect a single categorical value
    in the data.

While this flexibility provides a cornerstone to `rtables`’ power -
alongside the flexibility of analysis functions discussed in the
previous chapter - it also means we must actively think about faceting
when creating table layouts in a way simply not required of users of
`facet_grid` in `ggplot2`.

In this chapter we will cover identifying which aspects of a shell or
desired table should be achieved by specifying the correct split
function(s) in the layout. As with the previous chapter’s handling of
analysis behavior, we will leave *implementation* of fully custom split
functions for the advanced portion of this guide and focus solely on the
identification of required behavior to prepare users to choose between a
selection of pre-existing non-default split functions available to them.

## A Brief Review

Faceting serves three purposes within the `rtables` layouting framework.
It declares

1.  The row- and column-labeling when the table is rendered,
2.  The organization of the sets of cells that will make up the table’s
    body, and
3.  The data to be analyzed when calculating contents for each set of
    cells in the table.

In particular, (3) means that the data passed to analysis functions is
the intersection of the data associated with the row- and column-facets
that define the location of the cell(s) whose contents are being
calculated.

`rtables` is designed such that data should not need to be duplicated,
nor .e.g, levels of a factor, restricted in the dataset prior to calling
`build_table`. Things like adding combination levels and restricting or
reordering factor levels are all declared via faceting in the layout and
then performed automatically by the internal `rtables` machinery during
table creation.

### Split Function Basics

We will leave a detailed technical discussion of how split functions
work for when we implement our own custom split functions in the
advanced portion of this guide. For our purposes here, it suffices to
consider a split function to be a mapping from an incoming dataset (the
data associated with the parent facet) to a set of one or more facets,
each of which are associated with (sub)sets of that incoming data.

### Default Faceting

By default, faceting instructions:

1.  Declare facets based on a *partition* of incoming data defined by a
    categorical variable, and
2.  Nest within previously declared instructions in the same dimension
    (row/column).

The above behaviors combine to mean that sequential faceting
instructions (i.e., repeated calls to `split_cols_by` or
`split_rows_by`) result in *full factorial faceting*, where each
combination of levels from the variables faceted on is represented.

This is true with column faceting:

``` r
lyt <- basic_table() |>
  split_cols_by("ARM") |>
  split_cols_by("SEX")

build_table(lyt, ex_adsl)
            A: Drug X                      B: Placebo                   C: Combination       
   F   M   U   UNDIFFERENTIATED   F   M   U   UNDIFFERENTIATED   F   M   U   UNDIFFERENTIATED
—————————————————————————————————————————————————————————————————————————————————————————————
```

as well as with row faceting, with the caveat that row faceting does not
generate individual rows, and thus an analyze call is required:

``` r
lyt2 <- basic_table() |>
  split_rows_by("STRATA1") |>
  split_rows_by("BMRKR2") |>
  analyze("AGE")

build_table(lyt2, ex_adsl)
           all obs
——————————————————
A                 
  LOW             
    Mean    34.67 
  MEDIUM          
    Mean    34.35 
  HIGH            
    Mean    33.52 
B                 
  LOW             
    Mean    33.40 
  MEDIUM          
    Mean    34.47 
  HIGH            
    Mean    38.38 
C                 
  LOW             
    Mean    34.33 
  MEDIUM          
    Mean    34.75 
  HIGH            
    Mean    35.96 
```

## Recognizing Non-Full-Factorial Faceting

Any time we need faceting that does not represent a full factorial
combination of one or more variables (i.e., the full set of combinations
of levels from those variables), we will need to use split functions to
declare our desired structure.

The key, then, is to carefully consider how our desired faceting
structure deviates from the full factorial structure that default
faceting would generate. This will tell us what behaviors we need from
our split functions.

### Excluding Factor Levels

The simplest deviation from full-factorial faceting is to omit some
levels when faceting based on a single categorical variable. This can
come in two flavors:

1.  Prescriptive - when the level(s) to be omitted are set a priori,
2.  Empirical - when the level(s) to be omitted depend on the data.

Prescriptively omitting levels(/facets) is fairly straightforward: you
have a set of levels that, for whatever reason, you do not want facets
for in the resulting table. `rtables` provides the `remove_split_levels`
to create split functions which achieve this.

Empirically omitting levels(/facets) is more open ended, as technically
the logic determining what should be omitted can be completely
arbitrary. The most common version, however, is to omit unobserved
levels (which would result in facets whose associated data subset is
empty); the `drop_split_levels` split function does this.

We will use a slightly modified version of our synthetic data to
illustrate the difference:

``` r
adsl <- subset(ex_adsl, as.character(SEX) %in% c("F", "M", "U"))
qtable(adsl, col_vars = "SEX")
           F         M        U     UNDIFFERENTIATED
        (N=222)   (N=166)   (N=9)        (N=0)      
————————————————————————————————————————————————————
count     222       166       9            0        
```

First we declare faceting that omits the (rare but observed) `"U"` level
using `remove_split_levels`.

``` r
lyt_pre <- basic_table() |>
  split_cols_by("SEX", split_fun = remove_split_levels("U")) |>
  analyze("STRATA1")

build_table(lyt_pre, adsl)
    F    M    UNDIFFERENTIATED
——————————————————————————————
A   63   55          0        
B   73   59          0        
C   86   52          0        
```

Next we will use `drop_split_levels`:

``` r
lyt_emp <- basic_table() |>
  split_cols_by("SEX", split_fun = drop_split_levels) |>
  analyze("STRATA1")

build_table(lyt_emp, adsl)
    F    M    U
———————————————
A   63   55   3
B   73   59   3
C   86   52   3
```

Here we get exactly – and only – facets for the levels of `SEX` observed
in the data.

It is important to note that `drop_split_levels` omits facets for levels
not observed ***in the incoming data*** which is the data for the parent
facet. This only translates to the full data being tabulated in cases of
top level faceting (not nested within anything) and other special cases.

We can see this if we nest faceting using the empirical
`drop_split_levels` within another faceting instruction:

``` r
lyt_bad_emp <- basic_table() |>
  split_cols_by("ARM") |>
  split_rows_by("RACE", split_fun = drop_split_levels) |>
  split_rows_by("SEX", split_fun = drop_split_levels) |>
  analyze("AGE")

build_table(lyt_bad_emp, adsl)
                                            A: Drug X   B: Placebo   C: Combination
———————————————————————————————————————————————————————————————————————————————————
ASIAN                                                                              
  F                                                                                
    Mean                                      31.22       35.06          36.44     
  M                                                                                
    Mean                                      34.60       38.63          37.66     
  U                                                                                
    Mean                                      33.50       35.00          34.50     
BLACK OR AFRICAN AMERICAN                                                          
  F                                                                                
    Mean                                      34.06       33.88          33.21     
  M                                                                                
    Mean                                      34.58       36.33          34.21     
  U                                                                                
    Mean                                       NA           NA           36.00     
WHITE                                                                              
  F                                                                                
    Mean                                      34.12       32.41          33.00     
  M                                                                                
    Mean                                      40.00       34.62          30.80     
  U                                                                                
    Mean                                      28.00       27.00            NA      
AMERICAN INDIAN OR ALASKA NATIVE                                                   
  F                                                                                
    Mean                                      38.33       34.86          37.00     
  M                                                                                
    Mean                                      34.80       33.50          32.75     
MULTIPLE                                                                           
  M                                                                                
    Mean                                       NA         53.00            NA      
NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER                                          
  F                                                                                
    Mean                                       NA         28.00            NA      
```

Here we see that different sets of `SEX` facets are generated within
different `RACE` facets, with the `"MULTIPLE"` and
`"NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER"` races each having only a
(different) single facet. This is sometimes the desired behavior, but
often it is not so care should be used with `drop_split_levels` in
non-trivial faceting structures.

### Adding Combination Levels

Some shells call for levels to be combined into new virtual levels. For
example, we might need an “All Drug X” category in our table which
represents both arms A (`"A: Drug X") and C (`“C: Combination”\`) as a
single group of patients, either in addition to or instead of those
individual arms.

As with omitting defined factor levels, this is a deviation from the
default full factorial behavior. In this case we want a facet for a
level not present in the data and (assuming the individual arms are left
in alongside our combination arm) our desired facets are not mutually
exclusive.

`rtables` provides the `add_combo_levels` split function to directly
invoke this behavior. It takes a “combination data.frame” that declares
the combination levels to add.

``` r
combodf <- tribble(
  ~valname, ~label, ~levelcombo, ~exargs,
  "A_C", "Arms A+C", c("A: Drug X", "C: Combination"), list()
)

lyt_combo1 <- basic_table() |>
  split_cols_by("ARM", split_fun = add_combo_levels(combodf), show_colcounts = TRUE)

build_table(lyt_combo1, ex_adsl)
   A: Drug X   B: Placebo   C: Combination   Arms A+C
    (N=134)     (N=134)        (N=132)       (N=266) 
—————————————————————————————————————————————————————
```

### Nested Faceting On Non-Independent Variables

Often times when performing nested faceting, the inner variable
represents the same information as the outer variable in more detail.
Another way to view this is that the information represented by the
outer variable is implicitly included (or embedded) within the
information for the inner variable. When this occurs, most combinations
of levels from the pair of variables are not logically consistent, can
never occur in practice, and most importantly, should not be represented
in our resulting table. Whenever this is the case, we cannot rely on the
default splitting behavior.

An ubiquitous example of this in clinical trials are the System Organ
Class (`AESOC`) and Preferred Term (`AEDECOD`) variables used when
describing adverse events. `AESOC` represents the broad category an
adverse events falls within (e.g., “SKELETOMUSCULAR” or
“GASTROINTESTINAL”) while `AEDECOD` represents the specific type of
adverse-event (“BACK PAIN”, “VOMITING”). In this example, the
combination of `AESOC` being `"SKELETOMUSCULAR"` while `AEDECOD` is
`"VOMITING"`. In our alternate framing we would say that the `AEDECOD`
value `"VOMITING"` implies that `AESOC` *must* be `"SKELETOMUSCULAR"`.

Note that our synthetic data does not contain realistic values for
`AESOC` and `AEDECOD`, but rather values of the form `"cl X`” (with X a
capital letter) and `"dcd X.m.n.o.p"` with m-p individual digits,
respectively. Note this makes the information embedding even more
explicit, as the X is the same between values of `AESOC` and the values
of `AEDECOD` they apply to.

As with omitting facets within a single faceting instruction, there are
broadly two ways to approach this type of nested faceting:

1.  Prescriptively, and
2.  Empirically.

In both cases, we can think about this in terms of *pairs of levels we
want to represent in our table*. The goal here is to preemptively omit
pairs which are not logically consistent (and thus which we can assume
have no observations in the data).

The empirical approach assumes that either:

- All valid pairs of levels have at least one observation, or
- we want to display *only* observed pairs, omitting any valid
  unobserved pairs.

To this end, `rtables` provides the `trim_levels_in_group` split
function factory, which, for each observed level in variable being
split, levels of a declared `inner_var` are restricted to those observed
*in combination to that level of the split variable*. When we then split
on or analyze the inner variable, we get a table that contains only the
observed pairs:

``` r
lyt_tig <- basic_table() |>
  split_rows_by("AESOC", split_fun = trim_levels_in_group("AEDECOD")) |>
  analyze("AEDECOD")

build_table(lyt_tig, ex_adae)
                  all obs
—————————————————————————
cl A                     
  dcd A.1.1.1.1     214  
  dcd A.1.1.1.2     208  
cl B                     
  dcd B.1.1.1.1     178  
  dcd B.2.1.2.1     193  
  dcd B.2.2.3.1     217  
cl C                     
  dcd C.1.1.1.3     182  
  dcd C.2.1.2.1     166  
cl D                     
  dcd D.1.1.1.1     183  
  dcd D.1.1.4.2     185  
  dcd D.2.1.5.3     208  
```

`trim_levels_in_group` can be used in chains to further restrict the
displayed combinations of more than two variables, if desired:

``` r
lyt_tig2 <- basic_table(title = "Observed Toxicity Grades") |>
  split_rows_by("AESOC", split_fun = trim_levels_in_group("AEDECOD")) |>
  split_rows_by("AEDECOD", split_fun = trim_levels_in_group("AETOXGR")) |>
  analyze("AETOXGR")

build_table(lyt_tig2, ex_adae)
Observed Toxicity Grades

—————————————————————————
                  all obs
—————————————————————————
cl A                     
  dcd A.1.1.1.1          
    1               214  
  dcd A.1.1.1.2          
    2               208  
cl B                     
  dcd B.1.1.1.1          
    5               178  
  dcd B.2.1.2.1          
    3               193  
  dcd B.2.2.3.1          
    1               217  
cl C                     
  dcd C.1.1.1.3          
    4               182  
  dcd C.2.1.2.1          
    2               166  
cl D                     
  dcd D.1.1.1.1          
    5               183  
  dcd D.1.1.4.2          
    3               185  
  dcd D.2.1.5.3          
    1               208  
```

Sometimes the above is the desired behavior; many times, however, there
are certain counts or values which are important to display *even when
they are not observed*. In such cases, we still want to omit pairs of
levels that are impossible/logically inconsistent, but cannot rely on
which combinations are observed in the data.

In such cases, we must *prescriptively* declare which combinations we
want to appear in our table. `rtables` provides the `trim_levels_to_map`
split function factory for this, which accepts a pre-defined map of all
combinations which should be included (in the form of a data.frame). Any
combinations which do not appear in the map will be omitted *even if
they are observed in the data*.

``` r
map <- tribble(
  ~AESOC, ~AEDECOD,
  "cl A", "dcd A.1.1.1.2",
  "cl B", "dcd B.1.1.1.1",
  "cl B", "dcd B.2.2.3.1",
  "cl D", "dcd D.1.1.1.1"
)

lyt_ttm <- basic_table() |>
  split_rows_by("AESOC", split_fun = trim_levels_to_map(map)) |>
  analyze("AEDECOD")

build_table(lyt_ttm, ex_adae)
                  all obs
—————————————————————————
cl A                     
  dcd A.1.1.1.2     208  
cl B                     
  dcd B.1.1.1.1     178  
  dcd B.2.2.3.1     217  
cl D                     
  dcd D.1.1.1.1     183  
```

Note that because there were no pairs in the map with an `AESOC` of
`"cl C"`, that entire facet is omitted. This will be true in the case of
nested faceting as well:

``` r
lyt_ttm2 <- basic_table() |>
  split_rows_by("AESOC", split_fun = trim_levels_to_map(map)) |>
  split_rows_by("AEDECOD", split_fun = trim_levels_in_group("AETOXGR")) |>
  analyze("AETOXGR")

build_table(lyt_ttm2, ex_adae)
                  all obs
—————————————————————————
cl A                     
  dcd A.1.1.1.2          
    2               208  
cl B                     
  dcd B.1.1.1.1          
    5               178  
  dcd B.2.2.3.1          
    1               217  
cl D                     
  dcd D.1.1.1.1          
    5               183  
```

### Facets That Vary Meaning Instead of Data Subset

In our examples so far, faceting has translated to mapping the incoming
data to a set of distinct (if not necessarily mutually exclusive or
exhaustive) subsets of the data. This is the most common form of
faceting, but it is not the only one `rtables` supports.

In some cases, we want facets to be *semantically* distinct from each
other; in other words, instead of representing different subsets of the
data, we want them to represent different aspects of the same data. This
is most commonly useful column space, where individual columns are
defined via faceting, unlike individual rows.

An toy example of this would be

                   A: Drug X          B: Placebo          C: Combination   
               n    mean    sd     n    mean    sd      n    mean      sd  
    ———————————————————————————————————————————————————————————————————————
    F          -     -       -     -     -       -      -      -       -   
      AGE      xx   xx.x   xx.xx   xx   xx.x   xx.xx   xx    xx.x    xx.xx 
      BMRKR1   xx   xx.x   xx.xx   xx   xx.x   xx.xx   xx    xx.x    xx.xx 
    M          -     -       -     -     -       -      -      -       -   
      AGE      xx   xx.x   xx.xx   xx   xx.x   xx.xx   xx    xx.x    xx.xx 
      BMRKR1   xx   xx.x   xx.xx   xx   xx.x   xx.xx   xx    xx.x    xx.xx 

Here we have individual columns for ***different statistics calculated
using the same data*** (`n`, `mean` and `sd`), within a faceting
structure that splits on arm in column space and gender in row space,
and calculated for two different continuous numeric variables (age and
“biomarker 1” value).

To achieve this, we need faceting that creates three columns all of
whose “subsets” of the incoming (arm) data are identical: all of it. We
can achieve this with the `add_combo_levels` split function factory we
used above; the key is to use the `select_all_levels` sentinel value
provided by rtables to indicate that all levels in the data should be
combined when creating each of our new combination levels.

We will turn on column counts at all levels to show that it is doing
what we want, despite it being redundant and not suitable for any actual
table output.

``` r
my_combo_df <- tribble(
  ~valname, ~label, ~levelcombo, ~exargs,
  "n", "n", select_all_levels, list(),
  "mean", "mean", select_all_levels, list(),
  "sd", "sd", select_all_levels, list()
)

lyt_tpose_cols_only <- basic_table() |>
  split_cols_by("ARM", show_colcounts = TRUE) |>
  split_cols_by("STUDYID",
    split_fun = add_combo_levels(my_combo_df, keep_levels = my_combo_df$valname),
    show_colcounts = TRUE
  )

build_table(lyt_tpose_cols_only, ex_adsl)
            A: Drug X                    B: Placebo                  C: Combination       
             (N=134)                       (N=134)                       (N=132)          
      n       mean       sd         n       mean       sd         n       mean       sd   
   (N=134)   (N=134)   (N=134)   (N=134)   (N=134)   (N=134)   (N=132)   (N=132)   (N=132)
——————————————————————————————————————————————————————————————————————————————————————————
```

We split on study id in the above code largely for convenience. Given
that we are defining combination levels using `select_all_levels`, we
could split on anything and have each of the facets represent the
entirety of the incoming data. This approach, however, is a
generalization of splitting on study id in order to create a single
facet representing all the incoming data, a trick worth having in our
back pocket.

Thus we’ve achieved the column structure we wanted. Now we need an
analysis function with the correct *column-conditional behavior* (see
[the previous
chapter](https://pharmaverse.github.io/rtables/articles/guided_intermediate_afun_reqs.md))
and we will have our output.

Without discussing how we construct it (as that will be covered in the
advanced portion of this guide), assuming we have a `tpose_afun` which
meets our requirements, we can then fully create our table:

``` r
lyt_tpose_full <- basic_table() |>
  split_cols_by("ARM", show_colcounts = TRUE) |>
  split_cols_by("STUDYID",
    split_fun = add_combo_levels(my_combo_df, keep_levels = combo_df$valname),
    show_colcounts = TRUE
  ) |>
  split_rows_by("SEX", split_fun = keep_split_levels(c("F", "M"))) |>
  analyze(c("AGE", "BMRKR1"), afun = tpose_afun, show_labels = "hidden")

build_table(lyt_tpose_full, ex_adsl)
                    A: Drug X                    B: Placebo                  C: Combination       
                     (N=134)                       (N=134)                       (N=132)          
              n       mean       sd         n       mean       sd         n       mean       sd   
           (N=134)   (N=134)   (N=134)   (N=134)   (N=134)   (N=134)   (N=132)   (N=132)   (N=132)
——————————————————————————————————————————————————————————————————————————————————————————————————
F                                                                                                 
  AGE        79       32.8      6.09       77       34.1      7.06       66       35.2      7.43  
  BMRKR1     79        5.8      3.31       77        5.6      3.36       66        5.7      4.12  
M                                                                                                 
  AGE        51       35.6      7.08       55       37.4      8.69       60       35.4      8.24  
  BMRKR1     51        6.3      3.99       55        5.9      3.30       60        5.3      2.57  
```

## Combining These Faceting Needs

For some table shells, we need to combine the types of needs we explored
above; we might need `trim_levels_to_map` type behavior, but also need
to include a virtual combination treatment/arm. The split
functions/function factories we discussed here generally cannot achieve
this, though our reasoning for ***how to think about the faceting we
need*** still applies. In such cases, we will construct fully custom
split functions which exactly meet our needs, which will be the topic of
an entire chapter in the advanced portion of this guide.
