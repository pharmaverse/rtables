# Add overall or combination levels to split groups

`add_overall_level` is a split function that adds a global level to the
current levels in the split. Similarly, `add_combo_levels` uses a
user-provided `data.frame` to define the combine the levels to be added.
If you need a single overall column, after all splits, please check
[`add_overall_col()`](https://pharmaverse.github.io/rtables/reference/add_overall_col.md).
Consider also defining your custom split function if you need more
flexibility (see
[custom_split_funs](https://pharmaverse.github.io/rtables/reference/custom_split_funs.md)).

## Usage

``` r
add_overall_level(
  valname = "Overall",
  label = valname,
  extra_args = list(),
  first = TRUE,
  trim = FALSE
)

select_all_levels

add_combo_levels(combosdf, trim = FALSE, first = FALSE, keep_levels = NULL)
```

## Arguments

- valname:

  (`string`)\
  value to be assigned to the implicit all-observations split level.
  Defaults to `"Overall"`.

- label:

  (`string`)\
  a label (not to be confused with the name) for the object/structure.

- extra_args:

  (`list`)\
  extra arguments to be passed to the tabulation function. Element
  position in the list corresponds to the children of this split. Named
  elements in the child-specific lists are ignored if they do not match
  a formal argument of the tabulation function.

- first:

  (`flag`)\
  whether the implicit level should appear first (`TRUE`) or last
  (`FALSE`). Defaults to `TRUE`.

- trim:

  (`flag`)\
  whether splits corresponding with 0 observations should be kept when
  tabulating.

- combosdf:

  (`data.frame` or `tbl_df`)\
  a data frame with columns `valname`, `label`, `levelcombo`, and
  `exargs`. `levelcombo` and `exargs` should be list columns. Passing
  the `select_all_levels` object as a value in `comblevels` column
  indicates that an overall/all-observations level should be created.

- keep_levels:

  (`character` or `NULL`)\
  if non-`NULL`, the levels to retain across both combination and
  individual levels.

## Value

A splitting function (`splfun`) that adds or changes the levels of a
split.

## Note

Analysis or summary functions for which the order matters should never
be used within the tabulation framework.

## See also

[custom_split_funs](https://pharmaverse.github.io/rtables/reference/custom_split_funs.md)
and
[split_funcs](https://pharmaverse.github.io/rtables/reference/split_funcs.md).

## Examples

``` r
lyt <- basic_table() |>
  split_cols_by("ARM", split_fun = add_overall_level("All Patients",
    first = FALSE
  )) |>
  analyze("AGE")

tbl <- build_table(lyt, DM)
tbl
#>        A: Drug X   B: Placebo   C: Combination   All Patients
#> —————————————————————————————————————————————————————————————
#> Mean     34.91       33.02          34.57           34.22    

lyt2 <- basic_table() |>
  split_cols_by("ARM") |>
  split_rows_by("RACE",
    split_fun = add_overall_level("All Ethnicities")
  ) |>
  summarize_row_groups(label_fstr = "%s (n)") |>
  analyze("AGE")
lyt2
#> A Pre-data Table Layout
#> 
#> Column-Split Structure:
#> ARM (lvls) 
#> 
#> Row-Split Structure:
#> RACE (lvls) -> AGE (** analysis **) 
#> 

tbl2 <- build_table(lyt2, DM)
tbl2
#>                                                  A: Drug X      B: Placebo    C: Combination
#> ————————————————————————————————————————————————————————————————————————————————————————————
#> All Ethnicities (n)                             121 (100.0%)   106 (100.0%)    129 (100.0%) 
#>   Mean                                             34.91          33.02           34.57     
#> ASIAN (n)                                        79 (65.3%)     68 (64.2%)      84 (65.1%)  
#>   Mean                                             34.20          32.68           34.63     
#> BLACK OR AFRICAN AMERICAN (n)                    28 (23.1%)     24 (22.6%)      27 (20.9%)  
#>   Mean                                             34.68          31.71           34.00     
#> WHITE (n)                                        14 (11.6%)     14 (13.2%)      18 (14.0%)  
#>   Mean                                             39.36          36.93           35.11     
#> AMERICAN INDIAN OR ALASKA NATIVE (n)              0 (0.0%)       0 (0.0%)        0 (0.0%)   
#>   Mean                                               NA             NA              NA      
#> MULTIPLE (n)                                      0 (0.0%)       0 (0.0%)        0 (0.0%)   
#>   Mean                                               NA             NA              NA      
#> NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER (n)     0 (0.0%)       0 (0.0%)        0 (0.0%)   
#>   Mean                                               NA             NA              NA      
#> OTHER (n)                                         0 (0.0%)       0 (0.0%)        0 (0.0%)   
#>   Mean                                               NA             NA              NA      
#> UNKNOWN (n)                                       0 (0.0%)       0 (0.0%)        0 (0.0%)   
#>   Mean                                               NA             NA              NA      


library(tibble)
combodf <- tribble(
  ~valname, ~label, ~levelcombo, ~exargs,
  "A_B", "Arms A+B", c("A: Drug X", "B: Placebo"), list(),
  "A_C", "Arms A+C", c("A: Drug X", "C: Combination"), list()
)

lyt <- basic_table(show_colcounts = TRUE) |>
  split_cols_by("ARM", split_fun = add_combo_levels(combodf)) |>
  analyze("AGE")

tbl <- build_table(lyt, DM)
tbl
#>        A: Drug X   B: Placebo   C: Combination   Arms A+B   Arms A+C
#>         (N=121)     (N=106)        (N=129)       (N=227)    (N=250) 
#> ————————————————————————————————————————————————————————————————————
#> Mean     34.91       33.02          34.57         34.03      34.73  

lyt1 <- basic_table(show_colcounts = TRUE) |>
  split_cols_by("ARM",
    split_fun = add_combo_levels(combodf,
      keep_levels = c(
        "A_B",
        "A_C"
      )
    )
  ) |>
  analyze("AGE")

tbl1 <- build_table(lyt1, DM)
tbl1
#>        Arms A+B   Arms A+C
#>        (N=227)    (N=250) 
#> ——————————————————————————
#> Mean    34.03      34.73  

smallerDM <- droplevels(subset(DM, SEX %in% c("M", "F") &
  grepl("^(A|B)", ARM)))
lyt2 <- basic_table(show_colcounts = TRUE) |>
  split_cols_by("ARM", split_fun = add_combo_levels(combodf[1, ])) |>
  split_cols_by("SEX",
    split_fun = add_overall_level("SEX_ALL", "All Genders")
  ) |>
  analyze("AGE")

lyt3 <- basic_table(show_colcounts = TRUE) |>
  split_cols_by("ARM", split_fun = add_combo_levels(combodf)) |>
  split_rows_by("SEX",
    split_fun = add_overall_level("SEX_ALL", "All Genders")
  ) |>
  summarize_row_groups() |>
  analyze("AGE")

tbl3 <- build_table(lyt3, smallerDM)
tbl3
#>                A: Drug X      B: Placebo      Arms A+B       Arms A+C  
#>                 (N=121)        (N=106)        (N=227)        (N=121)   
#> ———————————————————————————————————————————————————————————————————————
#> All Genders   121 (100.0%)   106 (100.0%)   227 (100.0%)   121 (100.0%)
#>   Mean           34.91          33.02          34.03          34.91    
#> F              70 (57.9%)     56 (52.8%)    126 (55.5%)     70 (57.9%) 
#>   Mean           33.71          33.84          33.77          33.71    
#> M              51 (42.1%)     50 (47.2%)    101 (44.5%)     51 (42.1%) 
#>   Mean           36.55          32.10          34.35          36.55    
```
