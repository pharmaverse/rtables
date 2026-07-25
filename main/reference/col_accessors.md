# Column information/structure accessors

Column information/structure accessors

## Usage

``` r
clayout(obj)

# S4 method for class 'VTableNodeInfo'
clayout(obj)

# S4 method for class 'PreDataTableLayouts'
clayout(obj)

# S4 method for class 'ANY'
clayout(obj)

clayout(object) <- value

# S4 method for class 'PreDataTableLayouts'
clayout(object) <- value

col_info(obj)

# S4 method for class 'VTableNodeInfo'
col_info(obj)

col_info(obj) <- value

# S4 method for class 'TableRow'
col_info(obj) <- value

# S4 method for class 'ElementaryTable'
col_info(obj) <- value

# S4 method for class 'TableTree'
col_info(obj) <- value

coltree(
  obj,
  df = NULL,
  rtpos = TreePos(),
  alt_counts_df = df,
  ccount_format = "(N=xx)"
)

# S4 method for class 'InstantiatedColumnInfo'
coltree(
  obj,
  df = NULL,
  rtpos = TreePos(),
  alt_counts_df = df,
  ccount_format = "(N=xx)"
)

# S4 method for class 'PreDataTableLayouts'
coltree(
  obj,
  df = NULL,
  rtpos = TreePos(),
  alt_counts_df = df,
  ccount_format = "(N=xx)"
)

# S4 method for class 'PreDataColLayout'
coltree(
  obj,
  df = NULL,
  rtpos = TreePos(),
  alt_counts_df = df,
  ccount_format = "(N=xx)"
)

# S4 method for class 'LayoutColTree'
coltree(
  obj,
  df = NULL,
  rtpos = TreePos(),
  alt_counts_df = df,
  ccount_format = "(N=xx)"
)

# S4 method for class 'VTableTree'
coltree(
  obj,
  df = NULL,
  rtpos = TreePos(),
  alt_counts_df = df,
  ccount_format = "(N=xx)"
)

# S4 method for class 'TableRow'
coltree(
  obj,
  df = NULL,
  rtpos = TreePos(),
  alt_counts_df = df,
  ccount_format = "(N=xx)"
)

col_exprs(obj, df = NULL)

# S4 method for class 'PreDataTableLayouts'
col_exprs(obj, df = NULL)

# S4 method for class 'PreDataColLayout'
col_exprs(obj, df = NULL)

# S4 method for class 'InstantiatedColumnInfo'
col_exprs(obj, df = NULL)

col_counts(obj, path = NULL)

# S4 method for class 'InstantiatedColumnInfo'
col_counts(obj, path = NULL)

# S4 method for class 'VTableNodeInfo'
col_counts(obj, path = NULL)

col_counts(obj, path = NULL) <- value

# S4 method for class 'InstantiatedColumnInfo'
col_counts(obj, path = NULL) <- value

# S4 method for class 'VTableNodeInfo'
col_counts(obj, path = NULL) <- value

col_total(obj)

# S4 method for class 'InstantiatedColumnInfo'
col_total(obj)

# S4 method for class 'VTableNodeInfo'
col_total(obj)

col_total(obj) <- value

# S4 method for class 'InstantiatedColumnInfo'
col_total(obj) <- value

# S4 method for class 'VTableNodeInfo'
col_total(obj) <- value
```

## Arguments

- obj:

  (`ANY`)\
  the object for the accessor to access or modify.

- object:

  (`ANY`)\
  the object to modify in place.

- value:

  (`ANY`)\
  the new value.

- df:

  (`data.frame` or `NULL`)\
  data to use if the column information is being generated from a
  pre-data layout object.

- rtpos:

  (`TreePos`)\
  root position.

- alt_counts_df:

  (`data.frame` or `tibble`)\
  alternative full dataset the rtables framework will use *only* when
  calculating column counts.

- ccount_format:

  (`FormatSpec`)\
  The format to be used by default for column counts throughout this
  column tree (i.e. if not overridden by a more specific format
  specification).

- path:

  (`character` or `NULL`)\
  `col_counts` accessor and setter only. Path (in column structure).

## Value

A `LayoutColTree` object.

Returns various information about columns, depending on the accessor
used.

## See also

[`facet_colcount()`](https://pharmaverse.github.io/rtables/reference/facet_colcount.md)
