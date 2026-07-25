# Convert an `rtable` object to a `shiny.tag` HTML object

The returned HTML object can be immediately used in `shiny` and
`rmarkdown`.

## Usage

``` r
as_html(
  x,
  width = NULL,
  class_table = "table table-condensed table-hover",
  class_tr = NULL,
  class_th = NULL,
  link_label = NULL,
  bold = c("header"),
  header_sep_line = TRUE,
  no_spaces_between_cells = FALSE,
  expand_newlines = FALSE,
  round_type = if (is(x, "VTableTree")) obj_round_type(x) else valid_round_type
)
```

## Arguments

- x:

  (`VTableTree`)\
  a `TableTree` object.

- width:

  (`character`)\
  a string to indicate the desired width of the table. Common input
  formats include a percentage of the viewer window width (e.g.
  `"100%"`) or a distance value (e.g. `"300px"`). Defaults to `NULL`.

- class_table:

  (`character`)\
  class for `table` tag.

- class_tr:

  (`character`)\
  class for `tr` tag.

- class_th:

  (`character`)\
  class for `th` tag.

- link_label:

  (`character`)\
  link anchor label (not including `tab:` prefix) for the table.

- bold:

  (`character`)\
  elements in table output that should be bold. Options are
  `"main_title"`, `"subtitles"`, `"header"`, `"row_names"`,
  `"label_rows"`, and `"content_rows"` (which includes any non-label
  rows). Defaults to `"header"`.

- header_sep_line:

  (`flag`)\
  whether a black line should be printed to under the table header.
  Defaults to `TRUE`.

- no_spaces_between_cells:

  (`flag`)\
  whether spaces between table cells should be collapsed. Defaults to
  `FALSE`.

- expand_newlines:

  (`flag`)\
  Defaults to `FALSE`, relying on `html` output to solve newline
  characters (`\n`). Doing this keeps the structure of the cells but may
  depend on the output device.

- round_type:

  (`"iec"`, `"iec_mod"` or `"sas"`)\
  the type of rounding to perform. See
  [`round_fmt()`](https://rdrr.io/pkg/formatters/man/round_fmt.html) for
  details.

## Value

A `shiny.tag` object representing `x` in HTML.

## Examples

``` r
tbl <- rtable(
  header = LETTERS[1:3],
  format = "xx",
  rrow("r1", 1, 2, 3),
  rrow("r2", 4, 3, 2, indent = 1),
  rrow("r3", indent = 2)
)

as_html(tbl)
#> <div class="rtables-all-parts-block rtables-container">
#>   <div class="rtables-titles-block rtables-container">
#>     <div class="rtables-main-titles-block rtables-container">
#>       <p class="rtables-main-title"></p>
#>     </div>
#>     <div class="rtables-subtitles-block rtables-container"></div>
#>   </div>
#>   <table class="table table-condensed table-hover">
#>     <tr style="white-space: pre;">
#>       <th style="text-align: left; border-bottom: 1px solid black; border-bottom: 1px solid black;"></th>
#>       <th style="text-align: center; border-bottom: 1px solid black;">A</th>
#>       <th style="text-align: center; border-bottom: 1px solid black;">B</th>
#>       <th style="text-align: center; border-bottom: 1px solid black;">C</th>
#>     </tr>
#>     <tr style="white-space: pre;">
#>       <td style="text-align: left;">r1</td>
#>       <td style="text-align: center;">1</td>
#>       <td style="text-align: center;">2</td>
#>       <td style="text-align: center;">3</td>
#>     </tr>
#>     <tr style="white-space: pre;">
#>       <td style="text-align: left;">r2</td>
#>       <td style="text-align: center;">4</td>
#>       <td style="text-align: center;">3</td>
#>       <td style="text-align: center;">2</td>
#>     </tr>
#>     <tr style="white-space: pre;">
#>       <td style="text-align: left;">r3</td>
#>       <td style="text-align: center;"></td>
#>       <td style="text-align: center;"></td>
#>       <td style="text-align: center;"></td>
#>     </tr>
#>     <caption style="caption-side: top;"></caption>
#>   </table>
#>   <div class="rtables-footers-block rtables-container"></div>
#> </div>

as_html(tbl, class_table = "table", class_tr = "row")
#> <div class="rtables-all-parts-block rtables-container">
#>   <div class="rtables-titles-block rtables-container">
#>     <div class="rtables-main-titles-block rtables-container">
#>       <p class="rtables-main-title"></p>
#>     </div>
#>     <div class="rtables-subtitles-block rtables-container"></div>
#>   </div>
#>   <table class="table">
#>     <tr class="row" style="white-space: pre;">
#>       <th style="text-align: left; border-bottom: 1px solid black; border-bottom: 1px solid black;"></th>
#>       <th style="text-align: center; border-bottom: 1px solid black;">A</th>
#>       <th style="text-align: center; border-bottom: 1px solid black;">B</th>
#>       <th style="text-align: center; border-bottom: 1px solid black;">C</th>
#>     </tr>
#>     <tr class="row" style="white-space: pre;">
#>       <td class="row" style="text-align: left;">r1</td>
#>       <td class="row" style="text-align: center;">1</td>
#>       <td class="row" style="text-align: center;">2</td>
#>       <td class="row" style="text-align: center;">3</td>
#>     </tr>
#>     <tr class="row" style="white-space: pre;">
#>       <td class="row" style="text-align: left;">r2</td>
#>       <td class="row" style="text-align: center;">4</td>
#>       <td class="row" style="text-align: center;">3</td>
#>       <td class="row" style="text-align: center;">2</td>
#>     </tr>
#>     <tr class="row" style="white-space: pre;">
#>       <td class="row" style="text-align: left;">r3</td>
#>       <td class="row" style="text-align: center;"></td>
#>       <td class="row" style="text-align: center;"></td>
#>       <td class="row" style="text-align: center;"></td>
#>     </tr>
#>     <caption style="caption-side: top;"></caption>
#>   </table>
#>   <div class="rtables-footers-block rtables-container"></div>
#> </div>

as_html(tbl, bold = c("header", "row_names"))
#> <div class="rtables-all-parts-block rtables-container">
#>   <div class="rtables-titles-block rtables-container">
#>     <div class="rtables-main-titles-block rtables-container">
#>       <p class="rtables-main-title"></p>
#>     </div>
#>     <div class="rtables-subtitles-block rtables-container"></div>
#>   </div>
#>   <table class="table table-condensed table-hover">
#>     <tr style="white-space: pre;">
#>       <th style="text-align: left; border-bottom: 1px solid black; border-bottom: 1px solid black; font-weight: bold;"></th>
#>       <th style="text-align: center; border-bottom: 1px solid black;">A</th>
#>       <th style="text-align: center; border-bottom: 1px solid black;">B</th>
#>       <th style="text-align: center; border-bottom: 1px solid black;">C</th>
#>     </tr>
#>     <tr style="white-space: pre;">
#>       <td style="text-align: left; font-weight: bold;">r1</td>
#>       <td style="text-align: center;">1</td>
#>       <td style="text-align: center;">2</td>
#>       <td style="text-align: center;">3</td>
#>     </tr>
#>     <tr style="white-space: pre;">
#>       <td style="text-align: left; font-weight: bold;">r2</td>
#>       <td style="text-align: center;">4</td>
#>       <td style="text-align: center;">3</td>
#>       <td style="text-align: center;">2</td>
#>     </tr>
#>     <tr style="white-space: pre;">
#>       <td style="text-align: left; font-weight: bold;">r3</td>
#>       <td style="text-align: center;"></td>
#>       <td style="text-align: center;"></td>
#>       <td style="text-align: center;"></td>
#>     </tr>
#>     <caption style="caption-side: top;"></caption>
#>   </table>
#>   <div class="rtables-footers-block rtables-container"></div>
#> </div>

if (FALSE) { # \dontrun{
Viewer(tbl)
} # }
```
