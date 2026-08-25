# Intermediate rtables - Identifying Required Analysis Behavior

## Introduction

Analysis functions can do anything. While this provides one of the
backbones of `rtables`’ power and flexibility, it also means that
analysis functions must be chosen (and designed) with care to ensure our
resulting tables contain the correct statistics.

While the diversity of tables is such that custom analysis functions
will inevitably be needed in some cases, we will not address the
*creation* of analysis functions in detail here; that is covered in
within the
[advanced](https://pharmaverse.github.io/rtables/articles/advanced_usage.md)
portion of this guided tour. Here we will focus on *selecting* analysis
functions and the reasoning that goes into that choice. While this might
seem like a strange distinction at first glance, this is in fact how
most tables will be created - when a template script or function is not
used to create them from whole cloth; packages like
[tern](https://cran.r-project.org/package=tern) and
[junco](https://cran.r-project.org/package=junco) provide libraries of
well-tested analysis functions that statistical programmers will often
simply select from when creating production outputs.

## Who Are Your Numbers And What Do They Do?

The details of what a desired analysis behavior calls for can be
categorized into two distinct types: specific and fundamental. Specific
analysis behaviors are things like which particular statistical test or
confidence interval method should be used, how missing or censored data
should be handled, etc.

Before specific details can be considered, however, the fundamental
aspects of the desired behavior must be determined. These come down to
three aspects fundamental to how the contents of our table are intended
to be interpreted:

1.  The **type** of observation being *counted or analyzed*,
2.  The **(sub)population** we are *analyzing within* or *comparing
    against*, and
3.  Whether the behavior is **conditional**, depending on the facet it
    is populating.

### There’s Counting And Then There’s Counting…

Consider the “simple” act of counting the frequency of different types
of adverse events (AEs) that occurred in a clinical trial; this could
mean one of two quite different things:

1.  The number of **(unique) patients** which suffered a particular AE,
    or
2.  The number of **times the AE was suffered**

These will generally give dramatically different numbers, as illustrated
by the table below, and one or both may be desired in a given table.

``` r
double_count <- function(x) {
  in_rows(
    "Unique Patients" = length(unique(x)),
    "Total Events" = length(x)
  )
}

lyt_counts <- basic_table() |>
  split_cols_by("ARM") |>
  split_rows_by("AEBODSYS", split_fun = trim_levels_in_group("AEDECOD")) |>
  split_rows_by("AEDECOD") |>
  analyze("USUBJID", afun = double_count)

build_table(lyt_counts, ex_adae, alt_counts_df = ex_adsl)
                      A: Drug X   B: Placebo   C: Combination
—————————————————————————————————————————————————————————————
cl A.1                                                       
  dcd A.1.1.1.1                                              
    Unique Patients      50           45             63      
    Total Events         64           62             88      
  dcd A.1.1.1.2                                              
    Unique Patients      48           48             50      
    Total Events         68           68             72      
cl B.1                                                       
  dcd B.1.1.1.1                                              
    Unique Patients      47           49             43      
    Total Events         56           60             62      
cl B.2                                                       
  dcd B.2.1.2.1                                              
    Unique Patients      49           44             52      
    Total Events         65           62             66      
  dcd B.2.2.3.1                                              
    Unique Patients      48           54             51      
    Total Events         64           76             77      
cl C.1                                                       
  dcd C.1.1.1.3                                              
    Unique Patients      43           46             43      
    Total Events         55           63             64      
cl C.2                                                       
  dcd C.2.1.2.1                                              
    Unique Patients      35           48             55      
    Total Events         48           53             65      
cl D.1                                                       
  dcd D.1.1.1.1                                              
    Unique Patients      50           42             51      
    Total Events         61           51             71      
  dcd D.1.1.4.2                                              
    Unique Patients      48           42             50      
    Total Events         66           55             64      
cl D.2                                                       
  dcd D.2.1.5.3                                              
    Unique Patients      47           58             57      
    Total Events         62           72             74      
```

### Denominators

Once we have defined counting, we often want to display percents
alongside the absolute counts. Even with the meaning of our counts
fixed, however, this can mean a number of different things, depending on
***the (sub)population we are considering the count a percent of***.
Different denominators used in production can include the overall
relevant count for the:

1.  column (often trial arm)
2.  individual facet (row x column)
3.  row group (across all columns)
4.  ancestor row facet (across all columns)
5.  ancestor row facet for a single column

Keeping in mind that each of the above might be either of the two
**types** of counting discussed above (generally events or patients in a
clinical trial setting).

Furthermore, these denominators can often need to be derived from the
`alt_counts_df` used to build the table when counting patients, rather
than the data being directly tabulated, due to the fact that not all
patients are guaranteed to appear in event based datasets (e.g.,
`ADAE`).

As before, we can see that these denominators can vary wildly, which
would cause the percents displayed to do so as well. We will use a
custom afun (`disp_denoms`) to explore the differences between the above
types of denominators. The details of how we implement the `disp_denoms`
function used below is not germane to our discussion here but motivated
readers can choose to inspect it below.

`disp_denoms`` ``<-`` ``function``(``x``, ``.var``, ``.N_col``, ``.df_row``, ``.alt_df_full``, ``.spl_context``)`` ``{`` `` ``## myfn <- RefFootnote("Patients observed in AE data", symbol = "*")`` `` ``parent_df`` ``<-`` ``.spl_context``$``full_parent_df``[[``3``]``]`` `` ``parent_df_onecol`` ``<-`` ``parent_df``[`[`eval`](https://rdrr.io/r/base/eval.html)`(``.spl_context``$``cur_col_expr``[[``1``]``]``, envir ``=`` ``parent_df``)``, ``]`` `` ``gparent_df`` ``<-`` ``.spl_context``$``full_parent_df``[[``2``]``]`` `` ``gparent_df_onecol`` ``<-`` ``gparent_df``[`[`eval`](https://rdrr.io/r/base/eval.html)`(``.spl_context``$``cur_col_expr``[[``1``]``]``, envir ``=`` ``gparent_df``)``, ``]`` `` ``cur_race`` ``<-`` ``.spl_context``$``value``[``2``]`` `` ``cur_aebodsys`` ``<-`` ``.spl_context``$``value``[``3``]`` `` ``cur_aedecod`` ``<-`` ``.spl_context``$``value``[``4``]`` `` ``alt_df_race`` ``<-`` `[`subset`](https://rdrr.io/r/base/subset.html)`(``.alt_df_full``, ``RACE`` ``==`` ``cur_race``)`` `` ``alt_df_race_col`` ``<-`` ``alt_df_race``[`[`eval`](https://rdrr.io/r/base/eval.html)`(``.spl_context``$``cur_col_expr``[[``1``]``]``, envir ``=`` ``alt_df_race``)``, ``]`` `` `` ``vals`` ``<-`` `[`list`](https://rdrr.io/r/base/list.html)`(`` `` ``.N_col``,`` `` `[`length`](https://rdrr.io/r/base/length.html)`(``x``)``,`` `` `[`length`](https://rdrr.io/r/base/length.html)`(`[`unique`](https://rdrr.io/r/base/unique.html)`(``x``)``)``,`` `` ``NA``,`` `` `[`NROW`](https://rdrr.io/r/base/nrow.html)`(``.df_row``)``,`` `` `[`length`](https://rdrr.io/r/base/length.html)`(`[`unique`](https://rdrr.io/r/base/unique.html)`(``.df_row``[[``.var``]``]``)``)``,`` `` ``NA``,`` `` `[`NROW`](https://rdrr.io/r/base/nrow.html)`(``parent_df``)``,`` `` `[`length`](https://rdrr.io/r/base/length.html)`(`[`unique`](https://rdrr.io/r/base/unique.html)`(``parent_df``[[``.var``]``]``)``)``,`` `` `[`NROW`](https://rdrr.io/r/base/nrow.html)`(``parent_df_onecol``)``,`` `` `[`length`](https://rdrr.io/r/base/length.html)`(`[`unique`](https://rdrr.io/r/base/unique.html)`(``parent_df_onecol``[[``.var``]``]``)``)``,`` `` `[`NROW`](https://rdrr.io/r/base/nrow.html)`(``gparent_df``)``,`` `` `[`length`](https://rdrr.io/r/base/length.html)`(`[`unique`](https://rdrr.io/r/base/unique.html)`(``gparent_df``[[``.var``]``]``)``)``,`` `` `[`NROW`](https://rdrr.io/r/base/nrow.html)`(``alt_df_race``)``,`` `` `[`NROW`](https://rdrr.io/r/base/nrow.html)`(``gparent_df_onecol``)``,`` `` `[`length`](https://rdrr.io/r/base/length.html)`(`[`unique`](https://rdrr.io/r/base/unique.html)`(``gparent_df_onecol``[[``.var``]``]``)``)``,`` `` `[`NROW`](https://rdrr.io/r/base/nrow.html)`(``alt_df_race_col``)`` `` ``)`` `` `[`names`](https://rdrr.io/r/base/names.html)`(``vals``)`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(`` `` ``"Column N"``,`` `` ``"facet events"``,`` `` ``"facet patients"``,`` `` ``"facet patients - alt df"``,`` `` `[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"%s events"``, ``cur_aedecod``)``,`` `` `[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"%s patients"``, ``cur_aedecod``)``,`` `` `[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"%s patients - alt df"``, ``cur_aedecod``)``,`` `` `[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"%s events (all arms)"``, ``cur_aebodsys``)``,`` `` `[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"%s patients (all arms)"``, ``cur_aebodsys``)``,`` `` `[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"%s events (this arm)"``, ``cur_aebodsys``)``,`` `` `[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"%s patients (this arm)"``, ``cur_aebodsys``)``,`` `` `[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"%s events (all arms)"``, ``cur_race``)``,`` `` `[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"%s patients (all arms)"``, ``cur_race``)``,`` `` `[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"%s patients (all arms) - alt df"``, ``cur_race``)``,`` `` `[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"%s events (this arms)"``, ``cur_race``)``,`` `` `[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"%s patients (this arms)"``, ``cur_race``)``,`` `` `[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"%s patients (this arms) - alt df"``, ``cur_race``)`` `` ``)`` `` `` `[`in_rows`](https://pharmaverse.github.io/rtables/reference/in_rows.md)`(``.list ``=`` ``vals``)`` ``}`

With `disp_denoms` defined, we can proceed with using it to see how
varied the options for denominator are when calculating a percent:

``` r
map <- tribble(
  ~RACE, ~AEBODSYS, ~AEDECOD,
  "ASIAN", "cl B.2", "dcd B.2.2.3.1",
  "WHITE", "cl A.1", "dcd A.1.1.1.1"
)

lyt_denoms <- basic_table() |>
  split_cols_by("ARM") |>
  split_rows_by("RACE", split_fun = trim_levels_to_map(map)) |> ## keep_split_levels(c("ASIAN", "WHITE"))) |>
  split_rows_by("AEBODSYS") |> # , split_fun = trim_levels_in_group("AEDECOD")) |>
  split_rows_by("AEDECOD") |>
  analyze("USUBJID", afun = disp_denoms)

build_table(lyt_denoms, ex_adae, alt_counts_df = ex_adsl)
                                            A: Drug X   B: Placebo   C: Combination
———————————————————————————————————————————————————————————————————————————————————
ASIAN                                                                              
  cl B.2                                                                           
    dcd B.2.2.3.1                                                                  
      Column N                                 134         134            132      
      facet events                             37           38             48      
      facet patients                           27           27             30      
      facet patients - alt df                  NA           NA             NA      
      dcd B.2.2.3.1 events                     123         123            123      
      dcd B.2.2.3.1 patients                   84           84             84      
      dcd B.2.2.3.1 patients - alt df          NA           NA             NA      
      cl B.2 events (all arms)                 123         123            123      
      cl B.2 patients (all arms)               84           84             84      
      cl B.2 events (this arm)                 37           38             48      
      cl B.2 patients (this arm)               27           27             30      
      ASIAN events (all arms)                  123         123            123      
      ASIAN patients (all arms)                84           84             84      
      ASIAN patients (all arms) - alt df       208         208            208      
      ASIAN events (this arms)                 37           38             48      
      ASIAN patients (this arms)               27           27             30      
      ASIAN patients (this arms) - alt df      68           67             73      
WHITE                                                                              
  cl A.1                                                                           
    dcd A.1.1.1.1                                                                  
      Column N                                 134         134            132      
      facet events                             14           19             13      
      facet patients                            9           14             10      
      facet patients - alt df                  NA           NA             NA      
      dcd A.1.1.1.1 events                     46           46             46      
      dcd A.1.1.1.1 patients                   33           33             33      
      dcd A.1.1.1.1 patients - alt df          NA           NA             NA      
      cl A.1 events (all arms)                 46           46             46      
      cl A.1 patients (all arms)               33           33             33      
      cl A.1 events (this arm)                 14           19             13      
      cl A.1 patients (this arm)                9           14             10      
      WHITE events (all arms)                  46           46             46      
      WHITE patients (all arms)                33           33             33      
      WHITE patients (all arms) - alt df       74           74             74      
      WHITE events (this arms)                 14           19             13      
      WHITE patients (this arms)                9           14             10      
      WHITE patients (this arms) - alt df      27           26             21      
```

The above table displays the various denominators we might use across
both types of counting discussed in the previous section. Each of these
denominator choices would result in at least one difference in
calculated percent from all other choices across the full table (barring
any coincidental equality between count types in your data). Thus when
programming against a table shell with the ubiquitous “xx (xx.x%)”
family of formats, we must **carefully choose an afun which calculates
the *correct type of percent***.

Many existing analysis functions provided by production libraries such
as `tern` and `junco` support different denominator options for use when
calculating percents out of the box, though they do not all support the
full breadth of variety explored above. Nonetheless, careful
consideration of the existing analysis functions available to you and
what they support should be made before choosing to create a custom one.

## “Yeah But What If” … Conditionality In `afun`s

While many tables call for analysis functions which perform identical
calculations across all facets they are applied within, this is **not**
a requirement of the `rtables` framework. In this vignette we will not
discuss the *creation* of analysis functions which support creating
facet-conditional cell values; rather we will discuss *identifying* when
such analysis functions are required, leaving the implementation of
`afun`s with complex behavior to advanced portion(s) of this tour.

### Conditionality Based On Column Facet

In point of fact, we saw conditionality on the current column in the
[previous
vignette](https://pharmaverse.github.io/rtables/articles/guided_intermediate_translating_shells.md)
when translating shells with risk difference columns; there the dummy
`afun` we used calculated count-percent values for facets in the “main
portion” of the table and displayed a custom string for facets in the
risk difference portion. In real tables that string would be replaced
with actual risk difference calculations, of course, but the
conditionality itself is the same.

Generally speaking, `afun`s we use will need this type of column-facet
conditionality any time we have a *heterogeneous column structure*
(i.e., any time we have non-nested column faceting in our layout). In
these cases analysts will need to use `afuns` specifically designed to
support the specific type of column structure their layout declares.

There is not currently a production-ready way to combine `afun`s into a
single function and declare the conditions under which each should be
used, though we we will explore this as an exercise in the advanced
portion of this tour.

### Conditionality Based On Row Facet

Unlike column-conditional `afun`s, purely row-conditional `afun`s do not
generate rows which have values with different meanings for different
cells in the row. Rather, row-conditionality manifests as different row
facets containing different numbers of rows and/or entire rows or sets
of rows with different types of content based on the current row facet.

A common example of a shell with different numbers of rows depending on
the row facet is one summarizing patient visits (`AVISIT`). In such
tables, the row facet for the initial or `BASELINE` visit will often
have only a subset of those in the other facets, as those will contain
comparisons to the baseline visit.

`avisit_afun`` ``<-`` ``function``(``df``, ``.var``, ``.spl_context``)`` ``{`` `` ``cur_visit`` ``<-`` `[`tail`](https://pharmaverse.github.io/rtables/reference/head_tail.md)`(``.spl_context``$``value``, ``1``)`` `` ``vals`` ``<-`` `[`list`](https://rdrr.io/r/base/list.html)`(``"Mean Patient DIABP"`` ``=`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``df``[[``.var``]``]``)``)`` `` ``pardf`` ``<-`` `[`head`](https://pharmaverse.github.io/rtables/reference/head_tail.md)`(``.spl_context``$``full_parent_df``, ``1``)``[[``1``]``]`` `` `` ``if`` ``(``!``(`[`as.character`](https://rdrr.io/r/base/character.html)`(``cur_visit``)`` `[`%in%`](https://rdrr.io/r/base/match.html)` `[`c`](https://rdrr.io/r/base/c.html)`(``"SCREENING"``, ``"BASELINE"``)``)``)`` ``{`` `` ``pardf`` ``<-`` `[`subset`](https://rdrr.io/r/base/subset.html)`(``pardf``, ``AVISIT`` `[`%in%`](https://rdrr.io/r/base/match.html)` `[`c`](https://rdrr.io/r/base/c.html)`(``"BASELINE"``, ``cur_visit``)``)`` `` ``difs`` ``<-`` `[`tapply`](https://rdrr.io/r/base/tapply.html)`(`` `` `[`seq_len`](https://rdrr.io/r/base/seq.html)`(`[`nrow`](https://rdrr.io/r/base/nrow.html)`(``pardf``)``)``, ``pardf``$``USUBJID``,`` `` ``function``(``iis``)`` ``{`` `` ``avalvec`` ``<-`` ``pardf``$``AVAL``[``iis``]`` `` ``bl`` ``<-`` `[`which`](https://rdrr.io/r/base/which.html)`(`[`as.character`](https://rdrr.io/r/base/character.html)`(``pardf``[``iis``, ``]``$``AVISIT``)`` ``==`` ``"BASELINE"``)`` `` `[`mean`](https://rdrr.io/r/base/mean.html)`(``avalvec``[``-``bl``]`` ``-`` ``avalvec``[``bl``]``)`` `` ``}`` `` ``)`` `` ``vals`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``vals``, `[`list`](https://rdrr.io/r/base/list.html)`(``"Mean Diff From Patient's Baseline DIABP"`` ``=`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``difs``)``)``)`` `` ``}`` `` `` `[`in_rows`](https://pharmaverse.github.io/rtables/reference/in_rows.md)`(``.list ``=`` ``vals``)`` ``}`

We can see this behavior using a basic row-conditional `afun` (defined
above for those curious):

``` r
lyt_rowcond <- basic_table() |>
  split_rows_by("AVISIT") |>
  analyze("AVAL", avisit_afun, format = "xx.xx")

build_table(lyt_rowcond, subset(ex_advs, PARAMCD == "DIABP"))
                                            all obs
———————————————————————————————————————————————————
SCREENING                                          
  Mean Patient DIABP                         50.30 
BASELINE                                           
  Mean Patient DIABP                         50.04 
WEEK 1 DAY 8                                       
  Mean Patient DIABP                         49.60 
  Mean Diff From Patient's Baseline DIABP    -0.44 
WEEK 2 DAY 15                                      
  Mean Patient DIABP                         50.18 
  Mean Diff From Patient's Baseline DIABP    0.13  
WEEK 3 DAY 22                                      
  Mean Patient DIABP                         49.92 
  Mean Diff From Patient's Baseline DIABP    -0.13 
WEEK 4 DAY 29                                      
  Mean Patient DIABP                         49.80 
  Mean Diff From Patient's Baseline DIABP    -0.24 
WEEK 5 DAY 36                                      
  Mean Patient DIABP                         49.34 
  Mean Diff From Patient's Baseline DIABP    -0.70 
```

In the above table, we display only the mean of the measurement for that
visit (simulated `DIABP` in this case) for the `SCREENING` and
`BASELINE` visits, while we additionally display the mean of the
per-patient difference between their values for that visit and their
baseline visit for follow-up visits.

### Why Not Both?

It is important to note that while we described row- and column-facet
conditionality separately in this section, an `afun` can be both
simultaneously. In fact an `afun`’s column conditionality can itself be
dependent on which row facet it is in.

The most straightforward example of this type of “dual conditionality”
is when we have heterogeneous column structure, but the additional
columns should only be populated for some portions of the table and left
blank for others.

For this example we repeat the same data preparation as in the Risk
Difference Columns section [in the previous
chapter](https://pharmaverse.github.io/rtables/articles/guided_intermediate_translating_shells.md)
without further comment.

`advs`` ``<-`` ``ex_advs`` ``advs``$``span_label`` ``<-`` ``"Active Treatment"`` ``advs``$``span_label``[``advs``$``ARM`` ``==`` ``"B: Placebo"``]`` ``<-`` ``" "`` `` ``span_label_map`` ``<-`` `[`tribble`](https://tibble.tidyverse.org/reference/tribble.html)`(`` `` ``~``span_label``, ``~``ARM``,`` `` ``"Active Treatment"``, ``"A: Drug X"``,`` `` ``"Active Treatment"``, ``"C: Combination"``,`` `` ``" "``, ``"B: Placebo"``,`` ``)`` `` ``advs``$``rr_header`` ``<-`` ``"Risk Differences"`` ``advs``$``rr_label`` ``<-`` `[`paste`](https://rdrr.io/r/base/paste.html)`(`[`substr`](https://rdrr.io/r/base/substr.html)`(``advs``$``ARM``, ``1``, ``1``)``, ``"vs B"``)`

We can then define an afun which populates the “risk difference” columns
only for follow up visits and leaves them blank otherwise:

`in_risk_diff`` ``<-`` ``function``(``spl_context``)`` `[`grepl`](https://rdrr.io/r/base/grep.html)`(``"Risk Differences"``, ``spl_context``$``cur_col_id``[``1``]``)`` `` ``avisit_afun2`` ``<-`` ``function``(``df``, ``.var``, ``.spl_context``)`` ``{`` `` ``in_rd`` ``<-`` ``in_risk_diff``(``.spl_context``)`` `` `` ``cur_visit`` ``<-`` `[`tail`](https://pharmaverse.github.io/rtables/reference/head_tail.md)`(``.spl_context``$``value``, ``1``)`` `` ``is_followup`` ``<-`` ``!``(`[`as.character`](https://rdrr.io/r/base/character.html)`(``cur_visit``)`` `[`%in%`](https://rdrr.io/r/base/match.html)` `[`c`](https://rdrr.io/r/base/c.html)`(``"SCREENING"``, ``"BASELINE"``)``)`` `` ``if`` ``(``!``in_rd``)`` ``{`` `` ``vals`` ``<-`` `[`list`](https://rdrr.io/r/base/list.html)`(``"Mean Patient DIABP"`` ``=`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``df``[[``.var``]``]``)``)`` `` ``}`` ``else`` ``if`` ``(``!``is_followup``)`` ``{`` `` ``vals`` ``<-`` `[`list`](https://rdrr.io/r/base/list.html)`(``"Mean Patient DIABP"`` ``=`` ``NULL``)`` `` ``}`` ``else`` ``{`` `` ``vals`` ``<-`` `[`list`](https://rdrr.io/r/base/list.html)`(``"Mean Patient DIABP"`` ``=`` `[`rcell`](https://pharmaverse.github.io/rtables/reference/rcell.md)`(``"-"``, format ``=`` ``"xx"``)``)`` `` ``}`` `` ``pardf`` ``<-`` `[`head`](https://pharmaverse.github.io/rtables/reference/head_tail.md)`(``.spl_context``$``full_parent_df``, ``1``)``[[``1``]``]`` `` `` ``if`` ``(``is_followup``)`` ``{`` `` ``if`` ``(``!``in_rd``)`` ``{`` `` ``pardf`` ``<-`` `[`subset`](https://rdrr.io/r/base/subset.html)`(``pardf``, ``AVISIT`` `[`%in%`](https://rdrr.io/r/base/match.html)` `[`c`](https://rdrr.io/r/base/c.html)`(``"BASELINE"``, ``cur_visit``)``)`` `` ``difs`` ``<-`` `[`tapply`](https://rdrr.io/r/base/tapply.html)`(`` `` `[`seq_len`](https://rdrr.io/r/base/seq.html)`(`[`nrow`](https://rdrr.io/r/base/nrow.html)`(``pardf``)``)``, ``pardf``$``USUBJID``,`` `` ``function``(``iis``)`` ``{`` `` ``avalvec`` ``<-`` ``pardf``$``AVAL``[``iis``]`` `` ``bl`` ``<-`` `[`which`](https://rdrr.io/r/base/which.html)`(`[`as.character`](https://rdrr.io/r/base/character.html)`(``pardf``[``iis``, ``]``$``AVISIT``)`` ``==`` ``"BASELINE"``)`` `` `[`mean`](https://rdrr.io/r/base/mean.html)`(``avalvec``[``-``bl``]`` ``-`` ``avalvec``[``bl``]``)`` `` ``}`` `` ``)`` `` ``vals`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``vals``, `[`list`](https://rdrr.io/r/base/list.html)`(``"Mean Diff From Baseline"`` ``=`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``difs``)``)``)`` `` ``}`` ``else`` ``{`` `` ``armlabel`` ``<-`` `[`tail`](https://pharmaverse.github.io/rtables/reference/head_tail.md)`(``.spl_context``$``cur_col_split_val``[[``1``]``]``, ``1``)`` ``# last split value, ie arm`` `` ``armletter`` ``<-`` `[`substr`](https://rdrr.io/r/base/substr.html)`(``armlabel``, ``1``, ``1``)`` `` ``vals`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``vals``, `[`list`](https://rdrr.io/r/base/list.html)`(``"Mean Diff From Baseline"`` ``=`` `[`rcell`](https://pharmaverse.github.io/rtables/reference/rcell.md)`(`[`paste`](https://rdrr.io/r/base/paste.html)`(``armletter``, ``"vs B"``)``, format ``=`` ``"xx"``)``)``)`` `` ``}`` `` ``}`` `` `` `[`in_rows`](https://pharmaverse.github.io/rtables/reference/in_rows.md)`(``.list ``=`` ``vals``)`` ``}`

With that done, we can construct a table that has dual conditionality in
its cell contents.

``` r
lyt_fullcond <- basic_table() |>
  split_cols_by("span_label", split_fun = trim_levels_to_map(span_label_map)) |>
  split_cols_by("ARM", show_colcounts = TRUE) |>
  split_cols_by("rr_header", nested = FALSE) |>
  split_cols_by("ARM", labels_var = "rr_label", split_fun = remove_split_levels("B: Placebo")) |>
  split_rows_by("AVISIT") |>
  analyze("AVAL", avisit_afun2, format = "xx.xx")


build_table(lyt_fullcond, subset(advs, PARAMCD == "DIABP"))
                                 Active Treatment                                        
                            A: Drug X   C: Combination   B: Placebo    Risk Differences  
                             (N=938)       (N=924)        (N=938)      A vs B     C vs B 
—————————————————————————————————————————————————————————————————————————————————————————
SCREENING                                                                                
  Mean Patient DIABP          49.97         50.19          50.75                         
BASELINE                                                                                 
  Mean Patient DIABP          48.60         51.11          50.44                         
WEEK 1 DAY 8                                                                             
  Mean Patient DIABP          50.26         48.86          49.67         -          -    
  Mean Diff From Baseline     -0.44         -0.44          -0.44       A vs B     C vs B 
WEEK 2 DAY 15                                                                            
  Mean Patient DIABP          50.84         49.98          49.72         -          -    
  Mean Diff From Baseline     0.13           0.13           0.13       A vs B     C vs B 
WEEK 3 DAY 22                                                                            
  Mean Patient DIABP          50.71         49.94          49.09         -          -    
  Mean Diff From Baseline     -0.13         -0.13          -0.13       A vs B     C vs B 
WEEK 4 DAY 29                                                                            
  Mean Patient DIABP          50.07         49.71          49.62         -          -    
  Mean Diff From Baseline     -0.24         -0.24          -0.24       A vs B     C vs B 
WEEK 5 DAY 36                                                                            
  Mean Patient DIABP          50.57         49.09          48.37         -          -    
  Mean Diff From Baseline     -0.70         -0.70          -0.70       A vs B     C vs B 
```

## A Final Note On `afun` Complexity

Many production `afun`s, such as those provided by `tern` or `junco`,
support multiple behaviors that are controlled user specified arguments
(passed via `extra_args`). This can be used to control denominator
types, choice of statistical methods, and anything else the developers
wish. This is a separate type of complexity from behavior that is
conditional on column or row structure – and in fact can be combined
with such – but it is nonetheless important to consider when choosing
which `afun` to use.
