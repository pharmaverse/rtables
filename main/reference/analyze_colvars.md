# Generate rows analyzing different variables across columns

Generate rows analyzing different variables across columns

## Usage

``` r
analyze_colvars(
  lyt,
  afun,
  parent_name = get_acolvar_name(lyt),
  format = NULL,
  na_str = NA_character_,
  nested = TRUE,
  extra_args = list(),
  indent_mod = 0L,
  inclNAs = FALSE
)
```

## Arguments

- lyt:

  (`PreDataTableLayouts`)\
  layout object pre-data used for tabulation.

- afun:

  (`function` or `list`)\
  function(s) to be used to calculate the values in each column. The
  list will be repped out as needed and matched by position with the
  columns during tabulation. This functions accepts the same parameters
  as
  [`analyze()`](https://pharmaverse.github.io/rtables/reference/analyze.md)
  like `afun` and `format`. For further information see
  [additional_fun_params](https://pharmaverse.github.io/rtables/reference/additional_fun_params.md).

- parent_name:

  (`character(1)`)\
  Name to assign to the table corresponding to the *split* or *group of
  sibling analyses*, for `split_rows_by*` and `analyze*` when analyzing
  more than one variable, respectively. Ignored when analyzing a single
  variable.

- format:

  (`string`, `function`, or `list`)\
  format associated with this split. Formats can be declared via strings
  (`"xx.x"`) or function. In cases such as `analyze` calls, they can be
  character vectors or lists of functions. See
  [`formatters::list_valid_format_labels()`](https://rdrr.io/pkg/formatters/man/list_formats.html)
  for a list of all available format strings.

- na_str:

  (`string`)\
  string that should be displayed when the value of `x` is missing.
  Defaults to `"NA"`.

- nested:

  (`logical`)\
  whether this layout instruction should be applied within the existing
  layout structure *if possible* (`TRUE`, the default) or as a new
  top-level element (`FALSE`). Ignored if it would nest a split
  underneath analyses, which is not allowed.

- extra_args:

  (`list`)\
  extra arguments to be passed to the tabulation function. Element
  position in the list corresponds to the children of this split. Named
  elements in the child-specific lists are ignored if they do not match
  a formal argument of the tabulation function.

- indent_mod:

  (`numeric`)\
  modifier for the default indent position for the structure created by
  this function (subtable, content table, or row) *and all of that
  structure's children*. Defaults to 0, which corresponds to the
  unmodified default behavior.

- inclNAs:

  (`logical`)\
  whether NA observations in the `var` variable(s) should be included
  when performing the analysis. Defaults to `FALSE`.

## Value

A `PreDataTableLayouts` object suitable for passing to further layouting
functions, and to
[`build_table()`](https://pharmaverse.github.io/rtables/reference/build_table.md).

## See also

[`split_cols_by_multivar()`](https://pharmaverse.github.io/rtables/reference/split_cols_by_multivar.md)

## Author

Gabriel Becker

## Examples

``` r
library(dplyr)

ANL <- DM |> mutate(value = rnorm(n()), pctdiff = runif(n()))

## toy example where we take the mean of the first variable and the
## count of >.5 for the second.
colfuns <- list(
  function(x) rcell(mean(x), format = "xx.x"),
  function(x) rcell(sum(x > .5), format = "xx")
)

lyt <- basic_table() |>
  split_cols_by("ARM") |>
  split_cols_by_multivar(c("value", "pctdiff")) |>
  split_rows_by("RACE",
    split_label = "ethnicity",
    split_fun = drop_split_levels
  ) |>
  summarize_row_groups() |>
  analyze_colvars(afun = colfuns)
lyt
#> A Pre-data Table Layout
#> 
#> Column-Split Structure:
#> ARM (lvls) -> value:pctdiff (vars) 
#> 
#> Row-Split Structure:
#> RACE (lvls) -> NA (** col-var analysis **) 
#> 

tbl <- build_table(lyt, ANL)
tbl
#>                                    A: Drug X                B: Placebo              C: Combination     
#>                               value       pctdiff       value       pctdiff       value       pctdiff  
#> ———————————————————————————————————————————————————————————————————————————————————————————————————————
#> ASIAN                       79 (65.3%)   79 (65.3%)   68 (64.2%)   68 (64.2%)   84 (65.1%)   84 (65.1%)
#>                                0.0           32          0.2           28          0.1           42    
#> BLACK OR AFRICAN AMERICAN   28 (23.1%)   28 (23.1%)   24 (22.6%)   24 (22.6%)   27 (20.9%)   27 (20.9%)
#>                                -0.0          15          0.1           9           0.1           15    
#> WHITE                       14 (11.6%)   14 (11.6%)   14 (13.2%)   14 (13.2%)   18 (14.0%)   18 (14.0%)
#>                                -0.2          10          0.3           7           -0.3          12    

lyt2 <- basic_table() |>
  split_cols_by("ARM") |>
  split_cols_by_multivar(c("value", "pctdiff"),
    varlabels = c("Measurement", "Pct Diff")
  ) |>
  split_rows_by("RACE",
    split_label = "ethnicity",
    split_fun = drop_split_levels
  ) |>
  summarize_row_groups() |>
  analyze_colvars(afun = mean, format = "xx.xx")

tbl2 <- build_table(lyt2, ANL)
tbl2
#>                                    A: Drug X                  B: Placebo               C: Combination     
#>                             Measurement    Pct Diff    Measurement    Pct Diff    Measurement    Pct Diff 
#> ——————————————————————————————————————————————————————————————————————————————————————————————————————————
#> ASIAN                       79 (65.3%)    79 (65.3%)   68 (64.2%)    68 (64.2%)   84 (65.1%)    84 (65.1%)
#>   mean                         0.04          0.45         0.19          0.44         0.14          0.51   
#> BLACK OR AFRICAN AMERICAN   28 (23.1%)    28 (23.1%)   24 (22.6%)    24 (22.6%)   27 (20.9%)    27 (20.9%)
#>   mean                         -0.04         0.53         0.13          0.46         0.06          0.57   
#> WHITE                       14 (11.6%)    14 (11.6%)   14 (13.2%)    14 (13.2%)   18 (14.0%)    18 (14.0%)
#>   mean                         -0.19         0.61         0.33          0.48         -0.27         0.55   
```
