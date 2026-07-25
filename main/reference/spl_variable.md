# Variable associated with a split

This function is intended for use when writing custom splitting logic.
In cases where the split is associated with a single variable, the name
of that variable will be returned. At time of writing this includes
splits generated via the
[`split_rows_by()`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md),
[`split_cols_by()`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md),
[`split_rows_by_cuts()`](https://pharmaverse.github.io/rtables/reference/varcuts.md),
[`split_cols_by_cuts()`](https://pharmaverse.github.io/rtables/reference/varcuts.md),
[`split_rows_by_cutfun()`](https://pharmaverse.github.io/rtables/reference/varcuts.md),
and
[`split_cols_by_cutfun()`](https://pharmaverse.github.io/rtables/reference/varcuts.md)
layout directives.

## Usage

``` r
spl_variable(spl)

# S4 method for class 'VarLevelSplit'
spl_variable(spl)

# S4 method for class 'VarDynCutSplit'
spl_variable(spl)

# S4 method for class 'VarStaticCutSplit'
spl_variable(spl)

# S4 method for class 'Split'
spl_variable(spl)
```

## Arguments

- spl:

  (`VarLevelSplit`)\
  the split object.

## Value

For splits with a single variable associated with them, returns the
split. Otherwise, an error is raised.

## See also

[`make_split_fun`](https://pharmaverse.github.io/rtables/reference/make_split_fun.md)
