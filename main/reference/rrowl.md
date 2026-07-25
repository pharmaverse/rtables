# Create an `rtable` row from a vector or list of values

Create an `rtable` row from a vector or list of values

## Usage

``` r
rrowl(
  row.name,
  ...,
  format = NULL,
  indent = 0,
  inset = 0L,
  round_type = valid_round_type
)
```

## Arguments

- row.name:

  (`string` or `NULL`)\
  row name. If `NULL`, an empty string is used as `row.name` of the
  [`rrow()`](https://pharmaverse.github.io/rtables/reference/rrow.md).

- ...:

  values in vector/list form.

- format:

  (`string`, `function`, or `list`)\
  the format label (string) or formatter function to apply to the cell
  values passed via `...`. See
  [`formatters::list_valid_format_labels()`](https://rdrr.io/pkg/formatters/man/list_formats.html)
  for currently supported format labels.

- indent:

  **\[deprecated\]**

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

A row object of the context-appropriate type (label or data).

## See also

Other compatibility:
[`rheader()`](https://pharmaverse.github.io/rtables/reference/rheader.md),
[`rrow()`](https://pharmaverse.github.io/rtables/reference/rrow.md),
[`rtable()`](https://pharmaverse.github.io/rtables/reference/rtable.md)

## Examples

``` r
rrowl("a", c(1, 2, 3), format = "xx")
#> [DataRow indent_mod 0]: a   1   2   3
rrowl("a", c(1, 2, 3), c(4, 5, 6), format = "xx")
#> [DataRow indent_mod 0]: a   1   2   3   4   5   6


rrowl("N", table(iris$Species))
#> [DataRow indent_mod 0]: N   50   50   50
rrowl("N", table(iris$Species), format = "xx")
#> [DataRow indent_mod 0]: N   50   50   50

x <- tapply(iris$Sepal.Length, iris$Species, mean, simplify = FALSE)

rrow(row.name = "row 1", x)
#> [DataRow indent_mod 0]: row 1   5.006, 5.936, 6.588
rrow("ABC", 2, 3)
#> [DataRow indent_mod 0]: ABC   2   3

rrowl(row.name = "row 1", c(1, 2), c(3, 4))
#> [DataRow indent_mod 0]: row 1   1   2   3   4
rrow(row.name = "row 2", c(1, 2), c(3, 4))
#> [DataRow indent_mod 0]: row 2   1, 2   3, 4
```
