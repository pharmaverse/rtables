# Titles, Footers, and Referential Footnotes

## Titles and Non-Referential Footer Materials

An `rtables` table can be annotated with three types of header (title)
information, as well as three types of footer information.

Header information comes in two forms that are specified directly (main
title and subtitles), as well as one that is populated automatically as
necessary (page title, which we will see in the next section).

Similarly, footer materials come with two directly specified components:
main footer and provenance footer, in addition to one that is computed
when necessary: referential footnotes.

[`basic_table()`](https://pharmaverse.github.io/rtables/reference/basic_table.md)
accepts the values for each static title and footer element during
layout construction:

``` r

library(rtables)
library(dplyr)
lyt <- basic_table(
  title = "Study XXXXXXXX",
  subtitles = c("subtitle YYYYYYYYYY", "subtitle2 ZZZZZZZZZ"),
  main_footer = "Analysis was done using cool methods that are correct",
  prov_footer = "file: /path/to/stuff/that/lives/there HASH:1ac41b242a"
) |>
  split_cols_by("ARM") |>
  split_rows_by("SEX", split_fun = drop_split_levels) |>
  split_rows_by("STRATA1") |>
  analyze("AGE", mean, format = "xx.x")

tbl <- build_table(lyt, DM)
cat(export_as_txt(tbl, paginate = TRUE, page_break = "\n\n\n"))
# Study XXXXXXXX
# subtitle YYYYYYYYYY
# subtitle2 ZZZZZZZZZ
# 
# ——————————————————————————————————————————————————
#            A: Drug X   B: Placebo   C: Combination
# ——————————————————————————————————————————————————
# F                                                 
#   A                                               
#     mean     30.9         32.9           36.0     
#   B                                               
#     mean     34.9         32.9           34.4     
#   C                                               
#     mean     35.2         36.0           34.3     
# M                                                 
#   A                                               
#     mean     35.1         31.1           35.6     
#   B                                               
#     mean     36.6         32.1           34.4     
#   C                                               
#     mean     37.4         32.8           32.8     
# ——————————————————————————————————————————————————
# 
# Analysis was done using cool methods that are correct
# 
# file: /path/to/stuff/that/lives/there HASH:1ac41b242a
```

## Page-by splitting

We often want to split tables based on the values of one or more
variables (e.g., lab measurement) and then paginate *separately within
each of those table subsections*. In `rtables` we do this via *page by*
row splits.

Row splits can be declared page by splits by setting `page_by = TRUE` in
the `split_rows_by*()` call, as below.

When page by splits are present, page titles are generated automatically
by appending the split value (typically a factor level, though it need
not be), to the `page_prefix`, separated by a `:`. By default,
`page_prefix` is name of the variable being split.

``` r

lyt2 <- basic_table(
  title = "Study XXXXXXXX",
  subtitles = c("subtitle YYYYYYYYYY", "subtitle2 ZZZZZZZZZ"),
  main_footer = "Analysis was done using cool methods that are correct",
  prov_footer = "file: /path/to/stuff/that/lives/there HASH:1ac41b242a"
) |>
  split_cols_by("ARM") |>
  split_rows_by("SEX", page_by = TRUE, page_prefix = "Patient Subset - Gender", split_fun = drop_split_levels) |>
  split_rows_by("STRATA1") |>
  analyze("AGE", mean, format = "xx.x")

tbl2 <- build_table(lyt2, DM)
cat(export_as_txt(tbl2, paginate = TRUE, page_break = "\n\n~~~~ Page Break ~~~~\n\n"))
# Study XXXXXXXX
# subtitle YYYYYYYYYY
# subtitle2 ZZZZZZZZZ
# Patient Subset - Gender: F
# 
# ——————————————————————————————————————————————————
#            A: Drug X   B: Placebo   C: Combination
# ——————————————————————————————————————————————————
# A                                                 
#   mean       30.9         32.9           36.0     
# B                                                 
#   mean       34.9         32.9           34.4     
# C                                                 
#   mean       35.2         36.0           34.3     
# ——————————————————————————————————————————————————
# 
# Analysis was done using cool methods that are correct
# 
# file: /path/to/stuff/that/lives/there HASH:1ac41b242a
# 
# 
# ~~~~ Page Break ~~~~
# 
# Study XXXXXXXX
# subtitle YYYYYYYYYY
# subtitle2 ZZZZZZZZZ
# Patient Subset - Gender: M
# 
# ——————————————————————————————————————————————————
#            A: Drug X   B: Placebo   C: Combination
# ——————————————————————————————————————————————————
# A                                                 
#   mean       35.1         31.1           35.6     
# B                                                 
#   mean       36.6         32.1           34.4     
# C                                                 
#   mean       37.4         32.8           32.8     
# ——————————————————————————————————————————————————
# 
# Analysis was done using cool methods that are correct
# 
# file: /path/to/stuff/that/lives/there HASH:1ac41b242a
```

Page by row splits can be nested, but only within other page_by splits,
they cannot be nested within traditional row splits. In this case, a
page title for each page by split will be present on every resulting
page, as seen below:

``` r

lyt3 <- basic_table(
  title = "Study XXXXXXXX",
  subtitles = c("subtitle YYYYYYYYYY", "subtitle2 ZZZZZZZZZ"),
  main_footer = "Analysis was done using cool methods that are correct",
  prov_footer = "file: /path/to/stuff/that/lives/there HASH:1ac41b242a"
) |>
  split_cols_by("ARM") |>
  split_rows_by("SEX", page_by = TRUE, page_prefix = "Patient Subset - Gender", split_fun = drop_split_levels) |>
  split_rows_by("STRATA1", page_by = TRUE, page_prefix = "Stratification - Strata") |>
  analyze("AGE", mean, format = "xx.x")

tbl3 <- build_table(lyt3, DM)
cat(export_as_txt(tbl3, paginate = TRUE, page_break = "\n\n~~~~ Page Break ~~~~\n\n"))
# Study XXXXXXXX
# subtitle YYYYYYYYYY
# subtitle2 ZZZZZZZZZ
# Patient Subset - Gender: F
# Stratification - Strata: A
# 
# ——————————————————————————————————————————————————
#            A: Drug X   B: Placebo   C: Combination
# ——————————————————————————————————————————————————
# mean         30.9         32.9           36.0     
# ——————————————————————————————————————————————————
# 
# Analysis was done using cool methods that are correct
# 
# file: /path/to/stuff/that/lives/there HASH:1ac41b242a
# 
# 
# ~~~~ Page Break ~~~~
# 
# Study XXXXXXXX
# subtitle YYYYYYYYYY
# subtitle2 ZZZZZZZZZ
# Patient Subset - Gender: F
# Stratification - Strata: B
# 
# ——————————————————————————————————————————————————
#            A: Drug X   B: Placebo   C: Combination
# ——————————————————————————————————————————————————
# mean         34.9         32.9           34.4     
# ——————————————————————————————————————————————————
# 
# Analysis was done using cool methods that are correct
# 
# file: /path/to/stuff/that/lives/there HASH:1ac41b242a
# 
# 
# ~~~~ Page Break ~~~~
# 
# Study XXXXXXXX
# subtitle YYYYYYYYYY
# subtitle2 ZZZZZZZZZ
# Patient Subset - Gender: F
# Stratification - Strata: C
# 
# ——————————————————————————————————————————————————
#            A: Drug X   B: Placebo   C: Combination
# ——————————————————————————————————————————————————
# mean         35.2         36.0           34.3     
# ——————————————————————————————————————————————————
# 
# Analysis was done using cool methods that are correct
# 
# file: /path/to/stuff/that/lives/there HASH:1ac41b242a
# 
# 
# ~~~~ Page Break ~~~~
# 
# Study XXXXXXXX
# subtitle YYYYYYYYYY
# subtitle2 ZZZZZZZZZ
# Patient Subset - Gender: M
# Stratification - Strata: A
# 
# ——————————————————————————————————————————————————
#            A: Drug X   B: Placebo   C: Combination
# ——————————————————————————————————————————————————
# mean         35.1         31.1           35.6     
# ——————————————————————————————————————————————————
# 
# Analysis was done using cool methods that are correct
# 
# file: /path/to/stuff/that/lives/there HASH:1ac41b242a
# 
# 
# ~~~~ Page Break ~~~~
# 
# Study XXXXXXXX
# subtitle YYYYYYYYYY
# subtitle2 ZZZZZZZZZ
# Patient Subset - Gender: M
# Stratification - Strata: B
# 
# ——————————————————————————————————————————————————
#            A: Drug X   B: Placebo   C: Combination
# ——————————————————————————————————————————————————
# mean         36.6         32.1           34.4     
# ——————————————————————————————————————————————————
# 
# Analysis was done using cool methods that are correct
# 
# file: /path/to/stuff/that/lives/there HASH:1ac41b242a
# 
# 
# ~~~~ Page Break ~~~~
# 
# Study XXXXXXXX
# subtitle YYYYYYYYYY
# subtitle2 ZZZZZZZZZ
# Patient Subset - Gender: M
# Stratification - Strata: C
# 
# ——————————————————————————————————————————————————
#            A: Drug X   B: Placebo   C: Combination
# ——————————————————————————————————————————————————
# mean         37.4         32.8           32.8     
# ——————————————————————————————————————————————————
# 
# Analysis was done using cool methods that are correct
# 
# file: /path/to/stuff/that/lives/there HASH:1ac41b242a
```

## Referential Footnotes

Referential footnotes are footnotes associated with a particular
component of a table: a column, a row, or a cell. They can be added
during tabulation via analysis functions, but they can also be added
post-hoc once a table is created.

They are rendered as a number within curly braces within the table body,
row, or column labels, followed by a message associated with that number
printed below the table during rendering.

### Adding Cell- and Analysis-row Referential Footnotes At Tabulation Time

``` r

afun <- function(df, .var, .spl_context) {
  val <- .spl_context$value[NROW(.spl_context)]
  rw_fnotes <- if (val == "C") list("This is strata level C for these patients") else list()
  cl_fnotes <- if (val == "B" && df[1, "ARM", drop = TRUE] == "C: Combination") {
    list("these Strata B patients got the drug combination")
  } else {
    list()
  }

  in_rows(
    mean = mean(df[[.var]]),
    .row_footnotes = rw_fnotes,
    .cell_footnotes = cl_fnotes,
    .formats = c(mean = "xx.x")
  )
}

lyt <- basic_table(
  title = "Study XXXXXXXX",
  subtitles = c("subtitle YYYYYYYYYY", "subtitle2 ZZZZZZZZZ"),
  main_footer = "Analysis was done using cool methods that are correct",
  prov_footer = "file: /path/to/stuff/that/lives/there HASH:1ac41b242a"
) |>
  split_cols_by("ARM") |>
  split_rows_by("SEX", page_by = TRUE, page_prefix = "Patient Subset - Gender", split_fun = drop_split_levels) |>
  split_rows_by("STRATA1") |>
  analyze("AGE", afun, format = "xx.x")

tbl <- build_table(lyt, DM)
cat(export_as_txt(tbl, paginate = TRUE, page_break = "\n\n\n"))
# Study XXXXXXXX
# subtitle YYYYYYYYYY
# subtitle2 ZZZZZZZZZ
# Patient Subset - Gender: F
# 
# ——————————————————————————————————————————————————————
#                A: Drug X   B: Placebo   C: Combination
# ——————————————————————————————————————————————————————
# A                                                     
#   mean           30.9         32.9           36.0     
# B                                                     
#   mean           34.9         32.9         34.4 {1}   
# C                                                     
#   mean {2}       35.2         36.0           34.3     
# ——————————————————————————————————————————————————————
# 
# {1} - these Strata B patients got the drug combination
# {2} - This is strata level C for these patients
# ——————————————————————————————————————————————————————
# 
# Analysis was done using cool methods that are correct
# 
# file: /path/to/stuff/that/lives/there HASH:1ac41b242a
# 
# 
# 
# Study XXXXXXXX
# subtitle YYYYYYYYYY
# subtitle2 ZZZZZZZZZ
# Patient Subset - Gender: M
# 
# ——————————————————————————————————————————————————————
#                A: Drug X   B: Placebo   C: Combination
# ——————————————————————————————————————————————————————
# A                                                     
#   mean           35.1         31.1           35.6     
# B                                                     
#   mean           36.6         32.1         34.4 {1}   
# C                                                     
#   mean {2}       37.4         32.8           32.8     
# ——————————————————————————————————————————————————————
# 
# {1} - these Strata B patients got the drug combination
# {2} - This is strata level C for these patients
# ——————————————————————————————————————————————————————
# 
# Analysis was done using cool methods that are correct
# 
# file: /path/to/stuff/that/lives/there HASH:1ac41b242a
```

We note that typically the type of footnote added within the analysis
function would be dependent on the computations done to calculate the
cell value(s), e.g., a model not converging. We simply use context
information as an illustrative proxy for that.

The procedure for adding footnotes to content (summary row) rows or
cells is identical to the above, when done within a content function.

### Annotating an Existing Table with Referential Footnotes

In addition to inserting referential footnotes at tabulation time within
our analysis functions, we can also annotate our tables with them
post-hoc.

This is also the only way to add footnotes to **column** labels, as
those cannot be controlled within an analysis or content function.

``` r

## from ?tolower example slightly modified
.simpleCap <- function(x) {
  if (length(x) > 1) {
    return(sapply(x, .simpleCap))
  }
  s <- strsplit(tolower(x), " ")[[1]]
  paste(toupper(substring(s, 1, 1)), substring(s, 2), sep = "", collapse = " ")
}

adsl2 <- ex_adsl |>
  filter(SEX %in% c("M", "F") & RACE %in% (levels(RACE)[1:3])) |>
  ## we trim the level names here solely due to space considerations
  mutate(ethnicity = .simpleCap(gsub("(.*)OR.*", "\\1", RACE)), RACE = factor(RACE))

lyt2 <- basic_table() |>
  split_cols_by("ARM") |>
  split_cols_by("SEX", split_fun = drop_split_levels) |>
  split_rows_by("RACE", labels_var = "ethnicity", split_fun = drop_split_levels) |>
  summarize_row_groups() |>
  analyze(c("AGE", "STRATA1"))

tbl2 <- build_table(lyt2, adsl2)
tbl2
#                    A: Drug X                B: Placebo              C: Combination     
#                 F            M            F            M            F            M     
# ———————————————————————————————————————————————————————————————————————————————————————
# Asian       41 (53.9%)   25 (54.3%)   36 (52.2%)   30 (60.0%)   39 (60.9%)   32 (57.1%)
#   AGE                                                                                  
#     Mean      31.22        34.60        35.06        38.63        36.44        37.66   
#   STRATA1                                                                              
#     A           11           10           14           10           11           7     
#     B           11           9            15           7            11           14    
#     C           19           6            7            13           17           11    
# Black       18 (23.7%)   12 (26.1%)   16 (23.2%)   12 (24.0%)   14 (21.9%)   14 (25.0%)
#   AGE                                                                                  
#     Mean      34.06        34.58        33.88        36.33        33.21        34.21   
#   STRATA1                                                                              
#     A           5            2            5            6            3            7     
#     B           6            5            3            4            4            4     
#     C           7            5            8            2            7            3     
# White       17 (22.4%)   9 (19.6%)    17 (24.6%)   8 (16.0%)    11 (17.2%)   10 (17.9%)
#   AGE                                                                                  
#     Mean      34.12        40.00        32.41        34.62        33.00        30.80   
#   STRATA1                                                                              
#     A           5            3            3            3            3            5     
#     B           5            4            8            4            5            2     
#     C           7            2            6            1            3            3
```

We do this with the `fnotes_at_path<-` function which accepts a row
path, a column path, and a value for the full set of footnotes for the
defined locations (`NULL` or a `character` vector).

A non-`NULL` row path with a `NULL` column path specifies the
footnote(s) should be attached to the row, while `NULL` row path with
non-`NULL` column path indicates they go with the column. Both being
non-`NULL` indicates a cell (and must resolve to an individual cell).

``` r

fnotes_at_path(tbl2, c("RACE", "ASIAN")) <- c("hi", "there")
tbl2
#                       A: Drug X                B: Placebo              C: Combination     
#                    F            M            F            M            F            M     
# ——————————————————————————————————————————————————————————————————————————————————————————
# Asian {1, 2}   41 (53.9%)   25 (54.3%)   36 (52.2%)   30 (60.0%)   39 (60.9%)   32 (57.1%)
#   AGE                                                                                     
#     Mean         31.22        34.60        35.06        38.63        36.44        37.66   
#   STRATA1                                                                                 
#     A              11           10           14           10           11           7     
#     B              11           9            15           7            11           14    
#     C              19           6            7            13           17           11    
# Black          18 (23.7%)   12 (26.1%)   16 (23.2%)   12 (24.0%)   14 (21.9%)   14 (25.0%)
#   AGE                                                                                     
#     Mean         34.06        34.58        33.88        36.33        33.21        34.21   
#   STRATA1                                                                                 
#     A              5            2            5            6            3            7     
#     B              6            5            3            4            4            4     
#     C              7            5            8            2            7            3     
# White          17 (22.4%)   9 (19.6%)    17 (24.6%)   8 (16.0%)    11 (17.2%)   10 (17.9%)
#   AGE                                                                                     
#     Mean         34.12        40.00        32.41        34.62        33.00        30.80   
#   STRATA1                                                                                 
#     A              5            3            3            3            3            5     
#     B              5            4            8            4            5            2     
#     C              7            2            6            1            3            3     
# ——————————————————————————————————————————————————————————————————————————————————————————
# 
# {1} - hi
# {2} - there
# ——————————————————————————————————————————————————————————————————————————————————————————
```

``` r

fnotes_at_path(tbl2, rowpath = NULL, c("ARM", "B: Placebo")) <- c("this is a placebo")
tbl2
#                       A: Drug X              B: Placebo {NA}           C: Combination     
#                    F            M            F            M            F            M     
# ——————————————————————————————————————————————————————————————————————————————————————————
# Asian {1, 2}   41 (53.9%)   25 (54.3%)   36 (52.2%)   30 (60.0%)   39 (60.9%)   32 (57.1%)
#   AGE                                                                                     
#     Mean         31.22        34.60        35.06        38.63        36.44        37.66   
#   STRATA1                                                                                 
#     A              11           10           14           10           11           7     
#     B              11           9            15           7            11           14    
#     C              19           6            7            13           17           11    
# Black          18 (23.7%)   12 (26.1%)   16 (23.2%)   12 (24.0%)   14 (21.9%)   14 (25.0%)
#   AGE                                                                                     
#     Mean         34.06        34.58        33.88        36.33        33.21        34.21   
#   STRATA1                                                                                 
#     A              5            2            5            6            3            7     
#     B              6            5            3            4            4            4     
#     C              7            5            8            2            7            3     
# White          17 (22.4%)   9 (19.6%)    17 (24.6%)   8 (16.0%)    11 (17.2%)   10 (17.9%)
#   AGE                                                                                     
#     Mean         34.12        40.00        32.41        34.62        33.00        30.80   
#   STRATA1                                                                                 
#     A              5            3            3            3            3            5     
#     B              5            4            8            4            5            2     
#     C              7            2            6            1            3            3     
# ——————————————————————————————————————————————————————————————————————————————————————————
# 
# {1} - hi
# {2} - there
# {NA} - this is a placebo
# ——————————————————————————————————————————————————————————————————————————————————————————
```

Note to step into a content row we must add that to the path, even
though we didn’t need it to put a footnote on the full row.

Currently, content rows by default are named with the *label* rather
than *name* of the corresponding facet. This is reflected in the output
of, e.g., `row_paths_summary`.

``` r

row_paths_summary(tbl2)
# rowname      node_class    path                                            
# ———————————————————————————————————————————————————————————————————————————
# Asian        ContentRow    RACE, ASIAN, @content, Asian                    
#   AGE        LabelRow      RACE, ASIAN, AGE                                
#     Mean     DataRow       RACE, ASIAN, AGE, Mean                          
#   STRATA1    LabelRow      RACE, ASIAN, STRATA1                            
#     A        DataRow       RACE, ASIAN, STRATA1, A                         
#     B        DataRow       RACE, ASIAN, STRATA1, B                         
#     C        DataRow       RACE, ASIAN, STRATA1, C                         
# Black        ContentRow    RACE, BLACK OR AFRICAN AMERICAN, @content, Black
#   AGE        LabelRow      RACE, BLACK OR AFRICAN AMERICAN, AGE            
#     Mean     DataRow       RACE, BLACK OR AFRICAN AMERICAN, AGE, Mean      
#   STRATA1    LabelRow      RACE, BLACK OR AFRICAN AMERICAN, STRATA1        
#     A        DataRow       RACE, BLACK OR AFRICAN AMERICAN, STRATA1, A     
#     B        DataRow       RACE, BLACK OR AFRICAN AMERICAN, STRATA1, B     
#     C        DataRow       RACE, BLACK OR AFRICAN AMERICAN, STRATA1, C     
# White        ContentRow    RACE, WHITE, @content, White                    
#   AGE        LabelRow      RACE, WHITE, AGE                                
#     Mean     DataRow       RACE, WHITE, AGE, Mean                          
#   STRATA1    LabelRow      RACE, WHITE, STRATA1                            
#     A        DataRow       RACE, WHITE, STRATA1, A                         
#     B        DataRow       RACE, WHITE, STRATA1, B                         
#     C        DataRow       RACE, WHITE, STRATA1, C
```

So we can add our footnotes to the cell like so:

``` r

fnotes_at_path(
  tbl2,
  rowpath = c("RACE", "ASIAN", "@content", "Asian"),
  colpath = c("ARM", "B: Placebo", "SEX", "F")
) <- "These asian women got placebo treatments"
tbl2
#                       A: Drug X                B: Placebo {NA}             C: Combination     
#                    F            M              F              M            F            M     
# ——————————————————————————————————————————————————————————————————————————————————————————————
# Asian {1, 2}   41 (53.9%)   25 (54.3%)   36 (52.2%) {3}   30 (60.0%)   39 (60.9%)   32 (57.1%)
#   AGE                                                                                         
#     Mean         31.22        34.60          35.06          38.63        36.44        37.66   
#   STRATA1                                                                                     
#     A              11           10             14             10           11           7     
#     B              11           9              15             7            11           14    
#     C              19           6              7              13           17           11    
# Black          18 (23.7%)   12 (26.1%)     16 (23.2%)     12 (24.0%)   14 (21.9%)   14 (25.0%)
#   AGE                                                                                         
#     Mean         34.06        34.58          33.88          36.33        33.21        34.21   
#   STRATA1                                                                                     
#     A              5            2              5              6            3            7     
#     B              6            5              3              4            4            4     
#     C              7            5              8              2            7            3     
# White          17 (22.4%)   9 (19.6%)      17 (24.6%)     8 (16.0%)    11 (17.2%)   10 (17.9%)
#   AGE                                                                                         
#     Mean         34.12        40.00          32.41          34.62        33.00        30.80   
#   STRATA1                                                                                     
#     A              5            3              3              3            3            5     
#     B              5            4              8              4            5            2     
#     C              7            2              6              1            3            3     
# ——————————————————————————————————————————————————————————————————————————————————————————————
# 
# {1} - hi
# {2} - there
# {3} - These asian women got placebo treatments
# {NA} - this is a placebo
# ——————————————————————————————————————————————————————————————————————————————————————————————
```
