# Row attribute accessors

Row attribute accessors

## Usage

``` r
obj_avar(obj)

# S4 method for class 'TableRow'
obj_avar(obj)

# S4 method for class 'ElementaryTable'
obj_avar(obj)

row_cells(obj)

# S4 method for class 'TableRow'
row_cells(obj)

# S4 method for class 'RowsVerticalSection'
row_cells(obj)

row_cells(obj) <- value

# S4 method for class 'TableRow'
row_cells(obj) <- value

row_values(obj)

# S4 method for class 'TableRow'
row_values(obj)

row_values(obj) <- value

# S4 method for class 'TableRow'
row_values(obj) <- value

# S4 method for class 'LabelRow'
row_values(obj) <- value
```

## Arguments

- obj:

  (`ANY`)\
  the object for the accessor to access or modify.

- value:

  (`ANY`)\
  the new value.

## Value

Various return values depending on the accessor called.
