# Add a content row of summary counts

Add a content row of summary counts

## Usage

``` r
summarize_row_groups(
  lyt,
  var = "",
  label_fstr = "%s",
  format = "xx (xx.x%)",
  na_str = "-",
  cfun = NULL,
  indent_mod = 0L,
  extra_args = list()
)
```

## Arguments

- lyt:

  (`PreDataTableLayouts`)\
  layout object pre-data used for tabulation.

- var:

  (`string`)\
  variable name.

- label_fstr:

  (`string`)\
  a `sprintf` style format string. For non-comparison splits, it can
  contain up to one `"\%s"` which takes the current split value and
  generates the row/column label. For comparison-based splits it can
  contain up to two `"\%s"`.

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

- cfun:

  (`list`, `function`, or `NULL`)\
  tabulation function(s) for creating content rows. Must accept `x` or
  `df` as first parameter. Must accept `labelstr` as the second
  argument. Can optionally accept all optional arguments accepted by
  analysis functions. See
  [`analyze()`](https://pharmaverse.github.io/rtables/reference/analyze.md).

- indent_mod:

  (`numeric`)\
  modifier for the default indent position for the structure created by
  this function (subtable, content table, or row) *and all of that
  structure's children*. Defaults to 0, which corresponds to the
  unmodified default behavior.

- extra_args:

  (`list`)\
  extra arguments to be passed to the tabulation function. Element
  position in the list corresponds to the children of this split. Named
  elements in the child-specific lists are ignored if they do not match
  a formal argument of the tabulation function.

## Value

A `PreDataTableLayouts` object suitable for passing to further layouting
functions, and to
[`build_table()`](https://pharmaverse.github.io/rtables/reference/build_table.md).

## Details

If `format` expects 1 value (i.e. it is specified as a format string and
`xx` appears for two values (i.e. `xx` appears twice in the format
string) or is specified as a function, then both raw and percent of
column total counts are calculated. If `format` is a format string where
`xx` appears only one time, only raw counts are used.

`cfun` must accept `x` or `df` as its first argument. For the `df`
argument `cfun` will receive the subset `data.frame` corresponding with
the row- and column-splitting for the cell being calculated. Must accept
`labelstr` as the second parameter, which accepts the `label` of the
level of the parent split currently being summarized. Can additionally
take any optional argument supported by analysis functions. (see
[`analyze()`](https://pharmaverse.github.io/rtables/reference/analyze.md)).

In addition, if complex custom functions are needed, we suggest checking
the available
[additional_fun_params](https://pharmaverse.github.io/rtables/reference/additional_fun_params.md)
that can be used in `cfun`.

## Author

Gabriel Becker

## Examples

``` r
DM2 <- subset(DM, COUNTRY %in% c("USA", "CAN", "CHN"))

lyt <- basic_table() |>
  split_cols_by("ARM") |>
  split_rows_by("COUNTRY", split_fun = drop_split_levels) |>
  summarize_row_groups(label_fstr = "%s (n)") |>
  analyze("AGE", afun = list_wrap_x(summary), format = "xx.xx")
lyt
#> A Pre-data Table Layout
#> 
#> Column-Split Structure:
#> ARM (lvls) 
#> 
#> Row-Split Structure:
#> COUNTRY (lvls) -> AGE (** analysis **) 
#> 

tbl <- build_table(lyt, DM2)
tbl
#>             A: Drug X    B: Placebo   C: Combination
#> ————————————————————————————————————————————————————
#> CHN (n)     62 (79.5%)   48 (75.0%)     69 (78.4%)  
#>   Min.        22.00        25.00          24.00     
#>   1st Qu.     29.25        30.00          30.00     
#>   Median      34.00        33.50          33.00     
#>   Mean        36.08        34.12          33.71     
#>   3rd Qu.     41.00        38.00          37.00     
#>   Max.        60.00        55.00          51.00     
#> USA (n)     13 (16.7%)   14 (21.9%)     17 (19.3%)  
#>   Min.        23.00        24.00          22.00     
#>   1st Qu.     31.00        28.00          31.00     
#>   Median      36.00        30.00          37.00     
#>   Mean        36.77        32.57          36.41     
#>   3rd Qu.     41.00        37.50          41.00     
#>   Max.        58.00        47.00          51.00     
#> CAN (n)      3 (3.8%)     2 (3.1%)       2 (2.3%)   
#>   Min.        29.00        30.00          28.00     
#>   1st Qu.     32.50        32.00          28.75     
#>   Median      36.00        34.00          29.50     
#>   Mean        36.00        34.00          29.50     
#>   3rd Qu.     39.50        36.00          30.25     
#>   Max.        43.00        38.00          31.00     

row_paths_summary(tbl) # summary count is a content table
#> rowname      node_class    path                           
#> ——————————————————————————————————————————————————————————
#> CHN (n)      ContentRow    COUNTRY, CHN, @content, CHN (n)
#>   Min.       DataRow       COUNTRY, CHN, AGE, Min.        
#>   1st Qu.    DataRow       COUNTRY, CHN, AGE, 1st Qu.     
#>   Median     DataRow       COUNTRY, CHN, AGE, Median      
#>   Mean       DataRow       COUNTRY, CHN, AGE, Mean        
#>   3rd Qu.    DataRow       COUNTRY, CHN, AGE, 3rd Qu.     
#>   Max.       DataRow       COUNTRY, CHN, AGE, Max.        
#> USA (n)      ContentRow    COUNTRY, USA, @content, USA (n)
#>   Min.       DataRow       COUNTRY, USA, AGE, Min.        
#>   1st Qu.    DataRow       COUNTRY, USA, AGE, 1st Qu.     
#>   Median     DataRow       COUNTRY, USA, AGE, Median      
#>   Mean       DataRow       COUNTRY, USA, AGE, Mean        
#>   3rd Qu.    DataRow       COUNTRY, USA, AGE, 3rd Qu.     
#>   Max.       DataRow       COUNTRY, USA, AGE, Max.        
#> CAN (n)      ContentRow    COUNTRY, CAN, @content, CAN (n)
#>   Min.       DataRow       COUNTRY, CAN, AGE, Min.        
#>   1st Qu.    DataRow       COUNTRY, CAN, AGE, 1st Qu.     
#>   Median     DataRow       COUNTRY, CAN, AGE, Median      
#>   Mean       DataRow       COUNTRY, CAN, AGE, Mean        
#>   3rd Qu.    DataRow       COUNTRY, CAN, AGE, 3rd Qu.     
#>   Max.       DataRow       COUNTRY, CAN, AGE, Max.        

## use a cfun and extra_args to customize summarization
## behavior
sfun <- function(x, labelstr, trim) {
  in_rows(
    c(mean(x, trim = trim), trim),
    .formats = "xx.x (xx.x%)",
    .labels = sprintf(
      "%s (Trimmed mean and trim %%)",
      labelstr
    )
  )
}

lyt2 <- basic_table(show_colcounts = TRUE) |>
  split_cols_by("ARM") |>
  split_rows_by("COUNTRY", split_fun = drop_split_levels) |>
  summarize_row_groups("AGE",
    cfun = sfun,
    extra_args = list(trim = .2)
  ) |>
  analyze("AGE", afun = list_wrap_x(summary), format = "xx.xx") |>
  append_topleft(c("Country", "  Age"))

tbl2 <- build_table(lyt2, DM2)
tbl2
#> Country                          A: Drug X      B: Placebo    C: Combination
#>   Age                              (N=78)         (N=64)          (N=88)    
#> ————————————————————————————————————————————————————————————————————————————
#> CHN (Trimmed mean and trim %)   35.1 (20.0%)   33.4 (20.0%)    33.4 (20.0%) 
#>   Min.                             22.00          25.00           24.00     
#>   1st Qu.                          29.25          30.00           30.00     
#>   Median                           34.00          33.50           33.00     
#>   Mean                             36.08          34.12           33.71     
#>   3rd Qu.                          41.00          38.00           37.00     
#>   Max.                             60.00          55.00           51.00     
#> USA (Trimmed mean and trim %)   36.1 (20.0%)   31.9 (20.0%)    36.1 (20.0%) 
#>   Min.                             23.00          24.00           22.00     
#>   1st Qu.                          31.00          28.00           31.00     
#>   Median                           36.00          30.00           37.00     
#>   Mean                             36.77          32.57           36.41     
#>   3rd Qu.                          41.00          37.50           41.00     
#>   Max.                             58.00          47.00           51.00     
#> CAN (Trimmed mean and trim %)   36.0 (20.0%)   34.0 (20.0%)    29.5 (20.0%) 
#>   Min.                             29.00          30.00           28.00     
#>   1st Qu.                          32.50          32.00           28.75     
#>   Median                           36.00          34.00           29.50     
#>   Mean                             36.00          34.00           29.50     
#>   3rd Qu.                          39.50          36.00           30.25     
#>   Max.                             43.00          38.00           31.00     
```
