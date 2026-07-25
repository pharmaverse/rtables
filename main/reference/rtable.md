# Create a table

Create a table

## Usage

``` r
rtable(
  header,
  ...,
  format = NULL,
  hsep = default_hsep(),
  inset = 0L,
  round_type = valid_round_type
)

rtablel(header, ..., format = NULL, hsep = default_hsep(), inset = 0L)
```

## Arguments

- header:

  (`TableRow`, `character`, or `InstantiatedColumnInfo`)\
  information defining the header (column structure) of the table. This
  can be as row objects (legacy), character vectors, or an
  `InstantiatedColumnInfo` object.

- ...:

  rows to place in the table.

- format:

  (`string`, `function`, or `list`)\
  the format label (string) or formatter function to apply to the cell
  values passed via `...`. See
  [`formatters::list_valid_format_labels()`](https://rdrr.io/pkg/formatters/man/list_formats.html)
  for currently supported format labels.

- hsep:

  (`string`)\
  set of characters to be repeated as the separator between the header
  and body of the table when rendered as text. Defaults to a connected
  horizontal line (unicode 2014) in locals that use a UTF charset, and
  to `-` elsewhere (with a once per session warning). See
  [`formatters::set_default_hsep()`](https://rdrr.io/pkg/formatters/man/default_horizontal_sep.html)
  for further information.

- inset:

  (`integer(1)`)\
  the table inset for the row or table being constructed. See
  [`formatters::table_inset()`](https://rdrr.io/pkg/formatters/man/table_inset.html)
  for details.

- round_type:

  (`"iec"`, `"iec_mod"` or `"sas"`)\
  the type of rounding to perform. See
  [`round_fmt()`](https://rdrr.io/pkg/formatters/man/round_fmt.html) for
  details.

## Value

A formal table object of the appropriate type (`ElementaryTable` or
`TableTree`).

## See also

Other compatibility:
[`rheader()`](https://pharmaverse.github.io/rtables/reference/rheader.md),
[`rrow()`](https://pharmaverse.github.io/rtables/reference/rrow.md),
[`rrowl()`](https://pharmaverse.github.io/rtables/reference/rrowl.md)

## Examples

``` r
rtable(
  header = LETTERS[1:3],
  rrow("one to three", 1, 2, 3),
  rrow("more stuff", rcell(pi, format = "xx.xx"), "test", "and more")
)
#>                 A      B        C    
#> —————————————————————————————————————
#> one to three    1      2        3    
#> more stuff     3.14   test   and more

# Table with multirow header

sel <- iris$Species == "setosa"
mtbl <- rtable(
  header = rheader(
    rrow(
      row.name = NULL, rcell("Sepal.Length", colspan = 2),
      rcell("Petal.Length", colspan = 2)
    ),
    rrow(NULL, "mean", "median", "mean", "median")
  ),
  rrow(
    row.name = "All Species",
    mean(iris$Sepal.Length), median(iris$Sepal.Length),
    mean(iris$Petal.Length), median(iris$Petal.Length),
    format = "xx.xx"
  ),
  rrow(
    row.name = "Setosa",
    mean(iris$Sepal.Length[sel]), median(iris$Sepal.Length[sel]),
    mean(iris$Petal.Length[sel]), median(iris$Petal.Length[sel])
  )
)

mtbl
#>                Sepal.Length      Petal.Length  
#>                mean    median    mean    median
#> ———————————————————————————————————————————————
#> All Species    5.84     5.80     3.76     4.35 
#> Setosa        5.006      5      1.462     1.5  

names(mtbl) # always first row of header
#> [1] "Sepal.Length" "Sepal.Length" "Petal.Length" "Petal.Length"

# Single row header

tbl <- rtable(
  header = c("Treatement\nN=100", "Comparison\nN=300"),
  format = "xx (xx.xx%)",
  rrow("A", c(104, .2), c(100, .4)),
  rrow("B", c(23, .4), c(43, .5)),
  rrow(""),
  rrow("this is a very long section header"),
  rrow("estimate", rcell(55.23, "xx.xx", colspan = 2)),
  rrow("95% CI", indent = 1, rcell(c(44.8, 67.4), format = "(xx.x, xx.x)", colspan = 2))
)
tbl
#>                                       Treatement     Comparison 
#>                                         N=100          N=300    
#> ————————————————————————————————————————————————————————————————
#> A                                    104 (20.00%)   100 (40.00%)
#> B                                    23 (40.00%)    43 (50.00%) 
#>                                                                 
#> this is a very long section header                              
#> estimate                                        55.23           
#> 95% CI                                      (44.8, 67.4)        

row.names(tbl)
#> [1] "A"                                  "B"                                 
#> [3] ""                                   "this is a very long section header"
#> [5] "estimate"                           "95% CI"                            
names(tbl)
#> [1] "Treatement" "Comparison"

# Subsetting

tbl[1, ]
#>      Treatement     Comparison 
#>        N=100          N=300    
#> ———————————————————————————————
#> A   104 (20.00%)   100 (40.00%)
tbl[, 1]
#>                                       Treatement 
#>                                         N=100    
#> —————————————————————————————————————————————————
#> A                                    104 (20.00%)
#> B                                    23 (40.00%) 
#>                                                  
#> this is a very long section header               
#> estimate                                55.23    
#> 95% CI                               (44.8, 67.4)

tbl[1, 2]
#>      Comparison 
#>        N=300    
#> ————————————————
#> A   100 (40.00%)
tbl[2, 1]
#>     Treatement 
#>        N=100   
#> ———————————————
#> B   23 (40.00%)

tbl[3, 2]
#>    Comparison
#>      N=300   
#> —————————————
#>              
tbl[5, 1]
#>            Treatement
#>              N=100   
#> —————————————————————
#> estimate     55.23   
tbl[5, 2]
#>            Comparison
#>              N=300   
#> —————————————————————
#> estimate     55.23   

# Data Structure methods

dim(tbl)
#> [1] 6 2
nrow(tbl)
#> [1] 6
ncol(tbl)
#> [1] 2
names(tbl)
#> [1] "Treatement" "Comparison"

# Colspans

tbl2 <- rtable(
  c("A", "B", "C", "D", "E"),
  format = "xx",
  rrow("r1", 1, 2, 3, 4, 5),
  rrow("r2", rcell("sp2", colspan = 2), "sp1", rcell("sp2-2", colspan = 2))
)
tbl2
#>      A    B    C     D    E 
#> ————————————————————————————
#> r1   1    2    3     4    5 
#> r2    sp2     sp1    sp2-2  
```
