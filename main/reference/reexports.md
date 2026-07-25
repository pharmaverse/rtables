# Objects exported from other packages

These objects are imported from other packages. Follow the links below
to see their documentation.

- formatters:

  [`export_as_pdf()`](https://rdrr.io/pkg/formatters/man/export_as_pdf.html),
  [`export_as_txt()`](https://rdrr.io/pkg/formatters/man/export_as_txt.html)

## Examples

``` r
lyt <- basic_table() |>
  split_cols_by("ARM") |>
  analyze(c("AGE", "BMRKR2", "COUNTRY"))

tbl <- build_table(lyt, ex_adsl)

cat(export_as_txt(tbl, file = NULL, paginate = TRUE, lpp = 8))
#>            A: Drug X   B: Placebo   C: Combination
#> ——————————————————————————————————————————————————
#> AGE                                               
#>   Mean       33.77       35.43          35.43     
#> BMRKR2                                            
#>   LOW         50           45             40      
#>   MEDIUM      37           56             42      
#>   HIGH        47           33             50      
#> \s\n           A: Drug X   B: Placebo   C: Combination
#> ——————————————————————————————————————————————————
#> COUNTRY                                           
#>   CHN         74           81             64      
#>   USA         10           13             17      
#>   BRA         13           7              10      
#>   PAK         12           9              10      
#>   NGA          8           7              11      
#> \s\n           A: Drug X   B: Placebo   C: Combination
#> ——————————————————————————————————————————————————
#> COUNTRY                                           
#>   RUS          5           8              6       
#>   JPN          5           4              9       
#>   GBR          4           3              2       
#>   CAN          3           2              3       
#>   CHE          0           0              0       

if (FALSE) { # \dontrun{
tf <- tempfile(fileext = ".txt")
export_as_txt(tbl, file = tf)
system2("cat", tf)
} # }

lyt <- basic_table() |>
  split_cols_by("ARM") |>
  analyze(c("AGE", "BMRKR2", "COUNTRY"))

tbl <- build_table(lyt, ex_adsl)

if (FALSE) { # \dontrun{
tf <- tempfile(fileext = ".pdf")
export_as_pdf(tbl, file = tf, pg_height = 4)
tf <- tempfile(fileext = ".pdf")
export_as_pdf(tbl, file = tf, lpp = 8)
} # }
```
