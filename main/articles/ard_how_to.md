# Generating QC-Ready Result Data Frames (ARDs) from Tables

## Disclaimer

This vignette is a work in progress and subject to change.

### Creating an Example Table

In order to generate an ARD (Analysis Results Dataset), we first need to
create a table from which all the necessary information will be
retrieved. We will borrow a simple table from [this
vignette](https://insightsengineering.github.io/rtables/latest-tag/articles/clinical_trials.html)
about clinical trials.

``` r

library(rtables)
# Loading required package: formatters
# 
# Attaching package: 'formatters'
# The following object is masked from 'package:base':
# 
#     %||%
# 
# Attaching package: 'rtables'
# The following object is masked from 'package:utils':
# 
#     str
ADSL <- ex_adsl # Example ADSL dataset

# Very simple table
lyt <- basic_table() |>
  split_cols_by("ARM") |>
  analyze(c("AGE", "SEX"))

tbl <- build_table(lyt, ADSL)
tbl
#                      A: Drug X   B: Placebo   C: Combination
# ————————————————————————————————————————————————————————————
# AGE                                                         
#   Mean                 33.77       35.43          35.43     
# SEX                                                         
#   F                     79           77             66      
#   M                     51           55             60      
#   U                      3           2              4       
#   UNDIFFERENTIATED       1           0              2
```

### Converting the Table to a Result Data Frame (ARD)

The
[`as_result_df()`](https://pharmaverse.github.io/rtables/reference/data.frame_export.md)
function is used to convert a table to a result data frame. The result
data frame is a data frame that contains the result of the summary table
and is ready to be used for quality control purposes. This may be
customized according to different standards.

Let’s see how we can produce different result `data.frame`s. The
following outputs can be returned by setting different parameters in the
`as_results_df()` function, and these results can be transformed back
into a table using the
[`df_to_tt()`](https://pharmaverse.github.io/rtables/reference/df_to_tt.md)
function.

``` r

as_result_df(tbl)
#   avar_name         row_name       label_name row_num is_group_summary
# 1       AGE             Mean             Mean       2            FALSE
# 2       SEX                F                F       4            FALSE
# 3       SEX                M                M       5            FALSE
# 4       SEX                U                U       6            FALSE
# 5       SEX UNDIFFERENTIATED UNDIFFERENTIATED       7            FALSE
#   node_class A: Drug X B: Placebo C: Combination
# 1    DataRow  33.76866   35.43284       35.43182
# 2    DataRow        79         77             66
# 3    DataRow        51         55             60
# 4    DataRow         3          2              4
# 5    DataRow         1          0              2

as_result_df(tbl, data_format = "strings")
#   avar_name         row_name       label_name row_num is_group_summary
# 1       AGE             Mean             Mean       2            FALSE
# 2       SEX                F                F       4            FALSE
# 3       SEX                M                M       5            FALSE
# 4       SEX                U                U       6            FALSE
# 5       SEX UNDIFFERENTIATED UNDIFFERENTIATED       7            FALSE
#   node_class A: Drug X B: Placebo C: Combination
# 1    DataRow     33.77      35.43          35.43
# 2    DataRow        79         77             66
# 3    DataRow        51         55             60
# 4    DataRow         3          2              4
# 5    DataRow         1          0              2
as_result_df(tbl, simplify = TRUE)
#         label_name A: Drug X B: Placebo C: Combination
# 1             Mean  33.76866   35.43284       35.43182
# 2                F        79         77             66
# 3                M        51         55             60
# 4                U         3          2              4
# 5 UNDIFFERENTIATED         1          0              2
as_result_df(tbl, simplify = TRUE, keep_label_rows = TRUE)
#         label_name A: Drug X B: Placebo C: Combination
# 1              AGE        NA         NA             NA
# 2             Mean  33.76866   35.43284       35.43182
# 3              SEX        NA         NA             NA
# 4                F        79         77             66
# 5                M        51         55             60
# 6                U         3          2              4
# 7 UNDIFFERENTIATED         1          0              2
as_result_df(tbl, simplify = TRUE, keep_label_rows = TRUE, expand_colnames = TRUE)
#                label_name A: Drug X B: Placebo C: Combination
# 1 <only_for_column_names> A: Drug X B: Placebo C: Combination
# 2                     AGE        NA         NA             NA
# 3                    Mean  33.76866   35.43284       35.43182
# 4                     SEX        NA         NA             NA
# 5                       F        79         77             66
# 6                       M        51         55             60
# 7                       U         3          2              4
# 8        UNDIFFERENTIATED         1          0              2
```

Now let’s generate our final ARD output, which is ready to be used for
quality control purposes.

``` r

as_result_df(tbl, make_ard = TRUE)
#    group1   group1_level variable   variable_level   variable_label stat_name
# 1     ARM      A: Drug X      AGE             Mean             Mean      mean
# 2     ARM      A: Drug X      SEX                F                F         n
# 3     ARM      A: Drug X      SEX                M                M         n
# 4     ARM      A: Drug X      SEX                U                U         n
# 5     ARM      A: Drug X      SEX UNDIFFERENTIATED UNDIFFERENTIATED         n
# 6     ARM     B: Placebo      AGE             Mean             Mean      mean
# 7     ARM     B: Placebo      SEX                F                F         n
# 8     ARM     B: Placebo      SEX                M                M         n
# 9     ARM     B: Placebo      SEX                U                U         n
# 10    ARM     B: Placebo      SEX UNDIFFERENTIATED UNDIFFERENTIATED         n
# 11    ARM C: Combination      AGE             Mean             Mean      mean
# 12    ARM C: Combination      SEX                F                F         n
# 13    ARM C: Combination      SEX                M                M         n
# 14    ARM C: Combination      SEX                U                U         n
# 15    ARM C: Combination      SEX UNDIFFERENTIATED UNDIFFERENTIATED         n
#        stat stat_string
# 1  33.76866       33.77
# 2  79.00000          79
# 3  51.00000          51
# 4   3.00000           3
# 5   1.00000           1
# 6  35.43284       35.43
# 7  77.00000          77
# 8  55.00000          55
# 9   2.00000           2
# 10  0.00000           0
# 11 35.43182       35.43
# 12 66.00000          66
# 13 60.00000          60
# 14  4.00000           4
# 15  2.00000           2
```

### Customizing the Output

[`as_result_df()`](https://pharmaverse.github.io/rtables/reference/data.frame_export.md)
and ARDs depend on the content of the table, so it is possible to modify
the table to customize the output. For example, we can add some
user-defined statistics with custom names:

``` r

# rcell and in_rows are the core of any analysis function
rc <- rcell(c(1, 2), stat_names = c("Rand1", "Rand2"))
print(obj_stat_names(rc)) # c("Rand1", "Rand2")
# [1] "Rand1" "Rand2"

rc_row <- in_rows(
  .list = list(a = c(NA, 1), b = c(1, NA)),
  .formats = c("xx - xx", "xx.x - xx.x"),
  .format_na_strs = list(c("asda", "lkjklj")),
  .stat_names = list(c("A", "B"), c("B", "C"))
)

# Only a getter for this object
print(obj_stat_names(rc_row)) # list(a = c("A", "B"), b = c("B", "C"))
# $a
# [1] "A" "B"
# 
# $b
# [1] "B" "C"

# if c("A", "B"), one for each row
# if single list, duplicated
rc_row <- in_rows(
  .list = list(a = c(NA, 1), b = c(1, NA)),
  .formats = c("xx - xx", "xx.x - xx.x"),
  .format_na_strs = list(c("asda", "lkjklj")),
  .stat_names = c("A", "B")
)
print(obj_stat_names(rc_row)) # c("A", "B") # one for each row
# $a
# [1] "A"
# 
# $b
# [1] "B"
print(lapply(rc_row, obj_stat_names)) # identical to above + row names
# $a
# [1] "A"
# 
# $b
# [1] "B"

rc_row <- in_rows(
  .list = list(a = c(NA, 1), b = c(1, NA)),
  .formats = c("xx - xx", "xx.x - xx.x"),
  .format_na_strs = list(c("asda", "lkjklj")),
  .stat_names = list(c("A", "B")) # It is duplicated, check it yourself!
)
```

Let’s put it into practice:

``` r

mean_sd_custom <- function(x) {
  mean <- mean(x, na.rm = FALSE)
  sd <- sd(x, na.rm = FALSE)

  rcell(c(mean, sd),
    label = "Mean (SD)", format = "xx.x (xx.x)" # ,
    # stat_names = c("Mean", "SD")
  )
}
counts_percentage_custom <- function(x) {
  cnts <- table(x)
  out <- lapply(cnts, function(x) {
    perc <- x / sum(cnts)
    rcell(c(x, perc), format = "xx. (xx.%)")
  })
  in_rows(
    .list = as.list(out), .labels = names(cnts),
    .stat_names = list(c("Count", "Percentage"))
  )
}

lyt <- basic_table(show_colcounts = TRUE, colcount_format = "N=xx") |>
  split_cols_by("ARM", split_fun = keep_split_levels(c("A: Drug X", "B: Placebo"))) |>
  analyze(vars = "AGE", afun = mean_sd_custom) |>
  analyze(vars = "SEX", afun = counts_percentage_custom)

tbl <- build_table(lyt, ex_adsl)

as_result_df(tbl, make_ard = TRUE)
#    group1 group1_level variable   variable_level   variable_label  stat_name
# 1     ARM    A: Drug X      AGE        Mean (SD)        Mean (SD)       <NA>
# 2     ARM    A: Drug X      AGE        Mean (SD)        Mean (SD)       <NA>
# 3     ARM    A: Drug X      SEX                F                F      Count
# 4     ARM    A: Drug X      SEX                F                F Percentage
# 5     ARM    A: Drug X      SEX                M                M      Count
# 6     ARM    A: Drug X      SEX                M                M Percentage
# 7     ARM    A: Drug X      SEX                U                U      Count
# 8     ARM    A: Drug X      SEX                U                U Percentage
# 9     ARM    A: Drug X      SEX UNDIFFERENTIATED UNDIFFERENTIATED      Count
# 10    ARM    A: Drug X      SEX UNDIFFERENTIATED UNDIFFERENTIATED Percentage
# 11    ARM   B: Placebo      AGE        Mean (SD)        Mean (SD)       <NA>
# 12    ARM   B: Placebo      AGE        Mean (SD)        Mean (SD)       <NA>
# 13    ARM   B: Placebo      SEX                F                F      Count
# 14    ARM   B: Placebo      SEX                F                F Percentage
# 15    ARM   B: Placebo      SEX                M                M      Count
# 16    ARM   B: Placebo      SEX                M                M Percentage
# 17    ARM   B: Placebo      SEX                U                U      Count
# 18    ARM   B: Placebo      SEX                U                U Percentage
# 19    ARM   B: Placebo      SEX UNDIFFERENTIATED UNDIFFERENTIATED      Count
# 20    ARM   B: Placebo      SEX UNDIFFERENTIATED UNDIFFERENTIATED Percentage
#            stat stat_string
# 1  33.768656716        33.8
# 2   6.553325712         6.6
# 3  79.000000000          79
# 4   0.589552239          59
# 5  51.000000000          51
# 6   0.380597015          38
# 7   3.000000000           3
# 8   0.022388060           2
# 9   1.000000000           1
# 10  0.007462687           1
# 11 35.432835821        35.4
# 12  7.895413879         7.9
# 13 77.000000000          77
# 14  0.574626866          57
# 15 55.000000000          55
# 16  0.410447761          41
# 17  2.000000000           2
# 18  0.014925373           1
# 19  0.000000000           0
# 20  0.000000000           0
```

## More Complex Outputs

Let’s add hierarchical row and column splits:

``` r

lyt <- basic_table() |>
  split_rows_by("STRATA2") |>
  summarize_row_groups() |>
  split_cols_by("ARM") |>
  split_cols_by("STRATA1") |>
  analyze(c("AGE", "SEX"))

tbl <- build_table(lyt, ex_adsl)

as_result_df(tbl, make_ard = TRUE)
#      group1 group1_level group2   group2_level  group3 group3_level variable
# 1   STRATA2           S1    ARM      A: Drug X STRATA1            A  STRATA2
# 2   STRATA2           S1    ARM      A: Drug X STRATA1            A  STRATA2
# 3   STRATA2           S1    ARM      A: Drug X STRATA1            A      AGE
# 4   STRATA2           S1    ARM      A: Drug X STRATA1            A      SEX
# 5   STRATA2           S1    ARM      A: Drug X STRATA1            A      SEX
# 6   STRATA2           S1    ARM      A: Drug X STRATA1            A      SEX
# 7   STRATA2           S1    ARM      A: Drug X STRATA1            A      SEX
# 8   STRATA2           S2    ARM      A: Drug X STRATA1            A  STRATA2
# 9   STRATA2           S2    ARM      A: Drug X STRATA1            A  STRATA2
# 10  STRATA2           S2    ARM      A: Drug X STRATA1            A      AGE
# 11  STRATA2           S2    ARM      A: Drug X STRATA1            A      SEX
# 12  STRATA2           S2    ARM      A: Drug X STRATA1            A      SEX
# 13  STRATA2           S2    ARM      A: Drug X STRATA1            A      SEX
# 14  STRATA2           S2    ARM      A: Drug X STRATA1            A      SEX
# 15  STRATA2           S1    ARM      A: Drug X STRATA1            B  STRATA2
# 16  STRATA2           S1    ARM      A: Drug X STRATA1            B  STRATA2
# 17  STRATA2           S1    ARM      A: Drug X STRATA1            B      AGE
# 18  STRATA2           S1    ARM      A: Drug X STRATA1            B      SEX
# 19  STRATA2           S1    ARM      A: Drug X STRATA1            B      SEX
# 20  STRATA2           S1    ARM      A: Drug X STRATA1            B      SEX
# 21  STRATA2           S1    ARM      A: Drug X STRATA1            B      SEX
# 22  STRATA2           S2    ARM      A: Drug X STRATA1            B  STRATA2
# 23  STRATA2           S2    ARM      A: Drug X STRATA1            B  STRATA2
# 24  STRATA2           S2    ARM      A: Drug X STRATA1            B      AGE
# 25  STRATA2           S2    ARM      A: Drug X STRATA1            B      SEX
# 26  STRATA2           S2    ARM      A: Drug X STRATA1            B      SEX
# 27  STRATA2           S2    ARM      A: Drug X STRATA1            B      SEX
# 28  STRATA2           S2    ARM      A: Drug X STRATA1            B      SEX
# 29  STRATA2           S1    ARM      A: Drug X STRATA1            C  STRATA2
# 30  STRATA2           S1    ARM      A: Drug X STRATA1            C  STRATA2
# 31  STRATA2           S1    ARM      A: Drug X STRATA1            C      AGE
# 32  STRATA2           S1    ARM      A: Drug X STRATA1            C      SEX
# 33  STRATA2           S1    ARM      A: Drug X STRATA1            C      SEX
# 34  STRATA2           S1    ARM      A: Drug X STRATA1            C      SEX
# 35  STRATA2           S1    ARM      A: Drug X STRATA1            C      SEX
# 36  STRATA2           S2    ARM      A: Drug X STRATA1            C  STRATA2
# 37  STRATA2           S2    ARM      A: Drug X STRATA1            C  STRATA2
# 38  STRATA2           S2    ARM      A: Drug X STRATA1            C      AGE
# 39  STRATA2           S2    ARM      A: Drug X STRATA1            C      SEX
# 40  STRATA2           S2    ARM      A: Drug X STRATA1            C      SEX
# 41  STRATA2           S2    ARM      A: Drug X STRATA1            C      SEX
# 42  STRATA2           S2    ARM      A: Drug X STRATA1            C      SEX
# 43  STRATA2           S1    ARM     B: Placebo STRATA1            A  STRATA2
# 44  STRATA2           S1    ARM     B: Placebo STRATA1            A  STRATA2
# 45  STRATA2           S1    ARM     B: Placebo STRATA1            A      AGE
# 46  STRATA2           S1    ARM     B: Placebo STRATA1            A      SEX
# 47  STRATA2           S1    ARM     B: Placebo STRATA1            A      SEX
# 48  STRATA2           S1    ARM     B: Placebo STRATA1            A      SEX
# 49  STRATA2           S1    ARM     B: Placebo STRATA1            A      SEX
# 50  STRATA2           S2    ARM     B: Placebo STRATA1            A  STRATA2
# 51  STRATA2           S2    ARM     B: Placebo STRATA1            A  STRATA2
# 52  STRATA2           S2    ARM     B: Placebo STRATA1            A      AGE
# 53  STRATA2           S2    ARM     B: Placebo STRATA1            A      SEX
# 54  STRATA2           S2    ARM     B: Placebo STRATA1            A      SEX
# 55  STRATA2           S2    ARM     B: Placebo STRATA1            A      SEX
# 56  STRATA2           S2    ARM     B: Placebo STRATA1            A      SEX
# 57  STRATA2           S1    ARM     B: Placebo STRATA1            B  STRATA2
# 58  STRATA2           S1    ARM     B: Placebo STRATA1            B  STRATA2
# 59  STRATA2           S1    ARM     B: Placebo STRATA1            B      AGE
# 60  STRATA2           S1    ARM     B: Placebo STRATA1            B      SEX
# 61  STRATA2           S1    ARM     B: Placebo STRATA1            B      SEX
# 62  STRATA2           S1    ARM     B: Placebo STRATA1            B      SEX
# 63  STRATA2           S1    ARM     B: Placebo STRATA1            B      SEX
# 64  STRATA2           S2    ARM     B: Placebo STRATA1            B  STRATA2
# 65  STRATA2           S2    ARM     B: Placebo STRATA1            B  STRATA2
# 66  STRATA2           S2    ARM     B: Placebo STRATA1            B      AGE
# 67  STRATA2           S2    ARM     B: Placebo STRATA1            B      SEX
# 68  STRATA2           S2    ARM     B: Placebo STRATA1            B      SEX
# 69  STRATA2           S2    ARM     B: Placebo STRATA1            B      SEX
# 70  STRATA2           S2    ARM     B: Placebo STRATA1            B      SEX
# 71  STRATA2           S1    ARM     B: Placebo STRATA1            C  STRATA2
# 72  STRATA2           S1    ARM     B: Placebo STRATA1            C  STRATA2
# 73  STRATA2           S1    ARM     B: Placebo STRATA1            C      AGE
# 74  STRATA2           S1    ARM     B: Placebo STRATA1            C      SEX
# 75  STRATA2           S1    ARM     B: Placebo STRATA1            C      SEX
# 76  STRATA2           S1    ARM     B: Placebo STRATA1            C      SEX
# 77  STRATA2           S1    ARM     B: Placebo STRATA1            C      SEX
# 78  STRATA2           S2    ARM     B: Placebo STRATA1            C  STRATA2
# 79  STRATA2           S2    ARM     B: Placebo STRATA1            C  STRATA2
# 80  STRATA2           S2    ARM     B: Placebo STRATA1            C      AGE
# 81  STRATA2           S2    ARM     B: Placebo STRATA1            C      SEX
# 82  STRATA2           S2    ARM     B: Placebo STRATA1            C      SEX
# 83  STRATA2           S2    ARM     B: Placebo STRATA1            C      SEX
# 84  STRATA2           S2    ARM     B: Placebo STRATA1            C      SEX
# 85  STRATA2           S1    ARM C: Combination STRATA1            A  STRATA2
# 86  STRATA2           S1    ARM C: Combination STRATA1            A  STRATA2
# 87  STRATA2           S1    ARM C: Combination STRATA1            A      AGE
# 88  STRATA2           S1    ARM C: Combination STRATA1            A      SEX
# 89  STRATA2           S1    ARM C: Combination STRATA1            A      SEX
# 90  STRATA2           S1    ARM C: Combination STRATA1            A      SEX
# 91  STRATA2           S1    ARM C: Combination STRATA1            A      SEX
# 92  STRATA2           S2    ARM C: Combination STRATA1            A  STRATA2
# 93  STRATA2           S2    ARM C: Combination STRATA1            A  STRATA2
# 94  STRATA2           S2    ARM C: Combination STRATA1            A      AGE
# 95  STRATA2           S2    ARM C: Combination STRATA1            A      SEX
# 96  STRATA2           S2    ARM C: Combination STRATA1            A      SEX
# 97  STRATA2           S2    ARM C: Combination STRATA1            A      SEX
# 98  STRATA2           S2    ARM C: Combination STRATA1            A      SEX
# 99  STRATA2           S1    ARM C: Combination STRATA1            B  STRATA2
# 100 STRATA2           S1    ARM C: Combination STRATA1            B  STRATA2
# 101 STRATA2           S1    ARM C: Combination STRATA1            B      AGE
# 102 STRATA2           S1    ARM C: Combination STRATA1            B      SEX
# 103 STRATA2           S1    ARM C: Combination STRATA1            B      SEX
# 104 STRATA2           S1    ARM C: Combination STRATA1            B      SEX
# 105 STRATA2           S1    ARM C: Combination STRATA1            B      SEX
# 106 STRATA2           S2    ARM C: Combination STRATA1            B  STRATA2
# 107 STRATA2           S2    ARM C: Combination STRATA1            B  STRATA2
# 108 STRATA2           S2    ARM C: Combination STRATA1            B      AGE
# 109 STRATA2           S2    ARM C: Combination STRATA1            B      SEX
# 110 STRATA2           S2    ARM C: Combination STRATA1            B      SEX
# 111 STRATA2           S2    ARM C: Combination STRATA1            B      SEX
# 112 STRATA2           S2    ARM C: Combination STRATA1            B      SEX
# 113 STRATA2           S1    ARM C: Combination STRATA1            C  STRATA2
# 114 STRATA2           S1    ARM C: Combination STRATA1            C  STRATA2
# 115 STRATA2           S1    ARM C: Combination STRATA1            C      AGE
# 116 STRATA2           S1    ARM C: Combination STRATA1            C      SEX
# 117 STRATA2           S1    ARM C: Combination STRATA1            C      SEX
# 118 STRATA2           S1    ARM C: Combination STRATA1            C      SEX
# 119 STRATA2           S1    ARM C: Combination STRATA1            C      SEX
# 120 STRATA2           S2    ARM C: Combination STRATA1            C  STRATA2
# 121 STRATA2           S2    ARM C: Combination STRATA1            C  STRATA2
# 122 STRATA2           S2    ARM C: Combination STRATA1            C      AGE
# 123 STRATA2           S2    ARM C: Combination STRATA1            C      SEX
# 124 STRATA2           S2    ARM C: Combination STRATA1            C      SEX
# 125 STRATA2           S2    ARM C: Combination STRATA1            C      SEX
# 126 STRATA2           S2    ARM C: Combination STRATA1            C      SEX
#       variable_level   variable_label stat_name       stat stat_string
# 1                 S1               S1         n 18.0000000          18
# 2                 S1               S1         p  0.4736842        47.4
# 3               Mean             Mean      mean 31.6111111       31.61
# 4                  F                F         n 12.0000000          12
# 5                  M                M         n  5.0000000           5
# 6                  U                U         n  1.0000000           1
# 7   UNDIFFERENTIATED UNDIFFERENTIATED         n  0.0000000           0
# 8                 S2               S2         n 20.0000000          20
# 9                 S2               S2         p  0.5263158        52.6
# 10              Mean             Mean      mean 34.4000000        34.4
# 11                 F                F         n  9.0000000           9
# 12                 M                M         n 11.0000000          11
# 13                 U                U         n  0.0000000           0
# 14  UNDIFFERENTIATED UNDIFFERENTIATED         n  0.0000000           0
# 15                S1               S1         n 28.0000000          28
# 16                S1               S1         p  0.5957447        59.6
# 17              Mean             Mean      mean 34.5714286       34.57
# 18                 F                F         n 14.0000000          14
# 19                 M                M         n 13.0000000          13
# 20                 U                U         n  1.0000000           1
# 21  UNDIFFERENTIATED UNDIFFERENTIATED         n  0.0000000           0
# 22                S2               S2         n 19.0000000          19
# 23                S2               S2         p  0.4042553        40.4
# 24              Mean             Mean      mean 32.7894737       32.79
# 25                 F                F         n 11.0000000          11
# 26                 M                M         n  8.0000000           8
# 27                 U                U         n  0.0000000           0
# 28  UNDIFFERENTIATED UNDIFFERENTIATED         n  0.0000000           0
# 29                S1               S1         n 27.0000000          27
# 30                S1               S1         p  0.5510204        55.1
# 31              Mean             Mean      mean 35.2592593       35.26
# 32                 F                F         n 17.0000000          17
# 33                 M                M         n  8.0000000           8
# 34                 U                U         n  1.0000000           1
# 35  UNDIFFERENTIATED UNDIFFERENTIATED         n  1.0000000           1
# 36                S2               S2         n 22.0000000          22
# 37                S2               S2         p  0.4489796        44.9
# 38              Mean             Mean      mean 32.9545455       32.95
# 39                 F                F         n 16.0000000          16
# 40                 M                M         n  6.0000000           6
# 41                 U                U         n  0.0000000           0
# 42  UNDIFFERENTIATED UNDIFFERENTIATED         n  0.0000000           0
# 43                S1               S1         n 22.0000000          22
# 44                S1               S1         p  0.5000000          50
# 45              Mean             Mean      mean 36.6818182       36.68
# 46                 F                F         n 11.0000000          11
# 47                 M                M         n 10.0000000          10
# 48                 U                U         n  1.0000000           1
# 49  UNDIFFERENTIATED UNDIFFERENTIATED         n  0.0000000           0
# 50                S2               S2         n 22.0000000          22
# 51                S2               S2         p  0.5000000          50
# 52              Mean             Mean      mean 33.5454545       33.55
# 53                 F                F         n 13.0000000          13
# 54                 M                M         n  9.0000000           9
# 55                 U                U         n  0.0000000           0
# 56  UNDIFFERENTIATED UNDIFFERENTIATED         n  0.0000000           0
# 57                S1               S1         n 19.0000000          19
# 58                S1               S1         p  0.4222222        42.2
# 59              Mean             Mean      mean 37.6842105       37.68
# 60                 F                F         n 12.0000000          12
# 61                 M                M         n  7.0000000           7
# 62                 U                U         n  0.0000000           0
# 63  UNDIFFERENTIATED UNDIFFERENTIATED         n  0.0000000           0
# 64                S2               S2         n 26.0000000          26
# 65                S2               S2         p  0.5777778        57.8
# 66              Mean             Mean      mean 34.7692308       34.77
# 67                 F                F         n 15.0000000          15
# 68                 M                M         n 10.0000000          10
# 69                 U                U         n  1.0000000           1
# 70  UNDIFFERENTIATED UNDIFFERENTIATED         n  0.0000000           0
# 71                S1               S1         n 26.0000000          26
# 72                S1               S1         p  0.5777778        57.8
# 73              Mean             Mean      mean 35.3846154       35.38
# 74                 F                F         n 13.0000000          13
# 75                 M                M         n 13.0000000          13
# 76                 U                U         n  0.0000000           0
# 77  UNDIFFERENTIATED UNDIFFERENTIATED         n  0.0000000           0
# 78                S2               S2         n 19.0000000          19
# 79                S2               S2         p  0.4222222        42.2
# 80              Mean             Mean      mean 34.8947368       34.89
# 81                 F                F         n 13.0000000          13
# 82                 M                M         n  6.0000000           6
# 83                 U                U         n  0.0000000           0
# 84  UNDIFFERENTIATED UNDIFFERENTIATED         n  0.0000000           0
# 85                S1               S1         n 14.0000000          14
# 86                S1               S1         p  0.3500000          35
# 87              Mean             Mean      mean 34.0000000          34
# 88                 F                F         n  7.0000000           7
# 89                 M                M         n  6.0000000           6
# 90                 U                U         n  1.0000000           1
# 91  UNDIFFERENTIATED UNDIFFERENTIATED         n  0.0000000           0
# 92                S2               S2         n 26.0000000          26
# 93                S2               S2         p  0.6500000          65
# 94              Mean             Mean      mean 34.3461538       34.35
# 95                 F                F         n 11.0000000          11
# 96                 M                M         n 14.0000000          14
# 97                 U                U         n  0.0000000           0
# 98  UNDIFFERENTIATED UNDIFFERENTIATED         n  1.0000000           1
# 99                S1               S1         n 18.0000000          18
# 100               S1               S1         p  0.4186047        41.9
# 101             Mean             Mean      mean 35.8333333       35.83
# 102                F                F         n  9.0000000           9
# 103                M                M         n  9.0000000           9
# 104                U                U         n  0.0000000           0
# 105 UNDIFFERENTIATED UNDIFFERENTIATED         n  0.0000000           0
# 106               S2               S2         n 25.0000000          25
# 107               S2               S2         p  0.5813953        58.1
# 108             Mean             Mean      mean 36.6800000       36.68
# 109                F                F         n 12.0000000          12
# 110                M                M         n 12.0000000          12
# 111                U                U         n  1.0000000           1
# 112 UNDIFFERENTIATED UNDIFFERENTIATED         n  0.0000000           0
# 113               S1               S1         n 24.0000000          24
# 114               S1               S1         p  0.4897959          49
# 115             Mean             Mean      mean 36.5833333       36.58
# 116                F                F         n 14.0000000          14
# 117                M                M         n  8.0000000           8
# 118                U                U         n  1.0000000           1
# 119 UNDIFFERENTIATED UNDIFFERENTIATED         n  1.0000000           1
# 120               S2               S2         n 25.0000000          25
# 121               S2               S2         p  0.5102041          51
# 122             Mean             Mean      mean 34.7200000       34.72
# 123                F                F         n 13.0000000          13
# 124                M                M         n 11.0000000          11
# 125                U                U         n  1.0000000           1
# 126 UNDIFFERENTIATED UNDIFFERENTIATED         n  0.0000000           0
```
