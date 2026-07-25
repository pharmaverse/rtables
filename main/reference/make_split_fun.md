# Create a custom splitting function

Create a custom splitting function

## Usage

``` r
make_split_fun(pre = list(), core_split = NULL, post = list())
```

## Arguments

- pre:

  (`list`)\
  zero or more functions which operate on the incoming data and return a
  new data frame that should split via `core_split`. They will be called
  on the data in the order they appear in the list.

- core_split:

  (`function` or `NULL`)\
  if non-`NULL`, a function which accepts the same arguments that
  `do_base_split` does, and returns the same type of named list. Custom
  functions which override this behavior cannot be used in column
  splits.

- post:

  (`list`)\
  zero or more functions which should be called on the list output by
  splitting.

## Value

A custom function that can be used as a split function.

## Details

Custom split functions can be thought of as (up to) 3 different types of
manipulations of the splitting process:

1.  Pre-processing of the incoming data to be split.

2.  (Row-splitting only) Customization of the core mapping of incoming
    data to facets.

3.  Post-processing operations on the set of facets (groups) generated
    by the split.

This function provides an interface to create custom split functions by
implementing and specifying sets of operations in each of those classes
of customization independently.

Pre-processing functions (1), must accept: `df`, `spl`, `vals`, and
`labels`, and can optionally accept `.spl_context`. They then manipulate
`df` (the incoming data for the split) and return a modified data frame.
This modified data frame *must* contain all columns present in the
incoming data frame, but can add columns if necessary (though we note
that these new columns cannot be used in the layout as split or analysis
variables, because they will not be present when validity checking is
done).

The preprocessing component is useful for things such as manipulating
factor levels, e.g., to trim unobserved ones or to reorder levels based
on observed counts, etc.

Core splitting functions override the fundamental splitting procedure,
and are only necessary in rare cases. These must accept `spl`, `df`,
`vals`, `labels`, and can optionally accept `.spl_context`. They should
return a split result object constructed via
[`make_split_result()`](https://pharmaverse.github.io/rtables/reference/make_split_result.md).

In particular, if the custom split function will be used in column
space, subsetting expressions (e.g., as returned by
[`quote()`](https://rdrr.io/r/base/substitute.html) or `bquote` must be
provided, while they are optional (and largely ignored, currently) in
row space.

Post-processing functions (3) must accept the result of the core split
as their first argument (which can be anything), in addition to `spl`,
and `fulldf`, and can optionally accept `.spl_context`. They must each
return a modified version of the same structure specified above for core
splitting.

In both the pre- and post-processing cases, multiple functions can be
specified. When this happens, they are applied sequentially, in the
order they appear in the list passed to the relevant argument (`pre` and
`post`, respectively).

## See also

[custom_split_funs](https://pharmaverse.github.io/rtables/reference/custom_split_funs.md)
for a more detailed discussion on what custom split functions do.

Other make_custom_split:
[`add_combo_facet()`](https://pharmaverse.github.io/rtables/reference/add_combo_facet.md),
[`drop_facet_levels()`](https://pharmaverse.github.io/rtables/reference/drop_facet_levels.md),
[`make_split_result()`](https://pharmaverse.github.io/rtables/reference/make_split_result.md),
[`restrict_facets()`](https://pharmaverse.github.io/rtables/reference/restrict_facets.md),
[`trim_levels_in_facets()`](https://pharmaverse.github.io/rtables/reference/trim_levels_in_facets.md)

## Examples

``` r
mysplitfun <- make_split_fun(
  pre = list(drop_facet_levels),
  post = list(add_overall_facet("ALL", "All Arms"))
)

basic_table(show_colcounts = TRUE) |>
  split_cols_by("ARM", split_fun = mysplitfun) |>
  analyze("AGE") |>
  build_table(subset(DM, ARM %in% c("B: Placebo", "C: Combination")))
#>        B: Placebo   C: Combination   All Arms
#>         (N=106)        (N=129)       (N=235) 
#> —————————————————————————————————————————————
#> Mean     33.02          34.57         33.87  

## post (and pre) arguments can take multiple functions, here
## we add an overall facet and the reorder the facets
reorder_facets <- function(splret, spl, fulldf, ...) {
  ord <- order(names(splret$values))
  make_split_result(
    splret$values[ord],
    splret$datasplit[ord],
    splret$labels[ord]
  )
}

mysplitfun2 <- make_split_fun(
  pre = list(drop_facet_levels),
  post = list(
    add_overall_facet("ALL", "All Arms"),
    reorder_facets
  )
)
basic_table(show_colcounts = TRUE) |>
  split_cols_by("ARM", split_fun = mysplitfun2) |>
  analyze("AGE") |>
  build_table(subset(DM, ARM %in% c("B: Placebo", "C: Combination")))
#>        All Arms   B: Placebo   C: Combination
#>        (N=235)     (N=106)        (N=129)    
#> —————————————————————————————————————————————
#> Mean    33.87       33.02          34.57     

very_stupid_core <- function(spl, df, vals, labels, .spl_context) {
  make_split_result(c("stupid", "silly"),
    datasplit = list(df[1:10, ], df[11:30, ]),
    labels = c("first 10", "second 20")
  )
}

dumb_30_facet <- add_combo_facet("dumb",
  label = "thirty patients",
  levels = c("stupid", "silly")
)
nonsense_splfun <- make_split_fun(
  core_split = very_stupid_core,
  post = list(dumb_30_facet)
)

## recall core split overriding is not supported in column space
## currently, but we can see it in action in row space

lyt_silly <- basic_table() |>
  split_rows_by("ARM", split_fun = nonsense_splfun) |>
  summarize_row_groups() |>
  analyze("AGE")
silly_table <- build_table(lyt_silly, DM)
silly_table
#>                    all obs 
#> ———————————————————————————
#> first 10          10 (2.8%)
#>   Mean              31.10  
#> second 20         20 (5.6%)
#>   Mean              34.25  
#> thirty patients   30 (8.4%)
#>   Mean              33.20  
```
