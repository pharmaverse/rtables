# Layout with 1 column and zero rows

Every layout must start with a basic table.

## Usage

``` r
basic_table(
  title = "",
  subtitles = character(),
  main_footer = character(),
  prov_footer = character(),
  show_colcounts = NA,
  colcount_format = "(N=xx)",
  header_section_div = NA_character_,
  top_level_section_div = NA_character_,
  inset = 0L,
  round_type = valid_round_type
)
```

## Arguments

- title:

  (`string`)\
  single string to use as main title
  ([`formatters::main_title()`](https://rdrr.io/pkg/formatters/man/title_footer.html)).
  Ignored for subtables.

- subtitles:

  (`character`)\
  a vector of strings to use as subtitles
  ([`formatters::subtitles()`](https://rdrr.io/pkg/formatters/man/title_footer.html)),
  where every element is printed on a separate line. Ignored for
  subtables.

- main_footer:

  (`character`)\
  a vector of strings to use as main global (non-referential) footer
  materials
  ([`formatters::main_footer()`](https://rdrr.io/pkg/formatters/man/title_footer.html)),
  where every element is printed on a separate line.

- prov_footer:

  (`character`)\
  a vector of strings to use as provenance-related global footer
  materials
  ([`formatters::prov_footer()`](https://rdrr.io/pkg/formatters/man/title_footer.html)),
  where every element is printed on a separate line.

- show_colcounts:

  (`logical(1)`)\
  Indicates whether the lowest level of applied to data. `NA`, the
  default, indicates that the `show_colcounts` argument(s) passed to the
  relevant calls to `split_cols_by*` functions. Non-missing values will
  override the behavior specified in column splitting layout
  instructions which create the lowest level, or leaf, columns.

- colcount_format:

  (`string`)\
  format for use when displaying the column counts. Must be 1d, or 2d
  where one component is a percent. This will also apply to any
  displayed higher level column counts where an explicit format was not
  specified. Defaults to `"(N=xx)"`. See Details below.

- header_section_div:

  (`string`)\
  string which will be used to divide the header from the table. See
  [`header_section_div()`](https://pharmaverse.github.io/rtables/reference/section_div.md)
  for the associated getter and setter. Please consider changing last
  element of
  [`section_div()`](https://pharmaverse.github.io/rtables/reference/section_div.md)
  when concatenating tables that require a divider between them.

- top_level_section_div:

  (`character(1)`)\
  if assigned a single character, the first (top level) split or
  division of the table will be highlighted by a line made of that
  character. See
  [section_div](https://pharmaverse.github.io/rtables/reference/section_div.md)
  for more information.

- inset:

  (`numeric(1)`)\
  number of spaces to inset the table header, table body, referential
  footnotes, and main_footer, as compared to alignment of title,
  subtitle, and provenance footer. Defaults to 0 (no inset).

- round_type:

  (`"iec"` (default), `"iec_mod"` or `"sas"`)\
  the type of rounding to perform. See
  [`formatters::format_value()`](https://rdrr.io/pkg/formatters/man/format_value.html)
  for details.

## Value

A `PreDataTableLayouts` object suitable for passing to further layouting
functions, and to
[`build_table()`](https://pharmaverse.github.io/rtables/reference/build_table.md).

## Details

`colcount_format` is ignored if `show_colcounts` is `FALSE` (the
default). When `show_colcounts` is `TRUE`, and `colcount_format` is
2-dimensional with a percent component, the value component for the
percent is always populated with `1` (i.e. 100%). 1d formats are used to
render the counts exactly as they normally would be, while 2d formats
which don't include a percent, and all 3d formats result in an error.
Formats in the form of functions are not supported for `colcount`
format. See
[`formatters::list_valid_format_labels()`](https://rdrr.io/pkg/formatters/man/list_formats.html)
for the list of valid format labels to select from.

## Note

- Because percent components in `colcount_format` are *always* populated
  with the value 1, we can get arguably strange results, such as that
  individual arm columns and a combined "all patients" column all list
  "100%" as their percentage, even though the individual arm columns
  represent strict subsets of the "all patients" column.

- Note that subtitles
  ([`formatters::subtitles()`](https://rdrr.io/pkg/formatters/man/title_footer.html))
  and footers
  ([`formatters::main_footer()`](https://rdrr.io/pkg/formatters/man/title_footer.html)
  and
  [`formatters::prov_footer()`](https://rdrr.io/pkg/formatters/man/title_footer.html))
  that span more than one line can be supplied as a character vector to
  maintain indentation on multiple lines.

## Examples

``` r
lyt <- basic_table() |>
  analyze("AGE", afun = mean)

tbl <- build_table(lyt, DM)
tbl
#>            all obs     
#> ———————————————————————
#> mean   34.2219101123596

lyt2 <- basic_table(
  title = "Title of table",
  subtitles = c("a number", "of subtitles"),
  main_footer = "test footer",
  prov_footer = paste(
    "test.R program, executed at",
    Sys.time()
  )
) |>
  split_cols_by("ARM") |>
  analyze("AGE", mean)

tbl2 <- build_table(lyt2, DM)
tbl2
#> Title of table
#> a number
#> of subtitles
#> 
#> —————————————————————————————————————————————————————————————
#>           A: Drug X          B: Placebo       C: Combination 
#> —————————————————————————————————————————————————————————————
#> mean   34.9090909090909   33.0188679245283   34.5658914728682
#> —————————————————————————————————————————————————————————————
#> 
#> test footer
#> 
#> test.R program, executed at 2026-07-29 16:32:54.993182

lyt3 <- basic_table(
  show_colcounts = TRUE,
  colcount_format = "xx. (xx.%)"
) |>
  split_cols_by("ARM")
```
