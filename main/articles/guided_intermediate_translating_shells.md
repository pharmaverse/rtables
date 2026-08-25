# Intermediate rtables - Translating Shells To Layouts

## Introduction

The first - and often largest - hurdle to creating a table via `rtables`
is translating the desired table structure (typically in the form of a
*table shell*) into an `rtables` *layout*. We will cover that
translation process in this vignette.

### A Table Shell

Table shells can come in various forms. We will begin with a table shell
which is essentially the entire table with desired formatting indicated
instead of values:

    Subject Response by Race and Sex; Treated Subjects

    ————————————————————————————————————————————————————————————————
                              A                         B           
    RACE           A: Drug X    B: Placebo   A: Drug X    B: Placebo
      SEX            (N=xx)       (N=xx)       (N=xx)       (N=xx)  
    ————————————————————————————————————————————————————————————————
    All Patients       -            -            -            -     
      Yes          xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)
      No           xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)
    Asian              -            -            -            -     
      Male             xx           xx           xx           xx    
        Yes        xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)
        No         xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)
      Female           xx           xx           xx           xx    
        Yes        xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)
        No         xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)
    Black              -            -            -            -     
      Male             xx           xx           xx           xx    
        Yes        xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)
        No         xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)
      Female           xx           xx           xx           xx    
        Yes        xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)
        No         xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)
    White              -            -            -            -     
      Male             xx           xx           xx           xx    
        Yes        xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)
        No         xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)
      Female           xx           xx           xx           xx    
        Yes        xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)
        No         xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)

We will use this shell to illustrate the translation process to an
rtables layout, and thus ultimately a table output.

### A *Brief* Review Of `rtables` Layouts

For an in-depth discussion of how constructing a layout works we refer
the reader to other documentation. That said, there are a couple things
to remember as we consider translating shells into layouts:

1.  Individual rows are declared by `analyze*` calls
2.  Individual columns are the result of column faceting
3.  New faceting will be nested within existing faceting in the same
    dimension (row/col) by default
4.  All row faceting structures must be terminated with at least one
    analysis (`analyze`)
5.  Row faceting which occurs directly after an `analyze` will *not* be
    nested

With those in mind, we will now discuss how to translate shells into
layouts.

## Translating

There are three aspects to a shell that we must translate:

1.  Column faceting structure
2.  Row faceting structure
3.  Cell contents
    - Marginal content for row facet structure
    - Individual facet content

We will explore each portion of the translation process separately.

### Translating Column Structure

Our first task, translating column structure, revolves around
identifying faceting in the column dimension of a shell or desired
table.

Our shell gives us the following to indicate column structure:

                 A                        B           
       A: Drug X   B: Placebo   A: Drug X   B: Placebo
        (N=xx)       (N=xx)      (N=xx)       (N=xx)  
    ——————————————————————————————————————————————————

The easiest way to identify faceting is to look at column- or row-labels
and determine the scope (i.e., the set of individual columns or rows)
they apply to.

For example, we see that the `"A"` column label applies to a group of
multiple columns each of which represent an individual arm:

``` r
fixed_shell(result[0, c("A", "*")])
             A           
   A: Drug X   B: Placebo
    (N=xx)       (N=xx)  
—————————————————————————
```

Thus we have strata faceting with arm faceting nested within it.

Faceting most commonly represents partitioning the data being tabulated
by the values of a categorical variable, though `rtables` supports a
generalized concept of faceting where the data group can overlap and
need not be exhaustive.

For our table, the faceting is nested faceting by the `"STRATA1"`, and
`"ARM"` variables. We achieve this by repeated calls to `split_cols_by`
(with the default `nested = TRUE`), with the call declaring the
outermost faceting first:

``` r
lyt_cols <- basic_table() |>
  split_cols_by("STRATA1", split_fun = keep_split_levels(only = c("A", "B"))) |>
  split_cols_by("ARM", split_fun = keep_split_levels(only = c("A: Drug X", "B: Placebo")))

build_table(lyt_cols, adsl)
             A                        B           
   A: Drug X   B: Placebo   A: Drug X   B: Placebo
——————————————————————————————————————————————————
```

This is almost correct. To fully achieve our shell we need the column
counts to show up, which we do via the `show_colcounts` argument in the
relevant `split_cols_by` call:

``` r
lyt_cols <- basic_table() |>
  split_cols_by("STRATA1", split_fun = keep_split_levels(only = c("A", "B"))) |>
  split_cols_by("ARM",
    split_fun = keep_split_levels(only = c("A: Drug X", "B: Placebo")),
    show_colcounts = TRUE
  )

build_table(lyt_cols, adsl)
             A                        B           
   A: Drug X   B: Placebo   A: Drug X   B: Placebo
    (N=36)       (N=41)      (N=40)       (N=41)  
——————————————————————————————————————————————————
```

This is a relatively straightforward column structure. We will cover
more complex ones later. Nevertheless we have translated our shell’s
column space into `rtables` layouting instructions.

### Translating Row Structure

Moving to the second aspect of translation, we will now translate the
row structure of our shell. Interpreting row structure is similar to
interpreting column structure with the caveat that individual rows do
not come from faceting, but rather from analysis (which is in charge of
populating the contents of the table’s primary, non-marginal cells).

Our row structure is slightly less trivial than our column structure. We
can see two sections in our shell, one that displays the response
(`"BMEASIFL"`) of all patients collectively (by the column structure):

                              A                         B           
    RACE           A: Drug X    B: Placebo   A: Drug X    B: Placebo
      SEX            (N=xx)       (N=xx)       (N=xx)       (N=xx)  
    ————————————————————————————————————————————————————————————————
    All Patients       -            -            -            -     
      Yes          xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)
      No           xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)

and one that subsets the patients before displaying the response within
each subset, and with some marginal rows for context.

                          A                         B           
    RACE       A: Drug X    B: Placebo   A: Drug X    B: Placebo
      SEX        (N=xx)       (N=xx)       (N=xx)       (N=xx)  
    ————————————————————————————————————————————————————————————
    Asian          -            -            -            -     
      Male         xx           xx           xx           xx    
        Yes    xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)
        No     xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)
      Female       xx           xx           xx           xx    
        Yes    xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)
        No     xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)
    Black          -            -            -            -     
      Male         xx           xx           xx           xx    
        Yes    xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)
        No     xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)
      Female       xx           xx           xx           xx    
        Yes    xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)
        No     xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)
    White          -            -            -            -     
      Male         xx           xx           xx           xx    
        Yes    xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)
        No     xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)
      Female       xx           xx           xx           xx    
        Yes    xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)
        No     xx (xx.x%)   xx (xx.x%)   xx (xx.x%)   xx (xx.x%)

Because none of the labels or cell-values from the all patients portion
of the table apply directly to the subset analysis portion - and vice
versa - we can treat these separately.

In point of fact, the first portion does not require any structure
beyond an analysis of the \`“BMEASIFL” variable with a label, so we can
leave that for the third translation step.

We can illustrate this using a dummy analyze as follows:

``` r
dummy_afun <- function(x, ...) in_rows("Analysis" = "-")
lyt_a <- basic_table() |>
  analyze("BMEASIFL",
    afun = dummy_afun,
    var_labels = "All Patients",
    show_labels = "visible"
  )

build_table(lyt_a, adsl)
               all obs
——————————————————————
All Patients          
  Analysis        -   
```

While we do not have the individual rows we desired, as that is left to
step 3 of translation, we can see that we have successfully created the
first portion of the row *structure*.

Note that in most tables the column and row structure are orthogonal and
so we do not need to worry about columns when we are translating the row
structure.

Also note we *could* say that there is a facet there which contains all
the patients and has the name/label `"All Patients"`; this would result
in an equivalent table from an output perspective but there isn’t really
any benefit to the added layouting instructions that would be required,
so we will not do so here.

The second portion of the table contains labels and rows which *do*
apply to multiple individual rows.

We see that the `"Asian"` label, for example, applies across the
corresponding `"Male"` and `"Female"` labels/marginal rows, each of
which in turn applies to a group of individual rows (`"Yes"`, and
`"No"`).

Thus we can recreate this section via nested faceting, this time with

``` r
lyt_b <- basic_table() |>
  split_rows_by("RACE") |>
  split_rows_by("SEX") |>
  analyze("BMEASIFL", afun = dummy_afun)

head(build_table(lyt_b, adsl), 30)
                     all obs
————————————————————————————
Asian                       
  Male                      
    Analysis            -   
  Female                    
    Analysis            -   
  Undifferentiated          
    Analysis            -   
  Unknown                   
    Analysis            -   
Black                       
  Male                      
    Analysis            -   
  Female                    
    Analysis            -   
  Undifferentiated          
    Analysis            -   
  Unknown                   
    Analysis            -   
White                       
  Male                      
    Analysis            -   
  Female                    
    Analysis            -   
  Undifferentiated          
    Analysis            -   
  Unknown                   
    Analysis            -   
```

We are almost there, but we see extra `"SEX"` values that weren’t in our
shell. We can prevent this with the `keep_split_levels` function
provided by `rtables`:

``` r
lyt_b2 <- basic_table() |>
  split_rows_by("RACE") |>
  split_rows_by("SEX", split_fun = keep_split_levels(only = c("Male", "Female"))) |>
  analyze("BMEASIFL", afun = dummy_afun)


build_table(lyt_b2, adsl)
               all obs
——————————————————————
Asian                 
  Male                
    Analysis      -   
  Female              
    Analysis      -   
Black                 
  Male                
    Analysis      -   
  Female              
    Analysis      -   
White                 
  Male                
    Analysis      -   
  Female              
    Analysis      -   
```

Finally, we can combine the two sections by simply combining the
relevant layout instructions:

``` r
lyt_b3 <- basic_table() |>
  analyze("BMEASIFL",
    afun = dummy_afun,
    var_labels = "All Patients",
    show_labels = "visible"
  ) |>
  split_rows_by("RACE") |>
  split_rows_by("SEX", split_fun = keep_split_levels(only = c("Male", "Female"))) |>
  analyze("BMEASIFL", afun = dummy_afun)

build_table(lyt_b3, adsl)
               all obs
——————————————————————
All Patients          
  Analysis        -   
Asian                 
  Male                
    Analysis      -   
  Female              
    Analysis      -   
Black                 
  Male                
    Analysis      -   
  Female              
    Analysis      -   
White                 
  Male                
    Analysis      -   
  Female              
    Analysis      -   
```

Note here that row split instructions which directly follow an `analyze`
call will automatically be non-nested, so we do not need to specify
`nested = FALSE` in the `"RACE"` split, though doing so would not harm
anything.

We can convince ourselves that treating the column and row structure
separately by combining the layouting instructions for both to receive
something equivalent in structure (i.e., up individual rows and marginal
cell contents) to our shell:

``` r
lyt_struct <- basic_table() |>
  split_cols_by("STRATA1", split_fun = keep_split_levels(only = c("A", "B"))) |>
  split_cols_by("ARM",
    split_fun = keep_split_levels(only = c("A: Drug X", "B: Placebo")),
    show_colcounts = TRUE
  ) |>
  analyze("BMEASIFL",
    afun = dummy_afun,
    var_labels = "All Patients",
    show_labels = "visible"
  ) |>
  split_rows_by("RACE") |>
  split_rows_by("SEX", split_fun = keep_split_levels(only = c("Male", "Female"))) |>
  analyze("BMEASIFL", afun = dummy_afun)

build_table(lyt_struct, adsl)
                         A                        B           
               A: Drug X   B: Placebo   A: Drug X   B: Placebo
                (N=36)       (N=41)      (N=40)       (N=41)  
——————————————————————————————————————————————————————————————
All Patients                                                  
  Analysis         -           -            -           -     
Asian                                                         
  Male                                                        
    Analysis       -           -            -           -     
  Female                                                      
    Analysis       -           -            -           -     
Black                                                         
  Male                                                        
    Analysis       -           -            -           -     
  Female                                                      
    Analysis       -           -            -           -     
White                                                         
  Male                                                        
    Analysis       -           -            -           -     
  Female                                                      
    Analysis       -           -            -           -     
```

We can see that the marginal cells for `"Male"` and `"Female"` within
each race are not present, but we will handle those in the third
translation step.

### Translating Cell Contents

Finally, we will finish our translation with the third step: translating
cell contents.

Tables can contain up to two types of rows with non-empty cells as
reckoned by the `rtables` conceptual model: individual analysis rows,
and marginal group summary rows (called *content* rows by the `rtables`
internals).

Analysis rows are declared via `analyze` during layout construction; an
analysis function (the `afun` argument) specifying how *all cells within
a single facet pane should be simultaneously created*.

We see in our shell that we want two rows whenever we analyze `BMEASIFL`
response: one for `"Yes"` and one for `"No"`.

Most analysis functions provided by `rtables` or extensions like `tern`
or `junco` will automatically generate multiple rows when analyzing a
categorical variable (i.e., factor):

``` r
rw_lyt <- basic_table() |>
  analyze("BMEASIFL",
    var_labels = "All Patients",
    show_labels = "visible"
  )

build_table(rw_lyt, adsl)
               all obs
——————————————————————
All Patients          
  Yes            182  
  No             179  
```

Further, recall that the faceting does the work of identifying subsets
and applying our analyses within those facets/subsets automatically.
Thus by applying the *structural* layout instructions we translated
above, we get something that is getting pretty close to our desired
table:

``` r
rw_lyt_struct <- basic_table() |>
  split_cols_by("STRATA1", split_fun = keep_split_levels(only = c("A", "B"))) |>
  split_cols_by("ARM",
    split_fun = keep_split_levels(only = c("A: Drug X", "B: Placebo")),
    show_colcounts = TRUE
  ) |>
  analyze("BMEASIFL",
    var_labels = "All Patients",
    show_labels = "visible"
  ) |>
  split_rows_by("RACE") |>
  split_rows_by("SEX", split_fun = keep_split_levels(only = c("Male", "Female"))) |>
  analyze("BMEASIFL")

build_table(rw_lyt_struct, adsl)
                         A                        B           
               A: Drug X   B: Placebo   A: Drug X   B: Placebo
                (N=36)       (N=41)      (N=40)       (N=41)  
——————————————————————————————————————————————————————————————
All Patients                                                  
  Yes             13           27          20           19    
  No              23           14          20           22    
Asian                                                         
  Male                                                        
    Yes            2           6            1           3     
    No             8           4            8           4     
  Female                                                      
    Yes            5           11           9           8     
    No             6           3            2           7     
Black                                                         
  Male                                                        
    Yes            0           4            3           3     
    No             2           2            2           1     
  Female                                                      
    Yes            2           4            3           2     
    No             3           1            3           1     
White                                                         
  Male                                                        
    Yes            2           1            2           0     
    No             1           2            2           4     
  Female                                                      
    Yes            2           1            2           3     
    No             3           2            3           5     
```

Two aspects remain before we have matched our desired shell: our
marginal counts in the the individual gender rows within each race are
missing, and our analysis rows contain only counts rather than matching
the desired `"xx (xx.x%)"` format of count and percent.

`rtables` provides a (*very*) simple afun to calculate count percent
values (`counts_wpcts`) which we can use for illustration purposes here.
We will see later that it is not flexible enough to meet a study team’s
full set of needs and more complex afuns will be used in practice in
production.

``` r
rw_lyt_structb <- basic_table() |>
  split_cols_by("STRATA1", split_fun = keep_split_levels(only = c("A", "B"))) |>
  split_cols_by("ARM",
    split_fun = keep_split_levels(only = c("A: Drug X", "B: Placebo")),
    show_colcounts = TRUE
  ) |>
  analyze("BMEASIFL",
    afun = counts_wpcts,
    var_labels = "All Patients",
    show_labels = "visible"
  ) |>
  split_rows_by("RACE") |>
  split_rows_by("SEX", split_fun = keep_split_levels(only = c("Male", "Female"))) |>
  analyze("BMEASIFL", afun = counts_wpcts)

build_table(rw_lyt_structb, adsl)
                          A                         B           
               A: Drug X    B: Placebo   A: Drug X    B: Placebo
                 (N=36)       (N=41)       (N=40)       (N=41)  
————————————————————————————————————————————————————————————————
All Patients                                                    
  Yes          13 (36.1%)   27 (65.9%)   20 (50.0%)   19 (46.3%)
  No           23 (63.9%)   14 (34.1%)   20 (50.0%)   22 (53.7%)
Asian                                                           
  Male                                                          
    Yes         2 (5.6%)    6 (14.6%)     1 (2.5%)     3 (7.3%) 
    No         8 (22.2%)     4 (9.8%)    8 (20.0%)     4 (9.8%) 
  Female                                                        
    Yes        5 (13.9%)    11 (26.8%)   9 (22.5%)    8 (19.5%) 
    No         6 (16.7%)     3 (7.3%)     2 (5.0%)    7 (17.1%) 
Black                                                           
  Male                                                          
    Yes         0 (0.0%)     4 (9.8%)     3 (7.5%)     3 (7.3%) 
    No          2 (5.6%)     2 (4.9%)     2 (5.0%)     1 (2.4%) 
  Female                                                        
    Yes         2 (5.6%)     4 (9.8%)     3 (7.5%)     2 (4.9%) 
    No          3 (8.3%)     1 (2.4%)     3 (7.5%)     1 (2.4%) 
White                                                           
  Male                                                          
    Yes         2 (5.6%)     1 (2.4%)     2 (5.0%)     0 (0.0%) 
    No          1 (2.8%)     2 (4.9%)     2 (5.0%)     4 (9.8%) 
  Female                                                        
    Yes         2 (5.6%)     1 (2.4%)     2 (5.0%)     3 (7.3%) 
    No          3 (8.3%)     2 (4.9%)     3 (7.5%)    5 (12.2%) 
```

Now, all we need is the marginal gender counts. We do this by adding
`summarize_row_groups` *directly after* the relevant row faceting
(`split_rows_by`) instruction in the layout. This function can accept a
fully custom function (the `cfun` argument), but for our purposes, we
can control whether the percent is included in the default group summary
with the `format` argument.

``` r
lyt_final <- basic_table() |>
  split_cols_by("STRATA1", split_fun = keep_split_levels(only = c("A", "B"))) |>
  split_cols_by("ARM",
    split_fun = keep_split_levels(only = c("A: Drug X", "B: Placebo")),
    show_colcounts = TRUE
  ) |>
  analyze("BMEASIFL",
    afun = counts_wpcts,
    var_labels = "All Patients",
    show_labels = "visible"
  ) |>
  split_rows_by("RACE") |>
  split_rows_by("SEX", split_fun = keep_split_levels(only = c("Male", "Female"))) |>
  summarize_row_groups(format = "xx") |>
  analyze("BMEASIFL", afun = counts_wpcts)

build_table(lyt_final, adsl)
                          A                         B           
               A: Drug X    B: Placebo   A: Drug X    B: Placebo
                 (N=36)       (N=41)       (N=40)       (N=41)  
————————————————————————————————————————————————————————————————
All Patients                                                    
  Yes          13 (36.1%)   27 (65.9%)   20 (50.0%)   19 (46.3%)
  No           23 (63.9%)   14 (34.1%)   20 (50.0%)   22 (53.7%)
Asian                                                           
  Male             10           10           9            7     
    Yes         2 (5.6%)    6 (14.6%)     1 (2.5%)     3 (7.3%) 
    No         8 (22.2%)     4 (9.8%)    8 (20.0%)     4 (9.8%) 
  Female           11           14           11           15    
    Yes        5 (13.9%)    11 (26.8%)   9 (22.5%)    8 (19.5%) 
    No         6 (16.7%)     3 (7.3%)     2 (5.0%)    7 (17.1%) 
Black                                                           
  Male             2            6            5            4     
    Yes         0 (0.0%)     4 (9.8%)     3 (7.5%)     3 (7.3%) 
    No          2 (5.6%)     2 (4.9%)     2 (5.0%)     1 (2.4%) 
  Female           5            5            6            3     
    Yes         2 (5.6%)     4 (9.8%)     3 (7.5%)     2 (4.9%) 
    No          3 (8.3%)     1 (2.4%)     3 (7.5%)     1 (2.4%) 
White                                                           
  Male             3            3            4            4     
    Yes         2 (5.6%)     1 (2.4%)     2 (5.0%)     0 (0.0%) 
    No          1 (2.8%)     2 (4.9%)     2 (5.0%)     4 (9.8%) 
  Female           5            3            5            8     
    Yes         2 (5.6%)     1 (2.4%)     2 (5.0%)     3 (7.3%) 
    No          3 (8.3%)     2 (4.9%)     3 (7.5%)    5 (12.2%) 
```

Thus, we have fully translated our shell into an `rtables` declarative
layout and realized our desired table output.

In the remainder of this vignette we will walk through a number of
shells with more complex structural elements and how to translate them
into `rtables` layouts.

## Spanning Column Headers

Some shells will call for spanning labels in column space which do not
directly reflect a categorical variable in the raw data, but rather
represent groups of levels in a variable, e.g., trial arms.

For example, we might have the following column structure in a shell:

            Active Treatment                  
       A: Drug X   C: Combination   B: Placebo
        (N=xx)        (N=xx)         (N=xx)   
    ——————————————————————————————————————————

Here we see the “Active Treatment” label spanning arms A and C, while no
label appears above the column for arm B. There are a couple things to
decode here that will collapse this column structure into a nested
faceting structure as we saw above.

Most importantly, while uneven splitting *is* possible with `rtables`,
including in column space, we can get our desired output by allowing the
B arm to have an invisible spanning label which is simply a single space
(`" "`). Viewing the structure this way, we can see that we have two
levels of faceting, one which splits between so called active treatments
and the remaining arms, and within that, we facet on individual arm.

This brings us to our second issue: we don’t have a variable for active
vs non-active treatments. There are a few ways to address this, but the
most user-friendly way is simply to create one as a preprocessing step
on the data before we make our table:

``` r
adsl_forspans <- adsl
adsl_forspans$span_label <- "Active Treatment"
adsl_forspans$span_label[adsl_forspans$ARM == "B: Placebo"] <- " "

qtable(adsl_forspans, "ARM", "span_label")
                 Active Treatment          
count                (N=242)        (N=119)
———————————————————————————————————————————
A: Drug X              122             0   
B: Placebo              0             119  
C: Combination         120             0   
```

With that we can build a table with the desired nested splitting:

``` r
lyt_cspan <- basic_table() |>
  split_cols_by("span_label") |>
  split_cols_by("ARM", show_colcounts = TRUE)

build_table(lyt_cspan, adsl_forspans)
              Active Treatment                                                      
   A: Drug X   B: Placebo   C: Combination   A: Drug X   B: Placebo   C: Combination
    (N=122)      (N=0)         (N=120)         (N=0)      (N=119)         (N=0)     
————————————————————————————————————————————————————————————————————————————————————
```

So we are getting close, but our individual arm columns are not only
showing up under their correct spanning label (though we see that the
*data* are being siphoned under the correct labels by the column
counts).

This type of non-full-factorial nesting is common; we often only want
facets that *make logical sense* within a nested faceting structure,
while wanting to omit any that don’t (e.g., in our table, the Active
Treatment - Placebo facet).

`rtables` provides multiple ways to declare this behavior in the form of
both full *split functions* and *split function behavior building
blocks*, the latter being for use within `make_split_fun`. For now, we
will use a built-in full split function as we will be covering
`make_split_fun` in a different vignette.

Our two options for split functions are `trim_levels_in_group` and
`trim_levels_to_map`; the former is empirical and will keep all
combinations which are *observed in the data*, omitting any that aren’t.
The latter requires us to provide a map of all combinations to be
displayed, but is more robust to sparse data (e.g., a data snapshot from
an in-flight trial) and allows for displaying zero counts for unobserved
but desired combinations.

Other than being empirical and declarative, respectively,
`trim_levels_in_group` and `trim_levels_to_map` behave similarly: when
used while splitting on a variable (the “outer variable”), the
observations and factor levels of of another (“inner”) variable are
restricted independently within each facet for the outer variable.

In our case, our outer variable is `"span_label"`, while our inner
variable would be `"ARM"`. Thus we want to restrict the levels of
`"ARM"` within each facet of `"span_label"`. For our toy example here,
the two split functions will be equivalent, but we will use
`trim_levels_to_map` as it is more robust and appropriate for more cases
of production use.

Thus we need to create our map, a `data.frame` that contains the two
variables with each desired combination as a separate row:

``` r
span_label_map <- tribble(
  ~span_label, ~ARM,
  "Active Treatment", "A: Drug X",
  "Active Treatment", "C: Combination",
  " ", "B: Placebo",
)

lyt_cspan_final <- basic_table() |>
  split_cols_by("span_label",
    split_fun = trim_levels_to_map(span_label_map)
  ) |>
  split_cols_by("ARM", show_colcounts = TRUE)

build_table(lyt_cspan_final, adsl_forspans)
        Active Treatment                  
   A: Drug X   C: Combination   B: Placebo
    (N=122)       (N=120)        (N=119)  
——————————————————————————————————————————
```

Thus we have again achieved a “table” matching our desired shell. We can
consider only the column structure because in this case as previously
the column structure, row structure, and analysis are all orthogonal. We
will see an example where that isn’t fully the case below

**Note:** in the general case, the level map used in
`trim_levels_to_map` will be a function of the data dictionaries for the
relevant variables within your study, thus for combinations of actual
variables these maps should not require manual construction as we did
above.

## Heterogeneous Column Structures (e.g., Risk Difference Columns)

In our previous examples, the column structure was simple nested
faceting, both in the case of faceting on two variables from the data,
and in the case we wanted spanning labels.

While this simple nesting structure is relatively common, particularly
for column structure, it does not fit the shells for all tables we might
need to create. One example of this is risk difference columns, as found
in modern FDA guidance for Adverse Event (AE) tables.

In this section we will translate a shell with both spanning headers and
risk difference columns into a layout. To avoid subtleties about
counting we will analyze the `BMRKR2` variable in our synthetic `ADSL`
dataset rather than going for a realistic AE table. These counting
issues and realistic AE tables will be addressed elsewhere in this
series of vignettes.

### Risk Difference Columns

Many tables call for “risk difference”, or comparison columns, in
addition to those used for the primary counts. When combined with
spanning labels, the column structure of our shell would look something
like:

            Active Treatment                                                                           
       A: Drug X   C: Combination   B: Placebo                      Risk Differences                   
        (N=xx)        (N=xx)         (N=xx)      A: Drug X vs B: Placebo   C: Combination vs B: Placebo
    ———————————————————————————————————————————————————————————————————————————————————————————————————

We see that the first portion of the column structure is the same, but
we now have the risk difference structure in addition. There are a
number of different ways to model risk difference columns but we will do
so as a separate nested substructure. Thus as we did with the “Active
Treatment” spanning label, we will create and then facet on a variable
that gives us the “Risk Differences” label.

We can build up this substructure separately and then combine it with
the structure we created above to match the full shell.

``` r
adsl_rr <- adsl_forspans
adsl_rr$rr_header <- "Risk Differences"

lyt_only_rr <- basic_table() |>
  split_cols_by("rr_header") |>
  split_cols_by("ARM")

build_table(lyt_only_rr, adsl_rr)
              Risk Differences            
   A: Drug X   B: Placebo   C: Combination
——————————————————————————————————————————
```

This is getting close there are two issues: first, we don’t want a
placebo column (which would nonsensically compare placebo against
itself), and the labels are simply the individual arms rather than the
pair of arms being compared as in our shell.

We can restrict the facets generated using the `remove_split_levels` (or
sibling `keep_split_levels`) split function provided by `rtables`. In
addition the `split_*_by` functions accept the `labels_var` argument
which specifies an additional variable which should be used for the
*labels* (not names) of the facets generated. With preprocessing to
create such a variable, and combining these two approaches, we can
achieve the risk difference structure:

``` r
adsl_rr$rr_label <- paste(adsl_rr$ARM, "vs B: Placebo")

lyt_only_rr2 <- basic_table() |>
  split_cols_by("rr_header") |>
  split_cols_by("ARM",
    split_fun = remove_split_levels("B: Placebo"),
    labels_var = "rr_label"
  )

build_table(lyt_only_rr2, adsl_rr)
                      Risk Differences                   
   A: Drug X vs B: Placebo   C: Combination vs B: Placebo
—————————————————————————————————————————————————————————
```

To combine our two sections of column structure, we simply combine the
sets of layouting instructions and add `nested = FALSE` to our split on
`"rr_header"`:

``` r
lyt_rr_cols <- basic_table() |>
  split_cols_by("span_label",
    split_fun = trim_levels_to_map(span_label_map)
  ) |>
  split_cols_by("ARM", show_colcounts = TRUE) |>
  split_cols_by("rr_header", nested = FALSE) |>
  split_cols_by("ARM",
    split_fun = remove_split_levels("B: Placebo"),
    labels_var = "rr_label"
  )

build_table(lyt_rr_cols, adsl_rr)
        Active Treatment                                                                           
   A: Drug X   C: Combination   B: Placebo                      Risk Differences                   
    (N=122)       (N=120)        (N=119)     A: Drug X vs B: Placebo   C: Combination vs B: Placebo
———————————————————————————————————————————————————————————————————————————————————————————————————
```

Note that because we used `show_colcounts` in our `split_cols_by` call
for `"ARM"`, rather than in `build_table`, we have counts for our main
arm columns but not for our comparison columns, as desired.

One caveat here, however, is that we will need a more sophisticated
analysis function because its behavior is no longer independent of which
facet it is in: it might generate e.g., counts for the primary arm
columns and then confidence intervals for our risk difference columns.

Typically trial teams will be using pre-existing analysis functions for
this, but we will illustrate these can be constructed now.

### Column-structure Aware Analysis Functions

Our analysis function needs two “modes”: the primary arm column mode and
the risk difference mode, and it needs to be able to distinguish between
them.

Analysis (and content, i.e., row group summary) functions can accept the
optional `.spl_context` argument to receive information where in the
faceting structure the facet they are currently populating is. We will
leave a detailed discussion of the full contents of the split context to
other documentation and simply use the portions we need here.

In particular, we will use the `cur_col_id` column of `.spl_context` to
determine which section of the column structure we are under. Note that
due to the vagaries of the current implementation, this is constructed
of the *labels* for the column facets rather than their names. This is
the split/value pairs of each column split in order concatenated
together, so it suffices to define

`in_risk_diff`` ``<-`` ``function``(``spl_context``)`` `[`grepl`](https://rdrr.io/r/base/grep.html)`(``"Risk Differences"``, ``spl_context``$``cur_col_id``[``1``]``)`

For simplicity, we will not worry about *calculating* risk differences
here, and simply write an analysis function that emits something
different to show that it can tell it is in “risk difference mode”.

Thus a very simplistic afun is as follows:

`rr_afun`` ``<-`` ``function``(``x``, ``.N_col``, ``.spl_context``)`` ``{`` `` ``xtbl`` ``<-`` `[`table`](https://rdrr.io/r/base/table.html)`(``x``)`` `` ``if`` ``(``in_risk_diff``(``.spl_context``)``)`` ``{`` `` ``armlabel`` ``<-`` `[`tail`](https://pharmaverse.github.io/rtables/reference/head_tail.md)`(``.spl_context``$``cur_col_split_val``[[``1``]``]``, ``1``)`` ``# last split value, ie arm`` `` ``armletter`` ``<-`` `[`substr`](https://rdrr.io/r/base/substr.html)`(``armlabel``, ``1``, ``1``)`` `` ``vals`` ``<-`` `[`as.list`](https://rdrr.io/r/base/list.html)`(`[`rep`](https://rdrr.io/r/base/rep.html)`(`[`paste`](https://rdrr.io/r/base/paste.html)`(``armletter``, ``"vs B"``)``, `[`length`](https://rdrr.io/r/base/length.html)`(``xtbl``)``)``)`` `` ``fmts`` ``<-`` `[`rep`](https://rdrr.io/r/base/rep.html)`(``"xx"``, `[`length`](https://rdrr.io/r/base/length.html)`(``xtbl``)``)`` `` ``}`` ``else`` ``{`` `` ``vals`` ``<-`` `[`lapply`](https://rdrr.io/r/base/lapply.html)`(``xtbl``, ``function``(``x``)`` ``x`` ``*`` `[`c`](https://rdrr.io/r/base/c.html)`(``1``, ``1`` ``/`` ``.N_col``)``)`` ``## count and pct`` `` ``fmts`` ``<-`` `[`rep`](https://rdrr.io/r/base/rep.html)`(``"xx.x (xx.x%)"``, `[`length`](https://rdrr.io/r/base/length.html)`(``xtbl``)``)`` `` ``}`` `` `[`names`](https://rdrr.io/r/base/names.html)`(``vals``)`` ``<-`` `[`names`](https://rdrr.io/r/base/names.html)`(``xtbl``)`` `` `[`names`](https://rdrr.io/r/base/names.html)`(``fmts``)`` ``<-`` `[`names`](https://rdrr.io/r/base/names.html)`(``vals``)`` `` `[`in_rows`](https://pharmaverse.github.io/rtables/reference/in_rows.md)`(``.list ``=`` ``vals``, .formats ``=`` ``fmts``)`` ``}`

With this we can create a table. We will analyze `BMRKR2` (biomarker 2)
for the sake of brevity. This is an oversimplifaction, as typically this
would be, e.g., `AEDECOD` in an `adae` dataset, but this requires more
sophisticated calculation of counts and/or percents that is important
but not germane to this specific issue.

``` r
lyt_rr_full <- basic_table() |>
  split_cols_by("span_label",
    split_fun = trim_levels_to_map(span_label_map)
  ) |>
  split_cols_by("ARM", show_colcounts = TRUE) |>
  split_cols_by("rr_header", nested = FALSE) |>
  split_cols_by("ARM",
    split_fun = remove_split_levels("B: Placebo"),
    labels_var = "rr_label"
  ) |>
  analyze("BMRKR2", afun = rr_afun)

build_table(lyt_rr_full, adsl_rr)
               Active Treatment                                                                               
          A: Drug X     C: Combination    B: Placebo                       Risk Differences                   
           (N=122)         (N=120)         (N=119)      A: Drug X vs B: Placebo   C: Combination vs B: Placebo
——————————————————————————————————————————————————————————————————————————————————————————————————————————————
LOW      42.0 (34.4%)    37.0 (30.8%)    41.0 (34.5%)           A vs B                       C vs B           
MEDIUM   34.0 (27.9%)    37.0 (30.8%)    48.0 (40.3%)           A vs B                       C vs B           
HIGH     46.0 (37.7%)    46.0 (38.3%)    30.0 (25.2%)           A vs B                       C vs B           
```

The blank space above the column counts is a known issue which we expect
to be resolved in a future release due to the fact that the header
construction/wrapping behavior is not accounting for the fact that the
two sections of the column structure are independent.

Note that while our analysis function was dependent on where in the
*column* structure we are, it remains independent of where in the *row*
faceting structure we are. Thus we can use our analysis function within
row faceting without changes:

``` r
lyt_rr_full2 <- basic_table() |>
  split_cols_by("span_label",
    split_fun = trim_levels_to_map(span_label_map)
  ) |>
  split_cols_by("ARM", show_colcounts = TRUE) |>
  split_cols_by("rr_header", nested = FALSE) |>
  split_cols_by("ARM",
    split_fun = remove_split_levels("B: Placebo"),
    labels_var = "rr_label"
  ) |>
  split_rows_by("STRATA1") |>
  split_rows_by("SEX", split_fun = keep_split_levels(c("Female", "Male"))) |>
  analyze("BMRKR2", afun = rr_afun)

tbl <- build_table(lyt_rr_full2, adsl_rr)

cwidths <- propose_column_widths(tbl)
cwidths[cwidths > 15] <- 15
cat(export_as_txt(tbl, colwidths = cwidths)) ## for wrapping
                   Active Treatment                                                          
              A: Drug X     C: Combination    B: Placebo            Risk Differences         
                                                            A: Drug X vs B:   C: Combination 
               (N=122)         (N=120)         (N=119)          Placebo        vs B: Placebo 
—————————————————————————————————————————————————————————————————————————————————————————————
A                                                                                            
  Female                                                                                     
    LOW       9.0 (7.4%)     10.0 (8.3%)      6.0 (5.0%)        A vs B            C vs B     
    MEDIUM    5.0 (4.1%)      3.0 (2.5%)     10.0 (8.4%)        A vs B            C vs B     
    HIGH      7.0 (5.7%)      4.0 (3.3%)      6.0 (5.0%)        A vs B            C vs B     
  Male                                                                                       
    LOW       3.0 (2.5%)      3.0 (2.5%)      8.0 (6.7%)        A vs B            C vs B     
    MEDIUM    4.0 (3.3%)      9.0 (7.5%)      6.0 (5.0%)        A vs B            C vs B     
    HIGH      8.0 (6.6%)      7.0 (5.8%)      5.0 (4.2%)        A vs B            C vs B     
B                                                                                            
  Female                                                                                     
    LOW       6.0 (4.9%)      6.0 (5.0%)      6.0 (5.0%)        A vs B            C vs B     
    MEDIUM    6.0 (4.9%)      8.0 (6.7%)     15.0 (12.6%)       A vs B            C vs B     
    HIGH     10.0 (8.2%)      6.0 (5.0%)      5.0 (4.2%)        A vs B            C vs B     
  Male                                                                                       
    LOW       8.0 (6.6%)      3.0 (2.5%)      5.0 (4.2%)        A vs B            C vs B     
    MEDIUM    5.0 (4.1%)      6.0 (5.0%)      6.0 (5.0%)        A vs B            C vs B     
    HIGH      5.0 (4.1%)     11.0 (9.2%)      4.0 (3.4%)        A vs B            C vs B     
C                                                                                            
  Female                                                                                     
    LOW      10.0 (8.2%)     10.0 (8.3%)      8.0 (6.7%)        A vs B            C vs B     
    MEDIUM    8.0 (6.6%)      5.0 (4.2%)      7.0 (5.9%)        A vs B            C vs B     
    HIGH     15.0 (12.3%)    12.0 (10.0%)     6.0 (5.0%)        A vs B            C vs B     
  Male                                                                                       
    LOW       6.0 (4.9%)      5.0 (4.2%)      8.0 (6.7%)        A vs B            C vs B     
    MEDIUM    6.0 (4.9%)      6.0 (5.0%)      4.0 (3.4%)        A vs B            C vs B     
    HIGH      1.0 (0.8%)      6.0 (5.0%)      4.0 (3.4%)        A vs B            C vs B     
```

A more complete exploration of creating production ready analysis
functions will be presented elsewhere in this vignette series.

## Mixed Nesting Levels

In practice, the row structure in most shells can be translated to a
layout using combinations of the methods shown above. Some shells,
however, essentially call for group summaries for all levels of a
categorical variable, but additionally call for analysis within those
groups *for only some levels of the variable*.

In clinical trial outputs we have seen this most commonly in disposition
tables, the shells of which might look something like:

                                             Active Treatment                   
                                        A: Drug X    C: Combination   B: Placebo
                                         (N=xx)         (N=xx)         (N=xx)   
    ————————————————————————————————————————————————————————————————————————————
    Asian                                   -              -              -     
      COMPLETED                         xx (xx.x%)     xx (xx.x%)     xx (xx.x%)
      DISCONTINUED                      xx (xx.x%)     xx (xx.x%)     xx (xx.x%)
        ADVERSE EVENT                   xx (xx.x%)     xx (xx.x%)     xx (xx.x%)
        LACK OF EFFICACY                xx (xx.x%)     xx (xx.x%)     xx (xx.x%)
        PHYSICIAN DECISION              xx (xx.x%)     xx (xx.x%)     xx (xx.x%)
        PROTOCOL VIOLATION              xx (xx.x%)     xx (xx.x%)     xx (xx.x%)
        WITHDRAWAL BY PARENT/GUARDIAN   xx (xx.x%)     xx (xx.x%)     xx (xx.x%)
        WITHDRAWAL BY SUBJECT           xx (xx.x%)     xx (xx.x%)     xx (xx.x%)
      ONGOING                           xx (xx.x%)     xx (xx.x%)     xx (xx.x%)
    Black                                   -              -              -     
      COMPLETED                         xx (xx.x%)     xx (xx.x%)     xx (xx.x%)
      DISCONTINUED                      xx (xx.x%)     xx (xx.x%)     xx (xx.x%)
        ADVERSE EVENT                   xx (xx.x%)     xx (xx.x%)     xx (xx.x%)
        LACK OF EFFICACY                xx (xx.x%)     xx (xx.x%)     xx (xx.x%)
        PHYSICIAN DECISION              xx (xx.x%)     xx (xx.x%)     xx (xx.x%)
        PROTOCOL VIOLATION              xx (xx.x%)     xx (xx.x%)     xx (xx.x%)
        WITHDRAWAL BY PARENT/GUARDIAN   xx (xx.x%)     xx (xx.x%)     xx (xx.x%)
        WITHDRAWAL BY SUBJECT           xx (xx.x%)     xx (xx.x%)     xx (xx.x%)
      ONGOING                           xx (xx.x%)     xx (xx.x%)     xx (xx.x%)

In this shell, the `COMPLETED`, `DISCONTINUED` and `ONGOING` rows are
siblings (derived from the `EOSSTT` variable), however only the
`DISCONTINUED` row acts as a group summary row for a facet containing
further analysis; the other two essentially act as individual rows.

This type of structure where individual analysis rows and facets/group
summary rows are direct siblings is not currently supported by the
`rtables` layouting and tabulation engines, and is *somewhat* supported
when created via, e.g., trimming rows of a created table.

The above said, we can arrive at a table which renders as desired using
the *two-tier analysis function* strategy.

The key to the two-tier analysis function strategy is to generate both
levels of row in the same analysis function and simply use indent
modifiers to differentiate them.

Below is a simple `afun` that implements this strategy. For the purposes
of this lesson readers can ignore the details of what this function does
if desired; analysis function design and implementation will be covered
in another vignette in the advanced section.

``` r
simple_two_tier <- function(df, .var, .N_col, inner_var, drill_down_levs) {
  ## group EOSSTT counts
  outer_tbl <- table(df[[.var]])

  cells <- lapply(
    names(outer_tbl),
    function(nm) {
      ## simulated group summary rows
      cont_cell <- rcell(outer_tbl[nm] * c(1, 1 / .N_col),
        format = "xx (xx.x%)"
      )
      if (nm %in% drill_down_levs) {
        ## detail (DCSREAS) counts
        inner_tbl <- table(df[[inner_var]])
        ## note indent_mod
        detail_cells <- lapply(
          names(inner_tbl),
          function(innm) {
            rcell(inner_tbl[innm] * c(1, 1 / .N_col),
              format = "xx (xx.x%)",
              ## appearance of "detail drill-down"
              indent_mod = 1L
            )
          }
        )
        names(detail_cells) <- names(inner_tbl)
      } else {
        detail_cells <- NULL
      }
      c(setNames(list(cont_cell), nm), detail_cells)
    }
  )

  in_rows(.list = unlist(cells, recursive = FALSE))
}

lyt_two_tier <- basic_table() |>
  analyze("EOSSTT",
    afun = simple_two_tier,
    extra_args = list(inner_var = "DCSREAS", drill_down_levs = "DISCONTINUED")
  )

build_table(lyt_two_tier, adsl_rr)
                                    all obs  
—————————————————————————————————————————————
COMPLETED                         181 (50.1%)
DISCONTINUED                      112 (31.0%)
  ADVERSE EVENT                    18 (5.0%) 
  LACK OF EFFICACY                 24 (6.6%) 
  PHYSICIAN DECISION               15 (4.2%) 
  PROTOCOL VIOLATION               20 (5.5%) 
  WITHDRAWAL BY PARENT/GUARDIAN    14 (3.9%) 
  WITHDRAWAL BY SUBJECT            21 (5.8%) 
ONGOING                           68 (18.8%) 
```

As in other cases, we can add the row- and column- structure
orthogonally (provided the analysis behavior is truly orthogonal to the
faceting, as it is in this shell):

``` r
lyt_two_tier_full <- basic_table() |>
  split_cols_by("span_label",
    split_fun = trim_levels_to_map(span_label_map)
  ) |>
  split_cols_by("ARM", show_colcounts = TRUE) |>
  split_rows_by("RACE", split_fun = keep_split_levels(c("Asian", "Black"))) |>
  analyze("EOSSTT",
    afun = simple_two_tier,
    extra_args = list(inner_var = "DCSREAS", drill_down_levs = "DISCONTINUED")
  )

build_table(lyt_two_tier_full, adsl_rr)
                                         Active Treatment                   
                                    A: Drug X    C: Combination   B: Placebo
                                     (N=122)        (N=120)        (N=119)  
————————————————————————————————————————————————————————————————————————————
Asian                                                                       
  COMPLETED                         32 (26.2%)     35 (29.2%)     31 (26.1%)
  DISCONTINUED                      18 (14.8%)     23 (19.2%)     26 (21.8%)
    ADVERSE EVENT                    4 (3.3%)       5 (4.2%)       4 (3.4%) 
    LACK OF EFFICACY                 5 (4.1%)       2 (1.7%)       5 (4.2%) 
    PHYSICIAN DECISION               2 (1.6%)       4 (3.3%)       4 (3.4%) 
    PROTOCOL VIOLATION               1 (0.8%)       5 (4.2%)       7 (5.9%) 
    WITHDRAWAL BY PARENT/GUARDIAN    3 (2.5%)       2 (1.7%)       1 (0.8%) 
    WITHDRAWAL BY SUBJECT            3 (2.5%)       5 (4.2%)       5 (4.2%) 
  ONGOING                           16 (13.1%)     13 (10.8%)      9 (7.6%) 
Black                                                                       
  COMPLETED                         13 (10.7%)     19 (15.8%)     16 (13.4%)
  DISCONTINUED                      12 (9.8%)       6 (5.0%)       6 (5.0%) 
    ADVERSE EVENT                    2 (1.6%)       1 (0.8%)       0 (0.0%) 
    LACK OF EFFICACY                 4 (3.3%)       1 (0.8%)       2 (1.7%) 
    PHYSICIAN DECISION               1 (0.8%)       1 (0.8%)       2 (1.7%) 
    PROTOCOL VIOLATION               3 (2.5%)       0 (0.0%)       1 (0.8%) 
    WITHDRAWAL BY PARENT/GUARDIAN    2 (1.6%)       0 (0.0%)       0 (0.0%) 
    WITHDRAWAL BY SUBJECT            0 (0.0%)       3 (2.5%)       1 (0.8%) 
  ONGOING                            5 (4.1%)       3 (2.5%)       6 (5.0%) 
```

Thus we have created our desired output.
