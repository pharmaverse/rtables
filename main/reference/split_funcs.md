# Split functions

This is a collection of useful, default split function that can help you
in dividing the data, hence the table rows or columns, into different
parts or groups (splits). You can also create your own split function if
you need to create a custom division as specific as you need. Please
consider reading
[custom_split_funs](https://pharmaverse.github.io/rtables/reference/custom_split_funs.md)
if this is the case. Beyond this list of functions, you can also use
[`add_overall_level()`](https://pharmaverse.github.io/rtables/reference/add_overall_level.md)
and
[`add_combo_levels()`](https://pharmaverse.github.io/rtables/reference/add_overall_level.md)
for adding or modifying levels and
[`trim_levels_to_map()`](https://pharmaverse.github.io/rtables/reference/trim_levels_to_map.md)
to provide possible level combinations to filter the split with.

## Usage

``` r
keep_split_levels(only, reorder = TRUE)

remove_split_levels(excl)

drop_split_levels(df, spl, vals = NULL, labels = NULL, trim = FALSE)

drop_and_remove_levels(excl)

reorder_split_levels(neworder, newlabels = neworder, drlevels = TRUE)

trim_levels_in_group(innervar, drop_outlevs = TRUE)
```

## Arguments

- only:

  (`character`)\
  levels to retain (all others will be dropped). If none of the levels
  is present an empty table is returned.

- reorder:

  (`flag`)\
  whether the order of `only` should be used as the order of the
  children of the split. Defaults to `TRUE`.

- excl:

  (`character`)\
  levels to be excluded (they will not be reflected in the resulting
  table structure regardless of presence in the data).

- df:

  (`data.frame` or `tibble`)\
  dataset.

- spl:

  (`Split`)\
  a `Split` object defining a partitioning or analysis/tabulation of the
  data.

- vals:

  (`ANY`)\
  for internal use only.

- labels:

  (`character`)\
  labels to use for the remaining levels instead of the existing ones.

- trim:

  (`flag`)\
  whether splits corresponding with 0 observations should be kept when
  tabulating.

- neworder:

  (`character`)\
  new order of factor levels. All need to be present in the data. To add
  empty levels, rely on pre-processing or create your
  [custom_split_funs](https://pharmaverse.github.io/rtables/reference/custom_split_funs.md).

- newlabels:

  (`character`)\
  labels for (new order of) factor levels. If named, the levels are
  matched. Otherwise, the order of `neworder` is used.

- drlevels:

  (`flag`)\
  whether levels that are not in `neworder` should be dropped. Default
  is `TRUE`. Note: `drlevels = TRUE` does not drop levels that are not
  originally in the data. Rely on pre-processing or use a combination of
  split functions with
  [`make_split_fun()`](https://pharmaverse.github.io/rtables/reference/make_split_fun.md)
  to also drop unused levels.

- innervar:

  (`string`)\
  variable whose factor levels should be trimmed (e.g. empty levels
  dropped) *separately within each grouping defined at this point in the
  structure*.

- drop_outlevs:

  (`flag`)\
  whether empty levels in the variable being split on (i.e. the "outer"
  variable, not `innervar`) should be dropped. Defaults to `TRUE`.

## Value

A function that can be used to split the data accordingly. The actual
function signature is similar to the one you can define when creating a
fully custom one. For more details see
[custom_split_funs](https://pharmaverse.github.io/rtables/reference/custom_split_funs.md).

## Functions

- `keep_split_levels()`: keeps only specified levels (`only`) in the
  split variable. If any of the specified levels is not present, an
  error is returned. `reorder = TRUE` (the default) orders the split
  levels according to the order of `only`.

- `remove_split_levels()`: Removes specified levels (`excl`) from the
  split variable. Nothing done if not in data.

- `drop_split_levels()`: Drops levels that have no representation in the
  data.

- `drop_and_remove_levels()`: Removes specified levels `excl` and drops
  all levels that are not in the data.

- `reorder_split_levels()`: Reorders split levels following `neworder`,
  which needs to be of same size as the levels in data.

- `trim_levels_in_group()`: Takes the split groups and removes levels of
  `innervar` if not present in those split groups. If you want to
  specify a filter of possible combinations, please consider using
  [`trim_levels_to_map()`](https://pharmaverse.github.io/rtables/reference/trim_levels_to_map.md).

## Note

The following parameters are also documented here but they are only the
default signature of a split function: `df` (data to be split), `spl`
(split object), and `vals = NULL`, `labels = NULL`, `trim = FALSE` (last
three only for internal use). See
[custom_split_funs](https://pharmaverse.github.io/rtables/reference/custom_split_funs.md)
for more details and
[`make_split_fun()`](https://pharmaverse.github.io/rtables/reference/make_split_fun.md)
for a more advanced API.

## See also

[custom_split_funs](https://pharmaverse.github.io/rtables/reference/custom_split_funs.md),
[`add_overall_level()`](https://pharmaverse.github.io/rtables/reference/add_overall_level.md),
[`add_combo_levels()`](https://pharmaverse.github.io/rtables/reference/add_overall_level.md),
and
[`trim_levels_to_map()`](https://pharmaverse.github.io/rtables/reference/trim_levels_to_map.md).

## Examples

``` r
# keep_split_levels keeps specified levels (reorder = TRUE by default)
lyt <- basic_table() |>
  split_rows_by("COUNTRY",
    split_fun = keep_split_levels(c("USA", "CAN", "BRA"))
  ) |>
  analyze("AGE")

tbl <- build_table(lyt, DM)
tbl
#>          all obs
#> ————————————————
#> USA             
#>   Mean    35.30 
#> CAN             
#>   Mean    33.57 
#> BRA             
#>   Mean    32.31 

# remove_split_levels removes specified split levels
lyt <- basic_table() |>
  split_rows_by("COUNTRY",
    split_fun = remove_split_levels(c(
      "USA", "CAN",
      "CHE", "BRA"
    ))
  ) |>
  analyze("AGE")

tbl <- build_table(lyt, DM)
tbl
#>          all obs
#> ————————————————
#> CHN             
#>   Mean    34.64 
#> PAK             
#>   Mean    35.32 
#> NGA             
#>   Mean    32.96 
#> RUS             
#>   Mean    33.45 
#> JPN             
#>   Mean    33.17 
#> GBR             
#>   Mean    30.14 

# drop_split_levels drops levels that are not present in the data
lyt <- basic_table() |>
  split_rows_by("SEX", split_fun = drop_split_levels) |>
  analyze("AGE")

tbl <- build_table(lyt, DM)
tbl
#>          all obs
#> ————————————————
#> F               
#>   Mean    34.13 
#> M               
#>   Mean    34.32 

# Removing "M" and "U" directly, then "UNDIFFERENTIATED" because not in data
lyt <- basic_table() |>
  split_rows_by("SEX", split_fun = drop_and_remove_levels(c("M", "U"))) |>
  analyze("AGE")

tbl <- build_table(lyt, DM)
tbl
#>          all obs
#> ————————————————
#> F               
#>   Mean    34.13 

# Reordering levels in split variable
lyt <- basic_table() |>
  split_rows_by(
    "SEX",
    split_fun = reorder_split_levels(
      neworder = c("U", "F"),
      newlabels = c(U = "Uu", `F` = "Female")
    )
  ) |>
  analyze("AGE")

tbl <- build_table(lyt, DM)
tbl
#>          all obs
#> ————————————————
#> Uu              
#>   Mean     NA   
#> Female          
#>   Mean    34.13 

# Reordering levels in split variable but keeping all the levels
lyt <- basic_table() |>
  split_rows_by(
    "SEX",
    split_fun = reorder_split_levels(
      neworder = c("U", "F"),
      newlabels = c("Uu", "Female"),
      drlevels = FALSE
    )
  ) |>
  analyze("AGE")

tbl <- build_table(lyt, DM)
tbl
#>                    all obs
#> ——————————————————————————
#> Uu                        
#>   Mean               NA   
#> Female                    
#>   Mean              34.13 
#> M                         
#>   Mean              34.32 
#> UNDIFFERENTIATED          
#>   Mean               NA   

# trim_levels_in_group() trims levels within each group defined by the split variable
dat <- data.frame(
  col1 = factor(c("A", "B", "C"), levels = c("A", "B", "C", "N")),
  col2 = factor(c("a", "b", "c"), levels = c("a", "b", "c", "x"))
) # N is removed if drop_outlevs = TRUE, x is removed always

tbl <- basic_table() |>
  split_rows_by("col1", split_fun = trim_levels_in_group("col2")) |>
  analyze("col2") |>
  build_table(dat)
tbl
#>       all obs
#> —————————————
#> A            
#>   a      1   
#> B            
#>   b      1   
#> C            
#>   c      1   
```
