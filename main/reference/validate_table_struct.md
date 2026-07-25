# Validate and assert valid table structure

**\[experimental\]**

A `TableTree` (`rtables`-built table) is considered degenerate if:

1.  It contains no subtables or data rows (content rows do not count).

2.  It contains a subtable which is degenerate by the criterion above.

`validate_table_struct` assesses whether `tt` has a valid
(non-degenerate) structure.

`assert_valid_table` asserts a table must have a valid structure, and
throws an informative error (the default) or warning (if `warn_only` is
`TRUE`) if the table is degenerate (has invalid structure or contains
one or more invalid substructures.

## Usage

``` r
validate_table_struct(tt)

assert_valid_table(tt, warn_only = FALSE)
```

## Arguments

- tt:

  (`TableTree`)\
  a `TableTree` object.

- warn_only:

  (`flag`)\
  whether a warning should be thrown instead of an error. Defaults to
  `FALSE`.

## Value

- `validate_table_struct` returns a logical value indicating valid
  structure.

- `assert_valid_table` is called for its side-effect of throwing an
  error or warning for degenerate tables.

## Note

This function is experimental and the exact text of the warning/error is
subject to change in future releases.

## See also

Other table structure validation functions:
[`find_degen_struct()`](https://pharmaverse.github.io/rtables/reference/find_degen_struct.md),
[`sanitize_table_struct()`](https://pharmaverse.github.io/rtables/reference/sanitize_table_struct.md)

## Examples

``` r
validate_table_struct(rtable("hahaha"))
#> [1] FALSE
if (FALSE) { # \dontrun{
assert_valid_table(rtable("oops"))
} # }
```
