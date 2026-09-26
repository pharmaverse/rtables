# Referential Footnote

Referential Footnote

## Usage

``` r
RefFootnote(note, index = NA_integer_, symbol = NA_character_)
```

## Arguments

- note:

  (`character(1)`)\
  The text of the footnote, not including the symbol or index.

- index:

  (`integer(1)`)\
  The index (position in the list of footnotes); this should not
  typically be set by users. `NA` (the default) indicates automatic
  counting.

- symbol:

  (`character(1)`)\
  The symbol to be used instead of the index value to indicate the
  footnote's anchor and message. `NA` (the default) will use the
  footnote's index (after automatic counting, if applicable) as its
  symbol.

## Value

a `RefFootnote` object suitable for use in `in_rows` and
`fnotes_at_path<-` and `rcell`, or `NULL` if `note` is of length zero.

## Details

When `symbol` is non-missing, all footnotes with the same symbol will
share a single footer entry containing `note`, rather than it being
entered repeatedly. `symbol` cannot be `"NA"` or contain `"{"` or `"}"`.

## Examples

``` r

afun1 <- function(x, ...) {
  in_rows(
    row1 = 5,
    row2 = c(1, 2),
    .row_footnotes = list(row1 = list(RefFootnote("row 1 rfn"))),
    .cell_footnotes = list(row2 = list(RefFootnote("row 2 cfn")))
  )
}

afun2 <- function(x, ...) {
  in_rows(
    row1 = 5,
    row2 = c(1, 2),
    .row_footnotes = list(row1 = list(RefFootnote("row 1 rfn", symbol = "+"))),
    .cell_footnotes = list(row2 = list(RefFootnote("row 2 cfn", symbol = "^")))
  )
}

lyt1 <- basic_table() |>
  split_cols_by("ARM") |>
  analyze("AGE", afun = afun1)

build_table(lyt1, DM)
#>            A: Drug X   B: Placebo   C: Combination
#> ——————————————————————————————————————————————————
#> row1 {1}       5           5              5       
#> row2       1, 2 {2}     1, 2 {2}       1, 2 {2}   
#> ——————————————————————————————————————————————————
#> 
#> {1} - row 1 rfn
#> {2} - row 2 cfn
#> ——————————————————————————————————————————————————
#> 

lyt2 <- basic_table() |>
  split_cols_by("ARM") |>
  split_rows_by("STRATA1") |>
  analyze("AGE", afun = afun2)

build_table(lyt2, DM)
#>              A: Drug X   B: Placebo   C: Combination
#> ————————————————————————————————————————————————————
#> A                                                   
#>   row1 {+}       5           5              5       
#>   row2       1, 2 {^}     1, 2 {^}       1, 2 {^}   
#> B                                                   
#>   row1 {+}       5           5              5       
#>   row2       1, 2 {^}     1, 2 {^}       1, 2 {^}   
#> C                                                   
#>   row1 {+}       5           5              5       
#>   row2       1, 2 {^}     1, 2 {^}       1, 2 {^}   
#> ————————————————————————————————————————————————————
#> 
#> {+} - row 1 rfn
#> {^} - row 2 cfn
#> ————————————————————————————————————————————————————
#> 
```
