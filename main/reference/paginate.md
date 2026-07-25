# Pagination of a `TableTree`

Paginate an `rtables` table in the vertical and/or horizontal direction,
as required for the specified page size.

## Usage

``` r
pag_tt_indices(
  tt,
  lpp = 15,
  min_siblings = 2,
  nosplitin = character(),
  colwidths = NULL,
  max_width = NULL,
  fontspec = NULL,
  col_gap = 3,
  verbose = FALSE
)

paginate_table(
  tt,
  page_type = "letter",
  font_family = "Courier",
  font_size = 8,
  lineheight = 1,
  landscape = FALSE,
  pg_width = NULL,
  pg_height = NULL,
  margins = c(top = 0.5, bottom = 0.5, left = 0.75, right = 0.75),
  lpp = NA_integer_,
  cpp = NA_integer_,
  min_siblings = 2,
  nosplitin = character(),
  colwidths = NULL,
  tf_wrap = FALSE,
  max_width = NULL,
  fontspec = font_spec(font_family, font_size, lineheight),
  col_gap = 3,
  verbose = FALSE
)
```

## Arguments

- tt:

  (`TableTree` or related class)\
  a `TableTree` object representing a populated table.

- lpp:

  (`numeric(1)`)\
  maximum lines per page including (re)printed header and context rows.

- min_siblings:

  (`numeric(1)`)\
  minimum sibling rows which must appear on either side of pagination
  row for a mid-subtable split to be valid. Defaults to 2.

- nosplitin:

  (`character`)\
  names of sub-tables where page-breaks are not allowed, regardless of
  other considerations. Defaults to none.

- colwidths:

  (`numeric`)\
  a vector of column widths for use in vertical pagination.

- max_width:

  (`integer(1)`, `string` or `NULL`)\
  width that title and footer (including footnotes) materials should be
  word-wrapped to. If `NULL`, it is set to the current print width of
  the session (`getOption("width")`). If set to `"auto"`, the width of
  the table (plus any table inset) is used. Parameter is ignored if
  `tf_wrap = FALSE`.

- fontspec:

  (`font_spec`)\
  a font_spec object specifying the font information to use for
  calculating string widths and heights, as returned by
  [`font_spec()`](https://rdrr.io/pkg/formatters/man/font_spec.html).

- col_gap:

  (`numeric(1)`)\
  space (in characters) between columns.

- verbose:

  (`flag`)\
  whether additional information should be displayed to the user.
  Defaults to `FALSE`.

- page_type:

  (`string`)\
  name of a page type. See
  [`page_types`](https://rdrr.io/pkg/formatters/man/page_types.html).
  Ignored when `pg_width` and `pg_height` are set directly.

- font_family:

  (`string`)\
  name of a font family. An error will be thrown if the family named is
  not monospaced. Defaults to `"Courier"`.

- font_size:

  (`numeric(1)`)\
  font size. Defaults to `12`.

- lineheight:

  (`numeric(1)`)\
  line height. Defaults to `1`.

- landscape:

  (`flag`)\
  whether the dimensions of `page_type` should be inverted for landscape
  orientation. Defaults to `FALSE`, ignored when `pg_width` and
  `pg_height` are set directly.

- pg_width:

  (`numeric(1)`)\
  page width in inches.

- pg_height:

  (`numeric(1)`)\
  page height in inches.

- margins:

  (`numeric(4)`)\
  named numeric vector containing `"bottom"`, `"left"`, `"top"`, and
  `"right"` margins in inches. Defaults to `.5` inches for both vertical
  margins and `.75` for both horizontal margins.

- cpp:

  (`numeric(1)` or `NULL`)\
  width (in characters) of the pages for horizontal pagination. `NA`
  (the default) indicates `cpp` should be inferred from the page size;
  `NULL` indicates no horizontal pagination should be done regardless of
  page size.

- tf_wrap:

  (`flag`)\
  whether the text for title, subtitles, and footnotes should be
  wrapped.

## Value

- `pag_tt_indices` returns a list of paginated-groups of row-indices of
  `tt`.

- `paginate_table` returns the subtables defined by subsetting by the
  indices defined by `pag_tt_indices`.

## Details

`rtables` pagination is context aware, meaning that label rows and
row-group summaries (content rows) are repeated after (vertical)
pagination, as appropriate. This allows the reader to immediately
understand where they are in the table after turning to a new page, but
does also mean that a rendered, paginated table will take up more lines
of text than rendering the table without pagination would.

Pagination also takes into account word-wrapping of title, footer,
column-label, and formatted cell value content.

Vertical pagination information (pagination `data.frame`) is created
using (`make_row_df`).

Horizontal pagination is performed by creating a pagination data frame
for the columns, and then applying the same algorithm used for vertical
pagination to it.

If physical page size and font information are specified, these are used
to derive lines-per-page (`lpp`) and characters-per-page (`cpp`) values.

The full multi-direction pagination algorithm then is as follows:

1.  Adjust `lpp` and `cpp` to account for rendered elements that are not
    rows (columns):

- titles/footers/column labels, and horizontal dividers in the vertical
  pagination case

- row-labels, table_inset, and top-left materials in the horizontal case

1.  Perform 'forced pagination' representing page-by row splits,
    generating 1 or more tables.

2.  Perform vertical pagination separately on each table generated in
    (1).

3.  Perform horizontal pagination **on the entire table** and apply the
    results to each table page generated in (1)-(2).

4.  Return a list of subtables representing full bi-directional
    pagination.

Pagination in both directions is done using the *Core Pagination
Algorithm* implemented in the `formatters` package:

## Pagination Algorithm

Pagination is performed independently in the vertical and horizontal
directions based solely on a *pagination data frame*, which includes the
following information for each row/column:

- Number of lines/characters rendering the row will take **after
  word-wrapping** (`self_extent`)

- The indices (`reprint_inds`) and number of lines (`par_extent`) of the
  rows which act as **context** for the row

- The row's number of siblings and position within its siblings

Given `lpp` (`cpp`) is already adjusted for rendered elements which are
not rows/columns and a data frame of pagination information, pagination
is performed via the following algorithm with `start = 1`.

Core Pagination Algorithm:

1.  Initial guess for pagination position is `start + lpp`
    (`start + cpp`)

2.  While the guess is not a valid pagination position, and
    `guess > start`, decrement guess and repeat.

    - An error is thrown if all possible pagination positions between
      `start` and `start + lpp` (`start + cpp`) would be `< start` after
      decrementing

3.  Retain pagination index

4.  If pagination point was less than `NROW(tt)` (`ncol(tt)`), set
    `start` to `pos + 1`, and repeat steps (1) - (4).

Validating Pagination Position:

Given an (already adjusted) `lpp` or `cpp` value, a pagination is
invalid if:

- The rows/columns on the page would take more than (adjusted) `lpp`
  lines/`cpp` characters to render **including**:

  - word-wrapping

  - (vertical only) context repetition

- (vertical only) footnote messages and/or section divider lines take up
  too many lines after rendering rows

- (vertical only) row is a label or content (row-group summary) row

- (vertical only) row at the pagination point has siblings, and it has
  less than `min_siblings` preceding or following siblings

- pagination would occur within a sub-table listed in `nosplitin`

## Examples

``` r
s_summary <- function(x) {
  if (is.numeric(x)) {
    in_rows(
      "n" = rcell(sum(!is.na(x)), format = "xx"),
      "Mean (sd)" = rcell(c(mean(x, na.rm = TRUE), sd(x, na.rm = TRUE)),
        format = "xx.xx (xx.xx)"
      ),
      "IQR" = rcell(IQR(x, na.rm = TRUE), format = "xx.xx"),
      "min - max" = rcell(range(x, na.rm = TRUE), format = "xx.xx - xx.xx")
    )
  } else if (is.factor(x)) {
    vs <- as.list(table(x))
    do.call(in_rows, lapply(vs, rcell, format = "xx"))
  } else {
    (
      stop("type not supported")
    )
  }
}

lyt <- basic_table() |>
  split_cols_by(var = "ARM") |>
  analyze(c("AGE", "SEX", "BEP01FL", "BMRKR1", "BMRKR2", "COUNTRY"), afun = s_summary)

tbl <- build_table(lyt, ex_adsl)
tbl
#>                        A: Drug X      B: Placebo     C: Combination
#> ———————————————————————————————————————————————————————————————————
#> AGE                                                                
#>   n                       134             134             132      
#>   Mean (sd)          33.77 (6.55)    35.43 (7.90)     35.43 (7.72) 
#>   IQR                    11.00           10.00           10.00     
#>   min - max          21.00 - 50.00   21.00 - 62.00   20.00 - 69.00 
#> SEX                                                                
#>   F                       79              77               66      
#>   M                       51              55               60      
#>   U                        3               2               4       
#>   UNDIFFERENTIATED         1               0               2       
#> BEP01FL                                                            
#>   Y                       68              63               66      
#>   N                       66              71               66      
#> BMRKR1                                                             
#>   n                       134             134             132      
#>   Mean (sd)           5.97 (3.55)     5.70 (3.31)     5.62 (3.49)  
#>   IQR                    4.16            4.06             3.88     
#>   min - max          0.41 - 17.67    0.65 - 14.24     0.17 - 21.39 
#> BMRKR2                                                             
#>   LOW                     50              45               40      
#>   MEDIUM                  37              56               42      
#>   HIGH                    47              33               50      
#> COUNTRY                                                            
#>   CHN                     74              81               64      
#>   USA                     10              13               17      
#>   BRA                     13               7               10      
#>   PAK                     12               9               10      
#>   NGA                      8               7               11      
#>   RUS                      5               8               6       
#>   JPN                      5               4               9       
#>   GBR                      4               3               2       
#>   CAN                      3               2               3       
#>   CHE                      0               0               0       

nrow(tbl)
#> [1] 33

row_paths_summary(tbl)
#> rowname               node_class    path                                                           
#> ———————————————————————————————————————————————————————————————————————————————————————————————————
#> AGE                   LabelRow      ma_AGE_SEX_BEP01FL_BMRKR1_BMRKR2_COUNTRY, AGE                  
#>   n                   DataRow       ma_AGE_SEX_BEP01FL_BMRKR1_BMRKR2_COUNTRY, AGE, n               
#>   Mean (sd)           DataRow       ma_AGE_SEX_BEP01FL_BMRKR1_BMRKR2_COUNTRY, AGE, Mean (sd)       
#>   IQR                 DataRow       ma_AGE_SEX_BEP01FL_BMRKR1_BMRKR2_COUNTRY, AGE, IQR             
#>   min - max           DataRow       ma_AGE_SEX_BEP01FL_BMRKR1_BMRKR2_COUNTRY, AGE, min - max       
#> SEX                   LabelRow      ma_AGE_SEX_BEP01FL_BMRKR1_BMRKR2_COUNTRY, SEX                  
#>   F                   DataRow       ma_AGE_SEX_BEP01FL_BMRKR1_BMRKR2_COUNTRY, SEX, F               
#>   M                   DataRow       ma_AGE_SEX_BEP01FL_BMRKR1_BMRKR2_COUNTRY, SEX, M               
#>   U                   DataRow       ma_AGE_SEX_BEP01FL_BMRKR1_BMRKR2_COUNTRY, SEX, U               
#>   UNDIFFERENTIATED    DataRow       ma_AGE_SEX_BEP01FL_BMRKR1_BMRKR2_COUNTRY, SEX, UNDIFFERENTIATED
#> BEP01FL               LabelRow      ma_AGE_SEX_BEP01FL_BMRKR1_BMRKR2_COUNTRY, BEP01FL              
#>   Y                   DataRow       ma_AGE_SEX_BEP01FL_BMRKR1_BMRKR2_COUNTRY, BEP01FL, Y           
#>   N                   DataRow       ma_AGE_SEX_BEP01FL_BMRKR1_BMRKR2_COUNTRY, BEP01FL, N           
#> BMRKR1                LabelRow      ma_AGE_SEX_BEP01FL_BMRKR1_BMRKR2_COUNTRY, BMRKR1               
#>   n                   DataRow       ma_AGE_SEX_BEP01FL_BMRKR1_BMRKR2_COUNTRY, BMRKR1, n            
#>   Mean (sd)           DataRow       ma_AGE_SEX_BEP01FL_BMRKR1_BMRKR2_COUNTRY, BMRKR1, Mean (sd)    
#>   IQR                 DataRow       ma_AGE_SEX_BEP01FL_BMRKR1_BMRKR2_COUNTRY, BMRKR1, IQR          
#>   min - max           DataRow       ma_AGE_SEX_BEP01FL_BMRKR1_BMRKR2_COUNTRY, BMRKR1, min - max    
#> BMRKR2                LabelRow      ma_AGE_SEX_BEP01FL_BMRKR1_BMRKR2_COUNTRY, BMRKR2               
#>   LOW                 DataRow       ma_AGE_SEX_BEP01FL_BMRKR1_BMRKR2_COUNTRY, BMRKR2, LOW          
#>   MEDIUM              DataRow       ma_AGE_SEX_BEP01FL_BMRKR1_BMRKR2_COUNTRY, BMRKR2, MEDIUM       
#>   HIGH                DataRow       ma_AGE_SEX_BEP01FL_BMRKR1_BMRKR2_COUNTRY, BMRKR2, HIGH         
#> COUNTRY               LabelRow      ma_AGE_SEX_BEP01FL_BMRKR1_BMRKR2_COUNTRY, COUNTRY              
#>   CHN                 DataRow       ma_AGE_SEX_BEP01FL_BMRKR1_BMRKR2_COUNTRY, COUNTRY, CHN         
#>   USA                 DataRow       ma_AGE_SEX_BEP01FL_BMRKR1_BMRKR2_COUNTRY, COUNTRY, USA         
#>   BRA                 DataRow       ma_AGE_SEX_BEP01FL_BMRKR1_BMRKR2_COUNTRY, COUNTRY, BRA         
#>   PAK                 DataRow       ma_AGE_SEX_BEP01FL_BMRKR1_BMRKR2_COUNTRY, COUNTRY, PAK         
#>   NGA                 DataRow       ma_AGE_SEX_BEP01FL_BMRKR1_BMRKR2_COUNTRY, COUNTRY, NGA         
#>   RUS                 DataRow       ma_AGE_SEX_BEP01FL_BMRKR1_BMRKR2_COUNTRY, COUNTRY, RUS         
#>   JPN                 DataRow       ma_AGE_SEX_BEP01FL_BMRKR1_BMRKR2_COUNTRY, COUNTRY, JPN         
#>   GBR                 DataRow       ma_AGE_SEX_BEP01FL_BMRKR1_BMRKR2_COUNTRY, COUNTRY, GBR         
#>   CAN                 DataRow       ma_AGE_SEX_BEP01FL_BMRKR1_BMRKR2_COUNTRY, COUNTRY, CAN         
#>   CHE                 DataRow       ma_AGE_SEX_BEP01FL_BMRKR1_BMRKR2_COUNTRY, COUNTRY, CHE         

tbls <- paginate_table(tbl, lpp = 15)
mf <- matrix_form(tbl, indent_rownames = TRUE)
w_tbls <- propose_column_widths(mf) # so that we have the same column widths


tmp <- lapply(tbls, function(tbli) {
  cat(toString(tbli, widths = w_tbls))
  cat("\n\n")
  cat("~~~~ PAGE BREAK ~~~~")
  cat("\n\n")
})
#>                        A: Drug X      B: Placebo     C: Combination
#> ———————————————————————————————————————————————————————————————————
#> AGE                                                                
#>   n                       134             134             132      
#>   Mean (sd)          33.77 (6.55)    35.43 (7.90)     35.43 (7.72) 
#>   IQR                    11.00           10.00           10.00     
#>   min - max          21.00 - 50.00   21.00 - 62.00   20.00 - 69.00 
#> SEX                                                                
#>   F                       79              77               66      
#>   M                       51              55               60      
#>   U                        3               2               4       
#>   UNDIFFERENTIATED         1               0               2       
#> BEP01FL                                                            
#>   Y                       68              63               66      
#>   N                       66              71               66      
#> 
#> 
#> ~~~~ PAGE BREAK ~~~~
#> 
#>                        A: Drug X      B: Placebo     C: Combination
#> ———————————————————————————————————————————————————————————————————
#> BMRKR1                                                             
#>   n                       134             134             132      
#>   Mean (sd)           5.97 (3.55)     5.70 (3.31)     5.62 (3.49)  
#>   IQR                    4.16            4.06             3.88     
#>   min - max          0.41 - 17.67    0.65 - 14.24     0.17 - 21.39 
#> BMRKR2                                                             
#>   LOW                     50              45               40      
#>   MEDIUM                  37              56               42      
#>   HIGH                    47              33               50      
#> COUNTRY                                                            
#>   CHN                     74              81               64      
#>   USA                     10              13               17      
#>   BRA                     13               7               10      
#> 
#> 
#> ~~~~ PAGE BREAK ~~~~
#> 
#>                        A: Drug X      B: Placebo     C: Combination
#> ———————————————————————————————————————————————————————————————————
#> COUNTRY                                                            
#>   PAK                     12               9               10      
#>   NGA                      8               7               11      
#>   RUS                      5               8               6       
#>   JPN                      5               4               9       
#>   GBR                      4               3               2       
#>   CAN                      3               2               3       
#>   CHE                      0               0               0       
#> 
#> 
#> ~~~~ PAGE BREAK ~~~~
#> 
```
