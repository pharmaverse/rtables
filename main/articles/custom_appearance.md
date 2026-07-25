# Customizing Appearance

## Customizing Appearance

In this vignette, we describe the various ways we can modify and
customize the appearance of `rtables`.

Loading the package:

``` r

library(rtables)
library(dplyr)
```

### Rows and cell values alignments

It is possible to align the content by assigning `"left"`, `"center"`
(default), and `"right"` to `.aligns` and `align` arguments in
[`in_rows()`](https://pharmaverse.github.io/rtables/reference/in_rows.md)
and
[`rcell()`](https://pharmaverse.github.io/rtables/reference/rcell.md),
respectively. It is also possible to use `decimal`, `dec_right`, and
`dec_left` for decimal alignments. The first takes all numerical values
and aligns the decimal character `.` in every value of the column that
has `align = "decimal"`. Also numeric without decimal values are aligned
according to an imaginary `.` if specified as such. `dec_left` and
`dec_right` behave similarly, with the difference that if the column
present empty spaces at left or right, it pushes values towards left or
right taking the one value that has most decimal characters, if right,
or non-decimal values if left. For more details, please read the related
documentation page
[`help("decimal_align")`](https://rdrr.io/pkg/formatters/man/decimal_align.html).

Please consider using
[`?in_rows`](https://pharmaverse.github.io/rtables/reference/in_rows.md)
and [`?rcell`](https://pharmaverse.github.io/rtables/reference/rcell.md)
for further clarifications on the two arguments, and use
[`formatters::list_valid_aligns()`](https://rdrr.io/pkg/formatters/man/list_formats.html)
to see all available alignment options.

In the following we show two simplified examples that use `align` and
`.aligns`, respectively.

``` r

# In rcell we use align.
lyt <- basic_table() |>
  analyze("AGE", function(x) {
    in_rows(
      left = rcell("l", align = "left"),
      right = rcell("r", align = "right"),
      center = rcell("c", align = "center")
    )
  })

tbl <- build_table(lyt, DM)
tbl
#          all obs
# ————————————————
# left     l      
# right          r
# center      c
```

``` r

# In in_rows, we use .aligns. This can either set the general value or the
#   single values (see NB).
lyt2 <- basic_table() |>
  analyze("AGE", function(x) {
    in_rows(
      left = rcell("l"),
      right = rcell("r"),
      center = rcell("c"),
      .aligns = c("right")
    ) # NB: .aligns = c("right", "left", "center")
  })

tbl2 <- build_table(lyt2, DM)
tbl2
#          all obs
# ————————————————
# left           l
# right          r
# center         c
```

These concepts can be well applied to any clinical table as shown in the
following, more complex, example.

``` r

lyt3 <- basic_table() |>
  split_cols_by("ARM") |>
  split_rows_by("SEX") |>
  analyze(c("AGE", "STRATA1"), function(x) {
    if (is.numeric(x)) {
      in_rows(
        "mean" = rcell(mean(x)),
        "sd" = rcell(sd(x)),
        .formats = c("xx.x"), .aligns = "left"
      )
    } else if (is.factor(x)) {
      rcell(length(unique(x)), align = "right")
    } else {
      stop("Unsupported type")
    }
  }, show_labels = "visible", na_str = "NE")

tbl3 <- build_table(lyt3, ex_adsl)
tbl3
#                    A: Drug X   B: Placebo   C: Combination
# ——————————————————————————————————————————————————————————
# F                                                         
#   AGE                                                     
#     mean           32.8        34.1         35.2          
#     sd             6.1         7.1          7.4           
#   STRATA1                                                 
#     STRATA1                3            3                3
# M                                                         
#   AGE                                                     
#     mean           35.6        37.4         35.4          
#     sd             7.1         8.7          8.2           
#   STRATA1                                                 
#     STRATA1                3            3                3
# U                                                         
#   AGE                                                     
#     mean           31.7        31.0         35.2          
#     sd             3.2         5.7          3.1           
#   STRATA1                                                 
#     STRATA1                3            2                3
# UNDIFFERENTIATED                                          
#   AGE                                                     
#     mean           28.0        NE           45.0          
#     sd             NE          NE           1.4           
#   STRATA1                                                 
#     STRATA1                1            0                2
```

### Top-left Materials

The sequence of strings printed in the area between the column header
display and the first row label can be modified during pre-processing
using label position argument in row splits `split_rows_by`, with the
`append_topleft` function, and during post-processing using the
[`top_left()`](https://pharmaverse.github.io/rtables/reference/top_left.md)
function. Note: Indenting is automatically added
`label_pos = "topleft"`.

Within the layout initializer:

``` r

lyt <- basic_table() |>
  split_cols_by("ARM") |>
  split_rows_by("STRATA1") |>
  analyze("AGE") |>
  append_topleft("New top_left material here")

build_table(lyt, DM)
# New top_left material here   A: Drug X   B: Placebo   C: Combination
# ————————————————————————————————————————————————————————————————————
# A                                                                   
#   Mean                         32.53       32.30          35.76     
# B                                                                   
#   Mean                         35.46       32.42          34.39     
# C                                                                   
#   Mean                         36.34       34.45          33.54
```

Specify label position using the `split_rows` function. Notice the
position of `STRATA1` and `SEX`.

``` r

lyt <- basic_table() |>
  split_cols_by("ARM") |>
  split_rows_by("STRATA1", label_pos = "topleft") |>
  split_rows_by("SEX", label_pos = "topleft") |>
  analyze("AGE")

build_table(lyt, DM)
# STRATA1                                                     
#   SEX                A: Drug X   B: Placebo   C: Combination
# ————————————————————————————————————————————————————————————
# A                                                           
#   F                                                         
#     Mean               30.91       32.91          35.95     
#   M                                                         
#     Mean               35.07       31.09          35.60     
#   U                                                         
#     Mean                NA           NA             NA      
#   UNDIFFERENTIATED                                          
#     Mean                NA           NA             NA      
# B                                                           
#   F                                                         
#     Mean               34.85       32.88          34.42     
#   M                                                         
#     Mean               36.64       32.09          34.37     
#   U                                                         
#     Mean                NA           NA             NA      
#   UNDIFFERENTIATED                                          
#     Mean                NA           NA             NA      
# C                                                           
#   F                                                         
#     Mean               35.19       36.00          34.32     
#   M                                                         
#     Mean               37.39       32.81          32.83     
#   U                                                         
#     Mean                NA           NA             NA      
#   UNDIFFERENTIATED                                          
#     Mean                NA           NA             NA
```

Post-processing using the
[`top_left()`](https://pharmaverse.github.io/rtables/reference/top_left.md)
function:

``` r

lyt <- basic_table() |>
  split_cols_by("ARM") |>
  split_rows_by("SEX") |>
  analyze(c("AGE", "STRATA1"), function(x) {
    if (is.numeric(x)) {
      in_rows(
        "mean" = rcell(mean(x)),
        "sd" = rcell(sd(x)),
        .formats = c("xx.x"), .aligns = "left"
      )
    } else if (is.factor(x)) {
      rcell(length(unique(x)), align = "right")
    } else {
      stop("Unsupported type")
    }
  }, show_labels = "visible", na_str = "NE") |>
  build_table(ex_adsl)

# Adding top-left material
top_left(lyt) <- "New top-left material here"

lyt
# New top-left material here   A: Drug X   B: Placebo   C: Combination
# ————————————————————————————————————————————————————————————————————
# F                                                                   
#   AGE                                                               
#     mean                     32.8        34.1         35.2          
#     sd                       6.1         7.1          7.4           
#   STRATA1                                                           
#     STRATA1                          3            3                3
# M                                                                   
#   AGE                                                               
#     mean                     35.6        37.4         35.4          
#     sd                       7.1         8.7          8.2           
#   STRATA1                                                           
#     STRATA1                          3            3                3
# U                                                                   
#   AGE                                                               
#     mean                     31.7        31.0         35.2          
#     sd                       3.2         5.7          3.1           
#   STRATA1                                                           
#     STRATA1                          3            2                3
# UNDIFFERENTIATED                                                    
#   AGE                                                               
#     mean                     28.0        NE           45.0          
#     sd                       NE          NE           1.4           
#   STRATA1                                                           
#     STRATA1                          1            0                2
```

### Table Inset

Table title, table body, referential footnotes and and main footers can
be inset from the left alignment of the titles and provenance footer
materials. This can be modified within the layout initializer
[`basic_table()`](https://pharmaverse.github.io/rtables/reference/basic_table.md)
using the `inset` argument or during post-processing with
[`table_inset()`](https://rdrr.io/pkg/formatters/man/table_inset.html).

Using the layout initializer:

``` r

lyt <- basic_table(inset = 5) |>
  analyze("AGE")

build_table(lyt, DM)
#             all obs
#      ——————————————
#      Mean    34.22
```

Using the post-processing function:

Without inset -

``` r

lyt <- basic_table() |>
  analyze("AGE")

tbl <- build_table(lyt, DM)
tbl
#        all obs
# ——————————————
# Mean    34.22
```

With an inset of 5 characters -

``` r

table_inset(tbl) <- 5
tbl
#             all obs
#      ——————————————
#      Mean    34.22
```

Below is an example with a table produced for clinical data. Compare the
inset of the table and main footer between the two tables.

Without inset -

``` r

analysisfun <- function(x, ...) {
  in_rows(
    row1 = 5,
    row2 = c(1, 2),
    .row_footnotes = list(row1 = "row 1 rfn"),
    .cell_footnotes = list(row2 = "row 2 cfn")
  )
}

lyt <- basic_table(
  title = "Title says Whaaaat", subtitles = "Oh, ok.",
  main_footer = "ha HA! Footer!", prov_footer = "provenaaaaance"
) |>
  split_cols_by("ARM") |>
  analyze("AGE", afun = analysisfun)

result <- build_table(lyt, ex_adsl)
result
# Title says Whaaaat
# Oh, ok.
# 
# ——————————————————————————————————————————————————
#            A: Drug X   B: Placebo   C: Combination
# ——————————————————————————————————————————————————
# row1 {1}       5           5              5       
# row2       1, 2 {2}     1, 2 {2}       1, 2 {2}   
# ——————————————————————————————————————————————————
# 
# {1} - row 1 rfn
# {2} - row 2 cfn
# ——————————————————————————————————————————————————
# 
# ha HA! Footer!
# 
# provenaaaaance
```

With inset -

Notice, the inset does not apply to any title materials (main title,
subtitles, page titles), or provenance footer materials. Inset settings
is applied to top-left materials, referential footnotes main footer
materials and any horizontal dividers.

``` r

table_inset(result) <- 5
result
# Title says Whaaaat
# Oh, ok.
# 
#      ——————————————————————————————————————————————————
#                 A: Drug X   B: Placebo   C: Combination
#      ——————————————————————————————————————————————————
#      row1 {1}       5           5              5       
#      row2       1, 2 {2}     1, 2 {2}       1, 2 {2}   
#      ——————————————————————————————————————————————————
# 
#      {1} - row 1 rfn
#      {2} - row 2 cfn
#      ——————————————————————————————————————————————————
# 
#      ha HA! Footer!
# 
# provenaaaaance
```

### Horizontal Separation

A character value can be specified to modify the horizontal separation
between column headers and the table. Horizontal separation applies
when:

1.  separating title + subtitles from the column labels + top left
    materials,
2.  column labels + top left material from row labels + cells,
3.  row labels + cells from footer content, and
4.  Referential footnotes from main + provenance content there would be
    something on both sides of the divider.

Below, we replace the default line with “=”.

``` r

tbl <- basic_table() |>
  split_cols_by("Species") |>
  add_colcounts() |>
  analyze(c("Sepal.Length", "Petal.Width"), function(x) {
    in_rows(
      mean_sd = c(mean(x), sd(x)),
      var = var(x),
      min_max = range(x),
      .formats = c("xx.xx (xx.xx)", "xx.xxx", "xx.x - xx.x"),
      .labels = c("Mean (sd)", "Variance", "Min - Max")
    )
  }) |>
  build_table(iris, hsep = "=")
tbl
#                  setosa      versicolor     virginica 
#                  (N=50)        (N=50)        (N=50)   
# ======================================================
# Sepal.Length                                          
#   Mean (sd)    5.01 (0.35)   5.94 (0.52)   6.59 (0.64)
#   Variance        0.124         0.266         0.404   
#   Min - Max     4.3 - 5.8     4.9 - 7.0     4.9 - 7.9 
# Petal.Width                                           
#   Mean (sd)    0.25 (0.11)   1.33 (0.20)   2.03 (0.27)
#   Variance        0.011         0.039         0.075   
#   Min - Max     0.1 - 0.6     1.0 - 1.8     1.4 - 2.5
```

### Section Dividers

A character value can be specified as a section divider which succeed
every group defined by a split instruction. Note, a trailing divider at
the end of the table is never printed.

Below, a “+” is repeated and used as a section divider.

``` r

lyt <- basic_table() |>
  split_cols_by("Species") |>
  analyze(head(names(iris), -1), afun = function(x) {
    list(
      "mean / sd" = rcell(c(mean(x), sd(x)), format = "xx.xx (xx.xx)"),
      "range" = rcell(diff(range(x)), format = "xx.xx")
    )
  }, section_div = "+")

build_table(lyt, iris)
#                  setosa      versicolor     virginica 
# ——————————————————————————————————————————————————————
# Sepal.Length                                          
#   mean / sd    5.01 (0.35)   5.94 (0.52)   6.59 (0.64)
#   range           1.50          2.10          3.00    
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Sepal.Width                                           
#   mean / sd    3.43 (0.38)   2.77 (0.31)   2.97 (0.32)
#   range           2.10          1.40          1.60    
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Petal.Length                                          
#   mean / sd    1.46 (0.17)   4.26 (0.47)   5.55 (0.55)
#   range           0.90          2.10          2.40    
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Petal.Width                                           
#   mean / sd    0.25 (0.11)   1.33 (0.20)   2.03 (0.27)
#   range           0.50          0.80          1.10
```

Section dividers can be set to ” ” to create a blank line.

``` r

lyt <- basic_table() |>
  split_cols_by("Species") |>
  analyze(head(names(iris), -1), afun = function(x) {
    list(
      "mean / sd" = rcell(c(mean(x), sd(x)), format = "xx.xx (xx.xx)"),
      "range" = rcell(diff(range(x)), format = "xx.xx")
    )
  }, section_div = " ")

build_table(lyt, iris)
#                  setosa      versicolor     virginica 
# ——————————————————————————————————————————————————————
# Sepal.Length                                          
#   mean / sd    5.01 (0.35)   5.94 (0.52)   6.59 (0.64)
#   range           1.50          2.10          3.00    
#                                                       
# Sepal.Width                                           
#   mean / sd    3.43 (0.38)   2.77 (0.31)   2.97 (0.32)
#   range           2.10          1.40          1.60    
#                                                       
# Petal.Length                                          
#   mean / sd    1.46 (0.17)   4.26 (0.47)   5.55 (0.55)
#   range           0.90          2.10          2.40    
#                                                       
# Petal.Width                                           
#   mean / sd    0.25 (0.11)   1.33 (0.20)   2.03 (0.27)
#   range           0.50          0.80          1.10
```

Separation characters can be specified for different row splits.
However, only one will be printed if they “pile up” next to each other.

``` r

lyt <- basic_table() |>
  split_cols_by("ARM") |>
  split_rows_by("RACE", section_div = "=") |>
  split_rows_by("STRATA1", section_div = "~") |>
  analyze("AGE", mean, var_labels = "Age", format = "xx.xx")

build_table(lyt, DM)
#                                             A: Drug X   B: Placebo   C: Combination
# ———————————————————————————————————————————————————————————————————————————————————
# ASIAN                                                                              
#   A                                                                                
#     mean                                      32.19       33.90          36.81     
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   B                                                                                
#     mean                                      34.12       31.62          34.73     
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   C                                                                                
#     mean                                      36.21       33.00          32.39     
# ===================================================================================
# BLACK OR AFRICAN AMERICAN                                                          
#   A                                                                                
#     mean                                      31.50       28.57          33.62     
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   B                                                                                
#     mean                                      35.60       30.83          33.67     
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   C                                                                                
#     mean                                      35.50       34.18          35.00     
# ===================================================================================
# WHITE                                                                              
#   A                                                                                
#     mean                                      37.67       31.33          33.17     
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   B                                                                                
#     mean                                      39.86       39.00          34.75     
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   C                                                                                
#     mean                                      39.75       44.67          36.75     
# ===================================================================================
# AMERICAN INDIAN OR ALASKA NATIVE                                                   
#   A                                                                                
#     mean                                       NA           NA             NA      
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   B                                                                                
#     mean                                       NA           NA             NA      
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   C                                                                                
#     mean                                       NA           NA             NA      
# ===================================================================================
# MULTIPLE                                                                           
#   A                                                                                
#     mean                                       NA           NA             NA      
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   B                                                                                
#     mean                                       NA           NA             NA      
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   C                                                                                
#     mean                                       NA           NA             NA      
# ===================================================================================
# NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER                                          
#   A                                                                                
#     mean                                       NA           NA             NA      
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   B                                                                                
#     mean                                       NA           NA             NA      
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   C                                                                                
#     mean                                       NA           NA             NA      
# ===================================================================================
# OTHER                                                                              
#   A                                                                                
#     mean                                       NA           NA             NA      
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   B                                                                                
#     mean                                       NA           NA             NA      
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   C                                                                                
#     mean                                       NA           NA             NA      
# ===================================================================================
# UNKNOWN                                                                            
#   A                                                                                
#     mean                                       NA           NA             NA      
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   B                                                                                
#     mean                                       NA           NA             NA      
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   C                                                                                
#     mean                                       NA           NA             NA
```

### Indent Modifier

Tables by default have indenting at each level of splitting. A custom
indent value can be supplied with the `indent_mod` argument within a
split function to modify this default. Compare the indenting of the
tables below:

Default Indent -

``` r

basic_table(
  title = "Study XXXXXXXX",
  subtitles = c("subtitle YYYYYYYYYY", "subtitle2 ZZZZZZZZZ"),
  main_footer = "Analysis was done using cool methods that are correct",
  prov_footer = "file: /path/to/stuff/that/lives/there HASH:1ac41b242a"
) |>
  split_cols_by("ARM") |>
  split_rows_by("SEX") |>
  split_rows_by("STRATA1") |>
  analyze("AGE", mean, format = "xx.x") |>
  build_table(DM)
# Study XXXXXXXX
# subtitle YYYYYYYYYY
# subtitle2 ZZZZZZZZZ
# 
# ——————————————————————————————————————————————————————————
#                    A: Drug X   B: Placebo   C: Combination
# ——————————————————————————————————————————————————————————
# F                                                         
#   A                                                       
#     mean             30.9         32.9           36.0     
#   B                                                       
#     mean             34.9         32.9           34.4     
#   C                                                       
#     mean             35.2         36.0           34.3     
# M                                                         
#   A                                                       
#     mean             35.1         31.1           35.6     
#   B                                                       
#     mean             36.6         32.1           34.4     
#   C                                                       
#     mean             37.4         32.8           32.8     
# U                                                         
#   A                                                       
#     mean              NA           NA             NA      
#   B                                                       
#     mean              NA           NA             NA      
#   C                                                       
#     mean              NA           NA             NA      
# UNDIFFERENTIATED                                          
#   A                                                       
#     mean              NA           NA             NA      
#   B                                                       
#     mean              NA           NA             NA      
#   C                                                       
#     mean              NA           NA             NA      
# ——————————————————————————————————————————————————————————
# 
# Analysis was done using cool methods that are correct
# 
# file: /path/to/stuff/that/lives/there HASH:1ac41b242a
```

Modified indent -

``` r

basic_table(
  title = "Study XXXXXXXX",
  subtitles = c("subtitle YYYYYYYYYY", "subtitle2 ZZZZZZZZZ"),
  main_footer = "Analysis was done using cool methods that are correct",
  prov_footer = "file: /path/to/stuff/that/lives/there HASH:1ac41b242a"
) |>
  split_cols_by("ARM") |>
  split_rows_by("SEX", indent_mod = 3) |>
  split_rows_by("STRATA1", indent_mod = 5) |>
  analyze("AGE", mean, format = "xx.x") |>
  build_table(DM)
# Study XXXXXXXX
# subtitle YYYYYYYYYY
# subtitle2 ZZZZZZZZZ
# 
# ——————————————————————————————————————————————————————————————————
#                            A: Drug X   B: Placebo   C: Combination
# ——————————————————————————————————————————————————————————————————
#       F                                                           
#                   A                                               
#                     mean     30.9         32.9           36.0     
#                   B                                               
#                     mean     34.9         32.9           34.4     
#                   C                                               
#                     mean     35.2         36.0           34.3     
#       M                                                           
#                   A                                               
#                     mean     35.1         31.1           35.6     
#                   B                                               
#                     mean     36.6         32.1           34.4     
#                   C                                               
#                     mean     37.4         32.8           32.8     
#       U                                                           
#                   A                                               
#                     mean      NA           NA             NA      
#                   B                                               
#                     mean      NA           NA             NA      
#                   C                                               
#                     mean      NA           NA             NA      
#       UNDIFFERENTIATED                                            
#                   A                                               
#                     mean      NA           NA             NA      
#                   B                                               
#                     mean      NA           NA             NA      
#                   C                                               
#                     mean      NA           NA             NA      
# ——————————————————————————————————————————————————————————————————
# 
# Analysis was done using cool methods that are correct
# 
# file: /path/to/stuff/that/lives/there HASH:1ac41b242a
```

### Variable Label Visibility

With split instructions, visibility of the label for the variable being
split can be modified to `visible`, `hidden` and `topleft` with the
`show_labels` argument, `label_pos` argument, and `child_labels`
argument where applicable. Note: this is NOT the name of the levels
contained in the variable. For analyze calls, indicates that the
variable should be visible only if multiple variables are analyzed at
the same level of nesting.

Visibility of labels for the groups generated by a split can also be
modified using the `child_label` argument with a split call. The
`child_label` argument can force labels to be visible in addition to
content rows but we cannot hide or move the content rows.

Notice the placement of the “AGE” label in this example:

``` r

lyt <- basic_table(show_colcounts = TRUE) |>
  split_cols_by(var = "ARM") |>
  split_rows_by("SEX", split_fun = drop_split_levels, child_labels = "visible") |>
  split_rows_by("STRATA1") |>
  analyze("AGE", mean, show_labels = "default")

build_table(lyt, DM)
#               A: Drug X          B: Placebo       C: Combination 
#                (N=121)            (N=106)            (N=129)     
# —————————————————————————————————————————————————————————————————
# F                                                                
#   A                                                              
#     mean   30.9090909090909   32.9090909090909        35.95      
#   B                                                              
#     mean   34.8518518518519   32.8823529411765   34.4210526315789
#   C                                                              
#     mean   35.1904761904762          36          34.3181818181818
# M                                                                
#   A                                                              
#     mean   35.0714285714286   31.0909090909091         35.6      
#   B                                                              
#     mean   36.6428571428571   32.0869565217391   34.3684210526316
#   C                                                              
#     mean   37.3913043478261       32.8125        32.8333333333333
```

When set to default, the label `AGE` is not repeated since there is only
one variable being analyzed at the same level of nesting. Override this
by setting the `show_labels` argument as “visible”.

``` r

lyt2 <- basic_table(show_colcounts = TRUE) |>
  split_cols_by(var = "ARM") |>
  split_rows_by("SEX", split_fun = drop_split_levels, child_labels = "hidden") |>
  split_rows_by("STRATA1") |>
  analyze("AGE", mean, show_labels = "visible")

build_table(lyt2, DM)
#               A: Drug X          B: Placebo       C: Combination 
#                (N=121)            (N=106)            (N=129)     
# —————————————————————————————————————————————————————————————————
# A                                                                
#   AGE                                                            
#     mean   30.9090909090909   32.9090909090909        35.95      
# B                                                                
#   AGE                                                            
#     mean   34.8518518518519   32.8823529411765   34.4210526315789
# C                                                                
#   AGE                                                            
#     mean   35.1904761904762          36          34.3181818181818
# A                                                                
#   AGE                                                            
#     mean   35.0714285714286   31.0909090909091         35.6      
# B                                                                
#   AGE                                                            
#     mean   36.6428571428571   32.0869565217391   34.3684210526316
# C                                                                
#   AGE                                                            
#     mean   37.3913043478261       32.8125        32.8333333333333
```

Below is an example using the `label_pos` argument for modifying label
visibility:

Label order will mirror the order of `split_rows_by` calls. If the
labels of any subgroups should be hidden, the `label_pos` argument
should be set to hidden.

“SEX” label position is hidden -

``` r

basic_table(
  title = "Study XXXXXXXX",
  subtitles = c("subtitle YYYYYYYYYY", "subtitle2 ZZZZZZZZZ"),
  main_footer = "Analysis was done using cool methods that are correct",
  prov_footer = "file: /path/to/stuff/that/lives/there HASH:1ac41b242a"
) |>
  split_cols_by("ARM") |>
  split_rows_by("SEX", split_fun = drop_split_levels, label_pos = "visible") |>
  split_rows_by("STRATA1", label_pos = "hidden") |>
  analyze("AGE", mean, format = "xx.x") |>
  build_table(DM)
# Study XXXXXXXX
# subtitle YYYYYYYYYY
# subtitle2 ZZZZZZZZZ
# 
# ————————————————————————————————————————————————————
#              A: Drug X   B: Placebo   C: Combination
# ————————————————————————————————————————————————————
# SEX                                                 
#   F                                                 
#     A                                               
#       mean     30.9         32.9           36.0     
#     B                                               
#       mean     34.9         32.9           34.4     
#     C                                               
#       mean     35.2         36.0           34.3     
#   M                                                 
#     A                                               
#       mean     35.1         31.1           35.6     
#     B                                               
#       mean     36.6         32.1           34.4     
#     C                                               
#       mean     37.4         32.8           32.8     
# ————————————————————————————————————————————————————
# 
# Analysis was done using cool methods that are correct
# 
# file: /path/to/stuff/that/lives/there HASH:1ac41b242a
```

“SEX” label position is with the top-left materials -

``` r

basic_table(
  title = "Study XXXXXXXX",
  subtitles = c("subtitle YYYYYYYYYY", "subtitle2 ZZZZZZZZZ"),
  main_footer = "Analysis was done using cool methods that are correct",
  prov_footer = "file: /path/to/stuff/that/lives/there HASH:1ac41b242a"
) |>
  split_cols_by("ARM") |>
  split_rows_by("SEX", split_fun = drop_split_levels, label_pos = "topleft") |>
  split_rows_by("STRATA1", label_pos = "hidden") |>
  analyze("AGE", mean, format = "xx.x") |>
  build_table(DM)
# Study XXXXXXXX
# subtitle YYYYYYYYYY
# subtitle2 ZZZZZZZZZ
# 
# ——————————————————————————————————————————————————
# SEX        A: Drug X   B: Placebo   C: Combination
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

### Cell, Label, and Annotation Wrapping

An `rtable` can be rendered with a customized width by setting custom
rendering widths for cell contents, row labels, and titles/footers.

This is demonstrated using the sample data and table below. In this
section we aim to render this table with a reduced width since the table
has very wide contents in several cells, labels, and titles/footers.

``` r

trimmed_data <- ex_adsl |>
  filter(SEX %in% c("M", "F")) |>
  filter(RACE %in% levels(RACE)[1:2])

levels(trimmed_data$ARM)[1] <- "Incredibly long column name to be wrapped"
levels(trimmed_data$ARM)[2] <- "This_column_name_should_be_split_somewhere"

wide_tbl <- basic_table(
  title = "Title that is too long and also needs to be wrapped to a smaller width",
  subtitles = "Subtitle that is also long and also needs to be wrapped to a smaller width",
  main_footer = "Footnote that is wider than expected for this table.",
  prov_footer = "Provenance footer material that is also wider than expected for this table."
) |>
  split_cols_by("ARM") |>
  split_rows_by("RACE", split_fun = drop_split_levels) |>
  analyze(
    c("AGE", "EOSDY"),
    na_str = "Very long cell contents to_be_wrapped_and_splitted",
    inclNAs = TRUE
  ) |>
  build_table(trimmed_data)

wide_tbl
# Title that is too long and also needs to be wrapped to a smaller width
# Subtitle that is also long and also needs to be wrapped to a smaller width
# 
# ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
#                                 Incredibly long column name to be wrapped            This_column_name_should_be_split_somewhere                         C: Combination                  
# ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
# ASIAN                                                                                                                                                                                   
#   AGE                                                                                                                                                                                   
#     Mean                                          32.50                                                36.68                                                36.99                       
#   EOSDY                                                                                                                                                                                 
#     Mean                    Very long cell contents to_be_wrapped_and_splitted   Very long cell contents to_be_wrapped_and_splitted   Very long cell contents to_be_wrapped_and_splitted
# BLACK OR AFRICAN AMERICAN                                                                                                                                                               
#   AGE                                                                                                                                                                                   
#     Mean                                          34.27                                                34.93                                                33.71                       
#   EOSDY                                                                                                                                                                                 
#     Mean                    Very long cell contents to_be_wrapped_and_splitted   Very long cell contents to_be_wrapped_and_splitted   Very long cell contents to_be_wrapped_and_splitted
# ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
# 
# Footnote that is wider than expected for this table.
# 
# Provenance footer material that is also wider than expected for this table.
```

In the following sections we will use the
[`toString()`](https://rdrr.io/pkg/formatters/man/tostring.html)
function to render the table in string form. This resulting string
representation is ready to be printed or written to a plain text file,
but we will use the [`strsplit()`](https://rdrr.io/r/base/strsplit.html)
function in combination with the
[`matrix()`](https://rdrr.io/r/base/matrix.html) function to preview the
rendered wrapped table in matrix form within this vignette.

#### Cell & Label Wrapping

The width of a rendered table can be customized by wrapping column
widths. This is done by setting custom width values via the `widths`
argument of the
[`toString()`](https://rdrr.io/pkg/formatters/man/tostring.html)
function. The length of the vector passed to the `widths` argument must
be equal to the total number of columns in the table, including the row
labels column, with each value of the vector corresponding to the
maximum width (in characters) allowed in each column, from left to
right.

Similarly, wrapping can be applied when exporting a table via one of the
four `export_as_*` functions and when implementing pagination via the
[`paginate_table()`](https://pharmaverse.github.io/rtables/reference/paginate.md)
function from the `rtables` package. In these cases, the rendered column
widths are set using the `colwidths` argument which takes input in the
same format as the `widths` argument of
[`toString()`](https://rdrr.io/pkg/formatters/man/tostring.html).

For example, `wide_tbl` has four columns (1 row label column and 3
content columns) which we will set the widths of below to use in the
rendered table. We set the width of the row label column to 10
characters and the widths of each of the 3 content columns to 8
characters. Any words longer than the specified width are broken and
continued on the following line. By default there are 3 spaces
separating each of the columns in the rendered table but this can be
customized via the `col_gap` argument to
[`toString()`](https://rdrr.io/pkg/formatters/man/tostring.html) if
further width customization is desired.

``` r

result_wrap_cells <- toString(wide_tbl, widths = c(10, 8, 8, 8))
matrix_wrap_cells <- matrix(strsplit(result_wrap_cells, "\n")[[1]], ncol = 1)
matrix_wrap_cells
#       [,1]                                                                         
#  [1,] "Title that is too long and also needs to be wrapped to a smaller width"     
#  [2,] "Subtitle that is also long and also needs to be wrapped to a smaller width" 
#  [3,] ""                                                                           
#  [4,] "———————————————————————————————————————————"                                
#  [5,] "             Incredib   This_col           "                                
#  [6,] "             ly long    umn_name           "                                
#  [7,] "              column    _should_           "                                
#  [8,] "               name     be_split           "                                
#  [9,] "              to be     _somewhe   C: Combi"                                
# [10,] "             wrapped       re       nation "                                
# [11,] "———————————————————————————————————————————"                                
# [12,] "ASIAN                                      "                                
# [13,] "  AGE                                      "                                
# [14,] "    Mean      32.50      36.68      36.99  "                                
# [15,] "  EOSDY                                    "                                
# [16,] "    Mean       Very       Very       Very  "                                
# [17,] "               long       long       long  "                                
# [18,] "               cell       cell       cell  "                                
# [19,] "             contents   contents   contents"                                
# [20,] "             to_be_wr   to_be_wr   to_be_wr"                                
# [21,] "             apped_an   apped_an   apped_an"                                
# [22,] "             d_splitt   d_splitt   d_splitt"                                
# [23,] "                ed         ed         ed   "                                
# [24,] "BLACK OR                                   "                                
# [25,] "AFRICAN                                    "                                
# [26,] "AMERICAN                                   "                                
# [27,] "  AGE                                      "                                
# [28,] "    Mean      34.27      34.93      33.71  "                                
# [29,] "  EOSDY                                    "                                
# [30,] "    Mean       Very       Very       Very  "                                
# [31,] "               long       long       long  "                                
# [32,] "               cell       cell       cell  "                                
# [33,] "             contents   contents   contents"                                
# [34,] "             to_be_wr   to_be_wr   to_be_wr"                                
# [35,] "             apped_an   apped_an   apped_an"                                
# [36,] "             d_splitt   d_splitt   d_splitt"                                
# [37,] "                ed         ed         ed   "                                
# [38,] "———————————————————————————————————————————"                                
# [39,] ""                                                                           
# [40,] "Footnote that is wider than expected for this table."                       
# [41,] ""                                                                           
# [42,] "Provenance footer material that is also wider than expected for this table."
```

In the resulting output we can see that the table has been correctly
rendered using wrapping with a total width of 43 characters, but that
the titles and footers remain wider than the rendered table.

#### Title & Footer Wrapping

In addition to wrapping column widths, titles and footers can be wrapped
by setting `tf_wrap = TRUE` in
[`toString()`](https://rdrr.io/pkg/formatters/man/tostring.html) and
setting the `max_width` argument of
[`toString()`](https://rdrr.io/pkg/formatters/man/tostring.html) to the
maximum width (in characters) allowed for titles/footers. The four
`export_as_*` functions and
[`paginate_table()`](https://pharmaverse.github.io/rtables/reference/paginate.md)
can also wrap titles/footers by setting the same two arguments. In the
following code, we set `max_width = 43` so that the rendered table and
all of its annotations have a maximum width of 43 characters.

``` r

result_wrap_cells_tf <- toString(
  wide_tbl,
  widths = c(10, 8, 8, 8),
  tf_wrap = TRUE,
  max_width = 43
)
matrix_wrap_cells_tf <- matrix(strsplit(result_wrap_cells_tf, "\n")[[1]], ncol = 1)
matrix_wrap_cells_tf
#       [,1]                                         
#  [1,] "Title that is too long and also needs to be"
#  [2,] "wrapped to a smaller width"                 
#  [3,] "Subtitle that is also long and also needs"  
#  [4,] "to be wrapped to a smaller width"           
#  [5,] ""                                           
#  [6,] "———————————————————————————————————————————"
#  [7,] "             Incredib   This_col           "
#  [8,] "             ly long    umn_name           "
#  [9,] "              column    _should_           "
# [10,] "               name     be_split           "
# [11,] "              to be     _somewhe   C: Combi"
# [12,] "             wrapped       re       nation "
# [13,] "———————————————————————————————————————————"
# [14,] "ASIAN                                      "
# [15,] "  AGE                                      "
# [16,] "    Mean      32.50      36.68      36.99  "
# [17,] "  EOSDY                                    "
# [18,] "    Mean       Very       Very       Very  "
# [19,] "               long       long       long  "
# [20,] "               cell       cell       cell  "
# [21,] "             contents   contents   contents"
# [22,] "             to_be_wr   to_be_wr   to_be_wr"
# [23,] "             apped_an   apped_an   apped_an"
# [24,] "             d_splitt   d_splitt   d_splitt"
# [25,] "                ed         ed         ed   "
# [26,] "BLACK OR                                   "
# [27,] "AFRICAN                                    "
# [28,] "AMERICAN                                   "
# [29,] "  AGE                                      "
# [30,] "    Mean      34.27      34.93      33.71  "
# [31,] "  EOSDY                                    "
# [32,] "    Mean       Very       Very       Very  "
# [33,] "               long       long       long  "
# [34,] "               cell       cell       cell  "
# [35,] "             contents   contents   contents"
# [36,] "             to_be_wr   to_be_wr   to_be_wr"
# [37,] "             apped_an   apped_an   apped_an"
# [38,] "             d_splitt   d_splitt   d_splitt"
# [39,] "                ed         ed         ed   "
# [40,] "———————————————————————————————————————————"
# [41,] ""                                           
# [42,] "Footnote that is wider than expected for"   
# [43,] "this table."                                
# [44,] ""                                           
# [45,] "Provenance footer material that is also"    
# [46,] "wider than expected for this table."
```
