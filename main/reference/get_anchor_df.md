# Retrieve Info About Possible Nesting Anchors

This function scans an existing layout's row structure and lists valid
`at_sibling` anchors for intermediate nesting.

## Usage

``` r
get_full_lyt_df(
  splvec,
  next_node = 1L,
  next_anchor_step = 1L,
  parent,
  depth,
  node_type
)

# S4 method for class 'PreDataTableLayouts'
get_full_lyt_df(
  splvec,
  next_node = 1L,
  next_anchor_step = 1,
  parent,
  depth,
  node_type
)

get_layout_dfs(lyt)

# S4 method for class 'PreDataRowLayout'
get_full_lyt_df(
  splvec,
  next_node = 1,
  next_anchor_step = 1L,
  parent = 0L,
  depth = 1L,
  node_type = "active"
)

# S4 method for class 'PreDataColLayout'
get_full_lyt_df(
  splvec,
  next_node = 1,
  next_anchor_step = 1L,
  parent = 0L,
  depth = 1L,
  node_type = "active"
)

# S4 method for class 'SplitVector'
get_full_lyt_df(
  splvec,
  next_node = 1L,
  next_anchor_step = 1L,
  parent,
  depth,
  node_type
)

# S4 method for class 'SplitVectorTree'
get_full_lyt_df(
  splvec,
  next_node = 1L,
  next_anchor_step = 1L,
  parent,
  depth,
  node_type
)

# S4 method for class 'Split'
get_full_lyt_df(
  splvec,
  next_node = 1L,
  next_anchor_step = 1L,
  parent,
  depth,
  node_type
)

# S4 method for class 'VTableNodeInfo'
get_full_lyt_df(
  splvec,
  next_node = 1L,
  next_anchor_step = 1L,
  parent,
  depth,
  node_type
)

get_anchor_dfs(lyt)

get_row_anchor_df(lyt)

get_row_anchor_list(lyt)
```

## Arguments

- splvec:

  (`PreDataTableLayouts` or internal classes)\
  The layout or partial layout to list anchors for.

- next_node:

  (`integer(1)`)\
  For internal use

- next_anchor_step:

  (`integer(1)`)\
  For internal use.

- parent:

  (`integer(1)`)\
  For internal use.

- depth:

  (`integer(1)`)\
  For internal use.

- node_type:

  (`character(1)`)\
  For internal use.

- lyt:

  (`PreDataTableLayouts` or `PreDataRowLayout`)\
  A layout or row to identify anchors for.

## Value

for `get_layout_dfs` a list with `rows` and `cols` elements containing
layout data.frames (see Details) for each structural dimension;
`get_anchor_dfs` returns the same, but with anchor data.frames rather
than full layout ones. `get_anchor_row_df` is a convenience function
that returns only the `rows` anchor data.frame. `get_row_anchor_list`
returns a list, each element of which is a set of the names of one or
more layout instructions that will be placed as direct siblings to
each-other; i.e., anchored to the first element of the vector when the
length of the element is greater than one.

## Details

A layout data.frame is a data.frame describing a single dimension of
pre-data layout structure, containing the following columns (most of
which are used for internal implementations and will not be useful to
the end-user):

- `name`: name of the element

- `nodeid`: sequential numeric id of the node, for use in constructing
  graphs (0 is the root node)

- `parentid`: node id of the layout instructions direct parent

- `depth`: length of path from root to the current node through the
  implicit graph defined by the (`nodeid`, `parentid`) pairings

- `type`: a description of the 'type' of the node, used internally

- `is_toplevel`: whether the node represents a top-level split/analysis.

- `anchor_step`: position *along the path of eligible anchor points*,
  (`NA` for nodes not along that path).

The core difference between a layout data.frame and an anchor data.frame
is that the anchor df has been subset to remove rows for nodes not
currently eligible to be anchor points (ie allowed targets for a
subsequent instruction's `at_sibling` argument).

## Note

Instructions which are anchored in such a way that they ultimately
become top-level instructions in the layout (i.e., by being anchored as
a sibling to a top-level instruction) are handled somewhat differently
for implementation reasons and may present differently to those anchored
to non-top-level instructions.

## Examples

``` r

lyt <- basic_table() |>
  split_cols_by("ARM") |>
  split_rows_by("STRATA1") |>
  split_rows_by("RACE") |>
  split_rows_by("SEX") |>
  analyze("AGE") |>
  split_rows_by("BMRKR1", at_sibling = "RACE") |>
  analyze("AGE")

get_layout_dfs(lyt)
#> $cols
#>   name nodeid parentid depth   type is_toplevel anchor_step force_pag
#> 1  ARM      1        0     1 active        TRUE           1     FALSE
#>   spl_abbrev
#> 1       lvls
#> 
#> $rows
#>      name nodeid parentid depth     type is_toplevel anchor_step force_pag
#> 1 STRATA1      1        0     1   active        TRUE           1     FALSE
#> 2    RACE      2        1     2   anchor       FALSE           2     FALSE
#> 3     SEX      3        2     3 inactive       FALSE          NA     FALSE
#> 4     AGE      4        3     4 inactive       FALSE          NA     FALSE
#> 5  BMRKR1      5        1     2   active       FALSE           2     FALSE
#> 6     AGE      6        5     3   active       FALSE           3     FALSE
#>   spl_abbrev
#> 1       lvls
#> 2       lvls
#> 3       lvls
#> 4  ** var **
#> 5       lvls
#> 6  ** var **
#> 
get_anchor_dfs(lyt)
#> $cols
#>   name nodeid parentid depth   type is_toplevel anchor_step force_pag
#> 1  ARM      1        0     1 active        TRUE           1     FALSE
#>   spl_abbrev
#> 1       lvls
#> 
#> $rows
#>      name nodeid parentid depth   type is_toplevel anchor_step force_pag
#> 1 STRATA1      1        0     1 active        TRUE           1     FALSE
#> 2    RACE      2        1     2 anchor       FALSE           2     FALSE
#> 5  BMRKR1      5        1     2 active       FALSE           2     FALSE
#> 6     AGE      6        5     3 active       FALSE           3     FALSE
#>   spl_abbrev
#> 1       lvls
#> 2       lvls
#> 5       lvls
#> 6  ** var **
#> 
get_row_anchor_df(lyt)
#>      name nodeid parentid depth   type is_toplevel anchor_step force_pag
#> 1 STRATA1      1        0     1 active        TRUE           1     FALSE
#> 2    RACE      2        1     2 anchor       FALSE           2     FALSE
#> 5  BMRKR1      5        1     2 active       FALSE           2     FALSE
#> 6     AGE      6        5     3 active       FALSE           3     FALSE
#>   spl_abbrev
#> 1       lvls
#> 2       lvls
#> 5       lvls
#> 6  ** var **
```
