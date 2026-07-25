# Trimming and pruning criteria

Criteria functions (and constructors thereof) for trimming and pruning
tables.

## Usage

``` r
all_zero_or_na(tr)

all_zero(tr)

content_all_zeros_nas(tt, criteria = all_zero_or_na)

prune_empty_level(tt)

prune_zeros_only(tt)

low_obs_pruner(min, type = c("sum", "mean"))
```

## Arguments

- tr:

  (`TableRow` or related class)\
  a `TableRow` object representing a single row within a populated
  table.

- tt:

  (`TableTree` or related class)\
  a `TableTree` object representing a populated table.

- criteria:

  (`function`)\
  function which takes a `TableRow` object and returns `TRUE` if that
  row should be removed. Defaults to `all_zero_or_na()`.

- min:

  (`numeric(1)`)\
  (used by `low_obs_pruner` only). Minimum aggregate count value.
  Subtables whose combined/average count are below this threshold will
  be pruned.

- type:

  (`string`)\
  how count values should be aggregated. Must be `"sum"` (the default)
  or `"mean"`.

## Value

A logical value indicating whether `tr` should be included (`TRUE`) or
pruned (`FALSE`) during pruning.

## Details

`all_zero_or_na` returns `TRUE` (and thus indicates trimming/pruning)
for any *non-`LabelRow`* `TableRow` which contain only any mix of `NA`
(including `NaN`), `0`, `Inf` and `-Inf` values.

`all_zero` returns `TRUE` for any non-`LabelRow` which contains only
(non-missing) zero values.

`content_all_zeros_nas` prunes a subtable if both of the following are
true:

- It has a content table with exactly one row in it.

- `all_zero_or_na` returns `TRUE` for that single content row. In
  practice, when the default summary/content function is used, this
  represents pruning any subtable which corresponds to an empty set of
  the input data (e.g. because a factor variable was used in
  [`split_rows_by()`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)
  but not all levels were present in the data).

`prune_empty_level` combines `all_zero_or_na` behavior for `TableRow`
objects, `content_all_zeros_nas` on `content_table(tt)` for `TableTree`
objects, and an additional check that returns `TRUE` if the `tt` has no
children.

`prune_zeros_only` behaves as `prune_empty_level` does, except that like
`all_zero` it prunes only in the case of all non-missing zero values.

`low_obs_pruner` is a *constructor function* which, when called, returns
a pruning criteria function which will prune on content rows by
comparing sum or mean (dictated by `type`) of the count portions of the
cell values (defined as the first value per cell regardless of how many
values per cell there are) against `min`.

## See also

[`prune_table()`](https://pharmaverse.github.io/rtables/reference/prune_table.md),
[`trim_rows()`](https://pharmaverse.github.io/rtables/reference/trim_rows.md)

## Examples

``` r
adsl <- ex_adsl
levels(adsl$SEX) <- c(levels(ex_adsl$SEX), "OTHER")
adsl$AGE[adsl$SEX == "UNDIFFERENTIATED"] <- 0
adsl$BMRKR1 <- 0

tbl_to_prune <- basic_table() |>
  analyze("BMRKR1") |>
  split_cols_by("ARM") |>
  split_rows_by("SEX") |>
  summarize_row_groups() |>
  split_rows_by("STRATA1") |>
  summarize_row_groups() |>
  analyze("AGE") |>
  build_table(adsl)

tbl_to_prune |> prune_table(all_zero_or_na)
#>            A: Drug X    B: Placebo   C: Combination
#> ———————————————————————————————————————————————————
#> F          79 (59.0%)   77 (57.5%)     66 (50.0%)  
#>   A        21 (15.7%)   24 (17.9%)     18 (13.6%)  
#>     Mean     31.14        32.08          34.22     
#>   B        25 (18.7%)   27 (20.1%)     21 (15.9%)  
#>     Mean     32.84        35.33          36.57     
#>   C        33 (24.6%)   26 (19.4%)     27 (20.5%)  
#>     Mean     33.73        34.73          34.78     
#> M          51 (38.1%)   55 (41.0%)     60 (45.5%)  
#>   A        16 (11.9%)   19 (14.2%)     20 (15.2%)  
#>     Mean     35.62        39.37          33.55     
#>   B        21 (15.7%)   17 (12.7%)     21 (15.9%)  
#>     Mean     35.33        37.12          36.05     
#>   C        14 (10.4%)   19 (14.2%)     19 (14.4%)  
#>     Mean     35.86        35.79          36.58     
#> U           3 (2.2%)     2 (1.5%)       4 (3.0%)   
#>   A         1 (0.7%)     1 (0.7%)       1 (0.8%)   
#>     Mean     33.00        27.00          38.00     
#>   B         1 (0.7%)     1 (0.7%)       1 (0.8%)   
#>     Mean     28.00        35.00          37.00     
#>   C         1 (0.7%)     0 (0.0%)       2 (1.5%)   
#>     Mean     34.00          NA           33.00     

tbl_to_prune |> prune_table(all_zero)
#>                    A: Drug X    B: Placebo   C: Combination
#> ———————————————————————————————————————————————————————————
#> F                  79 (59.0%)   77 (57.5%)     66 (50.0%)  
#>   A                21 (15.7%)   24 (17.9%)     18 (13.6%)  
#>     Mean             31.14        32.08          34.22     
#>   B                25 (18.7%)   27 (20.1%)     21 (15.9%)  
#>     Mean             32.84        35.33          36.57     
#>   C                33 (24.6%)   26 (19.4%)     27 (20.5%)  
#>     Mean             33.73        34.73          34.78     
#> M                  51 (38.1%)   55 (41.0%)     60 (45.5%)  
#>   A                16 (11.9%)   19 (14.2%)     20 (15.2%)  
#>     Mean             35.62        39.37          33.55     
#>   B                21 (15.7%)   17 (12.7%)     21 (15.9%)  
#>     Mean             35.33        37.12          36.05     
#>   C                14 (10.4%)   19 (14.2%)     19 (14.4%)  
#>     Mean             35.86        35.79          36.58     
#> U                   3 (2.2%)     2 (1.5%)       4 (3.0%)   
#>   A                 1 (0.7%)     1 (0.7%)       1 (0.8%)   
#>     Mean             33.00        27.00          38.00     
#>   B                 1 (0.7%)     1 (0.7%)       1 (0.8%)   
#>     Mean             28.00        35.00          37.00     
#>   C                 1 (0.7%)     0 (0.0%)       2 (1.5%)   
#>     Mean             34.00          NA           33.00     
#> UNDIFFERENTIATED    1 (0.7%)     0 (0.0%)       2 (1.5%)   
#>   A                 0 (0.0%)     0 (0.0%)       1 (0.8%)   
#>     Mean               NA           NA            0.00     
#>   B                 0 (0.0%)     0 (0.0%)       0 (0.0%)   
#>     Mean               NA           NA             NA      
#>   C                 1 (0.7%)     0 (0.0%)       1 (0.8%)   
#>     Mean              0.00          NA            0.00     
#> OTHER               0 (0.0%)     0 (0.0%)       0 (0.0%)   
#>   A                 0 (0.0%)     0 (0.0%)       0 (0.0%)   
#>     Mean               NA           NA             NA      
#>   B                 0 (0.0%)     0 (0.0%)       0 (0.0%)   
#>     Mean               NA           NA             NA      
#>   C                 0 (0.0%)     0 (0.0%)       0 (0.0%)   
#>     Mean               NA           NA             NA      

tbl_to_prune |> prune_table(content_all_zeros_nas)
#>                    A: Drug X    B: Placebo   C: Combination
#> ———————————————————————————————————————————————————————————
#> Mean                  0.00         0.00           0.00     
#> F                  79 (59.0%)   77 (57.5%)     66 (50.0%)  
#>   A                21 (15.7%)   24 (17.9%)     18 (13.6%)  
#>     Mean             31.14        32.08          34.22     
#>   B                25 (18.7%)   27 (20.1%)     21 (15.9%)  
#>     Mean             32.84        35.33          36.57     
#>   C                33 (24.6%)   26 (19.4%)     27 (20.5%)  
#>     Mean             33.73        34.73          34.78     
#> M                  51 (38.1%)   55 (41.0%)     60 (45.5%)  
#>   A                16 (11.9%)   19 (14.2%)     20 (15.2%)  
#>     Mean             35.62        39.37          33.55     
#>   B                21 (15.7%)   17 (12.7%)     21 (15.9%)  
#>     Mean             35.33        37.12          36.05     
#>   C                14 (10.4%)   19 (14.2%)     19 (14.4%)  
#>     Mean             35.86        35.79          36.58     
#> U                   3 (2.2%)     2 (1.5%)       4 (3.0%)   
#>   A                 1 (0.7%)     1 (0.7%)       1 (0.8%)   
#>     Mean             33.00        27.00          38.00     
#>   B                 1 (0.7%)     1 (0.7%)       1 (0.8%)   
#>     Mean             28.00        35.00          37.00     
#>   C                 1 (0.7%)     0 (0.0%)       2 (1.5%)   
#>     Mean             34.00          NA           33.00     
#> UNDIFFERENTIATED    1 (0.7%)     0 (0.0%)       2 (1.5%)   
#>   A                 0 (0.0%)     0 (0.0%)       1 (0.8%)   
#>     Mean               NA           NA            0.00     
#>   C                 1 (0.7%)     0 (0.0%)       1 (0.8%)   
#>     Mean              0.00          NA            0.00     

tbl_to_prune |> prune_table(prune_empty_level)
#>            A: Drug X    B: Placebo   C: Combination
#> ———————————————————————————————————————————————————
#> F          79 (59.0%)   77 (57.5%)     66 (50.0%)  
#>   A        21 (15.7%)   24 (17.9%)     18 (13.6%)  
#>     Mean     31.14        32.08          34.22     
#>   B        25 (18.7%)   27 (20.1%)     21 (15.9%)  
#>     Mean     32.84        35.33          36.57     
#>   C        33 (24.6%)   26 (19.4%)     27 (20.5%)  
#>     Mean     33.73        34.73          34.78     
#> M          51 (38.1%)   55 (41.0%)     60 (45.5%)  
#>   A        16 (11.9%)   19 (14.2%)     20 (15.2%)  
#>     Mean     35.62        39.37          33.55     
#>   B        21 (15.7%)   17 (12.7%)     21 (15.9%)  
#>     Mean     35.33        37.12          36.05     
#>   C        14 (10.4%)   19 (14.2%)     19 (14.4%)  
#>     Mean     35.86        35.79          36.58     
#> U           3 (2.2%)     2 (1.5%)       4 (3.0%)   
#>   A         1 (0.7%)     1 (0.7%)       1 (0.8%)   
#>     Mean     33.00        27.00          38.00     
#>   B         1 (0.7%)     1 (0.7%)       1 (0.8%)   
#>     Mean     28.00        35.00          37.00     
#>   C         1 (0.7%)     0 (0.0%)       2 (1.5%)   
#>     Mean     34.00          NA           33.00     

tbl_to_prune |> prune_table(prune_zeros_only)
#>                    A: Drug X    B: Placebo   C: Combination
#> ———————————————————————————————————————————————————————————
#> F                  79 (59.0%)   77 (57.5%)     66 (50.0%)  
#>   A                21 (15.7%)   24 (17.9%)     18 (13.6%)  
#>     Mean             31.14        32.08          34.22     
#>   B                25 (18.7%)   27 (20.1%)     21 (15.9%)  
#>     Mean             32.84        35.33          36.57     
#>   C                33 (24.6%)   26 (19.4%)     27 (20.5%)  
#>     Mean             33.73        34.73          34.78     
#> M                  51 (38.1%)   55 (41.0%)     60 (45.5%)  
#>   A                16 (11.9%)   19 (14.2%)     20 (15.2%)  
#>     Mean             35.62        39.37          33.55     
#>   B                21 (15.7%)   17 (12.7%)     21 (15.9%)  
#>     Mean             35.33        37.12          36.05     
#>   C                14 (10.4%)   19 (14.2%)     19 (14.4%)  
#>     Mean             35.86        35.79          36.58     
#> U                   3 (2.2%)     2 (1.5%)       4 (3.0%)   
#>   A                 1 (0.7%)     1 (0.7%)       1 (0.8%)   
#>     Mean             33.00        27.00          38.00     
#>   B                 1 (0.7%)     1 (0.7%)       1 (0.8%)   
#>     Mean             28.00        35.00          37.00     
#>   C                 1 (0.7%)     0 (0.0%)       2 (1.5%)   
#>     Mean             34.00          NA           33.00     
#> UNDIFFERENTIATED    1 (0.7%)     0 (0.0%)       2 (1.5%)   
#>   A                 0 (0.0%)     0 (0.0%)       1 (0.8%)   
#>     Mean               NA           NA            0.00     
#>   C                 1 (0.7%)     0 (0.0%)       1 (0.8%)   
#>     Mean              0.00          NA            0.00     

min_prune <- low_obs_pruner(70, "sum")
tbl_to_prune |> prune_table(min_prune)
#>            A: Drug X    B: Placebo   C: Combination
#> ———————————————————————————————————————————————————
#> Mean          0.00         0.00           0.00     
#> F          79 (59.0%)   77 (57.5%)     66 (50.0%)  
#>   B        25 (18.7%)   27 (20.1%)     21 (15.9%)  
#>     Mean     32.84        35.33          36.57     
#>   C        33 (24.6%)   26 (19.4%)     27 (20.5%)  
#>     Mean     33.73        34.73          34.78     
```
