# Apply basic split (for use in custom split functions)

This function is intended for use inside custom split functions. It
applies the current split *as if it had no custom splitting function* so
that those default splits can be further manipulated.

## Usage

``` r
do_base_split(spl, df, vals = NULL, labels = NULL, trim = FALSE)
```

## Arguments

- spl:

  (`Split`)\
  a `Split` object defining a partitioning or analysis/tabulation of the
  data.

- df:

  (`data.frame` or `tibble`)\
  dataset.

- vals:

  (`ANY`)\
  already calculated/known values of the split. Generally should be left
  as `NULL`.

- labels:

  (`character`)\
  labels associated with `vals`. Should be `NULL` whenever `vals` is,
  which should almost always be the case.

- trim:

  (`flag`)\
  whether groups corresponding to empty data subsets should be removed.
  Defaults to `FALSE`.

## Value

The result of the split being applied as if it had no custom split
function. See
[custom_split_funs](https://pharmaverse.github.io/rtables/reference/custom_split_funs.md).

## Examples

``` r
uneven_splfun <- function(df, spl, vals = NULL, labels = NULL, trim = FALSE) {
  ret <- do_base_split(spl, df, vals, labels, trim)
  if (NROW(df) == 0) {
    ret <- lapply(ret, function(x) x[1])
  }
  ret
}

lyt <- basic_table() |>
  split_cols_by("ARM") |>
  split_cols_by_multivar(c("USUBJID", "AESEQ", "BMRKR1"),
    varlabels = c("N", "E", "BMR1"),
    split_fun = uneven_splfun
  ) |>
  analyze_colvars(list(
    USUBJID = function(x, ...) length(unique(x)),
    AESEQ = max,
    BMRKR1 = mean
  ))

tbl <- build_table(lyt, subset(ex_adae, as.numeric(ARM) <= 2))
tbl
#>             A: Drug X                    B: Placebo            C: Combination
#>     N    E          BMR1          N    E          BMR1               N       
#> —————————————————————————————————————————————————————————————————————————————
#>    122   10   6.09356345928374   123   10   5.86496605625578         0       
```
