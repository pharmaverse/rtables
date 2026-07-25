# Retrieve and assign elements of a `TableTree`

Retrieve and assign elements of a `TableTree`

## Usage

``` r
# S4 method for class 'VTableTree,ANY,ANY,list'
x[i, j, ...] <- value

# S4 method for class 'VTableTree,logical,logical'
x[i, j, ..., drop = FALSE]
```

## Arguments

- x:

  (`TableTree`)\
  a `TableTree` object.

- i:

  (`numeric(1)`)\
  index.

- j:

  (`numeric(1)`)\
  index.

- ...:

  additional arguments. Includes:

  `keep_topleft`

  :   (`flag`) (`[` only) whether the top-left material for the table
      should be retained after subsetting. Defaults to `TRUE` if all
      rows are included (i.e. subsetting was by column), and drops it
      otherwise.

  `keep_titles`

  :   (`flag`) whether title information should be retained. Defaults to
      `FALSE`.

  `keep_footers`

  :   (`flag`) whether non-referential footer information should be
      retained. Defaults to `keep_titles`.

  `reindex_refs`

  :   (`flag`) whether referential footnotes should be re-indexed as if
      the resulting subset is the entire table. Defaults to `TRUE`.

- value:

  (`list`, `TableRow`, or `TableTree`)\
  replacement value.

- drop:

  (`flag`)\
  whether the value in the cell should be returned if one cell is
  selected by the combination of `i` and `j`. It is not possible to
  return a vector of values. To do so please consider using
  [`cell_values()`](https://pharmaverse.github.io/rtables/reference/cell_values.md).
  Defaults to `FALSE`.

## Value

A `TableTree` (or `ElementaryTable`) object, unless a single cell was
selected with `drop = TRUE`, in which case the (possibly multi-valued)
fully stripped raw value of the selected cell.

## Details

By default, subsetting drops the information about title, subtitle, main
footer, provenance footer, and `topleft`. If only a column is selected
and all rows are kept, the `topleft` information remains as default. Any
referential footnote is kept whenever the subset table contains the
referenced element.

## Note

Subsetting always preserve the original order, even if provided indexes
do not preserve it. If sorting is needed, please consider using
[`sort_at_path()`](https://pharmaverse.github.io/rtables/reference/sort_at_path.md).
Also note that `character` indices are treated as paths, not vectors of
names in both `[` and `[<-`.

## See also

- [`sort_at_path()`](https://pharmaverse.github.io/rtables/reference/sort_at_path.md)
  to understand sorting.

- [`summarize_row_groups()`](https://pharmaverse.github.io/rtables/reference/summarize_row_groups.md)
  to understand path structure.

## Examples

``` r
lyt <- basic_table(
  title = "Title",
  subtitles = c("Sub", "titles"),
  prov_footer = "prov footer",
  main_footer = "main footer"
) |>
  split_cols_by("ARM") |>
  split_rows_by("SEX") |>
  analyze(c("AGE"))

tbl <- build_table(lyt, DM)
top_left(tbl) <- "Info"
tbl
#> Title
#> Sub
#> titles
#> 
#> ——————————————————————————————————————————————————————————
#> Info               A: Drug X   B: Placebo   C: Combination
#> ——————————————————————————————————————————————————————————
#> F                                                         
#>   Mean               33.71       33.84          34.89     
#> M                                                         
#>   Mean               36.55       32.10          34.28     
#> U                                                         
#>   Mean                NA           NA             NA      
#> UNDIFFERENTIATED                                          
#>   Mean                NA           NA             NA      
#> ——————————————————————————————————————————————————————————
#> 
#> main footer
#> 
#> prov footer

# As default header, footer, and topleft information is lost
tbl[1, ]
#>     A: Drug X   B: Placebo   C: Combination
#> ———————————————————————————————————————————
#> F                                          
tbl[1:2, 2]
#>          B: Placebo
#> ———————————————————
#> F                  
#>   Mean     33.84   

# Also boolean filters can work
tbl[, c(FALSE, TRUE, FALSE)]
#> Note: method with signature ‘VTableTree#missing#ANY’ chosen for function ‘[’,
#>  target signature ‘TableTree#missing#logical’.
#>  "VTableTree#ANY#logical" would also be valid
#> Info               B: Placebo
#> —————————————————————————————
#> F                            
#>   Mean               33.84   
#> M                            
#>   Mean               32.10   
#> U                            
#>   Mean                 NA    
#> UNDIFFERENTIATED             
#>   Mean                 NA    

# If drop = TRUE, the content values are directly retrieved
tbl[2, 1]
#>        A: Drug X
#> ————————————————
#> Mean     33.71  
tbl[2, 1, drop = TRUE]
#> [1] 33.71429

# Drop works also if vectors are selected, but not matrices
tbl[, 1, drop = TRUE]
#> Warning: Trying to drop more than one subsetted value. We support this only with accessor function `cell_values()`. No drop will be done at this time.
#> Info               A: Drug X
#> ————————————————————————————
#> F                           
#>   Mean               33.71  
#> M                           
#>   Mean               36.55  
#> U                           
#>   Mean                NA    
#> UNDIFFERENTIATED            
#>   Mean                NA    
tbl[2, , drop = TRUE]
#> Warning: Trying to drop more than one subsetted value. We support this only with accessor function `cell_values()`. No drop will be done at this time.
#>        A: Drug X   B: Placebo   C: Combination
#> ——————————————————————————————————————————————
#> Mean     33.71       33.84          34.89     
tbl[1, 1, drop = TRUE] # NULL because it is a label row
#> Warning: The value selected with drop = TRUE belongs to a label row. NULL will be returned
#> NULL
tbl[2, 1:2, drop = TRUE] # vectors can be returned only with cell_values()
#> Warning: Trying to drop more than one subsetted value. We support this only with accessor function `cell_values()`. No drop will be done at this time.
#>        A: Drug X   B: Placebo
#> —————————————————————————————
#> Mean     33.71       33.84   
tbl[1:2, 1:2, drop = TRUE] # no dropping because it is a matrix
#> Warning: Trying to drop more than one subsetted value. We support this only with accessor function `cell_values()`. No drop will be done at this time.
#>          A: Drug X   B: Placebo
#> ———————————————————————————————
#> F                              
#>   Mean     33.71       33.84   

# If all rows are selected, topleft is kept by default
tbl[, 2]
#> Info               B: Placebo
#> —————————————————————————————
#> F                            
#>   Mean               33.84   
#> M                            
#>   Mean               32.10   
#> U                            
#>   Mean                 NA    
#> UNDIFFERENTIATED             
#>   Mean                 NA    
tbl[, 1]
#> Info               A: Drug X
#> ————————————————————————————
#> F                           
#>   Mean               33.71  
#> M                           
#>   Mean               36.55  
#> U                           
#>   Mean                NA    
#> UNDIFFERENTIATED            
#>   Mean                NA    

# It is possible to deselect values
tbl[-2, ]
#>                    A: Drug X   B: Placebo   C: Combination
#> ——————————————————————————————————————————————————————————
#> F                                                         
#> M                                                         
#>   Mean               36.55       32.10          34.28     
#> U                                                         
#>   Mean                NA           NA             NA      
#> UNDIFFERENTIATED                                          
#>   Mean                NA           NA             NA      
tbl[, -1]
#> Info               B: Placebo   C: Combination
#> ——————————————————————————————————————————————
#> F                                             
#>   Mean               33.84          34.89     
#> M                                             
#>   Mean               32.10          34.28     
#> U                                             
#>   Mean                 NA             NA      
#> UNDIFFERENTIATED                              
#>   Mean                 NA             NA      

# Values can be reassigned
tbl[4, 2] <- rcell(999, format = "xx.x")
tbl[2, ] <- list(rrow("FFF", 888, 666, 777))
tbl[6, ] <- list(-111, -222, -333)
tbl
#> Title
#> Sub
#> titles
#> 
#> ——————————————————————————————————————————————————————————
#> Info               A: Drug X   B: Placebo   C: Combination
#> ——————————————————————————————————————————————————————————
#> F                                                         
#>   FFF                 888         666            777      
#> M                                                         
#>   Mean               36.55       999.0          34.28     
#> U                                                         
#>   Mean               -111         -222           -333     
#> UNDIFFERENTIATED                                          
#>   Mean                NA           NA             NA      
#> ——————————————————————————————————————————————————————————
#> 
#> main footer
#> 
#> prov footer

# We can keep some information from the original table if we need
tbl[1, 2, keep_titles = TRUE]
#> Title
#> Sub
#> titles
#> 
#> ——————————————
#>     B: Placebo
#> ——————————————
#> F             
#> ——————————————
#> 
#> main footer
#> 
#> prov footer
tbl[1, 2, keep_footers = TRUE, keep_titles = FALSE]
#>     B: Placebo
#> ——————————————
#> F             
#> ——————————————
#> 
#> main footer
#> 
#> prov footer
tbl[1, 2, keep_footers = FALSE, keep_titles = TRUE]
#> Title
#> Sub
#> titles
#> 
#> ——————————————
#>     B: Placebo
#> ——————————————
#> F             
tbl[1, 2, keep_footers = TRUE]
#>     B: Placebo
#> ——————————————
#> F             
#> ——————————————
#> 
#> main footer
#> 
#> prov footer
tbl[1, 2, keep_topleft = TRUE]
#> Info   B: Placebo
#> —————————————————
#> F                

# Keeps the referential footnotes when subset contains them
fnotes_at_path(tbl, rowpath = c("SEX", "M", "AGE", "Mean")) <- "important"
tbl[4, 1]
#>            A: Drug X
#> ————————————————————
#> Mean {1}     36.55  
#> ————————————————————
#> 
#> {1} - important
#> ————————————————————
#> 
tbl[2, 1] # None present
#>       A: Drug X
#> ———————————————
#> FFF      888   

# We can reindex referential footnotes, so that the new table does not depend
#  on the original one
fnotes_at_path(tbl, rowpath = c("SEX", "U", "AGE", "Mean")) <- "important"
tbl[, 1] # both present
#> Info               A: Drug X
#> ————————————————————————————
#> F                           
#>   FFF                 888   
#> M                           
#>   Mean {1}           36.55  
#> U                           
#>   Mean {1}           -111   
#> UNDIFFERENTIATED            
#>   Mean                NA    
#> ————————————————————————————
#> 
#> {1} - important
#> ————————————————————————————
#> 
tbl[5:6, 1] # {1} because it has been indexed again
#>              A: Drug X
#> ——————————————————————
#> U                     
#>   Mean {1}     -111   
#> ——————————————————————
#> 
#> {1} - important
#> ——————————————————————
#> 
tbl[5:6, 1, reindex_refs = FALSE] # {2} -> not reindexed
#>              A: Drug X
#> ——————————————————————
#> U                     
#>   Mean {1}     -111   
#> ——————————————————————
#> 
#> {1} - important
#> ——————————————————————
#> 

# Note that order can not be changed with subsetting
tbl[c(4, 3, 1), c(3, 1)] # It preserves order and wanted selection
#>              A: Drug X   C: Combination
#> ———————————————————————————————————————
#> F                                      
#> M                                      
#>   Mean {1}     34.28         36.55     
#> ———————————————————————————————————————
#> 
#> {1} - important
#> ———————————————————————————————————————
#> 
```
