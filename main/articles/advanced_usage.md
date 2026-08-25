# {rtables} Advanced Usage

## NOTE

This vignette is currently under development. Any code or prose which
appears in a version of this vignette on the `main` branch of the
repository will work/be correct, but they likely are not in their final
form.

Initialization

[`library`](https://rdrr.io/r/base/library.html)`(`[`rtables`](https://github.com/pharmaverse/rtables)`)`

## Control splitting with provided function (limited customization)

rtables provides an array of functions to control the splitting logic
without creating an entirely new split functions. By default
`split_*_by` facets data based on categorical variable.

`d1`` ``<-`` `[`subset`](https://rdrr.io/r/base/subset.html)`(``ex_adsl``, ``AGE`` ``<`` ``25``)`` ``d1``$``AGE`` ``<-`` `[`as.factor`](https://rdrr.io/r/base/factor.html)`(``d1``$``AGE``)`` ``lyt1`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`` `` `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"AGE"``)`` ``|>`` `` `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"SEX"``)`` `` `[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt1``, ``d1``)`

    ##                    20   21   23   24
    ## ————————————————————————————————————
    ## F                  0    2    4    5 
    ## M                  1    1    2    3 
    ## U                  0    0    0    0 
    ## UNDIFFERENTIATED   0    0    0    0

For continuous variables, the `split_*_by_cutfun` can be leveraged to
create categories and the corresponding faceting, when the break points
are dependent from the data.

`sd_cutfun`` ``<-`` ``function``(``x``)`` ``{`` `` ``cutpoints`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(`` `` `[`min`](https://rdrr.io/r/base/Extremes.html)`(``x``)``,`` `` `[`mean`](https://rdrr.io/r/base/mean.html)`(``x``)`` ``-`` `[`sd`](https://rdrr.io/r/stats/sd.html)`(``x``)``,`` `` `[`mean`](https://rdrr.io/r/base/mean.html)`(``x``)`` ``+`` `[`sd`](https://rdrr.io/r/stats/sd.html)`(``x``)``,`` `` `[`max`](https://rdrr.io/r/base/Extremes.html)`(``x``)`` `` ``)`` `` `` `[`names`](https://rdrr.io/r/base/names.html)`(``cutpoints``)`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``""``, ``"Low"``, ``"Medium"``, ``"High"``)`` `` ``cutpoints`` ``}`` `` ``lyt1`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`` `` `[`split_cols_by_cutfun`](https://pharmaverse.github.io/rtables/reference/varcuts.md)`(``"AGE"``, cutfun ``=`` ``sd_cutfun``)`` ``|>`` `` `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"SEX"``)`` `` `[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt1``, ``ex_adsl``)`

    ##                    Low   Medium   High
    ## ——————————————————————————————————————
    ## F                  36     165      21 
    ## M                  21     115      30 
    ## U                   1      8       0  
    ## UNDIFFERENTIATED    0      1       2

Alternatively, `split_*_by_cuts` can be used when breakpoints are
predefined and `split_*_by_quartiles` when the data should be faceted by
quantile.

`lyt1`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`` `` `[`split_cols_by_cuts`](https://pharmaverse.github.io/rtables/reference/varcuts.md)`(`` `` ``"AGE"``,`` `` cuts ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``0``, ``30``, ``60``, ``100``)``,`` `` cutlabels ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"0-30 y.o."``, ``"30-60 y.o."``, ``"60-100 y.o."``)`` `` ``)`` ``|>`` `` `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"SEX"``)`` `` `[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt1``, ``ex_adsl``)`

    ##                    0-30 y.o.   30-60 y.o.   60-100 y.o.
    ## ———————————————————————————————————————————————————————
    ## F                     71          150            1     
    ## M                     48          116            2     
    ## U                      2           7             0     
    ## UNDIFFERENTIATED       1           2             0

## Custom Split Functions

### Adding an Overall Column Only When The Split Would Already Define 2+ Facets

Our custom split functions can do anything, including conditionally
applying one or more other existing custom split functions.

Here we define a function constructor which accepts the variable name we
want to check, and then return a custom split function that has the
behavior you want using functions provided by rtables for both cases:

`picky_splitter`` ``<-`` ``function``(``var``)`` ``{`` `` ``function``(``df``, ``spl``, ``vals``, ``labels``, ``trim``)`` ``{`` `` ``orig_vals`` ``<-`` ``vals`` `` ``if`` ``(`[`is.null`](https://rdrr.io/r/base/NULL.html)`(``vals``)``)`` ``{`` `` ``vec`` ``<-`` ``df``[[``var``]``]`` `` ``vals`` ``<-`` ``if`` ``(`[`is.factor`](https://rdrr.io/r/base/factor.html)`(``vec``)``)`` `[`levels`](https://rdrr.io/r/base/levels.html)`(``vec``)`` ``else`` `[`unique`](https://rdrr.io/r/base/unique.html)`(``vec``)`` `` ``}`` `` ``if`` ``(`[`length`](https://rdrr.io/r/base/length.html)`(``vals``)`` ``==`` ``1``)`` ``{`` `` `[`do_base_split`](https://pharmaverse.github.io/rtables/reference/do_base_split.md)`(``spl ``=`` ``spl``, df ``=`` ``df``, vals ``=`` ``vals``, labels ``=`` ``labels``, trim ``=`` ``trim``)`` `` ``}`` ``else`` ``{`` `` `[`add_overall_level`](https://pharmaverse.github.io/rtables/reference/add_overall_level.md)`(`` `` ``"Overall"``,`` `` label ``=`` ``"All Obs"``, first ``=`` ``FALSE`` `` ``)``(``df ``=`` ``df``, spl ``=`` ``spl``, vals ``=`` ``orig_vals``, trim ``=`` ``trim``)`` `` ``}`` `` ``}`` ``}`` `` `` ``d1`` ``<-`` `[`subset`](https://rdrr.io/r/base/subset.html)`(``ex_adsl``, ``ARM`` ``==`` ``"A: Drug X"``)`` ``d1``$``ARM`` ``<-`` `[`factor`](https://rdrr.io/r/base/factor.html)`(``d1``$``ARM``)`` `` ``lyt1`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`` `` `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"ARM"``, split_fun ``=`` ``picky_splitter``(``"ARM"``)``)`` ``|>`` `` `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``)`

This gives us the desired behavior in both the one column corner case:

[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt1``, ``d1``)`

    ##        A: Drug X
    ## ————————————————
    ## Mean     33.77

and the standard multi-column case:

[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt1``, ``ex_adsl``)`

    ##        A: Drug X   B: Placebo   C: Combination   All Obs
    ## ————————————————————————————————————————————————————————
    ## Mean     33.77       35.43          35.43         34.88

Notice we use add_overall_level which is itself a function constructor,
and then immediately call the constructed function in the
more-than-one-columns case.

## Leveraging `.spl_context`

### What Is `.spl_context`?

`.spl_context` (see
[`?spl_context`](https://pharmaverse.github.io/rtables/reference/spl_context.md))
is a mechanism by which the `rtables` tabulation machinery gives custom
split, analysis or content (row-group summary) functions information
about the overarching facet-structure the splits or cells they generate
will reside in.

In particular `.spl_context` ensures that your functions know (and thus
do computations based on) the following types of information:

- 

### Different Formats For Different Values Within A Row-Split

`dta_test`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`` `` USUBJID ``=`` `[`rep`](https://rdrr.io/r/base/rep.html)`(``1``:``6``, each ``=`` ``3``)``,`` `` PARAMCD ``=`` `[`rep`](https://rdrr.io/r/base/rep.html)`(``"lab"``, ``6`` ``*`` ``3``)``,`` `` AVISIT ``=`` `[`rep`](https://rdrr.io/r/base/rep.html)`(`[`paste0`](https://rdrr.io/r/base/paste.html)`(``"V"``, ``1``:``3``)``, ``6``)``,`` `` ARM ``=`` `[`rep`](https://rdrr.io/r/base/rep.html)`(``LETTERS``[``1``:``3``]``, `[`rep`](https://rdrr.io/r/base/rep.html)`(``6``, ``3``)``)``,`` `` AVAL ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``9``:``1``, `[`rep`](https://rdrr.io/r/base/rep.html)`(``NA``, ``9``)``)``,`` `` CHG ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``1``:``9``, `[`rep`](https://rdrr.io/r/base/rep.html)`(``NA``, ``9``)``)`` ``)`` `` ``my_afun`` ``<-`` ``function``(``x``, ``.spl_context``)`` ``{`` `` ``n`` ``<-`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``!`[`is.na`](https://rdrr.io/r/base/NA.html)`(``x``)``)`` `` ``meanval`` ``<-`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``x``, na.rm ``=`` ``TRUE``)`` `` ``sdval`` ``<-`` `[`sd`](https://rdrr.io/r/stats/sd.html)`(``x``, na.rm ``=`` ``TRUE``)`` `` `` ``## get the split value of the most recent parent`` `` ``## (row) split above this analyze`` `` ``val`` ``<-`` ``.spl_context``[`[`nrow`](https://rdrr.io/r/base/nrow.html)`(``.spl_context``)``, ``"value"``]`` `` ``## do a silly thing to decide the different format precisiosn`` `` ``## your real logic would go here`` `` ``valnum`` ``<-`` `[`min`](https://rdrr.io/r/base/Extremes.html)`(``2L``, `[`as.integer`](https://rdrr.io/r/base/integer.html)`(`[`gsub`](https://rdrr.io/r/base/grep.html)`(``"[^[:digit:]]*"``, ``""``, ``val``)``)``)`` `` ``fstringpt`` ``<-`` `[`paste0`](https://rdrr.io/r/base/paste.html)`(``"xx."``, `[`strrep`](https://rdrr.io/r/base/strrep.html)`(``"x"``, ``valnum``)``)`` `` ``fmt_mnsd`` ``<-`` `[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"%s (%s)"``, ``fstringpt``, ``fstringpt``)`` `` `[`in_rows`](https://pharmaverse.github.io/rtables/reference/in_rows.md)`(`` `` n ``=`` ``n``,`` `` ``"Mean, SD"`` ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``meanval``, ``sdval``)``,`` `` .formats ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``n ``=`` ``"xx"``, ``"Mean, SD"`` ``=`` ``fmt_mnsd``)`` `` ``)`` ``}`` `` ``lyt`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`` `` `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"ARM"``)`` ``|>`` `` `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"AVISIT"``)`` ``|>`` `` `[`split_cols_by_multivar`](https://pharmaverse.github.io/rtables/reference/split_cols_by_multivar.md)`(``vars ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"AVAL"``, ``"CHG"``)``)`` ``|>`` `` `[`analyze_colvars`](https://pharmaverse.github.io/rtables/reference/analyze_colvars.md)`(``my_afun``)`` `` `[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt``, ``dta_test``)`

    ##                          A                         B                 C     
    ##                 AVAL           CHG         AVAL         CHG      AVAL   CHG
    ## ———————————————————————————————————————————————————————————————————————————
    ## V1                                                                         
    ##   n               2             2            1           1        0      0 
    ##   Mean, SD    7.5 (2.1)     2.5 (2.1)    3.0 (NA)    7.0 (NA)     NA    NA 
    ## V2                                                                         
    ##   n               2             2            1           1        0      0 
    ##   Mean, SD   6.50 (2.12)   3.50 (2.12)   2.00 (NA)   8.00 (NA)    NA    NA 
    ## V3                                                                         
    ##   n               2             2            1           1        0      0 
    ##   Mean, SD   5.50 (2.12)   4.50 (2.12)   1.00 (NA)   9.00 (NA)    NA    NA

### Simulating ‘Baseline Comparison’ In Row Space

`my_afun`` ``<-`` ``function``(``x``, ``.var``, ``.spl_context``)`` ``{`` `` ``n`` ``<-`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``!`[`is.na`](https://rdrr.io/r/base/NA.html)`(``x``)``)`` `` ``meanval`` ``<-`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``x``, na.rm ``=`` ``TRUE``)`` `` ``sdval`` ``<-`` `[`sd`](https://rdrr.io/r/stats/sd.html)`(``x``, na.rm ``=`` ``TRUE``)`` `` `` ``## get the split value of the most recent parent`` `` ``## (row) split above this analyze`` `` ``val`` ``<-`` ``.spl_context``[`[`nrow`](https://rdrr.io/r/base/nrow.html)`(``.spl_context``)``, ``"value"``]`` `` ``## we show it if its not a CHG within V1`` `` ``show_it`` ``<-`` ``val`` ``!=`` ``"V1"`` ``||`` ``.var`` ``!=`` ``"CHG"`` `` ``## do a silly thing to decide the different format precisiosn`` `` ``## your real logic would go here`` `` ``valnum`` ``<-`` `[`min`](https://rdrr.io/r/base/Extremes.html)`(``2L``, `[`as.integer`](https://rdrr.io/r/base/integer.html)`(`[`gsub`](https://rdrr.io/r/base/grep.html)`(``"[^[:digit:]]*"``, ``""``, ``val``)``)``)`` `` ``fstringpt`` ``<-`` `[`paste0`](https://rdrr.io/r/base/paste.html)`(``"xx."``, `[`strrep`](https://rdrr.io/r/base/strrep.html)`(``"x"``, ``valnum``)``)`` `` ``fmt_mnsd`` ``<-`` ``if`` ``(``show_it``)`` `[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"%s (%s)"``, ``fstringpt``, ``fstringpt``)`` ``else`` ``"xx"`` `` `[`in_rows`](https://pharmaverse.github.io/rtables/reference/in_rows.md)`(`` `` n ``=`` ``if`` ``(``show_it``)`` ``n``, ``## NULL otherwise`` `` ``"Mean, SD"`` ``=`` ``if`` ``(``show_it``)`` `[`c`](https://rdrr.io/r/base/c.html)`(``meanval``, ``sdval``)``, ``## NULL otherwise`` `` .formats ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``n ``=`` ``"xx"``, ``"Mean, SD"`` ``=`` ``fmt_mnsd``)`` `` ``)`` ``}`` `` ``lyt`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`` `` `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"ARM"``)`` ``|>`` `` `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"AVISIT"``)`` ``|>`` `` `[`split_cols_by_multivar`](https://pharmaverse.github.io/rtables/reference/split_cols_by_multivar.md)`(``vars ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"AVAL"``, ``"CHG"``)``)`` ``|>`` `` `[`analyze_colvars`](https://pharmaverse.github.io/rtables/reference/analyze_colvars.md)`(``my_afun``)`` `` `[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt``, ``dta_test``)`

    ##                          A                         B                 C     
    ##                 AVAL           CHG         AVAL         CHG      AVAL   CHG
    ## ———————————————————————————————————————————————————————————————————————————
    ## V1                                                                         
    ##   n               2                          1                    0        
    ##   Mean, SD    7.5 (2.1)                  3.0 (NA)                 NA       
    ## V2                                                                         
    ##   n               2             2            1           1        0      0 
    ##   Mean, SD   6.50 (2.12)   3.50 (2.12)   2.00 (NA)   8.00 (NA)    NA    NA 
    ## V3                                                                         
    ##   n               2             2            1           1        0      0 
    ##   Mean, SD   5.50 (2.12)   4.50 (2.12)   1.00 (NA)   9.00 (NA)    NA    NA

We can further simulate the formal modeling of reference row(s) using
the `extra_args` machinery

`my_afun`` ``<-`` ``function``(``x``, ``.var``, ``ref_rowgroup``, ``.spl_context``)`` ``{`` `` ``n`` ``<-`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``!`[`is.na`](https://rdrr.io/r/base/NA.html)`(``x``)``)`` `` ``meanval`` ``<-`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``x``, na.rm ``=`` ``TRUE``)`` `` ``sdval`` ``<-`` `[`sd`](https://rdrr.io/r/stats/sd.html)`(``x``, na.rm ``=`` ``TRUE``)`` `` `` ``## get the split value of the most recent parent`` `` ``## (row) split above this analyze`` `` ``val`` ``<-`` ``.spl_context``[`[`nrow`](https://rdrr.io/r/base/nrow.html)`(``.spl_context``)``, ``"value"``]`` `` ``## we show it if its not a CHG within V1`` `` ``show_it`` ``<-`` ``val`` ``!=`` ``ref_rowgroup`` ``||`` ``.var`` ``!=`` ``"CHG"`` `` ``fmt_mnsd`` ``<-`` ``if`` ``(``show_it``)`` ``"xx.x (xx.x)"`` ``else`` ``"xx"`` `` `[`in_rows`](https://pharmaverse.github.io/rtables/reference/in_rows.md)`(`` `` n ``=`` ``if`` ``(``show_it``)`` ``n``, ``## NULL otherwise`` `` ``"Mean, SD"`` ``=`` ``if`` ``(``show_it``)`` `[`c`](https://rdrr.io/r/base/c.html)`(``meanval``, ``sdval``)``, ``## NULL otherwise`` `` .formats ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``n ``=`` ``"xx"``, ``"Mean, SD"`` ``=`` ``fmt_mnsd``)`` `` ``)`` ``}`` `` ``lyt2`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`` `` `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"ARM"``)`` ``|>`` `` `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"AVISIT"``)`` ``|>`` `` `[`split_cols_by_multivar`](https://pharmaverse.github.io/rtables/reference/split_cols_by_multivar.md)`(``vars ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"AVAL"``, ``"CHG"``)``)`` ``|>`` `` `[`analyze_colvars`](https://pharmaverse.github.io/rtables/reference/analyze_colvars.md)`(``my_afun``, extra_args ``=`` `[`list`](https://rdrr.io/r/base/list.html)`(``ref_rowgroup ``=`` ``"V1"``)``)`` `` `[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt2``, ``dta_test``)`

    ##                        A                      B                C     
    ##                AVAL         CHG        AVAL       CHG      AVAL   CHG
    ## —————————————————————————————————————————————————————————————————————
    ## V1                                                                   
    ##   n              2                      1                   0        
    ##   Mean, SD   7.5 (2.1)               3.0 (NA)               NA       
    ## V2                                                                   
    ##   n              2           2          1          1        0      0 
    ##   Mean, SD   6.5 (2.1)   3.5 (2.1)   2.0 (NA)   8.0 (NA)    NA    NA 
    ## V3                                                                   
    ##   n              2           2          1          1        0      0 
    ##   Mean, SD   5.5 (2.1)   4.5 (2.1)   1.0 (NA)   9.0 (NA)    NA    NA
