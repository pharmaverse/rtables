# Format Precedence and NA Handling

## Formats Precedence

Users of the `rtables` package can specify the format in which the
numbers in the reporting tables are printed. Formatting functionality is
provided by the
[`formatters`](https://pharmaverse.github.io/formatters/) R package. See
[`formatters::list_valid_format_labels()`](https://rdrr.io/pkg/formatters/man/list_formats.html)
for a list of all available formats. The format can be specified by the
user in a few different places. It may happen that, for a single table
layout, the format is specified in more than one place. In such a case,
the final format that will be applied depends on format precedence rules
defined by `rtables`. In this vignette, we describe the basic rules of
`rtables` format precedence.

The examples shown in this vignette utilize the example `ADSL` dataset,
a demographic table that summarizes the variables content for different
population subsets (encoded in the columns).

``` r

library(rtables)
ADSL <- ex_adsl
```

Note that all `ex_*` data which is currently attached to the `rtables`
package is provided by the
[`formatters`](https://pharmaverse.github.io/formatters/) package and
was created using the publicly available
[`random.cdisc.data`](https://insightsengineering.github.io/random.cdisc.data/)
R package.

### Format Precedence and Inheritance Rules

The format in which numbers are printed can be specified by the user in
a few different places. In the context of precedence, it is important
which level of the split hierarchy formats are specified at. In general,
there are two such levels: the **cell** level and the so-called **parent
table** level. The concept of the cell and the parent table results from
the way in which the `rtables` package stores resulting tables. It
models the resulting tables as hierarchical, tree-like objects with the
cells (as leaves) containing multiple values. Particularly noteworthy in
this context is the fact that the actual table splitting occurs in a
row-dominant way (even if column splitting is present in the layout).
`rtables` provides user-end function
[`table_structure()`](https://pharmaverse.github.io/rtables/reference/table_structure.md)
that prints the structure of a given table object.

For a simple illustration, consider the following example:

``` r

lyt <- basic_table() |>
  split_cols_by("ARM") |>
  split_rows_by("SEX") |>
  analyze(vars = "AGE", afun = mean)

adsl_analyzed <- build_table(lyt, ADSL)
adsl_analyzed
```

    #                       A: Drug X          B: Placebo       C: Combination 
    # —————————————————————————————————————————————————————————————————————————
    # F                                                                        
    #   mean             32.7594936708861   34.1168831168831   35.1969696969697
    # M                                                                        
    #   mean             35.5686274509804   37.4363636363636   35.3833333333333
    # U                                                                        
    #   mean             31.6666666666667          31               35.25      
    # UNDIFFERENTIATED                                                         
    #   mean                    28                 NA                 45

``` r

table_structure(adsl_analyzed)
```

    # [TableTree] SEX
    #  [TableTree] F
    #   [ElementaryTable] AGE (1 x 3)
    #  [TableTree] M
    #   [ElementaryTable] AGE (1 x 3)
    #  [TableTree] U
    #   [ElementaryTable] AGE (1 x 3)
    #  [TableTree] UNDIFFERENTIATED
    #   [ElementaryTable] AGE (1 x 3)

In this table, there are 4 sub-tables under the `SEX` table. These are:
`F`, `M`, `U`, and `UNDIFFERENTIATED`. Each of these sub-tables has one
sub-table `AGE`. For example, for the first `AGE` sub-table, its parent
table is `F`.

The concept of hierarchical, tree-like representations of resulting
tables translates directly to format precedence and inheritance rules.
As a general principle, the format being finally applied for the cell is
the one that is the most specific, that is, the one which is the closest
to the cell in a given path in the tree. Hence, the
precedence-inheritance chain looks like the following:

    parent_table -> parent_table -> ... -> parent_table -> cell

In such a chain, the outermost `parent_table` is the least specific
place to specify the format, while the `cell` is the most specific one.
In cases where the format is specified by the user in more than one
place, the one which is most specific will be applied in the cell. If no
specific format has been selected by the user for the split, then the
default format will be applied. The default format is `"xx"` and it
yields the same formatting as the
[`as.character()`](https://rdrr.io/r/base/character.html) function. In
the following sections of this vignette, we will illustrate the format
precedence rules with a few examples.

### Standard Format

Below is a simple layout that does not explicitly set a format for the
output of the analysis function. In such a case, the default format is
applied.

``` r

lyt0 <- basic_table() |>
  split_cols_by("ARM") |>
  analyze(vars = "AGE", afun = mean)

build_table(lyt0, ADSL)
```

    #           A: Drug X          B: Placebo       C: Combination 
    # —————————————————————————————————————————————————————————————
    # mean   33.7686567164179   35.4328358208955   35.4318181818182

### Cell Format

The format of a cell can be explicitly specified via the
[`rcell()`](https://pharmaverse.github.io/rtables/reference/rcell.md) or
[`in_rows()`](https://pharmaverse.github.io/rtables/reference/in_rows.md)
functions. The former is essentially a collection of data objects while
the latter is a collection of
[`rcell()`](https://pharmaverse.github.io/rtables/reference/rcell.md)
objects. As previously mentioned, this is the most specific place where
the format can be specified by the user.

``` r

lyt1 <- basic_table() |>
  split_cols_by("ARM") |>
  analyze(vars = "AGE", afun = function(x) {
    rcell(mean(x), format = "xx.xx", label = "Mean")
  })

build_table(lyt1, ADSL)
```

    #        A: Drug X   B: Placebo   C: Combination
    # ——————————————————————————————————————————————
    # Mean     33.77       35.43          35.43

``` r

lyt1a <- basic_table() |>
  split_cols_by("ARM") |>
  analyze(vars = "AGE", afun = function(x) {
    in_rows(
      "Mean" = rcell(mean(x)),
      .formats = "xx.xx"
    )
  })

build_table(lyt1a, ADSL)
```

    #        A: Drug X   B: Placebo   C: Combination
    # ——————————————————————————————————————————————
    # Mean     33.77       35.43          35.43

If the format is specified in both of these places at the same time, the
one specified via
[`in_rows()`](https://pharmaverse.github.io/rtables/reference/in_rows.md)
takes highest precedence. Technically, in this case, the format defined
in [`rcell()`](https://pharmaverse.github.io/rtables/reference/rcell.md)
will simply be overwritten by the one defined in
[`in_rows()`](https://pharmaverse.github.io/rtables/reference/in_rows.md).
This is because the format specified in
[`in_rows()`](https://pharmaverse.github.io/rtables/reference/in_rows.md)
is applied to the cells not the rows (overriding the previously
specified cell-specific values), which indicates that the precedence
rules described above are still in place.

``` r

lyt2 <- basic_table() |>
  split_cols_by("ARM") |>
  analyze(vars = "AGE", afun = function(x) {
    in_rows(
      "Mean" = rcell(mean(x), format = "xx.xxx"),
      .formats = "xx.xx"
    )
  })

build_table(lyt2, ADSL)
```

    #        A: Drug X   B: Placebo   C: Combination
    # ——————————————————————————————————————————————
    # Mean     33.77       35.43          35.43

### Parent Table Format and Inheritance

In addition to the cell level, the format can be specified at the parent
table level. If no format has been set by the user for a cell, the most
specific format for that cell is the one defined at its innermost parent
table split (if any).

``` r

lyt3 <- basic_table() |>
  split_cols_by("ARM") |>
  analyze(vars = "AGE", mean, format = "xx.x")

build_table(lyt3, ADSL)
```

    #        A: Drug X   B: Placebo   C: Combination
    # ——————————————————————————————————————————————
    # mean     33.8         35.4           35.4

If the cell format is also specified for a cell, then the parent table
format is ignored for this cell since the cell format is more specific
and therefore takes precedence.

``` r

lyt4 <- basic_table() |>
  split_cols_by("ARM") |>
  analyze(
    vars = "AGE", afun = function(x) {
      rcell(mean(x), format = "xx.xx", label = "Mean")
    },
    format = "xx.x"
  )

build_table(lyt4, ADSL)
```

    #        A: Drug X   B: Placebo   C: Combination
    # ——————————————————————————————————————————————
    # Mean     33.77       35.43          35.43

``` r

lyt4a <- basic_table() |>
  split_cols_by("ARM") |>
  analyze(
    vars = "AGE", afun = function(x) {
      in_rows(
        "Mean" = rcell(mean(x)),
        "SD" = rcell(sd(x)),
        .formats = "xx.xx"
      )
    },
    format = "xx.x"
  )

build_table(lyt4a, ADSL)
```

    #        A: Drug X   B: Placebo   C: Combination
    # ——————————————————————————————————————————————
    # Mean     33.77       35.43          35.43     
    # SD       6.55         7.90           7.72

In the following, slightly more complicated, example, we can observe
partial inheritance. That is, only `SD` cells inherit the parent table’s
format while the `Mean` cells do not.

``` r

lyt5 <- basic_table() |>
  split_cols_by("ARM") |>
  analyze(
    vars = "AGE", afun = function(x) {
      in_rows(
        "Mean" = rcell(mean(x), format = "xx.xx"),
        "SD" = rcell(sd(x))
      )
    },
    format = "xx.x"
  )

build_table(lyt5, ADSL)
```

    #        A: Drug X   B: Placebo   C: Combination
    # ——————————————————————————————————————————————
    # Mean     33.77       35.43          35.43     
    # SD        6.6         7.9            7.7

## `NA` Handling

Consider the following layout and the resulting table created:

``` r

lyt6 <- basic_table() |>
  split_cols_by("ARM") |>
  split_rows_by("SEX") |>
  analyze(vars = "AGE", afun = mean, format = "xx.xx")

build_table(lyt6, ADSL)
```

    #                    A: Drug X   B: Placebo   C: Combination
    # ——————————————————————————————————————————————————————————
    # F                                                         
    #   mean               32.76       34.12          35.20     
    # M                                                         
    #   mean               35.57       37.44          35.38     
    # U                                                         
    #   mean               31.67       31.00          35.25     
    # UNDIFFERENTIATED                                          
    #   mean               28.00         NA           45.00

In the output the cell corresponding to the `UNDIFFERENTIATED` level of
`SEX` and the `B: Placebo` level of `ARM` is displayed as `NA`. This
occurs because there were no non-`NA` values under this facet that could
be used to compute the mean. `rtables` allows the user to specify a
string to display when cell values are `NA`. Similar to formats for
numbers, the user can specify a string to replace `NA` with the
parameter `format_na_str` or `.format_na_str`. This can be specified at
the cell or parent table level. `NA` string precedence and inheritance
rules are the same as those for number format precedence, described in
the previous section of this vignette. We will illustrate this with a
few examples.

### Replacing `NA` Values at the Cell Level

At the cell level, it is possible to replace `NA` values with a custom
string by means of the `format_na_str` parameter in
[`rcell()`](https://pharmaverse.github.io/rtables/reference/rcell.md) or
`.format_na_str` parameter in
[`in_rows()`](https://pharmaverse.github.io/rtables/reference/in_rows.md).

``` r

lyt7 <- basic_table() |>
  split_cols_by("ARM") |>
  split_rows_by("SEX") |>
  analyze(vars = "AGE", afun = function(x) {
    rcell(mean(x), format = "xx.xx", label = "Mean", format_na_str = "<missing>")
  })

build_table(lyt7, ADSL)
```

    #                    A: Drug X   B: Placebo   C: Combination
    # ——————————————————————————————————————————————————————————
    # F                                                         
    #   Mean               32.76       34.12          35.20     
    # M                                                         
    #   Mean               35.57       37.44          35.38     
    # U                                                         
    #   Mean               31.67       31.00          35.25     
    # UNDIFFERENTIATED                                          
    #   Mean               28.00     <missing>        45.00

``` r

lyt7a <- basic_table() |>
  split_cols_by("ARM") |>
  split_rows_by("SEX") |>
  analyze(vars = "AGE", afun = function(x) {
    in_rows(
      "Mean" = rcell(mean(x), format = "xx.xx"),
      .format_na_strs = "<MISSING>"
    )
  })

build_table(lyt7a, ADSL)
```

    #                    A: Drug X   B: Placebo   C: Combination
    # ——————————————————————————————————————————————————————————
    # F                                                         
    #   Mean               32.76       34.12          35.20     
    # M                                                         
    #   Mean               35.57       37.44          35.38     
    # U                                                         
    #   Mean               31.67       31.00          35.25     
    # UNDIFFERENTIATED                                          
    #   Mean               28.00     <MISSING>        45.00

If the `NA` string is specified in both of these places at the same
time, the one specified with
[`in_rows()`](https://pharmaverse.github.io/rtables/reference/in_rows.md)
takes precedence. Technically, in this case the `NA` replacement string
defined in
[`rcell()`](https://pharmaverse.github.io/rtables/reference/rcell.md)
will simply be overwritten by the one defined in
[`in_rows()`](https://pharmaverse.github.io/rtables/reference/in_rows.md).
This is because the `NA` string specified in
[`in_rows()`](https://pharmaverse.github.io/rtables/reference/in_rows.md)
is applied to the cells, not the rows (overriding the previously
specified cell specific values), which means that the precedence rules
described above are still in place.

``` r

lyt8 <- basic_table() |>
  split_cols_by("ARM") |>
  split_rows_by("SEX") |>
  analyze(vars = "AGE", afun = function(x) {
    in_rows(
      "Mean" = rcell(mean(x), format = "xx.xx", format_na_str = "<missing>"),
      .format_na_strs = "<MISSING>"
    )
  })

build_table(lyt8, ADSL)
```

    #                    A: Drug X   B: Placebo   C: Combination
    # ——————————————————————————————————————————————————————————
    # F                                                         
    #   Mean               32.76       34.12          35.20     
    # M                                                         
    #   Mean               35.57       37.44          35.38     
    # U                                                         
    #   Mean               31.67       31.00          35.25     
    # UNDIFFERENTIATED                                          
    #   Mean               28.00     <MISSING>        45.00

### Parent Table Replacement of `NA` Values and Inheritance Principles

In addition to the cell level, the string replacement for `NA` values
can be specified at the parent table level. If no replacement string has
been specified by the user for a cell, the most specific `NA` string for
that cell is the one defined at its innermost parent table split (if
any).

``` r

lyt9 <- basic_table() |>
  split_cols_by("ARM") |>
  split_rows_by("SEX") |>
  analyze(vars = "AGE", mean, format = "xx.xx", na_str = "not available")

build_table(lyt9, ADSL)
```

    #                    A: Drug X    B: Placebo     C: Combination
    # —————————————————————————————————————————————————————————————
    # F                                                            
    #   mean               32.76         34.12           35.20     
    # M                                                            
    #   mean               35.57         37.44           35.38     
    # U                                                            
    #   mean               31.67         31.00           35.25     
    # UNDIFFERENTIATED                                             
    #   mean               28.00     not available       45.00

If an `NA` value replacement string was also specified at the cell
level, then the one set at the parent table level is ignored for this
cell as the cell level format is more specific and therefore takes
precedence.

``` r

lyt10 <- basic_table() |>
  split_cols_by("ARM") |>
  split_rows_by("SEX") |>
  analyze(
    vars = "AGE", afun = function(x) {
      rcell(mean(x), format = "xx.xx", label = "Mean", format_na_str = "<missing>")
    },
    na_str = "not available"
  )

build_table(lyt10, ADSL)
```

    #                    A: Drug X   B: Placebo   C: Combination
    # ——————————————————————————————————————————————————————————
    # F                                                         
    #   Mean               32.76       34.12          35.20     
    # M                                                         
    #   Mean               35.57       37.44          35.38     
    # U                                                         
    #   Mean               31.67       31.00          35.25     
    # UNDIFFERENTIATED                                          
    #   Mean               28.00     <missing>        45.00

``` r

lyt10a <- basic_table() |>
  split_cols_by("ARM") |>
  split_rows_by("SEX") |>
  analyze(
    vars = "AGE", afun = function(x) {
      in_rows(
        "Mean" = rcell(mean(x)),
        "SD" = rcell(sd(x)),
        .formats = "xx.xx",
        .format_na_strs = "<missing>"
      )
    },
    na_str = "not available"
  )

build_table(lyt10a, ADSL)
```

    #                    A: Drug X   B: Placebo   C: Combination
    # ——————————————————————————————————————————————————————————
    # F                                                         
    #   Mean               32.76       34.12          35.20     
    #   SD                 6.09         7.06           7.43     
    # M                                                         
    #   Mean               35.57       37.44          35.38     
    #   SD                 7.08         8.69           8.24     
    # U                                                         
    #   Mean               31.67       31.00          35.25     
    #   SD                 3.21         5.66           3.10     
    # UNDIFFERENTIATED                                          
    #   Mean               28.00     <missing>        45.00     
    #   SD               <missing>   <missing>         1.41

In the following, slightly more complicated example, we can observe
partial inheritance of NA strings. That is, only `SD` cells inherit the
parent table’s `NA` string, while the `Mean` cells do not.

``` r

lyt11 <- basic_table() |>
  split_cols_by("ARM") |>
  split_rows_by("SEX") |>
  analyze(
    vars = "AGE", afun = function(x) {
      in_rows(
        "Mean" = rcell(mean(x), format_na_str = "<missing>"),
        "SD" = rcell(sd(x))
      )
    },
    format = "xx.xx",
    na_str = "not available"
  )

build_table(lyt11, ADSL)
```

    #                      A: Drug X      B: Placebo     C: Combination
    # —————————————————————————————————————————————————————————————————
    # F                                                                
    #   Mean                 32.76           34.12           35.20     
    #   SD                   6.09            7.06             7.43     
    # M                                                                
    #   Mean                 35.57           37.44           35.38     
    #   SD                   7.08            8.69             8.24     
    # U                                                                
    #   Mean                 31.67           31.00           35.25     
    #   SD                   3.21            5.66             3.10     
    # UNDIFFERENTIATED                                                 
    #   Mean                 28.00         <missing>         45.00     
    #   SD               not available   not available        1.41
