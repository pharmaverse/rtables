# Create a header

Create a header

## Usage

``` r
rheader(..., format = "xx", .lst = NULL)
```

## Arguments

- ...:

  row specifications, either as character vectors or the output from
  [`rrow()`](https://pharmaverse.github.io/rtables/reference/rrow.md),
  [`DataRow()`](https://pharmaverse.github.io/rtables/reference/rowclasses.md),
  [`LabelRow()`](https://pharmaverse.github.io/rtables/reference/rowclasses.md),
  etc.

- format:

  (`string`, `function`, or `list`)\
  the format label (string) or formatter function to apply to the cell
  values passed via `...`. See
  [`formatters::list_valid_format_labels()`](https://rdrr.io/pkg/formatters/man/list_formats.html)
  for currently supported format labels.

- .lst:

  (`list`)\
  an already-collected list of arguments to be used instead of the
  elements of `...`. Arguments passed via `...` will be ignored if this
  is specified.

## Value

A `InstantiatedColumnInfo` object.

## See also

Other compatibility:
[`rrow()`](https://pharmaverse.github.io/rtables/reference/rrow.md),
[`rrowl()`](https://pharmaverse.github.io/rtables/reference/rrowl.md),
[`rtable()`](https://pharmaverse.github.io/rtables/reference/rtable.md)

## Examples

``` r
h1 <- rheader(c("A", "B", "C"))
h1
#> An InstantiatedColumnInfo object
#> Columns:
#> A (mnl)
#> B (mnl)
#> C (mnl)
#> 

h2 <- rheader(
  rrow(NULL, rcell("group 1", colspan = 2), rcell("group 2", colspan = 2)),
  rrow(NULL, "A", "B", "A", "B")
)
h2
#> An InstantiatedColumnInfo object
#> Columns:
#> group 1 (mnl) -> A (mnl)
#> group 1 (mnl) -> B (mnl)
#> group 2 (mnl) -> A (mnl)
#> group 2 (mnl) -> B (mnl)
#> 
```
