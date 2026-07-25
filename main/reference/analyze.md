# Generate rows analyzing variables across columns

Adding *analyzed variables* to our table layout defines the primary
tabulation to be performed. We do this by adding calls to `analyze`
and/or
[`analyze_colvars()`](https://pharmaverse.github.io/rtables/reference/analyze_colvars.md)
into our layout pipeline. As with adding further splitting, the
tabulation will occur at the current/next level of nesting by default.

## Usage

``` r
analyze(
  lyt,
  vars,
  afun = simple_analysis,
  var_labels = vars,
  table_names = vars,
  parent_name = NULL,
  format = NULL,
  formats_var = NULL,
  na_str = NA_character_,
  na_strs_var = NULL,
  nested = TRUE,
  inclNAs = FALSE,
  extra_args = list(),
  show_labels = c("default", "visible", "hidden"),
  indent_mod = 0L,
  section_div = NA_character_
)
```

## Arguments

- lyt:

  (`PreDataTableLayouts`)\
  layout object pre-data used for tabulation.

- vars:

  (`character`)\
  vector of variable names.

- afun:

  (`function`)\
  analysis function. Must accept `x` or `df` as its first parameter. Can
  optionally take other parameters which will be populated by the
  tabulation framework. See Details in `analyze()`.

- var_labels:

  (`character`)\
  vector of labels for one or more variables.

- table_names:

  (`character`)\
  names for the tables representing each atomic analysis. Defaults to
  `var`.

- parent_name:

  (`character(1)`)\
  Name to assign to the table corresponding to the *split* or *group of
  sibling analyses*, for `split_rows_by*` and `analyze*` when analyzing
  more than one variable, respectively. Ignored when analyzing a single
  variable.

- format:

  (`string`, `function`, or `list`)\
  format associated with this split. Formats can be declared via strings
  (`"xx.x"`) or function. In cases such as `analyze` calls, they can be
  character vectors or lists of functions. See
  [`formatters::list_valid_format_labels()`](https://rdrr.io/pkg/formatters/man/list_formats.html)
  for a list of all available format strings.

- formats_var:

  (`string` or `NULL`)\
  `NULL` (the default) or the name of the list column containing named
  lists of default formats to use. These will be applied with the same
  precedence as the `format` argument; i.e., they will not override
  formats (other than `"default"`) set within the afun. Cannot be used
  simultaneously with `format`.

- na_str:

  (`string`)\
  string that should be displayed when the value of `x` is missing.
  Defaults to `"NA"`.

- na_strs_var:

  (`string` or `NULL`)\
  `NULL` (the default) or the name of the list column containing named
  lists of default NA strings to use. These will be applied with the
  same precedence as the `format` argument; i.e., they will not override
  formats (other than `"default"`) set within the afun. Cannot be used
  simultaneously with `format`. Cannot be used if `formats_var` is
  `NULL`.

- nested:

  (`logical`)\
  whether this layout instruction should be applied within the existing
  layout structure *if possible* (`TRUE`, the default) or as a new
  top-level element (`FALSE`). Ignored if it would nest a split
  underneath analyses, which is not allowed.

- inclNAs:

  (`logical`)\
  whether NA observations in the `var` variable(s) should be included
  when performing the analysis. Defaults to `FALSE`.

- extra_args:

  (`list`)\
  extra arguments to be passed to the tabulation function. Element
  position in the list corresponds to the children of this split. Named
  elements in the child-specific lists are ignored if they do not match
  a formal argument of the tabulation function.

- show_labels:

  (`string`)\
  whether the variable labels corresponding to the variable(s) in `vars`
  should be visible in the resulting table.

- indent_mod:

  (`numeric`)\
  modifier for the default indent position for the structure created by
  this function (subtable, content table, or row) *and all of that
  structure's children*. Defaults to 0, which corresponds to the
  unmodified default behavior.

- section_div:

  (`string`)\
  string which should be repeated as a section divider after the set of
  rows defined by (each sub-analysis/variable) of this analyze
  instruction, or `NA_character_` (the default) for no section divider.
  This section divider will be overridden by a split-level section
  divider when both apply to the same position in the rendered output.

## Value

A `PreDataTableLayouts` object suitable for passing to further layouting
functions, and to
[`build_table()`](https://pharmaverse.github.io/rtables/reference/build_table.md).

## Details

When `length(vars) > 1` and when two calls to `analyze` are done in
sequence (the second with the default `nested = TRUE`), the analyses
will be combined into a multi-variable analysis that will be reflected
in the row structure of the resulting table. In these cases, the default
is to show the label describing the variable analyzed for each of the
resulting subtables, while that is hidden by default in one-variable
cases.

## Note

None of the arguments described in
[additional_fun_params](https://pharmaverse.github.io/rtables/reference/additional_fun_params.md)
can be overridden via `extra_args` or when calling
[`make_afun()`](https://pharmaverse.github.io/rtables/reference/make_afun.md).
`.N_col` and `.N_total` can be overridden via the `col_counts` argument
to
[`build_table()`](https://pharmaverse.github.io/rtables/reference/build_table.md).
Alternative values for the others must be calculated within `afun` based
on a combination of extra arguments and the unmodified values provided
by the tabulation framework.

## Specifying Default Formatting Behavior

*Default* formatting behavior for rows generated by `afun` can be
specified by one of `format` or `formats_var`. In both cases, these
default formatting instructions *will not* supersede formatting
specified from within `afun` at either the `rcell` or `in_rows` call
levels; They will only apply to rows/cells whose formatting as returned
by `afun` is either `NULL` or `"default"`. When non-`NULL`, `format` is
used to specify formats for all generated rows, and can be a character
vector, a function, or a list of functions. It will be repped out to the
number of rows once this is calculated during the tabulation process,
but will be overridden by formats specified within `rcell` calls in
`afun`.

`format` can accept a format label string (see
[`formatters::list_valid_format_labels()`](https://rdrr.io/pkg/formatters/man/list_formats.html)),
a formatting function, an unnamed list, or a named list.

When `format` is an unnamed list - or a named list where not all values
of `vars` appear in the names - its elements will be repped out to the
number of rows generated by `afun` (separately) within each row facet
`afun` is applied within. **This includes recycling behavior, even in
the case where the number of rows is not cleanly divisible by the number
of specified formats**. This behavior is retained largely for legacy
reasons and switching to the new named-list behavior is advised where
applicable.

When `format` is a named list whose names contain all values in `vars`,
the elements of `format` are taken to be specific to the analysis of the
corresponding variable; this allows us to specify a multi-variable
analysis where e.g., the different variables are analyzed by the same
`afun` but have different levels of measurement precision (and thus
different formatting needs). In this case the var-specific formatting
can be a single format (label string or function) or can be a named list
whose names will be matched up to those of the rows generated by
applying `afun` in each row facet. Matching of formats to rows is
performed the same as in the `formats_var` case and is described below.

When `formats_var` is non-`NULL`, it specifies the name of a list column
containing formatting instructions for one or more rows `afun` will
generate when applied within a row facet. This can be used when the
analysis results for a single variable (e.g., `value` or `AVAL` in
long-form data) should be formatted differently within different row
facets (e.g., when faceting on `statistic` or `PARAMCD`). The value of
`df[[formats_var]]` is assumed without verification to be constant
within each row facet `afun` is applied within, and the first (list)
value of the column within the row facet data will be used.

In the `formats_var` case as well as the case of `format` being a named
list containing the values of `vars`, after rows are created during
tabulation, the default formats are matched and applied to them as
follows:

1.  When the generated row's name (as given by `obj_name`) matches a
    name in the list, the corresponding default format is applied,

2.  for those without exact matches, the default format whose name
    provides *the best partial match* to each row name is applied,

3.  For those without default format names that partially match the row
    name, no default format is applied.

Note carefully that in (2), it is the names of the list of formats that
are partially matching the row names not the other way around.

## The Analysis Function

The analysis function (`afun`) should take as its first parameter either
`x` or `df`. Whichever of these the function accepts will change the
behavior when tabulation is performed as follows:

- If `afun`'s first parameter is `x`, it will receive the corresponding
  subset *vector* of data from the relevant column (from `var` here) of
  the raw data being used to build the table.

- If `afun`'s first parameter is `df`, it will receive the corresponding
  subset *data frame* (i.e. all columns) of the raw data being
  tabulated.

In addition to differentiation on the first argument, the analysis
function can optionally accept a number of other parameters which, *if
and only if* present in the formals, will be passed to the function by
the tabulation machinery. These are listed and described in
[additional_fun_params](https://pharmaverse.github.io/rtables/reference/additional_fun_params.md).

## Author

Gabriel Becker

## Examples

``` r
lyt <- basic_table() |>
  split_cols_by("ARM") |>
  analyze("AGE", afun = list_wrap_x(summary), format = "xx.xx")
lyt
#> A Pre-data Table Layout
#> 
#> Column-Split Structure:
#> ARM (lvls) 
#> 
#> Row-Split Structure:
#> AGE (** analysis **) 
#> 

tbl <- build_table(lyt, DM)
tbl
#>           A: Drug X   B: Placebo   C: Combination
#> —————————————————————————————————————————————————
#> Min.        20.00       21.00          22.00     
#> 1st Qu.     29.00       29.00          30.00     
#> Median      33.00       32.00          33.00     
#> Mean        34.91       33.02          34.57     
#> 3rd Qu.     39.00       37.00          38.00     
#> Max.        60.00       55.00          53.00     

lyt2 <- basic_table() |>
  split_cols_by("Species") |>
  analyze(head(names(iris), -1), afun = function(x) {
    list(
      "mean / sd" = rcell(c(mean(x), sd(x)), format = "xx.xx (xx.xx)"),
      "range" = rcell(diff(range(x)), format = "xx.xx")
    )
  })
lyt2
#> A Pre-data Table Layout
#> 
#> Column-Split Structure:
#> Species (lvls) 
#> 
#> Row-Split Structure:
#> Sepal.Length:Sepal.Width:Petal.Length:Petal.Width (** multivar analysis **) 
#> 

tbl2 <- build_table(lyt2, iris)
tbl2
#>                  setosa      versicolor     virginica 
#> ——————————————————————————————————————————————————————
#> Sepal.Length                                          
#>   mean / sd    5.01 (0.35)   5.94 (0.52)   6.59 (0.64)
#>   range           1.50          2.10          3.00    
#> Sepal.Width                                           
#>   mean / sd    3.43 (0.38)   2.77 (0.31)   2.97 (0.32)
#>   range           2.10          1.40          1.60    
#> Petal.Length                                          
#>   mean / sd    1.46 (0.17)   4.26 (0.47)   5.55 (0.55)
#>   range           0.90          2.10          2.40    
#> Petal.Width                                           
#>   mean / sd    0.25 (0.11)   1.33 (0.20)   2.03 (0.27)
#>   range           0.50          0.80          1.10    
```
