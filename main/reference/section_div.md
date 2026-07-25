# Section dividers accessor and setter

`section_div` can be used to set or get the section divider for a table
object produced by
[`build_table()`](https://pharmaverse.github.io/rtables/reference/build_table.md).
When assigned in post-processing (`section_div<-`) the table can have a
section divider after every row, each assigned independently. If
assigning during layout creation, only
[`split_rows_by()`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)
(and its related row-wise splits) and
[`analyze()`](https://pharmaverse.github.io/rtables/reference/analyze.md)
have a `section_div` parameter that will produce separators between
split sections and data subgroups, respectively. These two approaches
generally should not be mixed (see Details).

## Usage

``` r
section_div(obj)

# S4 method for class 'VTableTree'
section_div(obj)

# S4 method for class 'list'
section_div(obj)

# S4 method for class 'TableRow'
section_div(obj)

section_div(obj, only_sep_sections = FALSE) <- value

# S4 method for class 'VTableTree'
section_div(obj, only_sep_sections = FALSE) <- value

# S4 method for class 'TableRow'
section_div(obj, only_sep_sections = FALSE) <- value

header_section_div(obj)

# S4 method for class 'PreDataTableLayouts'
header_section_div(obj)

# S4 method for class 'VTableTree'
header_section_div(obj)

header_section_div(obj) <- value

# S4 method for class 'PreDataTableLayouts'
header_section_div(obj) <- value

# S4 method for class 'VTableTree'
header_section_div(obj) <- value

top_level_section_div(obj)

# S4 method for class 'PreDataTableLayouts'
top_level_section_div(obj)

top_level_section_div(obj) <- value

# S4 method for class 'PreDataTableLayouts'
top_level_section_div(obj) <- value

section_div_info(obj)

section_div_at_path(obj, path, labelrow = FALSE)

section_div_at_path(
  obj,
  path,
  .prev_path = character(),
  labelrow = FALSE,
  tt_type = c("any", "row", "table", "elemtable")
) <- value
```

## Arguments

- obj:

  (`VTableTree`)\
  table object. This can be of any class that inherits from `VTableTree`
  or `TableRow`/`LabelRow`.

- only_sep_sections:

  (`flag`)\
  defaults to `FALSE` for `section_div<-`. Allows you to set the section
  divider only for sections that are splits or analyses if the number of
  values is less than the number of rows in the table. If `TRUE`, the
  section divider will be set for all rows of the table.

- value:

  (`character`)\
  vector of strings to use as section dividers (a single string for
  `section_div_at_path<-`). Each string's character(s) are repeated to
  the full width of the printed table. Non-`NA` strings will result in a
  trailing separator at the associated location (see Details); values of
  `NA_character_` result in no visible divider when the table is
  printed/exported. For `section_div<-`, `value`'s length should the
  number of rows in `obj`, when `only_sep_sections` is `FALSE` and
  should be less than or equal to the maximum number of nested
  split/analyze steps anywhere in the layout corresponding to the table
  when `only_sep_sections` is `TRUE`. See the Details section below for
  more information.

- path:

  (`character`)\
  The path of the element(s) to set section_div(s) on. Can include `'*'`
  wildcards for `section_div_at_path<-` only.

- labelrow:

  (`logical(1)`)\
  For `section_div_at_path`, when `path` leads to a subtable, indicates
  whether the section div be set/retrieved for the subtable (`FALSE`,
  the default) or the subtable's label row (`TRUE`). Ignored when `path`
  resolves to an individual row.

- .prev_path:

  (`character`)\
  Internal detail, do not manually set.

- tt_type:

  (`character(1)`)\
  One of "any", "row", "table", "elemtable"; when testing existence or
  resolving a path with "\*" wildcards, this indicates a restriction on
  *the final element the path resolves to*. E.g., for "table", possible
  paths which match the structure of the wild-card path but resolve to
  an individual row will not be considered matching. The value
  "elemtable" indicates an Elementary table, i.e., one representing a
  single variable within an `analyze` call.

## Value

The section divider string. Each line that does not have a trailing
separator will have `NA_character_` as section divider.

For `section_div_info`, a dataframe containing `label`, `name`,
"node_class", `path`, `trailing_sep` (the effective divider, whether
inherited or not), `self_section_div` (the divider set on the row
itself), and `sect_div_from_path` (the path to the table element the
value in `trailing_sep` is inherited from, or `NA_character_` for label
rows, which are not pathable).

## Details

Section dividers provide visual breaks between structural elements of a
table in row space. They are repeated to fill a full line of the table
and printed after the element (row, subtable) they are associated with.
Use a value of `" "` to display a blank line section divider in the
table. A section divider of `NA_character_` indicates no visible divider
(i.e., no line at all) should be printed for that row or section when
rendering the table.

When multiple section dividers would appear consecutively with no rows
between them (e.g., a subtable and its last row both having a section
divider set), only the *least specific* section divider (the subtable
divider in this example) will be displayed when rendering the table.
This is to avoid multiple non-informative lines of consecutive dividers
when there is nested splitting in the row structure of a table.

`section_div_at_path<-` accepts a single path (which can include the
`'*'` wildcard), and a single string in `value` and sets the section
divider on the element(s) of `obj` that the path resolve to.

For `section_div<-` `value` should be a character vector. When you want
to only affect sections or splits, please use `only_sep_sections` or
provide a shorter vector than the number of rows. Ideally, the length of
the vector should be less than the number of splits with, eventually,
the leaf-level, i.e. `DataRow` where analyze results are. Note that if
only one value is inserted, only the first split will be affected. If
`only_sep_sections = TRUE`, which is the default for `section_div()`
produced from the table construction, the section divider will be set
for all the splits and eventually analyses, but not for the header or
each row of the table. This can be set with `header_section_div` in
[`basic_table()`](https://pharmaverse.github.io/rtables/reference/basic_table.md)
or, eventually, with `hsep` in
[`build_table()`](https://pharmaverse.github.io/rtables/reference/build_table.md).
If `only_sep_sections` is `FALSE`, "section" dividers will be set for
each row in the table *including content and label rows*.

In `section_div<-`, when `only_sep_sections` is `FALSE` *all higher
order section divs are removed, even when new value for a row that they
would apply to is `NA`*.

A `section_div` -\> modify -\> `section_div<-` workflow will not work to
modify section dividers declared in a layout (i.e., with
`split_rows_by*(., section_div=)` or `analyze(.,section_div=)`) after
the table has been built. In that case a row 'inherits' its section
divider behavior from the largest subtable that has a section divider
set and for which it is the final row. Instead it clears the
higher-order section dividers and sets an individual divider on each row
(setting `NA_character_` for rows that had no divider after them when
rendering). This means that if pruning is done after the above process
and the last row in a "section" is pruned, the last remaining row *will
not inherit the section's divider* the way it would before the
modification by `section_div<-`.

Generally it is advisable to use `section_div_at_path<-` - often with
`"*"` wildcards in the path - to modify dividers declared in the layout
instead of `section_div<-`. Alternatively, pruning should be done
*before* calling `section_div<-` (when passing a a vector of length
`nrow(tt)`), when a script or function will do both operations on a
table.

Setting section_dividers for rows which do not currently inherit section
divider behavior from a containing subtable will work as expected.

`section_div_info` returns a data.frame of section divider info (a
subset of the result of `make_row_df` when called on a table tree or row
object). This information can be used to reset section dividers at the
correct path via `section_div_at_path` for tables which have section
dividers deriving from their layout ( which will be attached to
subtables, rather than rows).

## Note

Section dividers which would appear after the last row of the table (ie
those on the last row or last elementary subtable in the table) are
never printed when rendering the table.

when called on an individual row object, `section_div` and
`section_div<-` get and set the trialing divider for that row. In
generally this is to be avoided; when manually constructing row objects,
the `trailing_section_div` argument can set the trailing divider
directly during creation.

## See also

[`basic_table()`](https://pharmaverse.github.io/rtables/reference/basic_table.md)
parameter `header_section_div` and `top_level_section_div` for global
section dividers.

## Examples

``` r
# Data
df <- data.frame(
  cat = c(
    "really long thing its so ", "long"
  ),
  value = c(6, 3, 10, 1)
)
fast_afun <- function(x) list("m" = rcell(mean(x), format = "xx."), "m/2" = max(x) / 2)

tbl <- basic_table() |>
  split_rows_by("cat", section_div = "~") |>
  analyze("value", afun = fast_afun, section_div = " ") |>
  build_table(df)

# Getter
section_div(tbl)
#> [1] NA  NA  "~" NA  NA  "~"

# Setter
section_div(tbl) <- letters[seq_len(nrow(tbl))]
tbl
#>                             all obs
#> ———————————————————————————————————
#> really long thing its so           
#> aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
#>   m                            8   
#> bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
#>   m/2                          5   
#> ccccccccccccccccccccccccccccccccccc
#> long                               
#> ddddddddddddddddddddddddddddddddddd
#>   m                            2   
#> eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
#>   m/2                         1.5  

# last letter can appear if there is another table
rbind(tbl, tbl)
#> Modifying subtable (or row) names to ensure uniqueness among direct siblings
#> [cat  -> { cat, cat[2] }]
#>   To control table names use split_rows_by*(, parent_name =.) or  analyze(., table_names = .) when analyzing a single variable, or analyze(., parent_name = .) when analyzing multiple variables in a single call.FALSE
#>                             all obs
#> ———————————————————————————————————
#> really long thing its so           
#> aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
#>   m                            8   
#> bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
#>   m/2                          5   
#> ccccccccccccccccccccccccccccccccccc
#> long                               
#> ddddddddddddddddddddddddddddddddddd
#>   m                            2   
#> eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
#>   m/2                         1.5  
#> fffffffffffffffffffffffffffffffffff
#> really long thing its so           
#> aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
#>   m                            8   
#> bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
#>   m/2                          5   
#> ccccccccccccccccccccccccccccccccccc
#> long                               
#> ddddddddddddddddddddddddddddddddddd
#>   m                            2   
#> eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
#>   m/2                         1.5  

# header_section_div
header_section_div(tbl) <- "+"
tbl
#>                             all obs
#> ———————————————————————————————————
#> +++++++++++++++++++++++++++++++++++
#> really long thing its so           
#> aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
#>   m                            8   
#> bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
#>   m/2                          5   
#> ccccccccccccccccccccccccccccccccccc
#> long                               
#> ddddddddddddddddddddddddddddddddddd
#>   m                            2   
#> eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
#>   m/2                         1.5  
```
