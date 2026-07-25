# Recursively prune a `TableTree`

Recursively prune a `TableTree`

## Usage

``` r
prune_table(
  tt,
  prune_func = prune_empty_level,
  stop_depth = NA_real_,
  depth = 0,
  ...
)
```

## Arguments

- tt:

  (`TableTree` or related class)\
  a `TableTree` object representing a populated table.

- prune_func:

  (`function`)\
  a function to be called on each subtree which returns `TRUE` if the
  entire subtree should be removed.

- stop_depth:

  (`numeric(1)`)\
  the depth after which subtrees should not be checked for pruning.
  Defaults to `NA` which indicates pruning should happen at all levels.

- depth:

  (`numeric(1)`)\
  used internally, not intended to be set by the end user.

- ...:

  named arguments to optionally be passed down to `prune_func` if it
  accepts them (or `...`)

## Value

A `TableTree` pruned via recursive application of `prune_func`.

## See also

[`prune_empty_level()`](https://pharmaverse.github.io/rtables/reference/trim_prune_funs.md)
for details on this and several other basic pruning functions included
in the `rtables` package.

## Examples

``` r
adsl <- ex_adsl
levels(adsl$SEX) <- c(levels(ex_adsl$SEX), "OTHER")

tbl_to_prune <- basic_table() |>
  split_cols_by("ARM") |>
  split_rows_by("SEX") |>
  summarize_row_groups() |>
  split_rows_by("STRATA1") |>
  summarize_row_groups() |>
  analyze("AGE") |>
  build_table(adsl)

tbl_to_prune |> prune_table()
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
#>     Mean               NA           NA           44.00     
#>   C                 1 (0.7%)     0 (0.0%)       1 (0.8%)   
#>     Mean             28.00          NA           46.00     
```
