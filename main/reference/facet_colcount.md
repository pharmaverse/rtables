# Get or set column count for a facet in column space

Get or set column count for a facet in column space

## Usage

``` r
facet_colcount(obj, path)

# S4 method for class 'LayoutColTree'
facet_colcount(obj, path = NULL)

# S4 method for class 'LayoutColLeaf'
facet_colcount(obj, path = NULL)

# S4 method for class 'VTableTree'
facet_colcount(obj, path)

# S4 method for class 'InstantiatedColumnInfo'
facet_colcount(obj, path)

facet_colcount(obj, path) <- value

# S4 method for class 'LayoutColTree'
facet_colcount(obj, path) <- value

# S4 method for class 'LayoutColLeaf'
facet_colcount(obj, path) <- value

# S4 method for class 'VTableTree'
facet_colcount(obj, path) <- value

# S4 method for class 'InstantiatedColumnInfo'
facet_colcount(obj, path) <- value
```

## Arguments

- obj:

  (`ANY`)\
  the object for the accessor to access or modify.

- path:

  character. This path must end on a split value, e.g., the level of a
  categorical variable that was split on in column space, but it need
  not be the path to an individual column.

- value:

  (`ANY`)\
  the new value.

## Value

for `facet_colcount` the current count associated with that facet in
column space, for `facet_colcount<-`, `obj` modified with the new column
count for the specified facet.

## Note

Updating a lower-level (more specific) column count manually **will
not** update the counts for its parent facets. This cannot be made
automatic because the rtables framework does not require sibling facets
to be mutually exclusive (e.g., total "arm", faceting into cumulative
quantiles, etc) and thus the count of a parent facet will not always be
simply the sum of the counts for all of its children.

## See also

[`col_counts()`](https://pharmaverse.github.io/rtables/reference/col_accessors.md)

## Examples

``` r
lyt <- basic_table() |>
  split_cols_by("ARM", show_colcounts = TRUE) |>
  split_cols_by("SEX",
    split_fun = keep_split_levels(c("F", "M")),
    show_colcounts = TRUE
  ) |>
  split_cols_by("STRATA1", show_colcounts = TRUE) |>
  analyze("AGE")

tbl <- build_table(lyt, ex_adsl)

facet_colcount(tbl, c("ARM", "A: Drug X"))
#> [1] 134
facet_colcount(tbl, c("ARM", "A: Drug X", "SEX", "F"))
#> [1] 79
facet_colcount(tbl, c("ARM", "A: Drug X", "SEX", "F", "STRATA1", "A"))
#> [1] 21

## modify specific count after table creation
facet_colcount(tbl, c("ARM", "A: Drug X", "SEX", "F", "STRATA1", "A")) <- 25

## show black space for certain counts by assign NA

facet_colcount(tbl, c("ARM", "A: Drug X", "SEX", "F", "STRATA1", "C")) <- NA
```
