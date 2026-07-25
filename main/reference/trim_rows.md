# Trim rows from a populated table without regard for table structure

Trim rows from a populated table without regard for table structure

## Usage

``` r
trim_rows(tt, criteria = all_zero_or_na)
```

## Arguments

- tt:

  (`TableTree` or related class)\
  a `TableTree` object representing a populated table.

- criteria:

  (`function`)\
  function which takes a `TableRow` object and returns `TRUE` if that
  row should be removed. Defaults to
  [`all_zero_or_na()`](https://pharmaverse.github.io/rtables/reference/trim_prune_funs.md).

## Value

The table with rows that have only `NA` or 0 cell values removed.

## Details

This function will be deprecated in the future in favor of the more
elegant and versatile
[`prune_table()`](https://pharmaverse.github.io/rtables/reference/prune_table.md)
function which can perform the same function as `trim_rows()` but is
more powerful as it takes table structure into account.

## Note

Visible `LabelRow`s are including in this trimming, which can lead to
either all label rows being trimmed or label rows remaining when all
data rows have been trimmed, depending on what `criteria` returns when
called on a `LabelRow` object. To avoid this, use the structurally-aware
[`prune_table()`](https://pharmaverse.github.io/rtables/reference/prune_table.md)
machinery instead.

## See also

[`prune_table()`](https://pharmaverse.github.io/rtables/reference/prune_table.md)

## Examples

``` r
adsl <- ex_adsl
levels(adsl$SEX) <- c(levels(ex_adsl$SEX), "OTHER")

tbl_to_trim <- basic_table() |>
  analyze("BMRKR1") |>
  split_cols_by("ARM") |>
  split_rows_by("SEX") |>
  summarize_row_groups() |>
  split_rows_by("STRATA1") |>
  summarize_row_groups() |>
  analyze("AGE") |>
  build_table(adsl)

tbl_to_trim |> trim_rows()
#>                    A: Drug X    B: Placebo   C: Combination
#> ———————————————————————————————————————————————————————————
#> Mean                  5.97         5.70           5.62     
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
#>     Mean               NA           NA           44.00     
#>   C                 1 (0.7%)     0 (0.0%)       1 (0.8%)   
#>     Mean             28.00          NA           46.00     

tbl_to_trim |> trim_rows(all_zero)
#>                    A: Drug X    B: Placebo   C: Combination
#> ———————————————————————————————————————————————————————————
#> Mean                  5.97         5.70           5.62     
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
#>     Mean               NA           NA           44.00     
#>   Mean                 NA           NA             NA      
#>   C                 1 (0.7%)     0 (0.0%)       1 (0.8%)   
#>     Mean             28.00          NA           46.00     
#> Mean                   NA           NA             NA      
#> Mean                   NA           NA             NA      
#> Mean                   NA           NA             NA      
```
