# Introductory rtables - Facet And Analysis Nesting

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

`lyt`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`` `` `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"ARM"``)`` ``|>`` `` `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"STRATA1"``)`` ``|>`` `` `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"SEX"``)`` ``|>`` `` `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"BMRKR2"``)`` ``|>`` `` `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``)`` `[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt``, ``ex_adsl``)`

    ##                          A: Drug X              B: Placebo            C: Combination    
    ##                      A       B       C       A       B       C       A       B       C  
    ## ————————————————————————————————————————————————————————————————————————————————————————
    ## F                                                                                       
    ##   LOW                                                                                   
    ##     Mean           31.22   30.57   34.20   33.71   33.50   34.75   33.40   33.50   34.20
    ##   MEDIUM                                                                                
    ##     Mean           32.20   32.88   31.00   31.64   33.25   34.73   33.67   36.00   30.00
    ##   HIGH                                                                                  
    ##     Mean           30.29   34.40   34.87   31.00   44.20   34.71   36.20   40.50   37.25
    ## M                                                                                       
    ##   LOW                                                                                   
    ##     Mean           34.00   34.55   34.43   41.88   35.29   34.00   32.33   31.67   33.60
    ##   MEDIUM                                                                                
    ##     Mean           38.00   36.60   38.33   42.33   35.83   38.17   32.50   34.43   37.33
    ##   HIGH                                                                                  
    ##     Mean           35.11   35.80   31.00   31.80   42.25   35.80   35.57   38.27   37.88
    ## U                                                                                       
    ##   LOW                                                                                   
    ##     Mean            NA     28.00   34.00   27.00    NA      NA      NA     37.00    NA  
    ##   MEDIUM                                                                                
    ##     Mean           33.00    NA      NA      NA      NA      NA      NA      NA     33.00
    ##   HIGH                                                                                  
    ##     Mean            NA      NA      NA      NA     35.00    NA     38.00    NA      NA  
    ## UNDIFFERENTIATED                                                                        
    ##   LOW                                                                                   
    ##     Mean            NA      NA     28.00    NA      NA      NA     44.00    NA     46.00
    ##   MEDIUM                                                                                
    ##     Mean            NA      NA      NA      NA      NA      NA      NA      NA      NA  
    ##   HIGH                                                                                  
    ##     Mean            NA      NA      NA      NA      NA      NA      NA      NA      NA

When `analyze` instructions are ‘nested within’ another `analyze`, the
analyses are bundled into a ‘multi-analysis’ parent structure. This
parent structure as a whole, then, has the nesting behavior that an
single `analyze` call would have in its place.

`lyt2`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`` `` `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"ARM"``)`` ``|>`` `` `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"STRATA1"``)`` ``|>`` `` `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"SEX"``)`` ``|>`` `` `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"BMRKR2"``)`` ``|>`` `` `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``)`` ``|>`` `` `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"BMRKR1"``)`` `[`head`](https://pharmaverse.github.io/rtables/reference/head_tail.md)`(`[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt2``, ``ex_adsl``)``, ``32``)`

    ##                    A: Drug X              B: Placebo            C: Combination    
    ##                A       B       C       A       B       C       A       B       C  
    ## ——————————————————————————————————————————————————————————————————————————————————
    ## F                                                                                 
    ##   LOW                                                                             
    ##     AGE                                                                           
    ##       Mean   31.22   30.57   34.20   33.71   33.50   34.75   33.40   33.50   34.20
    ##     BMRKR1                                                                        
    ##       Mean   4.60    5.10    5.13    6.79    6.40    4.81    5.49    5.57    6.30 
    ##   MEDIUM                                                                          
    ##     AGE                                                                           
    ##       Mean   32.20   32.88   31.00   31.64   33.25   34.73   33.67   36.00   30.00
    ##     BMRKR1                                                                        
    ##       Mean   6.67    7.34    6.57    4.80    5.65    5.10    7.15    4.80    6.49 
    ##   HIGH                                                                            
    ##     AGE                                                                           
    ##       Mean   30.29   34.40   34.87   31.00   44.20   34.71   36.20   40.50   37.25
    ##     BMRKR1                                                                        
    ##       Mean   7.75    5.08    5.08    4.53    7.24    6.15    3.13    8.59    4.94 
    ## M                                                                                 
    ##   LOW                                                                             
    ##     AGE                                                                           
    ##       Mean   34.00   34.55   34.43   41.88   35.29   34.00   32.33   31.67   33.60
    ##     BMRKR1                                                                        
    ##       Mean   4.86    6.99    6.91    4.37    5.69    4.55    4.09    7.43    5.47 
    ##   MEDIUM                                                                          
    ##     AGE                                                                           
    ##       Mean   38.00   36.60   38.33   42.33   35.83   38.17   32.50   34.43   37.33
    ##     BMRKR1                                                                        
    ##       Mean   4.35    5.45    8.09    6.60    3.22    7.76    5.66    4.83    6.02 
    ##   HIGH                                                                            
    ##     AGE                                                                           
    ##       Mean   35.11   35.80   31.00   31.80   42.25   35.80   35.57   38.27   37.88
    ##     BMRKR1                                                                        
    ##       Mean   5.69    6.39    3.70    6.70    7.27    8.69    4.48    5.23    5.37

By default:

- `analyze` calls nest within the most recently preceding
  `split_rows_by` or instruction
  - multiple `analyze` calls that nest within the
