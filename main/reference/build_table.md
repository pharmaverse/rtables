# Create a table from a layout and data

Layouts are used to describe a table pre-data. `build_table` is used to
create a table using a layout and a dataset.

## Usage

``` r
build_table(
  lyt,
  df,
  alt_counts_df = NULL,
  col_counts = NULL,
  col_total = if (is.null(alt_counts_df)) nrow(df) else nrow(alt_counts_df),
  topleft = NULL,
  hsep = default_hsep(),
  round_type = if (is(lyt, "PreDataTableLayouts")) obj_round_type(lyt) else
    valid_round_type,
  ...
)
```

## Arguments

- lyt:

  (`PreDataTableLayouts`)\
  layout object pre-data used for tabulation.

- df:

  (`data.frame` or `tibble`)\
  dataset.

- alt_counts_df:

  (`data.frame` or `tibble`)\
  alternative full dataset the rtables framework will use *only* when
  calculating column counts.

- col_counts:

  (`numeric` or `NULL`)\
  **\[deprecated\]** if non-`NULL`, column counts *for leaf-columns
  only* which override those calculated automatically during tabulation.
  Must specify "counts" for *all* leaf-columns if non-`NULL`. `NA`
  elements will be replaced with the automatically calculated counts.
  Turns on display of leaf-column counts when non-`NULL`.

- col_total:

  (`integer(1)`)\
  the total observations across all columns. Defaults to `nrow(df)`.

- topleft:

  (`character`)\
  override values for the "top left" material to be displayed during
  printing.

- hsep:

  (`string`)\
  set of characters to be repeated as the separator between the header
  and body of the table when rendered as text. Defaults to a connected
  horizontal line (unicode 2014) in locals that use a UTF charset, and
  to `-` elsewhere (with a once per session warning). See
  [`formatters::set_default_hsep()`](https://rdrr.io/pkg/formatters/man/default_horizontal_sep.html)
  for further information.

- round_type:

  (`"iec"` (default), `"iec_mod"` or `"sas"`)\
  the type of rounding to perform. See
  [`formatters::format_value()`](https://rdrr.io/pkg/formatters/man/format_value.html)
  for details.

- ...:

  ignored.

## Value

A `TableTree` or `ElementaryTable` object representing the table created
by performing the tabulations declared in `lyt` to the data `df`.

## Details

When `alt_counts_df` is specified, column counts are calculated by
applying the exact column subsetting expressions determined when
applying column splitting to the main data (`df`) to `alt_counts_df` and
counting the observations in each resulting subset.

In particular, this means that in the case of splitting based on cuts of
the data, any dynamic cuts will have been calculated based on `df` and
simply re-used for the count calculation.

## Note

When overriding the column counts or totals care must be taken that,
e.g., [`length()`](https://rdrr.io/r/base/length.html) or
[`nrow()`](https://rdrr.io/r/base/nrow.html) are not called within
tabulation functions, because those will NOT give the overridden counts.
Writing/using tabulation functions which accept `.N_col` and `.N_total`
or do not rely on column counts at all (even implicitly) is the only way
to ensure overridden counts are fully respected.

## Author

Gabriel Becker

## Examples

``` r
lyt <- basic_table() |>
  split_cols_by("Species") |>
  analyze("Sepal.Length", afun = function(x) {
    list(
      "mean (sd)" = rcell(c(mean(x), sd(x)), format = "xx.xx (xx.xx)"),
      "range" = diff(range(x))
    )
  })
lyt
#> A Pre-data Table Layout
#> 
#> Column-Split Structure:
#> Species (lvls) 
#> 
#> Row-Split Structure:
#> Sepal.Length (** analysis **) 
#> 

tbl <- build_table(lyt, iris)
tbl
#>               setosa      versicolor     virginica 
#> ———————————————————————————————————————————————————
#> mean (sd)   5.01 (0.35)   5.94 (0.52)   6.59 (0.64)
#> range           1.5           2.1            3     

# analyze multiple variables
lyt2 <- basic_table() |>
  split_cols_by("Species") |>
  analyze(c("Sepal.Length", "Petal.Width"), afun = function(x) {
    list(
      "mean (sd)" = rcell(c(mean(x), sd(x)), format = "xx.xx (xx.xx)"),
      "range" = diff(range(x))
    )
  })

tbl2 <- build_table(lyt2, iris)
tbl2
#>                  setosa      versicolor     virginica 
#> ——————————————————————————————————————————————————————
#> Sepal.Length                                          
#>   mean (sd)    5.01 (0.35)   5.94 (0.52)   6.59 (0.64)
#>   range            1.5           2.1            3     
#> Petal.Width                                           
#>   mean (sd)    0.25 (0.11)   1.33 (0.20)   2.03 (0.27)
#>   range            0.5           0.8           1.1    

# an example more relevant for clinical trials with column counts
lyt3 <- basic_table(show_colcounts = TRUE) |>
  split_cols_by("ARM") |>
  analyze("AGE", afun = function(x) {
    setNames(as.list(fivenum(x)), c(
      "minimum", "lower-hinge", "median",
      "upper-hinge", "maximum"
    ))
  })

tbl3 <- build_table(lyt3, DM)
tbl3
#>               A: Drug X   B: Placebo   C: Combination
#>                (N=121)     (N=106)        (N=129)    
#> —————————————————————————————————————————————————————
#> minimum          20           21             22      
#> lower-hinge      29           29             30      
#> median           33           32             33      
#> upper-hinge      39           37             38      
#> maximum          60           55             53      

tbl4 <- build_table(lyt3, subset(DM, AGE > 40))
tbl4
#>               A: Drug X   B: Placebo   C: Combination
#>                (N=25)       (N=10)         (N=21)    
#> —————————————————————————————————————————————————————
#> minimum          41           41             41      
#> lower-hinge      43           42             43      
#> median           45          45.5            45      
#> upper-hinge      49           48             47      
#> maximum          60           55             53      

# with column counts calculated based on different data
miniDM <- DM[sample(1:NROW(DM), 100), ]
tbl5 <- build_table(lyt3, DM, alt_counts_df = miniDM)
tbl5
#>               A: Drug X   B: Placebo   C: Combination
#>                (N=37)       (N=30)         (N=33)    
#> —————————————————————————————————————————————————————
#> minimum          20           21             22      
#> lower-hinge      29           29             30      
#> median           33           32             33      
#> upper-hinge      39           37             38      
#> maximum          60           55             53      

tbl6 <- build_table(lyt3, DM, col_counts = 1:3)
tbl6
#>               A: Drug X   B: Placebo   C: Combination
#>                 (N=1)       (N=2)          (N=3)     
#> —————————————————————————————————————————————————————
#> minimum          20           21             22      
#> lower-hinge      29           29             30      
#> median           33           32             33      
#> upper-hinge      39           37             38      
#> maximum          60           55             53      
```
