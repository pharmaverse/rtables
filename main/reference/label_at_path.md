# Label at path

Accesses or sets the label at a path.

## Usage

``` r
label_at_path(tt, path)

label_at_path(tt, path) <- value
```

## Arguments

- tt:

  (`TableTree` or related class)\
  a `TableTree` object representing a populated table.

- path:

  (`character`)\
  a vector path for a position within the structure of a `TableTree`.
  Each element represents a subsequent choice amongst the children of
  the previous choice.

- value:

  (`ANY`)\
  the new value.

## Details

If `path` resolves to a single row, the label for that row is retrieved
or set. If, instead, `path` resolves to a subtable, the text for the
row-label associated with that path is retrieved or set. In the subtable
case, if the label text is set to a non-`NA` value, the `labelrow` will
be set to visible, even if it was not before. Similarly, if the label
row text for a subtable is set to `NA`, the label row will bet set to
non-visible, so the row will not appear at all when the table is
printed.

## Note

When changing the row labels for content rows, it is important to path
all the way to the *row*. Paths ending in `"@content"` will not exhibit
the behavior you want, and are thus an error. See
[`row_paths()`](https://pharmaverse.github.io/rtables/reference/make_col_row_df.md)
for help determining the full paths to content rows.

## Examples

``` r
lyt <- basic_table() |>
  split_rows_by("COUNTRY", split_fun = keep_split_levels(c("CHN", "USA"))) |>
  analyze("AGE")

tbl <- build_table(lyt, DM)

label_at_path(tbl, c("COUNTRY", "CHN"))
#> [1] "CHN"

label_at_path(tbl, c("COUNTRY", "USA")) <- "United States"
tbl
#>                 all obs
#> ———————————————————————
#> CHN                    
#>   Mean           34.64 
#> United States          
#>   Mean           35.30 
```
